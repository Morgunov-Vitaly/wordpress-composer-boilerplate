# Agent workflow

Every coding task gets its own Git worktree and branch. Do not edit another
agent's worktree or use the main checkout for task work.

## Pick a database mode before starting

- Use `shared` only for non-destructive visual or logic work. It exposes the
  team's persistent WordPress posts, options, custom post types and uploads.
- Use `isolated` for imports, migrations, plugin/core updates, destructive
  experiments, tests that write data, or anything uncertain.
- CI always uses an ephemeral isolated database. It must never connect to the
  local shared database.

## Commands

```bash
mise run worktree:new -- task-name
cd ../.worktrees/task-name
mise run deps
mise run shared:up       # or: mise run isolated:up
mise run check
mise run down
```

`mise run destroy` deletes volumes only after it confirms `DB_MODE=isolated`.
Never bypass that guard. To seed fresh isolated databases from realistic local
data, a human first runs `mise run db:snapshot`; it replaces the one local
snapshot shared by all linked worktrees, outside Git, and must be sanitized
before sharing outside the machine.
