FROM arm64v8/ubuntu:xenial

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get -q update && \
    apt-get -q -y install --no-install-recommends \
      curl ca-certificates build-essential make golang-go && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV GO_VERSION 1.7.6
RUN mkdir /usr/src/go && curl -fsSL https://golang.org/dl/go${GO_VERSION}.src.tar.gz | tar -v -C /usr/src/go -xz --strip-components=1 \
  && cd /usr/src/go/src \
  && GOOS=linux GOARCH=arm64 GOROOT_BOOTSTRAP="$(go env GOROOT)" ./make.bash

ENV PATH /go/bin:/usr/src/go/bin:$PATH
ENV GOPATH /go

VOLUME /go/src/github.com/docker/cli

WORKDIR /go/src/github.com/docker/cli
