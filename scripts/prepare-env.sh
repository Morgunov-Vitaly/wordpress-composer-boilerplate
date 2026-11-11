#!/usr/bin/env bash

set -euo pipefail

mode="${1:-}"
if [[ "$mode" != "shared" && "$mode" != "isolated" ]]; then
  echo "Usage: $0 {shared|isolated}" >&2
  exit 64
fi

root="$(git rev-parse --show-toplevel)"
port="$(bash "$root/scripts/task-context.sh" port)"

cat > "$root/.env" <<EOF
WP_ENV=development
APP_PORT=${port}
WP_HOME=http://localhost:${port}
WP_SITEURL=http://localhost:${port}/wp

DB_MODE=${mode}
DB_NAME=wordpress
DB_USER=wordpress
DB_PASSWORD=wordpress
DB_HOST=db
DB_PREFIX=wp_

# Development-only keys. Production keys are managed outside the repository.
AUTH_KEY=local-development-auth-key
SECURE_AUTH_KEY=local-development-secure-auth-key
LOGGED_IN_KEY=local-development-logged-in-key
NONCE_KEY=local-development-nonce-key
AUTH_SALT=local-development-auth-salt
SECURE_AUTH_SALT=local-development-secure-auth-salt
LOGGED_IN_SALT=local-development-logged-in-salt
NONCE_SALT=local-development-nonce-salt
EOF

echo "Wrote .env for ${mode} mode: http://localhost:${port}"
