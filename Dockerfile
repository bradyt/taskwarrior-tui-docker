FROM rust:1.56.1-bullseye

RUN apt-get update && apt-get install -y \
    curl \
    cmake \
    libgnutls28-dev \
    vim \
    gnutls-bin

RUN curl -O https://taskwarrior.org/download/task-2.6.1.tar.gz
RUN tar xzvf task-2.6.1.tar.gz
WORKDIR task-2.6.1
RUN cmake -DCMAKE_BUILD_TYPE=release .
RUN make
RUN make install
WORKDIR ..

RUN curl -O https://taskwarrior.org/download/taskd-1.1.0.tar.gz
RUN tar xzvf taskd-1.1.0.tar.gz
WORKDIR taskd-1.1.0
RUN cmake -DCMAKE_BUILD_TYPE=release .
RUN make
RUN make install
WORKDIR ..

WORKDIR /usr/local/bin
RUN curl -LO https://github.com/kdheepak/taskwarrior-tui/releases/download/v0.14.8/taskwarrior-tui-x86_64-unknown-linux-gnu.tar.gz
RUN tar xf taskwarrior-tui-x86_64-unknown-linux-gnu.tar.gz

# RUN git clone \
#     -b v0.14.8 \
#     https://github.com/kdheepak/taskwarrior-tui.git
# WORKDIR taskwarrior-tui
# RUN cargo fetch
# RUN cargo build --release
# WORKDIR target/release

RUN task rc.confirmation:no calc 1 + 1 # dummy command to create .taskrc

ENV TASKDDATA /root/opt/var/taskd
RUN mkdir -p $TASKDDATA
RUN taskd init
RUN taskd config server localhost:53589

WORKDIR /taskd-1.1.0
RUN cp -r pki $TASKDDATA
WORKDIR $TASKDDATA/pki
RUN ./generate

RUN    cp client.cert.pem $TASKDDATA \
    && cp client.key.pem  $TASKDDATA \
    && cp server.cert.pem $TASKDDATA \
    && cp server.key.pem  $TASKDDATA \
    && cp server.crl.pem  $TASKDDATA \
    && cp ca.cert.pem     $TASKDDATA \
    \
    && taskd config client.cert $TASKDDATA/client.cert.pem \
    && taskd config client.key  $TASKDDATA/client.key.pem \
    && taskd config server.cert $TASKDDATA/server.cert.pem \
    && taskd config server.key  $TASKDDATA/server.key.pem \
    && taskd config server.crl  $TASKDDATA/server.crl.pem \
    && taskd config ca.cert     $TASKDDATA/ca.cert.pem \
    \
    && taskd config log         $TASKDDATA/taskd.log \
    && taskd config pid.file    $TASKDDATA/taskd.pid \
    && taskd config server      localhost:53589

RUN taskd config debug.tls 3

RUN taskd add org Public
RUN taskd add user Public "Testing Account"

RUN ./generate.client testing_account

RUN task rc.confirmation:no config confirmation no

RUN    cp testing_account.cert.pem ~/.task \
    && cp testing_account.key.pem  ~/.task \
    && cp ca.cert.pem              ~/.task \
    \
    && task config taskd.certificate -- ~/.task/testing_account.cert.pem \
    && task config taskd.key         -- ~/.task/testing_account.key.pem \
    && task config taskd.ca          -- ~/.task/ca.cert.pem \
    && task config taskd.server      -- localhost:53589 \
    && task config taskd.credentials -- Public/Testing Account/$(ls ../orgs/Public/users)
