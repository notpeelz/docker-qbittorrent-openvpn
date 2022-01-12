ARG ALPINE_VERSION=3.14

# stage: download dependencies
FROM alpine:${ALPINE_VERSION} as builder

# qb-web
ARG QBWEB_REPO=https://github.com/CzBiX/qb-web.git
ARG QBWEB_REV=nightly-20210808
RUN apk add --update --no-cache \
  git \
  nodejs \
  npm
RUN git config --global init.defaultBranch master \
  && git init /tmp/qbweb \
  && cd /tmp/qbweb \
  && git remote add origin ${QBWEB_REPO} \
  && git fetch --tags --depth=1 origin ${QBWEB_REV} \
  && git -c advice.detachedHead=false checkout ${QBWEB_REV} \
  && npm install \
  && npm run build

# vuetorrent
ARG VUETORRENT_RELEASE=https://github.com/WDaan/VueTorrent/archive/latest-release.tar.gz
ADD ${VUETORRENT_RELEASE} /tmp/vuetorrent.tar.gz
RUN mkdir /tmp/vuetorrent \
  && tar xzf /tmp/vuetorrent.tar.gz -C /tmp/vuetorrent

# qbittorrent-nox
ARG QBITTORRENT_ARCH=x86_64
ARG QBITTORRENT_VERSION=4.4.0
ARG LIBTORRENT_VERSION=2.0.5
ARG QBITTORRENT_RELEASE=https://github.com/userdocs/qbittorrent-nox-static/releases/download/release-${QBITTORRENT_VERSION}_v${LIBTORRENT_VERSION}/${QBITTORRENT_ARCH}-cmake-icu-qbittorrent-nox
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

COPY --from=builder /tmp/vuetorrent/VueTorrent-latest-release /vuetorrent
COPY --from=builder /tmp/qbweb/dist /qbweb
COPY --from=builder /tmp/qbittorrent-nox /usr/bin/qbittorrent-nox

ENV SET_UIDGID=0:0 \
  QBT_PORTABLE=1 \
  QBT_PROFILE=/config \
  QBT_SAVE_PATH=/downloads \
  S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# deploy our files
COPY ./data /data

# deploy s6 services
COPY ./data/config/s6/cont-init.d /etc/cont-init.d
COPY ./data/config/s6/services.d /etc/services.d

EXPOSE 8080

ENTRYPOINT /init
