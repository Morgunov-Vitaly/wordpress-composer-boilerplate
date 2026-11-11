# WordPress Composer Boilerplate

Small WordPress starter intended for learning CI/CD through GitHub Actions and Jenkins.

## What is versioned

- Project configuration, a must-use plugin, and a minimal theme are source code.
- WordPress core and Composer dependencies are installed into `public/wp` and `vendor`; they are not committed.
- `.env` contains secrets and local infrastructure settings; it is never committed. Start with `cp .env.example .env`.

## Local prerequisites

- PHP 8.2+
- Composer 2
- MySQL or MariaDB

## First local run

```bash
cp .env.example .env
composer install
composer run check
```

Create the database named in `.env`, point your web server's document root at `public/`, then complete WordPress installation at `WP_HOME`.

## Project layout

| Path | Purpose |
| --- | --- |
| `public/content/` | Versioned project code: themes and must-use plugins. |
| `config/` | Environment-aware WordPress configuration. |
| `public/` | Web root; Composer installs WordPress core here. |
| `.github/workflows/ci.yml` | GitHub Actions CI workflow. |
| `Jenkinsfile` | Same initial checks expressed as Jenkins Pipeline. |

## CI lesson 1

The CI workflow runs for every pull request, every push to `main`, and manually. Its jobs are deliberately small:

1. GitHub provides a clean Ubuntu runner.
2. The workflow checks out the exact commit.
3. It installs PHP and Composer.
4. Composer validates `composer.lock`, restores downloads from cache, and installs the exact locked dependencies.
5. PHP syntax and a minimal smoke test must pass.

Try changing a PHP file to invalid syntax on a feature branch, opening a pull request, and reading the failed Actions log. Then fix it and observe the next run turn green.

## CI lesson 2: supply-chain discipline

Run `composer update` locally only when intentionally updating dependencies, review the resulting `composer.lock`, and commit it. CI uses `composer install`, so every runner receives the exact dependency set that was reviewed.

## Jenkins equivalent

`Jenkinsfile` contains the same Validate and Quality stages. In Jenkins, create a **Pipeline** job pointing at this repository and set the script path to `Jenkinsfile`. Add a GitHub webhook after Jenkins is publicly reachable. A Multibranch Pipeline job is preferable once branches and pull requests are part of the team's normal workflow.

## Next exercises

1. Add `composer.lock` and a dependency-install job with Composer cache.
2. Add PHPCS/WordPress Coding Standards and turn violations into a required PR check.
3. Build a deployable artifact that excludes `.env`, Git history, tests, and development dependencies.
4. Add a manual staging deployment using GitHub Environments and encrypted secrets.
5. Reproduce that deploy stage in Jenkins and compare credential handling.
