FROM alpine:3.14

ENV KILL_SWITCH=on \
  VPN_LOG_LEVEL=3 \
  HTTP_PROXY=off \
  SOCKS_PROXY=off

RUN apk add --update --no-cache \
  bash \
  s6-overlay \
  bind-tools \
  openvpn

# deploy our files
COPY ./data /data

# deploy s6 services
COPY ./data/config/s6/cont-init.d /etc/cont-init.d
COPY ./data/config/s6/services.d /etc/services.d

HEALTHCHECK CMD ping -c 3 1.1.1.1 || exit 1

ENTRYPOINT /init
