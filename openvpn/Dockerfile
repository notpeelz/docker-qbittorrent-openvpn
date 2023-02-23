FROM alpine:3.17

ENV KILL_SWITCH=on \
  VPN_LOG_LEVEL=3 \
  HTTP_PROXY=off \
  SOCKS_PROXY=off

RUN apk add --update --no-cache \
  bash \
  s6-overlay \
  curl \
  bind-tools \
  iptables \
  iproute2-minimal \
  openvpn

# deploy our files
COPY ./data /data

# deploy s6 services
COPY ./data/config/s6/s6-rc.d /etc/s6-overlay/s6-rc.d
COPY ./data/scripts /scripts

HEALTHCHECK CMD ping -c 3 1.1.1.1 || exit 1

ENTRYPOINT /init
