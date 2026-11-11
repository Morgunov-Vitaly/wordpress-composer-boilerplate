#!/usr/bin/env bash

set -euo pipefail

action="${1:-}"
root="$(git rev-parse --show-toplevel)"
project="$(bash "$root/scripts/task-context.sh" project)"
base=(docker compose -p "$project" -f "$root/compose.app.yml")

mode_from_env() {
  if [[ ! -f "$root/.env" ]]; then
    echo "No .env exists. Start shared:up or isolated:up first." >&2
    exit 1
  fi
  sed -n 's/^DB_MODE=//p' "$root/.env"
}

case "$action" in
  shared:init)
    docker compose -p wp-shared -f "$root/compose.shared-db.yml" up -d
    ;;
  shared:up)
    bash "$root/scripts/prepare-env.sh" shared
    docker compose -p wp-shared -f "$root/compose.shared-db.yml" up -d
    "${base[@]}" -f "$root/compose.shared-app.yml" up -d --build
    ;;
  isolated:up)
    bash "$root/scripts/prepare-env.sh" isolated
    "${base[@]}" -f "$root/compose.isolated.yml" up -d --build
    ;;
  down)
    case "$(mode_from_env)" in
      shared) "${base[@]}" -f "$root/compose.shared-app.yml" down --remove-orphans ;;
      isolated) "${base[@]}" -f "$root/compose.isolated.yml" down --remove-orphans ;;
      *) echo "Unknown DB_MODE in .env" >&2; exit 1 ;;
    esac
    ;;
  destroy)
    if [[ "$(mode_from_env)" != "isolated" ]]; then
      echo "Refusing to remove volumes: destroy is available only in isolated mode." >&2
      exit 1
    fi
    "${base[@]}" -f "$root/compose.isolated.yml" down -v --remove-orphans
    ;;
  status)
    docker compose -p "$project" ps
    ;;
  url)
    if [[ -f "$root/.env" ]]; then
      sed -n 's/^WP_HOME=//p' "$root/.env"
    else
      echo "No environment is running." >&2
      exit 1
    fi
    ;;
  deps)
    "${base[@]}" run --rm app composer install --no-interaction --prefer-dist --no-progress
    ;;
  check)
    "${base[@]}" run --rm app composer run check
    ;;
  db:snapshot)
    mkdir -p "$root/infra/snapshots"
    docker compose -p wp-shared -f "$root/compose.shared-db.yml" exec -T -e MYSQL_PWD=wordpress db \
      mariadb-dump -uwordpress --single-transaction --routines --events wordpress \
      | gzip -c > "$root/infra/snapshots/wordpress.sql.gz"
    echo "Wrote infra/snapshots/wordpress.sql.gz (ignored by Git)."
    ;;
  *)
    echo "Usage: $0 {shared:init|shared:up|isolated:up|down|destroy|status|url|deps|check|db:snapshot}" >&2
    exit 64
    ;;
esac
