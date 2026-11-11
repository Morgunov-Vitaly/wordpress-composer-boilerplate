# WordPress Composer Boilerplate

Учебный Composer-based WordPress-проект для CI/CD и параллельной работы с ИИ-агентами.

## Что здесь есть

- WordPress core и PHP-зависимости устанавливаются Composer, а не хранятся в Git.
- `public/content/` содержит версионируемый код темы и mu-plugins.
- Docker фиксирует runtime: PHP 8.3.36, Apache и Composer 2.8.12.
- `mise` даёт единый набор lifecycle-команд.
- GitHub Actions запускает проверку Composer, PHP syntax lint и smoke test на каждом PR и push в `main`.

## Первый запуск

```bash
mise trust
mise run deps
mise run shared:init
mise run shared:up
mise run url
```

Откройте URL из последней команды и выполните стандартную установку WordPress.

## Работа над несколькими задачами

Для каждой задачи создаётся отдельная ветка и Git worktree:

```bash
mise run worktree:new -- task-name
cd ../.worktrees/task-name
mise trust
mise run deps
```

### Обычная задача: общая БД

Используйте, если нужны реальные посты, CPT, настройки и uploads, но задача не
выполняет миграции, импорты, обновления плагинов или другие destructive-операции:

```bash
mise run shared:up
mise run url
mise run check
mise run down
```

Код, контейнер и URL будут отдельными для worktree. Shared MariaDB и uploads —
общие для всех таких задач. Остановить shared БД без удаления данных:

```bash
mise run shared:down
```

### Рискованная задача: isolated БД

Используйте для миграций, импортов, E2E-тестов, обновлений и экспериментов:

```bash
mise run isolated:up
mise run url
mise run check
mise run destroy
```

`destroy` удаляет только isolated DB/uploads этой worktree и намеренно
отказывается работать в shared-режиме.

## Общий snapshot для isolated БД

Создайте или обновите локальный dump текущей shared БД:

```bash
mise run shared:init
mise run db:snapshot
```

Snapshot хранится вне Git в `.git/wordpress-snapshots/wordpress.sql.gz` и один
на все linked worktree. Новая isolated БД загрузит его автоматически. Чтобы
применить обновлённый snapshot к уже созданной isolated БД, выполните:

```bash
mise run destroy
mise run isolated:up
```

## Важные правила

- `vendor/` и `public/wp/` отдельные в каждой worktree; общий только Composer download cache.
- Никогда не выполняйте destructive-операции в shared БД.
- Не добавляйте `.env`, uploads и DB snapshot в Git.
- Перед передачей задачи агент должен запустить `mise run check`.

Полные правила для агентов находятся в [AGENTS.md](AGENTS.md), а подробная
английская документация — в [README.md](README.md).
