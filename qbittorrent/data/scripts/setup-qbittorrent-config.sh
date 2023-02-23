#!/usr/bin/with-contenv /bin/bash
# vim:ft=sh

set -Eeuo pipefail

rm -rf /certs
cp /mnt/certs /certs -R

if [[ ! "$UIDGID" =~ ^[0-9]+:[0-9]*$ ]]; then
  echo "ERROR: \$UIDGID is not valid"
  exit 1
fi

mounts="$(mount | grep '^/dev/' | grep -v '/etc' | awk '{print $3}')"
if ! (echo "$mounts" | grep -q '^/config$'); then
  echo "ERROR: /config is not mounted"
  exit 1
fi
if ! (echo "$mounts" | grep -q '^/downloads$'); then
  echo "ERROR: /downloads is not mounted"
  exit 1
fi

chown "$UIDGID" /certs -R

config_dir="/config/qBittorrent/config"
mkdir -p "$config_dir"

config_file="$config_dir/qBittorrent.conf"
if [[ ! -s "$config_file" ]]; then
  echo "config file doesn't exist; copying default config file"
  cp /data/config/qBittorrent/qBittorrent.conf "$config_file"
  chown "$UIDGID" "$config_file"
fi

set_setting() {
  section="$1"
  key="$2"
  value="$3"
  if [[ ! -w "$config_file" ]]; then
    echo "WARNING: $config_file is not writable; aborting config file initialization"
    exit 0
  fi
  crudini --inplace --set "$config_file" "$section" "$key" "$value"
}

if [[ "${WEBUI_HTTPS:-}" == "1" ]]; then
  set_setting 'Preferences' 'WebUI\HTTPS\Enabled' true
else
  set_setting 'Preferences' 'WebUI\HTTPS\Enabled' false
fi

if [[ "${WEBUI_AUTH:-}" == "0" ]]; then
  set_setting 'Preferences' 'WebUI\AuthSubnetWhitelist' '0.0.0.0/0'
  set_setting 'Preferences' 'WebUI\AuthSubnetWhitelistEnabled' true
else
  set_setting 'Preferences' 'WebUI\AuthSubnetWhitelistEnabled' false

  default_user="admin"
  default_pass="ARQ77eY1NUZaQsuDHbIMCA==:0WMRkYTUWVT9wVvdDtHAjU9b3b7uB8NR1Gur2hmQCvCDpm39Q+PsJRJPaCU51dEiz+dTzh8qbPsL8WkFljQYFQ=="
  user="${WEBUI_USER:-$default_user}"
  pass="${WEBUI_PASS:-$default_pass}"

  set_setting 'Preferences' 'WebUI\Username' "$user"
  set_setting 'Preferences' 'WebUI\Password_PBKDF2' "$pass"
fi

if [[ ! -z "${QB_PEER_PORT:-}" ]]; then
  set_setting 'BitTorrent' 'Session\Port' "$QB_PEER_PORT"
else
  set_setting 'BitTorrent' 'Session\Port' 6881
fi

if [[ "${QB_DHT:-}" == "1" ]]; then
  set_setting 'Preferences' 'Bittorrent\DHT' true
else
  set_setting 'Preferences' 'Bittorrent\DHT' false
fi

if [[ "${QB_LSD:-}" == "1" ]]; then
  set_setting 'Preferences' 'Bittorrent\LSD' true
else
  set_setting 'Preferences' 'Bittorrent\LSD' false
fi

if [[ "${QB_PEX:-}" == "1" ]]; then
  set_setting 'Preferences' 'Bittorrent\PeX' true
else
  set_setting 'Preferences' 'Bittorrent\PeX' false
fi

if [[ "${QB_ANONYMOUS:-}" == "0" ]]; then
  set_setting 'Preferences' 'Advanced\AnonymousMode' false
else
  set_setting 'Preferences' 'Advanced\AnonymousMode' true
fi

if [[ ! -z "${QB_LIMIT_DL:-}" ]]; then
  set_setting 'Preferences' 'Connection\GlobalDLLimit' "$QB_LIMIT_DL"
fi

if [[ ! -z "${QB_LIMIT_UP:-}" ]]; then
  set_setting 'Preferences' 'Connection\GlobalUPLimit' "$QB_LIMIT_UP"
fi

if [[ ! -z "${QB_LIMIT_ALT_DL:-}" ]]; then
  set_setting 'Preferences' 'Connection\GlobalDLLimitAlt' "$QB_LIMIT_ALT_DL"
fi

if [[ ! -z "${QB_LIMIT_ALT_UP:-}" ]]; then
  set_setting 'Preferences' 'Connection\GlobalUPLimitAlt' "$QB_LIMIT_ALT_UP"
fi
