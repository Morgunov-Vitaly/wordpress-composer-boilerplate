# WordPress Composer Boilerplate

Small WordPress starter intended for learning CI/CD through GitHub Actions and Jenkins.

## What is versioned

- Project configuration, a must-use plugin, and a minimal theme are source code.
- WordPress core and Composer dependencies are installed into `public/wp` and `vendor`; they are not committed.
- `.env` contains secrets and local infrastructure settings; it is never committed. Start with `cp .env.example .env`.

## Local prerequisites

- Docker Engine with Docker Compose v2
- [mise](https://mise.jdx.dev/) as the task runner and project command surface
- Git 2.20+

The local web stack is Nginx with PHP-FPM 8.3.36. Nginx is the only service
that publishes a host port; the PHP container is reachable only from Docker.

## Parallel worktrees and environments

One Git worktree equals one task and one branch. The worktree owns its PHP
runtime and application containers; it never shares those with another task.
Docker Compose assigns every task a unique project name and deterministic local
port, so two branches can run at once.

Each worktree still has its own ignored `vendor/` and `public/wp/` directories:
their lock files may diverge. The Docker volume `wordpress-composer-cache` is
the only shared dependency resource; it stores Composer download archives to
avoid downloading the same packages again.

In shared mode the PHP container alone joins the shared database network. Nginx
and PHP-FPM communicate through a private Compose network for that worktree,
so the `app` FastCGI hostname can never resolve to another task's PHP container.

```text
main checkout                 integration work
../.worktrees/feature-a       agent A + its application container
../.worktrees/feature-b       agent B + its application container
wp-shared-db                  one deliberate, persistent shared MariaDB
```

There are two data modes:

| Mode | Use it for | Data lifetime |
| --- | --- | --- |
| `shared` | Non-destructive UI and logic work that needs real posts, options, custom post types, and uploads. | Persistent across worktrees. |
| `isolated` | Tests, imports, migrations, plugin updates, destructive experiments, and uncertain changes. | Per worktree; `mise run destroy` removes it. |

Do **not** treat the shared database as a test fixture. It is a convenient
local viewing environment, not a safe place to reset, migrate or import data.
The `destroy` task refuses to run unless the local `.env` says `DB_MODE=isolated`.

## First local run

```bash
mise trust
mise run deps
mise run isolated:up
mise run url
mise run check
```

Open the URL printed by `mise run url` and complete the normal WordPress setup.
The initial isolated database is empty unless a shared local snapshot exists.
When it is no longer needed, run `mise run destroy`.

## Working with AI agents

Create one worktree per task from the main checkout:

```bash
mise run worktree:new -- fix-footer-spacing
cd ../.worktrees/fix-footer-spacing
mise trust
mise run deps
mise run shared:up          # only for safe, non-destructive work
mise run check
```

For a migration, import or E2E test, replace `shared:up` with `isolated:up`.
The full operating rules are in [AGENTS.md](AGENTS.md); give that file to every
agent before it starts work.

### Sharing realistic local data safely

After starting the shared environment and intentionally loading suitable local
content, create a local seed dump:

```bash
mise run shared:init
mise run db:snapshot
```

This writes one local, shared snapshot at
`.git/wordpress-snapshots/wordpress.sql.gz`. Every linked worktree uses that
same file when it creates a brand-new isolated MariaDB volume. It is outside
the tracked files and never enters Git. Sanitize personal data and secrets
before copying a snapshot outside this machine.

### Lifecycle commands

| Command | Effect |
| --- | --- |
| `mise run shared:init` | Starts the one persistent shared MariaDB and uploads volume. |
| `mise run shared:down` | Stops shared MariaDB while preserving its data and uploads. |
| `mise run shared:up` | Starts this worktree's app against shared data. |
| `mise run isolated:up` | Starts this worktree's app, database, and uploads volumes. |
| `mise run deps` | Runs locked Composer installation in the PHP container. |
| `mise run check` | Runs repository checks in the PHP container. |
| `mise run status`, `mise run url`, `mise run down` | Inspect, locate, and stop this task. |
| `mise run destroy` | Deletes only this task's isolated data volumes. |

## Project layout

| Path | Purpose |
| --- | --- |
| `public/content/` | Versioned project code: themes and must-use plugins. |
| `config/` | Environment-aware WordPress configuration. |
| `public/` | Web root; Composer installs WordPress core here. |
| `.github/workflows/ci.yml` | GitHub Actions CI workflow. |
| `Jenkinsfile` | Same initial checks expressed as Jenkins Pipeline. |
| `compose.*.yml` | Shared and isolated Docker Compose topology. |
| `mise.toml` | Single task-command surface for developers and agents. |
| `AGENTS.md` | Non-negotiable data-isolation rules for coding agents. |

## CI lesson 1

The CI workflow runs for every pull request, every push to `main`, and manually. Its jobs are deliberately small:

1. GitHub provides a clean Ubuntu runner.
2. The workflow checks out the exact commit.
3. It installs PHP and Composer.
4. Composer metadata, PHP syntax, and a minimal smoke test must pass.

Try changing a PHP file to invalid syntax on a feature branch, opening a pull request, and reading the failed Actions log. Then fix it and observe the next run turn green.

## CI lesson 2: supply-chain discipline

Run `composer update` locally only when intentionally updating dependencies, review the resulting `composer.lock`, and commit it. CI should normally use `composer install` with that lock file. The first lesson does not download WordPress because its checks do not require it.

## Jenkins equivalent

`Jenkinsfile` contains the same Validate and Quality stages. In Jenkins, create a **Pipeline** job pointing at this repository and set the script path to `Jenkinsfile`. Add a GitHub webhook after Jenkins is publicly reachable. A Multibranch Pipeline job is preferable once branches and pull requests are part of the team's normal workflow.

## Next exercises

1. Add PHPCS/WordPress Coding Standards and turn violations into a required PR check.
2. Build a deployable artifact that excludes `.env`, Git history, tests, and development dependencies.
3. Add Playwright smoke and E2E tests that always select isolated mode.
4. Add a manual staging deployment using GitHub Environments and encrypted secrets.
5. Reproduce that deploy stage in Jenkins and compare credential handling.
