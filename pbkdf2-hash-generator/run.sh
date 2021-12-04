#!/usr/bin/env bash

SCRIPT_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"

if [[ "$PROMPT" == '1' ]]; then
  echo -n "Password: "
fi
exec "$SCRIPT_DIR/hash"
