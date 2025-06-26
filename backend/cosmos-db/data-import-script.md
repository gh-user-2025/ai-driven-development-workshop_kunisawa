# Cosmos DB データインポート用 Node.js スクリプト

## 概要

このドキュメントでは、Azure Cosmos DB へのデータインポートを自動化するNode.jsスクリプトの使用方法を説明します。

## 必要なパッケージのインストール

```bash
# プロジェクトの初期化
npm init -y

# 必要なパッケージのインストール
npm install @azure/cosmos faker moment
```

## 環境変数の設定

`.env` ファイルを作成して、Cosmos DB の接続情報を設定します：

```bash
# .env ファイルの内容
COSMOS_DB_ENDPOINT=https://factory-monitoring-cosmos.documents.azure.com:443/
COSMOS_DB_KEY=your-primary-key-here
COSMOS_DB_DATABASE_NAME=FactoryMonitoringDB
```

## データインポートスクリプトの実行

### 1. 設備データのインポート

```bash
# 設備マスターデータをインポート
node scripts/import-equipment-data.js
```

### 2. 時系列データの生成とインポート

```bash
# 過去30日分のセンサーデータを生成・インポート
node scripts/generate-sensor-data.js --days 30

# リアルタイムデータの継続生成（デモ用）
node scripts/realtime-data-generator.js
```

### 3. アラートデータのインポート

```bash
# サンプルアラートデータをインポート
node scripts/import-alerts.js
```

### 4. 保守記録データのインポート

```bash
# 保守記録データをインポート
node scripts/import-maintenance-records.js
```

## スクリプトファイルの説明

### package.json の設定例

```json
{
  "name": "factory-monitoring-data-import",
  "version": "1.0.0",
  "description": "Azure Cosmos DB データインポートツール",
  "main": "index.js",
  "scripts": {
    "import-all": "node scripts/import-all-data.js",
    "import-equipment": "node scripts/import-equipment-data.js",
    "generate-sensor-data": "node scripts/generate-sensor-data.js",
    "import-alerts": "node scripts/import-alerts.js",
    "import-maintenance": "node scripts/import-maintenance-records.js",
    "realtime-demo": "node scripts/realtime-data-generator.js"
  },
  "dependencies": {
    "@azure/cosmos": "^4.0.0",
    "faker": "^6.6.6",
    "moment": "^2.29.4",
    "dotenv": "^16.0.3"
  }
}
```

### 基本的なインポートスクリプトの構造

```javascript
// scripts/import-equipment-data.js の例
const { CosmosClient } = require('@azure/cosmos');
const fs = require('fs');
require('dotenv').config();

const client = new CosmosClient({
  endpoint: process.env.COSMOS_DB_ENDPOINT,
  key: process.env.COSMOS_DB_KEY
});

async function importEquipmentData() {
  try {
    const database = client.database(process.env.COSMOS_DB_DATABASE_NAME);
    const container = database.container('EquipmentData');
    
    // JSONファイルからデータを読み込み
    const equipmentData = JSON.parse(
      fs.readFileSync('../equipment-data.json', 'utf8')
    );
    
    // データを一括インポート
    for (const item of equipmentData) {
      const { resource } = await container.items.create(item);
      console.log(`設備データをインポートしました: ${resource.id}`);
    }
    
    console.log('設備データのインポートが完了しました。');
  } catch (error) {
    console.error('エラーが発生しました:', error);
  }
}

importEquipmentData();
```

### 時系列データ生成スクリプトの例

```javascript
// scripts/generate-sensor-data.js の例
const { CosmosClient } = require('@azure/cosmos');
const faker = require('faker');
const moment = require('moment');
require('dotenv').config();

// 設定
const SENSORS = [
  { id: '1', name: 'シリンダ温度センサー', baseValue: 225, variance: 15, unit: '℃' },
  { id: '5', name: 'プレス圧力センサー', baseValue: 32, variance: 5, unit: 'MPa' },
  { id: '9', name: '主軸回転数センサー', baseValue: 2200, variance: 300, unit: 'rpm' }
];

async function generateSensorData(days = 30) {
  const client = new CosmosClient({
    endpoint: process.env.COSMOS_DB_ENDPOINT,
    key: process.env.COSMOS_DB_KEY
  });
  
  const database = client.database(process.env.COSMOS_DB_DATABASE_NAME);
  const container = database.container('SensorTimeSeries');
  
  const startTime = moment().subtract(days, 'days');
  const endTime = moment();
  
  for (let sensor of SENSORS) {
    let currentTime = startTime.clone();
    
    while (currentTime.isBefore(endTime)) {
      // 稼働時間内のみデータを生成（平日8-17時、土曜8-12時）
      if (isOperatingHours(currentTime)) {
        const value = generateSensorValue(sensor);
        const quality = determineQuality(value, sensor);
        
        const dataPoint = {
          id: `sensor_${sensor.id}_${currentTime.format('YYYYMMDD_HHmmss')}`,
          sensorId: sensor.id,
          sensorName: sensor.name,
          timestamp: currentTime.toISOString(),
          value: value,
          unit: sensor.unit,
          quality: quality,
          ttl: 2592000 // 30日間で自動削除
        };
        
        await container.items.create(dataPoint);
      }
      
      currentTime.add(5, 'minutes'); // 5分間隔
    }
    
    console.log(`センサー ${sensor.name} のデータ生成完了`);
  }
}

function isOperatingHours(time) {
  const hour = time.hour();
  const dayOfWeek = time.day();
  
  if (dayOfWeek === 0) return false; // 日曜日は停止
  if (dayOfWeek === 6) return hour >= 8 && hour < 12; // 土曜日は8-12時
  return hour >= 8 && hour < 17; // 平日は8-17時
}

function generateSensorValue(sensor) {
  // 正規分布に近い値を生成
  const random = faker.datatype.float({ min: -1, max: 1 });
  return sensor.baseValue + (random * sensor.variance);
}

function determineQuality(value, sensor) {
  // 5%の確率で異常値、1%の確率で推定値
  const rand = Math.random();
  if (rand < 0.01) return '推定値';
  if (rand < 0.05) return '異常';
  return '正常';
}

// コマンドライン引数から日数を取得
const args = process.argv.slice(2);
const days = args.includes('--days') ? 
  parseInt(args[args.indexOf('--days') + 1]) : 30;

generateSensorData(days);
```

