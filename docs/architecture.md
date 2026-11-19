# Архітектура AI-агента

## 1. Які проблеми вирішує агент

AI-агент автоматизує створення кросплатформного JavaScript/Node.js проєкту
Hello World. Він вирішує такі задачі:

- створює початкову структуру проєкту без перезапису наявних файлів;
- налаштовує npm scripts і залежність Jest;
- створює кросплатформну збірку без залежності від shell-команд конкретної ОС;
- готує локальні CI-скрипти для Bash і Windows Batch;
- створює GitHub Actions workflow для Linux, Windows і macOS;
- перевіряє тести, збірку, артефакти та правила `.gitignore`;
- забезпечує ідемпотентність повторного запуску.

## 2. Skills і їхня відповідальність

Агент використовує три skills:

- `project-scaffold` — створює `src/hello.js`, `src/calculator.js`,
  `docs/`, а також відсутні `README.md` і `.gitignore` за визначеними
  правилами;
- `build-and-test` — налаштовує `package.json`, генерує
  `package-lock.json`, створює build-скрипт, Jest-тест і локальні
  `ci.sh`/`ci.bat`;
- `github-actions` — створює та перевіряє `.github/workflows/ci.yml` із
  matrix для трьох операційних систем.

## 3. Commands, доступні користувачу

- `git-init` — перевіряє Git-репозиторій і створює або доповнює `.gitignore`;
- `create-project` — створює початкову структуру JavaScript/Node.js проєкту;
- `create-build` — налаштовує npm, Jest, збірку та локальні CI-скрипти;
- `create-actions` — створює workflow GitHub Actions для Linux, Windows і
  macOS;
- `check` — виконує read-only перевірку інструкцій, проєкту, тестів, збірки,
  CI та Git-відстеження;
- `project-init` — послідовно оркеструє всі попередні етапи та завершує повною
  перевіркою.

## 4. Дані між етапами

Потік даних проходить послідовно:

```text
project_name=hello
        |
        v
src/hello.js + src/calculator.js
        |
        v
package.json + tests/basic.test.js
        |
        v
ci.sh + ci.bat
        |
        v
.github/workflows/ci.yml
```

`project_name` визначає назву проєкту та використовується під час scaffold.
Файли `src/` є джерелом для build-скрипта, а `package.json` і
`tests/basic.test.js` визначають npm/Jest-перевірки. Локальні `ci.sh` і
`ci.bat` виконують однакову послідовність `npm ci`, тестування та збірки.
GitHub Actions запускає відповідний локальний CI-скрипт на кожній ОС і
завантажує каталог `dist/`.

## 5. Обробка помилок оркестратором `project-init`

Оркестратор `project-init` виконує етапи строго в такому порядку:

1. `git-init`;
2. `create-project`;
3. `create-build`;
4. `create-actions`;
5. `check`.

Після кожного етапу він перевіряє результат. Якщо етап або його перевірка
завершилися помилкою, `project-init` негайно зупиняється, не запускає наступні етапи
та виводить звіт із назвою кроку, причиною, виводом команди й необхідним
виправленням. Загальний успіх дозволений лише після явного
`Статус: PASSED` від `check`.

## 6. Відповідність файлів ролям

| Роль | Файли |
|---|---|
| Агент | `.github/agents/build-engineer.agent.md` |
| Skills | `.github/skills/project-scaffold/SKILL.md`, `.github/skills/build-and-test/SKILL.md`, `.github/skills/github-actions/SKILL.md` |
| Commands | `.github/prompts/git-init.prompt.md`, `.github/prompts/create-project.prompt.md`, `.github/prompts/create-build.prompt.md`, `.github/prompts/create-actions.prompt.md`, `.github/prompts/check.prompt.md`, `.github/prompts/project-init.prompt.md` |
| Тести Jest | `tests/basic.test.js` |
| Збірка | `scripts/build.js` |
| Локальний CI | `ci.sh`, `ci.bat` |
| GitHub Actions CI | `.github/workflows/ci.yml` |

## 7. Формат VS Code Copilot

Проєкт використовує формат VS Code Copilot: custom agents, prompt files та
agent skills. Агент описаний у custom agent manifest, skills містять
спеціалізовані інструкції, а prompt files надають користувачу окремі
commands і оркестрацію повного процесу.
