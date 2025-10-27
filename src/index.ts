import https from 'https';
import fs from 'fs';
import path from 'path';
import readline from 'readline';
import osmtogeojson from 'osmtogeojson';

const MAX_RETRIES = 3;
const RETRY_DELAY = 2000; // 2 секунды

interface HTTPSRequestOptions {
  hostname: string;
  path: string;
  method: string;
  headers: {
    'Content-Type': string;
    'Content-Length': number;
    'Accept': string;
    'User-Agent': string;
    'Origin': string;
    'Referer': string;
  };
}

/**
 * Функция для чтения многострочного ввода
 */
function readMultilineInput(): Promise<string> {
  return new Promise((resolve) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    console.log('📝 Введите Overpass QL запрос (нажмите Ctrl+D для завершения ввода):\n');

    const lines: string[] = [];

    rl.on('line', (line: string) => {
      lines.push(line);
    });

    rl.on('close', () => {
      resolve(lines.join('\n'));
    });
  });
}

/**
 * Функция задержки для retry
 */
function delay(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Основная функция выполнения запроса
 */
async function fetchAndConvert(overpassQuery: string, attempt: number = 1): Promise<void> {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const outputDir = path.join(__dirname, 'results', timestamp);

  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  console.log(`\n📁 Папка для результатов: ${outputDir}`);

  // Сохраняем запрос
  const queryPath = path.join(outputDir, 'query.txt');
  fs.writeFileSync(queryPath, overpassQuery, 'utf8');
  console.log(`✅ Запрос сохранен: ${queryPath}`);

  // Подготовка данных для POST запроса
  const postData = `data=${encodeURIComponent(overpassQuery)}`;

  const options: HTTPSRequestOptions = {
    hostname: 'overpass-api.de',
    path: '/api/interpreter',
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'Content-Length': Buffer.byteLength(postData),
      'Accept': '*/*',
      'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
      'Origin': 'https://overpass-turbo.eu',
      'Referer': 'https://overpass-turbo.eu/'
    }
  };

  console.log(`🚀 Отправка запроса к Overpass API... (попытка ${attempt}/${MAX_RETRIES})\n`);

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';

      res.on('data', (chunk: Buffer) => {
        data += chunk.toString();
      });

      res.on('end', async () => {
        try {
          // Проверяем статус ответа
          if (res.statusCode !== 200) {
            throw new Error(`HTTP ${res.statusCode}: ${data}`);
          }

          // Сохраняем оригинальный ответ
          const responsePath = path.join(outputDir, 'response.json');
          fs.writeFileSync(responsePath, data, 'utf8');
          console.log(`✅ Оригинальный ответ сохранен: ${responsePath}`);

          // Парсим JSON
          const osmData = JSON.parse(data);
          console.log(`📊 Получено элементов OSM: ${osmData.elements ? osmData.elements.length : 0}`);

          // Конвертируем в GeoJSON
          console.log('🔄 Конвертация в GeoJSON...');
          const geojson = osmtogeojson(osmData);

          // Сохраняем GeoJSON
          const geojsonPath = path.join(outputDir, 'result.geojson');
          fs.writeFileSync(geojsonPath, JSON.stringify(geojson, null, 2), 'utf8');
          console.log(`✅ GeoJSON сохранен: ${geojsonPath}`);

          console.log('\n🎉 Готово!');
          console.log(`📂 Все файлы в папке: ${outputDir}`);
          console.log(`   - query.txt (запрос)`);
          console.log(`   - response.json (оригинальный ответ)`);
          console.log(`   - result.geojson (преобразованный GeoJSON)`);

          resolve();
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : String(error);
          console.error(`❌ Ошибка обработки данных: ${errorMessage}`);
          reject(error);
        }
      });
    });

    req.on('error', (error: Error) => {
      console.error(`❌ Ошибка запроса: ${error.message}`);
      reject(error);
    });

    req.write(postData);
    req.end();
  });
}

/**
 * Главная функция с retry логикой
 */
async function main(): Promise<void> {
  try {
    // Получаем запрос от пользователя
    const overpassQuery = await readMultilineInput();

    if (!overpassQuery.trim()) {
      console.error('❌ Запрос не может быть пустым!');
      process.exit(1);
    }

    console.log('\n✅ Запрос получен\n');

    // Пытаемся выполнить запрос с retry
    for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
      try {
        await fetchAndConvert(overpassQuery, attempt);
        break; // Успех - выходим из цикла
      } catch (error) {
        if (attempt < MAX_RETRIES) {
          console.log(`\n⏳ Повторная попытка через ${RETRY_DELAY / 1000} секунд...\n`);
          await delay(RETRY_DELAY);
        } else {
          console.error(`\n❌ Не удалось выполнить запрос после ${MAX_RETRIES} попыток`);
          process.exit(1);
        }
      }
    }
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    console.error('❌ Критическая ошибка:', errorMessage);
    process.exit(1);
  }
}

// Запускаем программу
main();
