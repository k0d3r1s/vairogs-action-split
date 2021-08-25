FROM debian:bookworm-20210816-slim

ENV DEBIAN_FRONTEND=noninteractive

ADD https://github.com/splitsh/lite/releases/download/v1.0.1/lite_linux_amd64.tar.gz /tmp
RUN tar -zxpf /tmp/lite_linux_amd64.tar.gz --directory /usr/local/bin/

RUN apt-get update && apt-get install -y git jq

COPY entrypoint.sh /entrypoint.sh

WORKDIR /tmp

ADD https://raw.githubusercontent.com/vairogs/vairogs/master/deploy/components.json /tmp/components.json

ENTRYPOINT ["/entrypoint.sh"]