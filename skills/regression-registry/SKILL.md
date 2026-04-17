---
name: regression-registry
description: Формат и методика ведения реестра регрессии. Используется qa-regression для отслеживания "что уже проверено и работает".
---

# Регрессионный реестр

## Назначение

Реестр — это журнал "что мы проверили и подтвердили, что работает". Он нужен, чтобы:
1. При повторных аудитах не тестировать заново всё с нуля.
2. Знать, какой функционал мог пострадать после изменений.
3. Иметь историю: когда что работало, когда сломалось.

## Расположение

В корне тестируемого проекта: `.qa/regression-registry.json`

## Формат

```json
{
  "version": "1.0",
  "project": "название",
  "last_updated": "2026-04-17T14:30:00Z",
  "entries": [
    {
      "id": "reg-001",
      "feature": "Регистрация нового пользователя",
      "description": "Регистрация с email/пароль, подтверждение через ссылку",
      "scenario": {
        "preconditions": "Очищенные cookies, неавторизованный пользователь",
        "steps": [
          "Открыть /signup",
          "Заполнить email, пароль",
          "Нажать 'Зарегистрироваться'",
          "Подтвердить по ссылке в email"
        ],
        "expected": "Пользователь залогинен и видит /dashboard"
      },
      "critical_paths": [
        "Форма регистрации",
        "Email верификация",
        "Первый логин"
      ],
      "affected_files": [
        "src/features/auth/SignupForm.tsx",
        "src/api/routes/auth.ts",
        "src/services/email.ts"
      ],
      "last_verified": "2026-04-15T10:30:00Z",
      "verified_in_iteration": 2,
      "tested_by": "qa-functional",
      "status": "passing",
      "history": [
        {
          "date": "2026-04-10",
          "status": "passing",
          "iteration": 1
        },
        {
          "date": "2026-04-15",
          "status": "passing",
          "iteration": 2
        }
      ],
      "notes": "Работает стабильно. Тестовые email: test+N@example.com"
    }
  ]
}
```

## Поля

| Поле | Обязательное | Описание |
|------|--------------|----------|
| `id` | да | Уникальный идентификатор записи (reg-NNN) |
| `feature` | да | Короткое имя фичи |
| `description` | да | Что делает фича |
| `scenario.preconditions` | да | Начальные условия |
| `scenario.steps` | да | Шаги тестирования |
| `scenario.expected` | да | Ожидаемый результат |
| `critical_paths` | рекомендуется | Под-компоненты фичи |
| `affected_files` | рекомендуется | Файлы, где реализовано |
| `last_verified` | да | ISO 8601 timestamp |
| `verified_in_iteration` | да | Номер итерации аудита |
| `tested_by` | да | Какой агент проверял |
| `status` | да | `passing` / `failing` / `blocked` / `outdated` |
| `history` | да | Журнал проверок |
| `notes` | нет | Доп. контекст |

## Статусы

- **`passing`** — работает, проверено
- **`failing`** — сломано, есть активный bug-report
- **`blocked`** — не смогли проверить (нет окружения, нет данных)
- **`outdated`** — >30 дней без проверки, требует ревалидации

## Как использовать

### При первом QA-аудите

`qa-regression` создаёт реестр с нуля:
1. Изучает `QA_BRIEF.md` → выделяет критичные фичи
2. После прогона `qa-functional` и других — фиксирует passing-результаты в реестре
3. Сохраняет `.qa/regression-registry.json`

### При повторных аудитах

1. Читает существующий реестр
2. Определяет, какие фичи могли пострадать:
   - По `affected_files` vs `git diff` последних изменений
   - По давности (`last_verified` > 14 дней)
3. Прогоняет повторно затронутые и устаревшие
4. Обновляет `status` и `history`
5. Сохраняет

### При фиксе багов

Когда разработчик фиксит баг:
- Если баг был регрессией → обновить `status` соответствующей записи
- Если фикс — новая проверенная работа → создать новую запись в реестре

## Приоритизация проверок

При ограниченном времени на прогон регрессии:

1. **P1 — обязательные:**
   - Все записи с `critical_paths` в зоне `affected_files` текущего git diff
   - Все записи со статусом `blocked` из прошлой итерации
   
2. **P2 — важные:**
   - Записи с `last_verified` > 14 дней
   - Записи, связанные с только что зафикшенными багами
   
3. **P3 — по возможности:**
   - Остальные passing

## Автоматизация

На будущее — возможная автоматизация:

```javascript
// .qa/detect-affected.js
// Скрипт, который по git diff определяет затронутые записи реестра

const diff = execSync('git diff --name-only HEAD~1').toString().split('\n');
const registry = JSON.parse(fs.readFileSync('.qa/regression-registry.json'));

const affected = registry.entries.filter(e =>
  e.affected_files.some(f => diff.includes(f))
);

console.log(`Затронуто записей: ${affected.length}`);
console.log(affected.map(e => `- ${e.feature}`).join('\n'));
```

## Пример полного реестра

```json
{
  "version": "1.0",
  "project": "Discript Main App",
  "last_updated": "2026-04-17T14:30:00Z",
  "entries": [
    {
      "id": "reg-001",
      "feature": "Регистрация пользователя",
      "status": "passing",
      "last_verified": "2026-04-17T10:00:00Z",
      "tested_by": "qa-functional"
    },
    {
      "id": "reg-002",
      "feature": "Оформление заказа",
      "status": "failing",
      "last_verified": "2026-04-17T11:00:00Z",
      "tested_by": "qa-functional",
      "notes": "Бэг B-042: падает при сумме >10000"
    }
  ]
}
```
