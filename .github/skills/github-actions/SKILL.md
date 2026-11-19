---
name: github-actions
description: Застосовуй для створення та перевірки кросплатформного GitHub Actions workflow, який запускає локальні CI-скрипти на Linux, Windows і macOS.
---

# GitHub Actions

## Вхід

Перед початком перевір:

- наявність `ci.sh` і його виконуваного режиму Git;
- наявність `ci.bat`;
- відсутність конфліктного `.github/workflows/ci.yml`;
- поточну гілку та стан робочого дерева.

Якщо `ci.sh` не має права на виконання, повідом про проблему та виправ його
режим командою:

```bash
git update-index --chmod=+x ci.sh
```

Не додавай секрети, токени, паролі або інші чутливі значення до workflow.

## Вихід

Створи `.github/workflows/ci.yml` з такими властивостями:

1. Тригери `push` і `pull_request` лише для гілок `develop` та `master`.
2. Глобальний дозвіл:

   ```yaml
   permissions:
     contents: read
   ```

3. Одна job із `strategy.fail-fast: false` і матрицею:

   ```yaml
   os: [ubuntu-latest, windows-latest, macos-latest]
   ```

4. Кроки job:
   - `actions/checkout@v4`;
   - `actions/setup-node@v4` із `node-version: "20"`;
   - запуск `./ci.sh` на не-Windows runner із `shell: bash`;
   - запуск `ci.bat` на Windows runner із `shell: cmd`;
   - `actions/upload-artifact@v4` для каталогу `dist/`.
5. Artifact має мати унікальне ім'я:

   ```yaml
   name: hello-${{ matrix.os }}
   ```

6. Для upload-кроку встанови:

   ```yaml
   if-no-files-found: error
   ```

## Обов'язкова форма workflow

Використовуй структуру, еквівалентну цій:

```yaml
name: CI

on:
  push:
    branches: [develop, master]
  pull_request:
    branches: [develop, master]

permissions:
  contents: read

jobs:
  build:
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
      - name: Run CI on Unix
        if: runner.os != 'Windows'
        shell: bash
        run: ./ci.sh
      - name: Run CI on Windows
        if: runner.os == 'Windows'
        shell: cmd
        run: ci.bat
      - uses: actions/upload-artifact@v4
        with:
          name: hello-${{ matrix.os }}
          path: dist/
          if-no-files-found: error
```

У `run` workflow-файла дозволено лише запускати `./ci.sh` або `ci.bat`.
Не додавай до `ci.yml` прямі команди `npm`, `node` чи `npx`, а також не
дублюй логіку цих скриптів у YAML.

## Правила

- Не перезаписуй наявний `.github/workflows/ci.yml` без перевірки його вмісту.
- Якщо безпечне злиття неможливе, повідом про конфлікт і не перезаписуй файл.
- Створи лише одну job; не додавай паралельних job поза матрицею.
- Не додавай секрети, токени, паролі або їхні значення.
- Не додавай кроки, що обходять `ci.sh` чи `ci.bat`.
- Не змінюй `ci.sh` або `ci.bat`, окрім виправлення права на виконання,
  якщо це необхідно для workflow.
- Перед завершенням покажи diff і список змінених файлів.

## Перевірки

1. Переконайся, що YAML синтаксично валідний. Використай `actionlint`, якщо
   він доступний, або:

   ```bash
   python -c "import yaml, pathlib; yaml.safe_load(pathlib.Path('.github/workflows/ci.yml').read_text())"
   ```

2. Перевір, що файл містить `ubuntu-latest`, `windows-latest` і
   `macos-latest`.
3. Перевір `fail-fast: false`, `contents: read`, версію Node `"20"`,
   `actions/checkout@v4`, `actions/setup-node@v4` і
   `actions/upload-artifact@v4`.
4. Перевір `name: hello-${{ matrix.os }}` і
   `if-no-files-found: error`.
5. Перевір, що всі `run` у `ci.yml` запускають лише `./ci.sh` або `ci.bat`,
   без прямих команд npm, node чи npx.
6. Перевір, що текст файлу не містить слів `token`, `password` або `secret`
   без урахування регістру.
7. Перевір, що `ci.sh` має виконуваний режим Git.

## Типова помилка

Якщо `ci.sh` не має права на виконання, workflow на Unix runner не зможе
запуститися. Спочатку встанови режим через
`git update-index --chmod=+x ci.sh`, потім повтори перевірки і покажи зміну
режиму у diff.

## Приклад

### Вхід

```text
ci.sh і ci.bat існують
ci.sh має виконуваний режим Git
потрібен workflow для develop та master
```

### Очікуваний результат

```text
Створено .github/workflows/ci.yml.
Workflow запускається для push і pull_request у develop та master.
Матриця містить ubuntu-latest, windows-latest і macos-latest.
На Unix запускається ./ci.sh, на Windows — ci.bat.
Після CI завантажується dist/ з унікальним артефактом для кожної ОС.
YAML валідний, прямі npm/node/npx-команди відсутні.
```
