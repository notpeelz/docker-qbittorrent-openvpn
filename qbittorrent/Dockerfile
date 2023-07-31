FROM alpine:3.18

# If any dependencies fail, the entire supervision tree should fail
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
# Prevent services from timing out
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

ARG QBITTORRENT_ARCH=x86_64
ARG QBITTORRENT_VERSION=4.5.4
ARG LIBTORRENT_VERSION=2.0.9
ARG QBITTORRENT_RELEASE=https://github.com/userdocs/qbittorrent-nox-static/releases/download/release-${QBITTORRENT_VERSION}_v${LIBTORRENT_VERSION}/${QBITTORRENT_ARCH}-qbittorrent-nox
ADD ${QBITTORRENT_RELEASE} /usr/bin/qbittorrent-nox
RUN chmod +x /usr/bin/qbittorrent-nox

RUN apk add --update --no-cache \
  bash \
  s6-overlay \
  curl \
  iptables \
  iproute2-minimal \
  python3 \
  py-pip \
  && pip install --upgrade pip \
  && pip install --no-cache-dir crudini

ENV UIDGID=0:0 \
  QBT_PORTABLE=1 \
  QBT_PROFILE=/config \
  QBT_SAVE_PATH=/downloads \
  S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# deploy our files
COPY ./data /data

# deploy s6 services
COPY ./data/config/s6/s6-rc.d /etc/s6-overlay/s6-rc.d
COPY ./data/scripts /scripts

ENTRYPOINT /init
