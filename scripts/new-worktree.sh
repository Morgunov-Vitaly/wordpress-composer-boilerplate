#!/usr/bin/env bash

set -euo pipefail

name="${1:-}"
if [[ ! "$name" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "Usage: $0 <lowercase-task-name>" >&2
  exit 64
fi

root="$(git rev-parse --show-toplevel)"
worktree_root="$(dirname "$root")/.worktrees"
path="$worktree_root/$name"
branch="agent/$name"

mkdir -p "$worktree_root"
git fetch origin main
git worktree add -b "$branch" "$path" origin/main
echo "Created $path on branch $branch"
