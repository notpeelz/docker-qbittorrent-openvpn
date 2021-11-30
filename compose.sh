#!/usr/bin/env bash

SCRIPT_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"

join_arr() {
  local name=$2[@]
  printf -v joined "$1" "${!name}"
  echo "$joined"
}

config_files=()
add_config() {
  while [[ "$#" -gt 0 ]]; do
    if [[ -s "$1" ]]; then
      echo "Sourcing docker-compose config from $(realpath "$1")"
      config_files+=("$1")
    fi
    shift
  done
}

add_config "$SCRIPT_DIR"/docker-compose.{base,custom}.yml

DOCKER_BUILDKIT=1 docker compose \
  $(join_arr ' -f %s' config_files) \
  "$@"
