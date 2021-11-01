FROM rust:1.56.1-bullseye

RUN apt-get update && apt-get install -y \
    curl \
    cmake \
    libgnutls28-dev \
    vim

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

# CMD ./taskwarrior-tui
