FROM alpine:3.17

RUN apk add --update --no-cache \
  bash \
  alpine-sdk \
  openssl-dev

COPY . /build
WORKDIR /build

RUN /build/build.sh

ENTRYPOINT /build/run.sh
