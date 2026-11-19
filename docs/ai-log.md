1. <system_reminder>
<environment_limitations>
Current command-sandbox guidance, superseding earlier sandbox status:
You are *not* operating in a sandboxed environment dedicated to this task. You may be sharing the environment with other users.
</environment_limitations>
</system_reminder>

<current_datetime>2026-11-19T16:29:39.777+02:00</current_datetime>

Я роблю лабораторну роботу (варіант 3): AI-агент для VS Code Copilot, який у репозиторії
генерує кросплатформний JavaScript проєкт Hello World (Node.js + npm scripts + Jest) і CI
на GitHub Actions (Windows, Linux, macOS).
Зараз я в гілці develop і створюю ТІЛЬКИ інструкції агента (manifest, skills,
prompts-команди, документацію). Не створюй src/, tests/, scripts/, package.json, ci.yml, ci.sh, ci.bat:
їх згенерує агент пізніше в гілці feature.
Файли створюй по одному, коли я попрошу. Мова інструкцій: українська,
імена файлів і команд: англійською.

<system_reminder>
<workspace_info>
Initial workspace structure (file names only):
```text
d:\\Навчання\4курс1\АПКС\1лаба
README.md
```
This snapshot may be truncated or stale. Use tools to inspect file contents and collect more context as needed.
</workspace_info>
</system_reminder>

2. <current_datetime>2026-11-19T16:30:27.688+02:00</current_datetime>

Створи файл .github/agents/build-engineer.agent.md з YAML frontmatter
(description, tools) і розділами:
1. Роль: build engineer для JavaScript/Node.js проєктів (npm scripts, Jest).
2. Область відповідальності: scaffold, збірка, юніт-тести, CI.
3. Доступні skills: project-scaffold, build-and-test, github-actions (з шляхами).
4. Доступні commands: git-init, create-project, create-build, create-actions,
   check, init (з коротким описом).
5. Правила роботи з файлами: ніколи не перезаписувати наявні файли без
   перевірки; ідемпотентність (повторний запуск не дублює вміст); показувати
   diff/список змін перед завершенням.
6. Заборонені дії: видалення файлів, git push --force, переписування історії,
   зміна захисту гілок, робота з секретами/токенами, публікація даних.
7. Порядок роботи.
8. Критерії успішного завершення: існує dist/hello.js і node dist/hello.js друкує Hello, World!; тест basicAddition (Jest) проходить (npm test); ci.yml містить ubuntu/windows/macos і лише викликає ci.sh/ci.bat; node_modules/ і dist/ не під Git; check завершується без помилок.
9. Поведінка при помилці: зупинитись, показати причину, не вважати роботу успішною.

3. <current_datetime>2026-11-19T16:31:38.676+02:00</current_datetime>

Створи .github/skills/project-scaffold/SKILL.md.
Frontmatter: name: project-scaffold, description (коли застосовувати).
Вхід: language=JavaScript, project_name=hello.
Вихід: src/hello.js (CommonJS; функція main друкує рівно один рядок "Hello, World!" і використовує
функцію add з calculator.js, наприклад обчислює add(2, 3) без виводу результату; main викликається лише
коли файл запущено напряму, через require.main === module), src/calculator.js
(функція add(a, b), яка повертає a + b; експорт module.exports = { add }),
порожній каталог docs/, README.md (якщо немає), .gitignore (якщо немає: створити з рядками,
які описані в .github/prompts/git-init.prompt.md; якщо є: не чіпати). Тести за конвенцією Jest
лежатимуть у tests/ (файли *.test.js), цей skill їх не створює.
Правила: не перезаписувати наявні файли; якщо файл існує і відрізняється, повідомити.
Перевірки: src/hello.js існує; node src/hello.js друкує Hello, World!; вказана команда запуску
(node dist/hello.js після збірки). Типова помилка: файл вже існує з іншим вмістом.
Додай приклад входу та очікуваного результату.

4. <current_datetime>2026-11-19T16:32:10.444+02:00</current_datetime>

