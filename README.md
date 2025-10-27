
Простое интерактивное CLI-приложение на TypeScript для конвертации данных из Overpass API (OpenStreetMap) в формат GeoJSON.

## Возможности

- 📝 Интерактивный ввод Overpass QL запросов
- 🔄 Автоматические повторные попытки (до 3 раз) при ошибках
- 💾 Сохранение всех этапов обработки (запрос → ответ → GeoJSON)
- 🪟 Кроссплатформенность (Windows, Mac, Linux)
- 📂 Автоматическая организация результатов с временными метками
- 📦 Возможность сборки в standalone executable (SEA)

## Быстрый старт

### Установка

```bash
npm install
```

### Разработка

```bash
# Сборка проекта
npm run build

# Запуск собранной версии
npm run dev

# Или сборка и запуск одной командой
npm start
```

### Запуск готового исполняемого файла

После сборки SEA (см. ниже) можно запускать напрямую:

```bash
# Mac/Linux
./overpass2geojson

# Windows
overpass2geojson.exe
```

### Ввод запроса

Скрипт поддерживает несколько способов завершения ввода:

- **Mac/Linux**: `Ctrl+D`
- **Windows**: `Ctrl+Z` + `Enter`
- **Универсально**: введите `END` на новой строке

## Пример использования

```bash
$ npm run fetch

📝 Введите Overpass QL запрос
   Для завершения ввода: Ctrl+D или введите строку "END" и нажмите Enter

[out:json][timeout:90];
(
  node["amenity"="restaurant"](55.7,37.5,55.8,37.7);
);
out geom;
END

✅ Запрос получен

📁 Папка для результатов: results/2025-10-27T17-35-46-155Z
✅ Запрос сохранен
🚀 Отправка запроса к Overpass API... (попытка 1/3)

✅ Оригинальный ответ сохранен
📊 Получено элементов OSM: 250
🔄 Конвертация в GeoJSON...
✅ GeoJSON сохранен

🎉 Готово!
```

## Структура результатов

Все файлы автоматически сохраняются в папке `results/` с временной меткой:

```
results/
└── 2025-10-27T17-35-46-155Z/
    ├── query.txt           # Исходный Overpass QL запрос
    ├── response.json       # Оригинальный ответ от API
    └── result.geojson      # Преобразованный GeoJSON
```

## Примеры запросов

### Рестораны в Москве
```
[out:json][timeout:90];
(
  node["amenity"="restaurant"](55.7,37.5,55.8,37.7);
);
out geom;
```

### Автомагистрали
```
[out:json][timeout:900];
(
  way["highway"="motorway"](35.48,105.78,46.35,131.90);
);
(._;>;);
out geom;
```

### Водоемы
```
[out:json][timeout:90];
(
  way["natural"="water"](55.0,37.0,56.0,38.0);
  relation["natural"="water"](55.0,37.0,56.0,38.0);
);
out geom;
```

## Обработка ошибок

Скрипт автоматически повторяет неудачные запросы до 3 раз с паузой 2 секунды между попытками.

```
🚀 Отправка запроса к Overpass API... (попытка 1/3)
❌ Ошибка запроса: ECONNRESET

⏳ Повторная попытка через 2 секунд...

🚀 Отправка запроса к Overpass API... (попытка 2/3)
✅ Успешно!
```

## Сборка Standalone версии (SEA)

Вы можете создать полностью самостоятельный исполняемый файл, который не требует установки Node.js:

### Windows
```cmd
build-sea.bat
```
Создаст `overpass2geojson.exe` (~105 MB)

### Mac / Linux
```bash
./build-sea.sh
```
Создаст `overpass2geojson` (~105 MB)

Подробнее: [BUILD-SEA.md](BUILD-SEA.md)

## Документация

- [USAGE.md](USAGE.md) - Подробная инструкция по использованию
- [BUILD-SEA.md](BUILD-SEA.md) - Сборка standalone версии

## Технологии

- **TypeScript** - типизированная разработка
- **Rsbuild** - быстрая сборка с Rspack
- [osmtogeojson](https://www.npmjs.com/package/osmtogeojson) - конвертация OSM в GeoJSON
- [postject](https://github.com/nodejs/postject) - внедрение JavaScript в executable (dev)

## Требования

- Node.js 20+ (для разработки и сборки)
- Для запуска собранного SEA executable Node.js не требуется!

## Структура проекта

```
.
├── src/
│   └── index.ts          # Основной TypeScript код
├── dist/                 # Собранные файлы (генерируется)
│   └── overpass2geojson-bundle.cjs
├── results/              # Результаты запросов (генерируется)
├── rsbuild.config.mjs    # Конфигурация сборки
├── tsconfig.json         # Конфигурация TypeScript
└── sea-config.json       # Конфигурация SEA
```

## Лицензия

ISC
