FROM rust:1.56.1-bullseye

RUN apt-get update && apt-get install -y \
    cmake \
    libgnutls28-dev

RUN curl https://taskwarrior.org/download/task-2.6.1.tar.gz \
    -o task-2.6.1.tar.gz

RUN tar xzvf task-2.6.1.tar.gz
WORKDIR task-2.6.1
RUN cmake -DCMAKE_BUILD_TYPE=release .
RUN make
RUN make install

WORKDIR ..

RUN git clone https://github.com/kdheepak/taskwarrior-tui.git \
    -b v0.14.7
WORKDIR taskwarrior-tui
RUN cargo fetch

RUN task rc.confirmation:no add foo

RUN cargo build --release

CMD ./target/release/taskwarrior-tui
