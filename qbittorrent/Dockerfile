ARG ALPINE_VERSION=3.17

# stage: download dependencies
FROM alpine:${ALPINE_VERSION} as builder

# qbittorrent-nox
ARG QBITTORRENT_ARCH=x86_64
ARG QBITTORRENT_VERSION=4.5.0
ARG LIBTORRENT_VERSION=2.0.8
ARG QBITTORRENT_RELEASE=https://github.com/userdocs/qbittorrent-nox-static/releases/download/release-${QBITTORRENT_VERSION}_v${LIBTORRENT_VERSION}/${QBITTORRENT_ARCH}-qbittorrent-nox
ADD ${QBITTORRENT_RELEASE} /tmp/qbittorrent-nox
RUN chmod +x /tmp/qbittorrent-nox

# stage: set up final image
FROM alpine:${ALPINE_VERSION} as setup

RUN apk add --update --no-cache \
  s6-overlay \
  bash \
  curl \
  python3 \
  py-pip \
  \
  && pip install --upgrade pip \
  && pip install --no-cache-dir crudini

COPY --from=builder /tmp/qbittorrent-nox /usr/bin/qbittorrent-nox

ENV UIDGID=0:0 \
  QBT_PORTABLE=1 \
  QBT_PROFILE=/config \
  QBT_SAVE_PATH=/downloads \
  S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# deploy our files
COPY ./data /data

# deploy s6 services
COPY ./data/config/s6/cont-init.d /etc/cont-init.d
COPY ./data/config/s6/services.d /etc/services.d

ENTRYPOINT /init
