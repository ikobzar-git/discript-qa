---
name: test-data-fixtures
description: Набор тестовых данных для разных сценариев — пользователи, карты, файлы, граничные значения. Используется всеми QA-агентами.
---

# Тестовые данные (фикстуры)

## Тестовые пользователи

### Email для регистрации

```
# Обычные email
test@example.com
user.name@example.com
qa-test+01@company.com
qa-test+02@company.com
...

# С плюс-нотацией (можно плодить много на одном ящике)
realaddress+test001@gmail.com
realaddress+test002@gmail.com

# Disposable email для временных тестов
test@mailinator.com
test@10minutemail.com
(ВНИМАНИЕ: не все сервисы их принимают — это может быть частью теста)

# Кириллица в email
пример@почта.рф
user@кириллица.рус

# Длинные email
very.long.email.address.with.many.dots.for.testing.limits@long-domain-name-for-testing.example.com

# Email с спецсимволами
user.name+tag-2024_test@example.com
```

### Пароли

```
# Валидные
TestPass123!
SecureP@ssword2024
correct horse battery staple

# На границе требований
Ab1!ab1! (8 символов с разными типами)

# Невалидные (для тестов валидации)
123456 (слишком короткий)
password (без цифр и спецсимволов)
12345678 (только цифры)
PASSWORD (только верхний регистр)

# Пароли с спецсимволами
Pass!@#$%^&*()_+-=[]{}|;:',.<>?/~`

# Unicode пароли (если поддерживается)
Пароль123!
密码123!
```

### Имена

```
# Обычные
Иван Иванов
Анна Смирнова
John Doe

# С дефисом
Анна-Мария
Мария-Тереза Иванова-Петрова

# С апострофом
O'Brien
D'Angelo

# Длинные
Мухаммад Ибрагим Абдул-Рахман Аль-Хусейни

# Одно слово
Мадонна
Cher

# С цифрами (часто валидация запрещает)
User123 (проверить — разрешено ли)

# С эмодзи
Иван 🔥 (проверить — разрешено ли)

# Только пробелы (должно отклоняться)
"   "

# Очень длинное
"А" × 300 символов
```

### Телефоны (RU формат)

```
# Валидные
+7 (999) 123-45-67
89991234567
+79991234567
8 999 123 45 67

# На грани
+7 999 000 0000 (все нули после кода оператора)

# Невалидные
+7 (999) 123-45 (короткий)
abc123 (буквы)
+1 555 123 4567 (другая страна — может быть валидным, может нет)

# Международные
+1 (555) 123-4567
+44 20 7946 0958
+86 138 0000 0000
```

## Платёжные карты

### Stripe test cards

```
# Успех
4242 4242 4242 4242

# Требуется 3DS
4000 0027 6000 3184

# Отказ банка (недостаточно средств)
4000 0000 0000 9995

# Карта потеряна
4000 0000 0000 9987

# Обработка занимает время (для тестирования async)
4000 0000 0000 0077

# Карта истекла
4000 0000 0000 0069
```

### ЮKassa test cards

```
# Успешный платёж
5555 5555 5555 4444

# Отказ
5555 5555 5555 4477 (ошибка)

# 3DS
5555 5555 5555 4499

# Страница подтверждения
5555 5555 5555 4412
```

### CVV / срок

- Любое будущее значение срока
- Любые 3 цифры CVV (например, 123)

## Даты

```
# Граничные
1900-01-01 — очень старая
1970-01-01 — Unix epoch
2000-01-01 — Y2K
2038-01-19 — Y2K38 (int32 переполнение в Unix timestamp)
9999-12-31 — максимум большинства систем

# Невисокосные годы с 29 февраля
2023-02-29 (несуществует → должно отклоняться)

# Переход на летнее время (зависит от региона)
2026-03-30 02:30 UTC+3

# Високосный
2024-02-29 — валидная

# Часовые пояса
2026-04-17T00:00:00+12:00 vs 2026-04-16T12:00:00Z
(одна и та же точка во времени)
```

## Числа

```
# Граничные
0
-1
1
-0.01
0.001
0.1 + 0.2 (= 0.30000000000000004, floating point)

# Очень большие
9007199254740991 (Number.MAX_SAFE_INTEGER)
9007199254740992 (превышает safe integer)
Number.MAX_VALUE
Number.MIN_VALUE
Infinity
-Infinity

# Невалидные
NaN
"123" (строка, а не число)
null
undefined

# Научная нотация
1e10
1e-10
1.5e+308