Створи .github/skills/build-and-test/SKILL.md.
Frontmatter: name: build-and-test, description (коли застосовувати).
Вхід: наявні src/hello.js та src/calculator.js.
Вихід: package.json (name hello, version 1.0.0, private true, main src/hello.js, engines node ">=20",
scripts: start = "node src/hello.js", test = "jest", build = "node scripts/build.js";
devDependencies: jest 29.7.0 (точна версія); jest config: testEnvironment node),
package-lock.json (згенерувати командою npm install, вручну не писати),
scripts/build.js (кросплатформний Node-скрипт на модулях fs: створює dist/ і копіює туди src/hello.js та src/calculator.js;
без shell-команд cp/copy; завершується з ненульовим кодом при помилці),
tests/basic.test.js з тестом basicAddition
(expect(add(2, 3)).toBe(5), add імпортується з ../src/calculator),
скрипти ci.sh (bash, set -euo pipefail, перехід у каталог скрипта) і ci.bat (перехід у каталог скрипта через cd /d "%~dp0"):
npm ci, потім npm test, потім npm run build, після чого перевіряють, що dist/hello.js існує.
ci.sh має бути виконуваним (git update-index --chmod=+x). У ci.bat викликати npm через call і
перевіряти %errorlevel% після кожної команди, завершуючись з ненульовим кодом при помилці.
Перевірки: у виводі Jest "Tests:       1 passed, 1 total"; існує dist/hello.js;
node dist/hello.js друкує Hello, World!. Типові помилки: Node.js 20 або npm не знайдено
(перевірити node -v, npm -v); у ci.bat забули call перед npm (скрипт обривається);
немає package-lock.json (npm ci падає).
Ідемпотентність: не дублювати scripts і devDependencies у package.json (зливати зміни, а не перезаписувати файл).
Додай приклад входу та очікуваного результату.

5. <current_datetime>2026-11-19T16:32:56.019+02:00</current_datetime>

Створи .github/skills/github-actions/SKILL.md.
Frontmatter: name: github-actions, description (коли застосовувати).
Вихід: .github/workflows/ci.yml: тригери push і pull_request на develop та master;
permissions: contents: read;
одна job з matrix os: [ubuntu-latest, windows-latest, macos-latest], fail-fast: false;
кроки: actions/checkout@v4, actions/setup-node@v4 з node-version: "20",
запуск ./ci.sh (не Windows, shell: bash) або ci.bat (Windows, shell: cmd),
upload-artifact з dist/ (actions/upload-artifact@v4, унікальне ім'я hello-${{ matrix.os }},
if-no-files-found: error). ВАЖЛИВО: у кроках run файлу ci.yml НЕ має бути команд npm/node/npx напряму,
лише запуск ci.sh/ci.bat. Без секретів.
Перевірки: YAML валідний (python -c "import yaml..." або actionlint, якщо є);
у файлі є три ОС; немає слів token/password/secret.
Типова помилка: ci.sh без прав на виконання.
Додай приклад входу та очікуваного результату.

6. <current_datetime>2026-11-19T16:33:39.130+02:00</current_datetime>

Створи .github/prompts/git-init.prompt.md.
Frontmatter: description, agent: build-engineer.
Розділи: Передумови, Дії, Очікувані файли, Команди перевірки, Повідомлення про помилку, Ідемпотентність.
Дії: перевірити, що поточний каталог є git-репозиторієм (git rev-parse); створити .gitignore або ДОПОВНИТИ його без дублів рядками node_modules/, dist/, build/, coverage/, out/, .vs/, .idea/, *.log, .env, *.pem, *.key; показати git status.
Нічого не видаляти.

7. <current_datetime>2026-11-19T16:34:00.726+02:00</current_datetime>

Створи .github/prompts/create-project.prompt.md.
Frontmatter: description, agent: build-engineer.
Розділи: Передумови (git-репозиторій), Дії (виконати інструкції зі skill .github/skills/project-scaffold/SKILL.md з language=JavaScript, project_name=hello), Очікувані файли (src/hello.js, src/calculator.js), Команди перевірки (src/hello.js існує, node src/hello.js друкує Hello, World!), Повідомлення про помилку, Ідемпотентність.

8. <current_datetime>2026-11-19T16:34:25.215+02:00</current_datetime>

Створи .github/prompts/create-build.prompt.md.
Frontmatter: description, agent: build-engineer.
Розділи: Передумови (є src/hello.js, src/calculator.js; встановлено Node.js 20 і npm), Дії (виконати skill .github/skills/build-and-test/SKILL.md), Очікувані файли (package.json, package-lock.json, scripts/build.js, tests/basic.test.js, ci.sh, ci.bat), Команди перевірки, Повідомлення про помилку, Ідемпотентність.

9. <current_datetime>2026-11-19T16:34:47.366+02:00</current_datetime>