## データ検証とクリーンアップ

### 1. インポートデータの検証

```bash
# インポートされたデータの件数確認
node scripts/validate-import.js

# データ品質チェック
node scripts/data-quality-check.js
```

### 2. テストデータのクリーンアップ

```bash
# 全てのテストデータを削除
node scripts/cleanup-test-data.js

# 指定期間より古いデータを削除
node scripts/cleanup-old-data.js --days 30
```

### データ検証スクリプトの例

```javascript
// scripts/validate-import.js の例
async function validateImport() {
  const client = new CosmosClient({
    endpoint: process.env.COSMOS_DB_ENDPOINT,
    key: process.env.COSMOS_DB_KEY
  });
  
  const database = client.database(process.env.COSMOS_DB_DATABASE_NAME);
  
  // 各コンテナのアイテム数を確認
  const containers = ['EquipmentData', 'SensorTimeSeries', 'Alerts', 'MaintenanceRecords'];
  
  for (const containerName of containers) {
    const container = database.container(containerName);
    const { resources } = await container.items.query('SELECT VALUE COUNT(1) FROM c').fetchAll();
    console.log(`${containerName}: ${resources[0]} 件`);
  }
}
```

## 継続的なデータ生成

### リアルタイムデータシミュレーター

```javascript
// scripts/realtime-data-generator.js の例
setInterval(async () => {
  // 5分ごとに新しいセンサーデータを生成
  await generateRealtimeData();
}, 5 * 60 * 1000);

async function generateRealtimeData() {
  // 現在時刻でのセンサーデータを生成
  const now = moment();
  
  for (let sensor of SENSORS) {
    if (isOperatingHours(now)) {
      const dataPoint = createDataPoint(sensor, now);
      await insertDataPoint(dataPoint);
      
      // 異常値の場合はアラートも生成
      if (dataPoint.quality === '異常') {
        await generateAlert(sensor, dataPoint);
      }
    }
  }
}
```

## トラブルシューティング

### よくあるエラーと対処法

1. **認証エラー**
   ```
   Error: Forbidden (403)
   ```
   - Cosmos DB のキーが正しいか確認
   - エンドポイントURLが正しいか確認

2. **スループット不足エラー**
   ```
   Error: Request rate is large (429)
   ```
   - RU (Request Unit) を増やす
   - バッチサイズを小さくする

3. **パーティション関連エラー**
   ```
   Error: Partition key not found
   ```
   - パーティションキーが正しく設定されているか確認

### デバッグ用スクリプト

```javascript
// scripts/debug-connection.js
async function testConnection() {
  try {
    const client = new CosmosClient({
      endpoint: process.env.COSMOS_DB_ENDPOINT,
      key: process.env.COSMOS_DB_KEY
    });
    
    const { resource } = await client.database(process.env.COSMOS_DB_DATABASE_NAME).read();
    console.log('接続成功:', resource.id);
  } catch (error) {
    console.error('接続エラー:', error.message);
  }
}
```

## パフォーマンス最適化

### バッチ処理の実装

```javascript
// 大量データの効率的なインポート
async function batchImport(items, batchSize = 100) {
  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize);
    const promises = batch.map(item => container.items.create(item));
    
    try {
      await Promise.all(promises);
      console.log(`バッチ ${Math.floor(i/batchSize) + 1} 完了`);
    } catch (error) {
      console.error(`バッチ処理エラー:`, error);
    }
  }
}
```

## 本番環境での注意事項

1. **環境変数の管理**
   - Azure Key Vault の使用を推奨
   - .env ファイルをソース管理に含めない

2. **エラーハンドリング**
   - リトライロジックの実装
   - 適切なログ出力

3. **監視**
   - データインポートの成功/失敗監視
   - RU消費量の監視