# Формат записи
1,000,000 (запятая как разделитель тысяч)
1.000.000 (точка как разделитель тысяч)
1 000 000 (пробел)
```

## Текст

### Unicode и спецсимволы

```
# Эмодзи
🔥 🚀 ❤️ 👨‍👩‍👧‍👦 (сложные составные эмодзи)

# Разные алфавиты
Кириллица: Привет мир
Арабский (RTL): مرحبا بالعالم
Иврит (RTL): שלום עולם
Китайский: 你好世界
Японский: こんにちは世界
Корейский: 안녕하세요

# Zalgo text (ломает высоту строк)
H̷̡̠͈̼e̶̢͘l̷̛͠͝l̴̨͒o̸͜

# Zero-width characters
Hello[ZWSP]World (Zero-Width Space: U+200B)
```

### Потенциальные инъекции (для security-тестов)

```
# XSS
<script>alert('XSS')</script>
<img src=x onerror="alert('XSS')">
<svg onload="alert(1)">
javascript:alert(1)
"><script>alert(1)</script>
';alert(1);//

# SQL injection
' OR '1'='1
'; DROP TABLE users; --
' UNION SELECT * FROM passwords --
admin'--
' OR 1=1#

# NoSQL injection
{"$ne": null}
{"$gt": ""}
{"$where": "this.password == ''"}

# Path traversal
../../etc/passwd
..\..\..\windows\system32\cmd.exe
%2e%2e/%2e%2e/etc/passwd

# SSTI
{{7*7}}
${7*7}
#{7*7}
<%= 7*7 %>

# Command injection
; ls -la
| cat /etc/passwd
` whoami `
$(whoami)

# LDAP injection
*)(uid=*))(|(uid=*
```

## Файлы

### Изображения

```
# Нормальные
test-image.jpg (100KB)
test-image.png (500KB)
test-image.webp (200KB)

# Граничные размеры
tiny.jpg (1KB)
exact-limit.jpg (ровно на границе лимита, например 5MB)
over-limit.jpg (5MB + 1KB)
huge.jpg (50MB)

# Битые файлы
corrupted.jpg (скопировать и обрезать файл)
fake.jpg (текстовый файл с расширением .jpg)

# Двойное расширение
image.jpg.exe
document.pdf.php

# Имена
file with spaces.jpg
файл с кириллицей.jpg
文件.jpg (китайский)
very-long-filename-that-might-exceed-fs-limits...jpg (255+ символов)

# Спецсимволы в имени
file'with'quotes.jpg
file<tag>.jpg
file/with/slashes.jpg (на Windows — проблема)
```

### Документы

```
# PDF
test.pdf (валидный)
empty.pdf (пустой)
password-protected.pdf
scanned.pdf (только изображения, без текста)

# Office
test.docx
test.xlsx
test.pptx

# Архивы
test.zip
test.tar.gz

# Исполняемые (должны отклоняться)
test.exe
test.sh
test.bat
```

## HTTP тест-данные

### Заголовки

```
# User-Agent для разных устройств
Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) ...
Mozilla/5.0 (Linux; Android 13) ...
Mozilla/5.0 (Windows NT 10.0; Win64; x64) ...
Googlebot/2.1 (+http://www.google.com/bot.html)

# Referer
https://google.com/search?q=...
https://ads.example.com/promo (для трекинга)
"" (пустой)

# Accept-Language
ru, en;q=0.9
zh-CN, zh;q=0.9, en;q=0.8
```

### Cookies и Storage

Полезно иметь:
- Пустой браузер (инкогнито)
- Браузер с десятками cookies (тест производительности)
- Браузер с истёкшими cookies
- Браузер с поломанными JSON в localStorage

## Сеть

### Эмуляция условий

```
# Chrome DevTools Network throttling presets
Fast 3G: 1.5Mb/s down, 750Kb/s up, 40ms latency
Slow 3G: 400Kb/s down, 400Kb/s up, 2000ms latency
Offline
```

### Тестовые URL

```
# Внешние (для тестов redirect, SSRF)
https://example.com (валидный)
https://httpbin.org (для разных HTTP-сценариев)
http://169.254.169.254/ (AWS metadata — НЕ ДОЛЖНО быть доступно из пользовательских полей)
http://localhost:8080 (локальный — SSRF-тест)
http://[::1]/ (IPv6 localhost)
```

## Использование

В каждом QA-аудите:
1. Создать `.qa/fixtures/` в тестируемом проекте
2. Скопировать нужные данные из этого skill
3. Адаптировать под проект (свои тестовые email, свои продукты)
4. Ссылаться на них в bug-report-ах как "см. .qa/fixtures/XXX"
