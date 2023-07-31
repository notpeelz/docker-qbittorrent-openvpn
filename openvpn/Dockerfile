FROM alpine:3.18

ENV VPN_LOG_LEVEL=3
# If any dependencies fail, the entire supervision tree should fail
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
# Prevent services from timing out
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

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

ENTRYPOINT /init
