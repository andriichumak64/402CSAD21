---
name: build-and-test
description: Застосовуй для налаштування npm, Jest, кросплатформної збірки та локальних CI-скриптів JavaScript/Node.js проєкту після створення src-файлів.
---

# Build and Test

## Вхід

Перед початком перевір, що існують:

- `src/hello.js`;
- `src/calculator.js`.

Також перевір версії інструментів командами `node -v` і `npm -v`. Для цього
skill потрібен Node.js 20 або новіший і доступний npm. Якщо Node.js або npm
не знайдено, зупинись і повідом причину.

## Вихід

Створи або безпечно онови такі об'єкти:

- `package.json`;
- `package-lock.json`;
- `scripts/build.js`;
- `tests/basic.test.js`;
- `ci.sh`;
- `ci.bat`.

### `package.json`

Файл має містити такі значення:

```json
{
  "name": "hello",
  "version": "1.0.0",
  "private": true,
  "main": "src/hello.js",
  "engines": {
    "node": ">=20"
  },
  "scripts": {
    "start": "node src/hello.js",
    "test": "jest",
    "build": "node scripts/build.js"
  },
  "devDependencies": {
    "jest": "29.7.0"
  },
  "jest": {
    "testEnvironment": "node"
  }
}
```

Якщо `package.json` уже існує, прочитай його та злий потрібні поля без
перезапису непов'язаних налаштувань. Не дублюй scripts або devDependencies.
Зберігай наявні сумісні поля, а конфліктні зміни покажи перед застосуванням.

### `package-lock.json`

Згенеруй lock-файл командою:

```bash
npm install
```

Не пиши `package-lock.json` вручну. Перед `npm install` перевір зміни в
`package.json`, а після команди переконайся, що lock-файл існує.

### `scripts/build.js`

Створи кросплатформний Node.js-скрипт, який:

1. імпортує модуль `fs` та потрібні засоби роботи зі шляхами;
2. створює каталог `dist/`, включно з батьківськими каталогами;
3. копіює `src/hello.js` у `dist/hello.js`;
4. копіює `src/calculator.js` у `dist/calculator.js`;
5. завершується з ненульовим кодом, якщо будь-яка операція завершується
   помилкою.

Не використовуй shell-команди `cp`, `copy` або залежність від роздільників
шляхів конкретної операційної системи. Помилку виводь у stderr і не приховуй.

### `tests/basic.test.js`

Створи Jest-тест із назвою `basicAddition`. Імпортуй `add` із
`../src/calculator` та перевір:

```js
expect(add(2, 3)).toBe(5);
```

### `ci.sh`

Створи Bash-скрипт, який:

1. містить shebang для Bash;
2. використовує `set -euo pipefail`;
3. переходить у каталог самого скрипта;
4. послідовно виконує `npm ci`, `npm test`, `npm run build`;
5. після збірки перевіряє існування `dist/hello.js`;
6. завершується з ненульовим кодом при будь-якій помилці.

Шлях до каталогу скрипта визначай кросплатформно для Bash, а не через
поточний робочий каталог. Після створення зроби файл виконуваним:

```bash
git update-index --chmod=+x ci.sh
```

### `ci.bat`

Створи Windows Batch-скрипт, який:

1. переходить у каталог самого скрипта через `cd /d "%~dp0"`;
2. виконує послідовно `npm ci`, `npm test`, `npm run build`;
3. використовує `call` перед кожною командою npm;
4. перевіряє `%errorlevel%` після кожної команди;
5. після збірки перевіряє, що `dist/hello.js` існує;
6. завершується з ненульовим кодом при будь-якій помилці.

Не покладайся лише на `set /e`: кожен виклик npm має мати явну перевірку
`%errorlevel%`.

## Правила

- Не перезаписуй наявні файли без перевірки їхнього вмісту.
- Для `package.json` зливай зміни, а не перезаписуй файл.
- Не дублюй scripts, devDependencies, Jest-поля або CI-кроки під час
  повторного запуску.
- Не створюй `package-lock.json` вручну.
- Не замінюй кросплатформні Node.js-операції shell-командами.
- Якщо наявний файл відрізняється від очікуваного та безпечне злиття неможливе,
  повідом про конфлікт і не перезаписуй його.
- Перед завершенням покажи diff і список змінених файлів.

## Перевірки

Виконай перевірки в такому порядку:

1. `node -v` підтверджує Node.js 20 або новіший.
2. `npm -v` підтверджує доступність npm.
3. `npm ci` завершується без помилок і використовує наявний
   `package-lock.json`.
4. `npm test` виводить:

   ```text
   Tests:       1 passed, 1 total
   ```

5. `npm run build` створює `dist/hello.js`.
6. `node dist/hello.js` друкує рівно `Hello, World!`.
7. `ci.sh` має виконуваний режим Git.
8. `ci.bat` містить `call` перед кожним викликом npm і перевірку
   `%errorlevel%` після нього.

## Типові помилки

- Якщо Node.js 20 або npm не знайдено, перевір `node -v` і `npm -v`, покажи
  причину та зупинись.
- Якщо у `ci.bat` пропущено `call` перед npm, виправ це до завершення.
  Без `call` Batch-скрипт може обірватися після першого виклику.
- Якщо немає `package-lock.json`, `npm ci` впаде. Спочатку виконай `npm
  install`, а потім повтори перевірки.
- Якщо збірка не створила `dist/hello.js`, вважай роботу невдалою та покажи
  помилку.

## Приклад

### Вхід

```text
src/hello.js і src/calculator.js існують
language=JavaScript
project_name=hello
```

### Очікуваний результат

```text
Створено або безпечно оновлено package.json, package-lock.json,
scripts/build.js, tests/basic.test.js, ci.sh і ci.bat.
Jest: Tests:       1 passed, 1 total
dist/hello.js існує.
node dist/hello.js -> Hello, World!
ci.sh має виконуваний режим Git.
```
