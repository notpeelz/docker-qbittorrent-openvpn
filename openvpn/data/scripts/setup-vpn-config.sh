#!/usr/bin/with-contenv /bin/bash
# vim:ft=sh

set -Eeuo pipefail

mkdir -p /run/data/vpn
cp /mnt/vpn-config/. /run/data/vpn -r

config_file="/run/data/vpn/${OPENVPN_CONFIG_FILE}"
if [ ! -s "$config_file" ]; then
  >&2 echo "ERROR: \$OPENVPN_CONFIG_FILE not found"
  exit 1
fi

# these configuration file changes are required by Alpine
sed -i \
  -e '/up /c up \/etc\/openvpn\/up.sh' \
  -e '/down /c down \/etc\/openvpn\/down.sh' \
  -e 's/^proto udp$/proto udp4/' \
  -e 's/^proto tcp$/proto tcp4/' \
  "$config_file"
