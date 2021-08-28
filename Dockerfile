FROM debian:stretch-backports

ENV DEBIAN_FRONTEND=noninteractive

COPY 01_nodoc /etc/dpkg/dpkg.cfg.d/01_nodoc
COPY 02nocache /etc/apt/apt.conf.d/02nocache

RUN \
    apt-get update && apt-get install -y wget golang-go=2:1.11~1~bpo9+1 golang-src=2:1.11~1~bpo9+1 zip unzip git libgit2-27 libgit2-dev make cmake jq \
&&  export GOPATH=/root/go \
&&  go get -d github.com/libgit2/git2go \
&&  cd /root/go/src/github.com/libgit2/git2go \
&&  git checkout next \
&&  git submodule update --init \
&&  make install \
&&  go get github.com/splitsh/lite \
&&  cd /root/go/src/github.com/splitsh/lite \
&&  go build -o splitsh-lite github.com/splitsh/lite \
&&  cp /root/go/src/github.com/splitsh/lite/splitsh-lite /usr/local/bin \
&&  chmod +x /usr/local/bin/splitsh-lite \
&&  apt-get autoremove -y \
&&  rm -rf /var/lib/apt/lists/* \
    /usr/share/doc/ \
    /usr/share/man/ \
    /usr/share/locale/

COPY entrypoint.sh /entrypoint.sh

WORKDIR /tmp

ENTRYPOINT ["/entrypoint.sh"]
