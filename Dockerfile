FROM debian:sid

RUN apt-get update && apt-get install -y \
    taskwarrior \
    curl

RUN curl -LOJ https://github.com/kdheepak/taskwarrior-tui/releases/download/v0.14.7/taskwarrior-tui-x86_64-unknown-linux-gnu.tar.gz
RUN tar xf taskwarrior-tui-x86_64-unknown-linux-gnu.tar.gz

RUN task rc.confirmation:no calc 1 + 1 # dummy command to create .taskrc

CMD ./taskwarrior-tui
