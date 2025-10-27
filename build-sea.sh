#!/bin/bash

set -e

echo "🔨 Building SEA (Single Executable Application)..."
echo ""

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Проверяем версию Node.js
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 20 ]; then
    echo "❌ Требуется Node.js версии 20 или выше"
    echo "   Текущая версия: $(node -v)"
    exit 1
fi

echo -e "${BLUE}1/6${NC} Создание бандла с rsbuild..."
npm run build

echo -e "${BLUE}2/6${NC} Генерация blob файла..."
node --experimental-sea-config sea-config.json

echo -e "${BLUE}3/6${NC} Копирование Node.js binary..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    cp $(command -v node) overpass2geojson
    OUTPUT_NAME="overpass2geojson"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    cp $(command -v node) overpass2geojson
    OUTPUT_NAME="overpass2geojson"
else
    echo "❌ Неизвестная платформа: $OSTYPE"
    exit 1
fi

echo -e "${BLUE}4/6${NC} Удаление signature (если есть)..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    codesign --remove-signature overpass2geojson 2>/dev/null || true
fi

echo -e "${BLUE}5/6${NC} Внедрение blob в исполняемый файл..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    npx postject overpass2geojson NODE_SEA_BLOB sea-prep.blob \
        --sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2 \
        --macho-segment-name NODE_SEA
else
    # Linux
    npx postject overpass2geojson NODE_SEA_BLOB sea-prep.blob \
        --sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2
fi

echo -e "${BLUE}6/6${NC} Подписание исполняемого файла..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    codesign --sign - overpass2geojson
fi

echo ""
echo -e "${GREEN}✅ Сборка завершена!${NC}"
echo ""
echo "Исполняемый файл: ./$OUTPUT_NAME"
echo ""
echo "Для запуска:"
echo "  ./$OUTPUT_NAME"
echo ""

# Показываем размер файла
FILE_SIZE=$(du -h "$OUTPUT_NAME" | cut -f1)
echo "Размер: $FILE_SIZE"
