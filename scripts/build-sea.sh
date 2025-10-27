#!/bin/bash
set -e

# Определяем платформу и архитектуру
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Преобразуем архитектуру в формат Node.js
case "$ARCH" in
    x86_64) ARCH="x64" ;;
    aarch64|arm64) ARCH="arm64" ;;
esac

# Определяем имя выходного файла
if [ "$PLATFORM" = "darwin" ]; then
    OUTPUT_NAME="overpass2geojson-macos-${ARCH}"
else
    OUTPUT_NAME="overpass2geojson-linux-${ARCH}"
fi

echo "🔨 Building Node.js SEA for $PLATFORM $ARCH..."
echo "   Output: $OUTPUT_NAME"
echo ""

# 1. Сборка с rspack
echo "📦 Step 1: Building with rspack..."
yarn build

# 2. Генерация blob
echo ""
echo "🗜️  Step 2: Generating SEA blob..."
node --experimental-sea-config sea-config.json

# 3. Копирование Node.js binary
echo ""
echo "📋 Step 3: Copying Node.js binary..."

# Ищем настоящий бинарный файл Node.js
NODE_PATH=$(which node)

# Если это скрипт, ищем настоящий binary
if file "$NODE_PATH" | grep -q "script"; then
    echo "   Detected wrapper script, searching for real binary..."
    # Пробуем найти через process substitution
    NODE_PATH=$(node -e "console.log(process.execPath)")
fi

echo "   Using Node.js binary: $NODE_PATH"

# Проверяем что это действительно бинарный файл
if ! file "$NODE_PATH" | grep -q "Mach-O\|ELF"; then
    echo "   ❌ Error: Not a valid binary file"
    file "$NODE_PATH"
    exit 1
fi

cp "$NODE_PATH" "$OUTPUT_NAME"

# 4. Удаление подписи (только для macOS)
if [ "$PLATFORM" = "darwin" ]; then
    echo ""
    echo "🔓 Step 4: Removing signature (macOS)..."
    codesign --remove-signature "$OUTPUT_NAME" 2>/dev/null || echo "   ⚠️  Warning: Could not remove signature"
else
    echo ""
    echo "⏭️  Step 4: Skipping signature removal (not macOS)..."
fi

# 5. Инжект blob в binary
echo ""
echo "💉 Step 5: Injecting SEA blob into binary..."
if [ "$PLATFORM" = "darwin" ]; then
    npx postject "$OUTPUT_NAME" NODE_SEA_BLOB sea-prep.blob \
        --sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2 \
        --macho-segment-name NODE_SEA
else
    npx postject "$OUTPUT_NAME" NODE_SEA_BLOB sea-prep.blob \
        --sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2
fi

# 6. Подпись binary (только для macOS)
if [ "$PLATFORM" = "darwin" ]; then
    echo ""
    echo "🔐 Step 6: Signing binary (macOS)..."
    codesign --sign - "$OUTPUT_NAME" 2>/dev/null || echo "   ⚠️  Warning: Could not sign binary"
else
    echo ""
    echo "⏭️  Step 6: Skipping signing (not macOS)..."
fi

# 7. Установка прав на выполнение
echo ""
echo "🔧 Step 7: Setting executable permissions..."
chmod +x "$OUTPUT_NAME"

# 8. Очистка
echo ""
echo "🧹 Step 8: Cleaning up..."
rm -f sea-prep.blob

echo ""
echo "✅ Done! Executable created: ./$OUTPUT_NAME"
ls -lh "$OUTPUT_NAME" | awk '{print "   Size: " $5}'

echo ""
echo "📝 To test the executable:"
echo "   ./$OUTPUT_NAME"
