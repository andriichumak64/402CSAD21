---
description: Налаштувати npm, Jest, кросплатформну збірку та локальні CI-скрипти проєкту hello за правилами build-and-test.
agent: build-engineer
---

# Create Build

## Передумови

- Існують `src/hello.js` і `src/calculator.js`.
- Встановлено Node.js 20 або новішої версії.
- Доступний npm.
- Перед змінами перевір поточний стан робочого дерева.
- Прочитай `.github/skills/build-and-test/SKILL.md` перед виконанням.
- Не перезаписуй наявні файли без перевірки їхнього вмісту.

Перевір інструменти командами:

```bash
node -v
npm -v
```

## Дії

1. Переконайся, що `node -v` показує Node.js 20 або новішої версії, а
   `npm -v` завершується успішно.
2. Виконай інструкції зі skill
   `.github/skills/build-and-test/SKILL.md`.
3. Дотримуйся всіх вимог skill до `package.json`, lock-файла, build-скрипта,
   Jest-тесту, `ci.sh` і `ci.bat`.
4. Для наявного `package.json` виконай безпечне злиття потрібних scripts,
   devDependencies і Jest-конфігурації без дублювання або перезапису
   непов'язаних полів.
5. Створи `package-lock.json` лише командою `npm install`.
6. Зроби `ci.sh` виконуваним відповідно до інструкцій skill.
7. Перед завершенням покажи diff і список змінених файлів.

## Очікувані файли

Після успішного виконання існують:

- `package.json`;
- `package-lock.json`;
- `scripts/build.js`;
- `tests/basic.test.js`;
- `ci.sh`;
- `ci.bat`.

Тести мають містити `basicAddition`, а build-скрипт має створювати
`dist/hello.js` і `dist/calculator.js`.

## Команди перевірки

Виконай команди в такому порядку:

```bash
node -v
npm -v
npm install
npm test
npm run build
node dist/hello.js
```

Переконайся, що:

- Jest виводить `Tests:       1 passed, 1 total`;
- існує `dist/hello.js`;
- `node dist/hello.js` друкує рівно `Hello, World!`;
- `package-lock.json` існує, щоб `npm ci` міг працювати;
- `ci.sh` має виконуваний режим Git;
- `ci.bat` містить `call` перед кожною командою npm та перевіряє
  `%errorlevel%`.

Після створення lock-файла додатково перевір:

```bash
npm ci
```

## Повідомлення про помилку

Якщо Node.js 20 або npm не знайдено, покажи вивід `node -v` і `npm -v`,
повідом причину та зупинись.

Якщо відсутні `src/hello.js` або `src/calculator.js`, не створюй build/test
артефакти цим prompt; покажи відсутній шлях і зупинись.

Якщо `npm install`, `npm ci`, `npm test`, `npm run build` або
`node dist/hello.js` завершується з помилкою, покажи команду та її вивід.
Не приховуй помилку й не вважай роботу успішною.

Якщо наявний файл має несумісний вміст і безпечне злиття неможливе, покажи
конфлікт і не перезаписуй файл.

## Ідемпотентність

- Повторний запуск не дублює scripts, devDependencies, Jest-поля або CI-кроки.
- Наявні файли спочатку перевіряються та не перезаписуються без безпечного
  злиття.
- `package-lock.json` не редагується вручну.
- Повторний запуск не додає дублікати у файли або Git-індекс.
- Після успішного повторного запуску не виникає зайвого diff.
