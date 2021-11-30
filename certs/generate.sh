#!/usr/bin/env bash

SCRIPT_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"

cd "$SCRIPT_DIR"

openssl req -new -x509 -newkey rsa:4096 -nodes \
  -keyout server.key -out server.crt \
  -subj "/C=CA/ST=Ontario/L=Toronto/O=./CN=." \
  -days 1460
