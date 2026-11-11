#!/usr/bin/env bash

set -euo pipefail

root="$(git rev-parse --show-toplevel)"
slug="$(basename "$root" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-')"
slug="${slug#-}"
slug="${slug%-}"
checksum="$(printf '%s' "$slug" | cksum | awk '{print $1}')"
port="$((18000 + checksum % 1000))"

case "${1:-}" in
  project) printf 'wp-%s\n' "$slug" ;;
  port) printf '%s\n' "$port" ;;
  root) printf '%s\n' "$root" ;;
  *)
    echo "Usage: $0 {project|port|root}" >&2
    exit 64
    ;;
esac
