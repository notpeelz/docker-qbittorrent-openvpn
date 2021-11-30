#!/usr/bin/env bash

SCRIPT_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"

if [[ "$PROMPT" == '1' ]]; then
  echo -n "Password: "
  "$SCRIPT_DIR/hash"
  echo
else
  "$SCRIPT_DIR/hash"
fi