Створи .github/prompts/create-actions.prompt.md.
Frontmatter: description, agent: build-engineer.
Розділи: Передумови (є ci.sh і ci.bat), Дії (виконати skill .github/skills/github-actions/SKILL.md), Очікувані файли (.github/workflows/ci.yml), Команди перевірки (валідність YAML, три ОС, виклик лише ci.sh/ci.bat), Повідомлення про помилку, Ідемпотентність.

10. <current_datetime>2026-11-19T16:35:07.884+02:00</current_datetime>

Створи .github/prompts/check.prompt.md.
Frontmatter: description, agent: build-engineer.
Режим: ТІЛЬКИ ЧИТАННЯ. Не створювати і не змінювати файли проєкту (тимчасові каталоги node_modules/ і dist/ дозволені, вони в .gitignore).
Виконати перевірки і вивести таблицю PASS/FAIL:
1. Існують .github/agents/build-engineer.agent.md і три SKILL.md.
2. Кожен skill має розділи Вхід, Вихід, Перевірки.
3. Існують src/hello.js, src/calculator.js, tests/basic.test.js, package.json, package-lock.json, scripts/build.js, ci.sh, ci.bat.
4. npm ci та npm run build проходять (збірка).
5. npm test проходить; у виводі Jest: Tests: 1 passed, 1 total (тест basicAddition passed).
6. Існує dist/hello.js і node dist/hello.js друкує Hello, World!.
7. ci.yml: валідний YAML, містить ubuntu-latest, windows-latest, macos-latest, у кроках run викликає лише ci.sh/ci.bat (без прямих команд npm/node).
8. git ls-files не містить node_modules/, dist/, build/, coverage/, .env, *.key, *.pem.
9. .gitignore містить node_modules/, dist/ і build/.
Якщо є хоча б один FAIL: вказати який саме і завершити зі статусом FAILED. Якщо все PASS: статус PASSED.
Додай розділи: Передумови, Повідомлення про помилку.

11. <current_datetime>2026-11-19T16:35:51.541+02:00</current_datetime>

Створи .github/prompts/init.prompt.md.
Frontmatter: description, agent: build-engineer.
Ти оркестратор. Виконуй кроки СТРОГО по порядку, читаючи і виконуючи інструкції з файлів:
1. .github/prompts/git-init.prompt.md
2. .github/prompts/create-project.prompt.md
3. .github/prompts/create-build.prompt.md
4. .github/prompts/create-actions.prompt.md
5. .github/prompts/check.prompt.md
Після кожного кроку перевіряй результат. Якщо крок завершився помилкою: ЗУПИНИСЬ, не виконуй наступні, виведи звіт (який крок, причина, що виправити). Не оголошуй успіх без PASSED від check.
Повторний запуск не повинен руйнувати чи дублювати наявні файли.
У кінці виведи таблицю: крок, статус, створені/змінені файли.
Додай розділи: Передумови, Очікувані файли, Повідомлення про помилку.

12. <current_datetime>2026-11-19T16:36:21.370+02:00</current_datetime>

Онови README.md (зараз там лише назва репозиторія, збережи її): ПІП [ПІП], група [група], варіант 3 (JavaScript, npm scripts, Jest), короткий опис проєкту, розділ "Запуск агента": відкрити папку у VS Code, відкрити Copilot Chat, вибрати агента build-engineer, виконати /init. Додай список commands. Залиш плейсхолдери для ПІП і групи.

13. <current_datetime>2026-11-19T16:37:26.240+02:00</current_datetime>

Онови README.md (зараз там лише назва репозиторія, збережи її): Чумак А.О. [ПІП], КІ-402 [група], варіант 3(21) (JavaScript, npm scripts, Jest), короткий опис проєкту, розділ "Запуск агента": відкрити папку у VS Code, відкрити Copilot Chat, вибрати агента build-engineer, виконати /init. Додай список commands. Залиш плейсхолдери для ПІП і групи.

14. <current_datetime>2026-11-19T16:37:48.383+02:00</current_datetime>

Створи docs/architecture.md з розділами:
1. Які проблеми вирішує агент.
2. Які skills використовує і за що вони відповідають.
3. Які commands доступні користувачу.
4. Які дані передаються між етапами (project_name -> src/ -> package.json + tests/ -> ci.sh/ci.bat -> ci.yml).
5. Як оркестратор init обробляє помилки.
6. Таблиця відповідності файлів ролям: agent -> .github/agents/, skills -> .github/skills/, commands -> .github/prompts/, тести Jest -> tests/, збірка -> scripts/build.js, CI -> ci.sh/ci.bat/.github/workflows/ci.yml.
7. Примітка, що використано формат VS Code Copilot (custom agents, prompt files, agent skills).
