#!/usr/bin/with-contenv /bin/bash
# vim:ft=sh

set -Eeuo pipefail

info() {
  printf "killswitch: %s\n" "$1"
}

error() {
  printf "killswitch: ERROR: %s\n" "$1"
}

is_ip() {
  echo "$1" | grep -Eq "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"
}

config_file="/run/data/vpn/${OPENVPN_CONFIG_FILE}"

default_gateway="$(ip r | grep 'default via' | cut -d' ' -f3)"
local_subnet="$(ip r | grep -v 'default via' | grep eth0 | tail -n1 | cut -d' ' -f1)"

info "default gateway: $default_gateway"
info "local subnet: $local_subnet"

# allow established and related connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# allow loopback connections
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# allow Docker network connections
iptables -A INPUT -s "$local_subnet" -j ACCEPT
iptables -A OUTPUT -d "$local_subnet" -j ACCEPT

ip route add "$default_gateway" dev eth0 scope link

# allow specified subnets
for subnet in ${SUBNETS//,/ }; do
  info "creating route to subnet: $subnet via $default_gateway"
  # create a route to the subnet
  ip route replace "$subnet" via "$default_gateway" dev eth0
  # allow connections
  iptables -A INPUT -s "$subnet" -j ACCEPT
  iptables -A OUTPUT -d "$subnet" -j ACCEPT
done

# allowing remote servers in configuration file
remote_port="$(grep "port " "$config_file" | cut -d' ' -f2 || echo '')"
remote_proto="$(grep "proto " "$config_file" | cut -d' ' -f2 | cut -c1-3 || echo '')"
remotes="$(grep "remote " "$config_file" | cut -d' ' -f2-4 || echo '')"

info "vpn remotes:"
echo "${remotes}" | while IFS= read -r line; do
  # strip any comments from line that could mess up cuts
  clean_line="${line%% #*}"
  addr="$(echo "$clean_line" | cut -d' ' -f1)"
  port="$(echo "$clean_line" | cut -s -d' ' -f2)"
  proto="$(echo "$clean_line" | cut -s -d' ' -f3 | cut -c1-3)"
  port="${port:-${remote_port:-1194}}"
  proto="${proto:-${remote_proto:-udp}}"

  if is_ip "$addr"; then
    info "IP: $addr PORT: $port PROTO: $proto"
    iptables -A OUTPUT -o eth0 -d "$addr" -p "${proto}" --dport "${port}" -j ACCEPT
  else
    for ip in $(dig -4 +short "$addr"); do
      if ! is_ip "$ip"; then
        error "dig resolved an invalid IPv4 address: $addr -> $ip"
        exit 1
      fi
      info "$addr (IP: $ip PORT: $port PROTO: $proto)"
      iptables -A OUTPUT -o eth0 -d "$ip" -p "${proto}" --dport "${port}" -j ACCEPT
    done
  fi
done

# allow connections over VPN interface
iptables -A INPUT -i tun0 -j ACCEPT
iptables -A OUTPUT -o tun0 -j ACCEPT

# prevent anything else
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
