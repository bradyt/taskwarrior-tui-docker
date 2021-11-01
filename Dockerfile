FROM rust:1.56.1-slim-bullseye

RUN apt-get update
RUN apt-get install -y taskwarrior
RUN apt-get install -y git
RUN git clone https://github.com/kdheepak/taskwarrior-tui.git
WORKDIR taskwarrior-tui
RUN cargo build --release
