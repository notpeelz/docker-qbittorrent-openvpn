#!/usr/bin/env bash

SCRIPT_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"

export DOCKER_BUILDKIT=1

name="peelz/qbittorrent-pbkdf2-hash-generator"
docker build -t "$name" "$SCRIPT_DIR/pbkdf2-hash-generator" &> /dev/null
exitcode=$?
if [[ "$exitcode" -ne 0 ]]; then
  echo "Failed to build docker image"
  exit 1
fi

PROMPT=0
[[ -t 0 ]] && PROMPT=1
docker run \
  -e "PROMPT=$PROMPT" \
  --interactive \
  --rm \
  "$name"
