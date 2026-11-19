402CSAD21

# Лабораторна робота

- Чумак А.О. [ПІП]
- КІ-402 [група]
- Варіант: 3(21) (JavaScript, npm scripts, Jest)

## Опис проєкту

Цей репозиторій містить інструкції AI-агента для VS Code Copilot, який
генерує кросплатформний JavaScript/Node.js проєкт Hello World. Агент створює
npm scripts, юніт-тест Jest і CI на GitHub Actions для Windows, Linux та
macOS.

## Запуск агента

1. Відкрити папку репозиторію у VS Code.
2. Відкрити Copilot Chat.
3. Вибрати агента `build-engineer`.
4. Виконати команду `/init`.

## Commands

- `git-init` — перевірити Git-репозиторій і створити або доповнити `.gitignore`.
- `create-project` — створити початкову структуру JavaScript/Node.js проєкту.
- `create-build` — налаштувати npm, Jest, збірку та локальні CI-скрипти.
- `create-actions` — створити workflow GitHub Actions для трьох операційних
  систем.
- `check` — виконати повну перевірку інструкцій і згенерованого проєкту.
- `init` — послідовно виконати всі команди та завершити перевіркою.