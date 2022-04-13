FROM debian:buster-backports

ENV DEBIAN_FRONTEND=noninteractive

COPY 01_nodoc /etc/dpkg/dpkg.cfg.d/01_nodoc
COPY 02_nocache /etc/apt/apt.conf.d/02_nocache
COPY compress /etc/initramfs-tools/conf.d/compress
COPY entrypoint.sh /entrypoint.sh

RUN \
    apt-get update \
&&  apt-get install -y --no-install-recommends wget golang-1.13-go=1.13.6-2~bpo10+1 golang-1.13-src=1.13.6-2~bpo10+1 golang-1.13=1.13.6-2~bpo10+1 zip unzip git libgit2-27 libgit2-dev make cmake jq \
    ca-certificates openssl gcc pkg-config \
&&  export PATH=$PATH:/usr/lib/go-1.13/bin \
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
&&  apt-get purge -y make cmake gcc pkg-config \
&&  apt-get autoremove -y \
&&  rm -rf /var/lib/apt/lists/* \
    /usr/share/doc/ \
    /usr/share/man/ \
    /usr/share/locale/

WORKDIR /tmp

ENTRYPOINT ["/entrypoint.sh"]
