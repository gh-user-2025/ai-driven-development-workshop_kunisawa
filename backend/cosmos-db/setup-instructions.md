# Azure Cosmos DB NoSQL API セットアップとデータインポート手順書

## 概要

本文書では、工場設備稼働監視システム用のAzure Cosmos DB NoSQL APIのインスタンス作成からサンプルデータのインポートまでの詳細な手順を説明します。

## 前提条件

- Azure CLI がインストールされていること
- Azureサブスクリプションへのアクセス権があること
- 必要に応じてリソースグループが作成済みであること

## 1. Azure Cosmos DB インスタンスの作成

### 1.1 Azure CLIでのログイン

```bash
# Azureにログイン
az login

# 使用するサブスクリプションを設定（必要に応じて）
az account set --subscription "your-subscription-id"
```

### 1.2 リソースグループの作成（既存のものを使用する場合はスキップ）

```bash
# リソースグループの作成
az group create \
  --name factory-monitoring-rg \
  --location japaneast
```

### 1.3 Azure Cosmos DB アカウントの作成

```bash
# Cosmos DB アカウントの作成（NoSQL API）
az cosmosdb create \
  --name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --location japaneast \
  --kind GlobalDocumentDB \
  --default-consistency-level Session \
  --enable-automatic-failover true \
  --enable-multiple-write-locations false
```

### 1.4 Cosmos DB データベースの作成

```bash
# データベースの作成
az cosmosdb sql database create \
  --account-name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --name FactoryMonitoringDB \
  --throughput 400
```

### 1.5 コンテナの作成

```bash
# 設備監視データ用コンテナ
az cosmosdb sql container create \
  --account-name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --database-name FactoryMonitoringDB \
  --name EquipmentData \
  --partition-key-path "/factoryId" \
  --throughput 400

# センサーデータ用コンテナ（時系列データ）
az cosmosdb sql container create \
  --account-name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --database-name FactoryMonitoringDB \
  --name SensorTimeSeries \
  --partition-key-path "/sensorId" \
  --throughput 1000

# アラートデータ用コンテナ
az cosmosdb sql container create \
  --account-name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --database-name FactoryMonitoringDB \
  --name Alerts \
  --partition-key-path "/factoryId" \
  --throughput 400

# 保守記録用コンテナ
az cosmosdb sql container create \
  --account-name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --database-name FactoryMonitoringDB \
  --name MaintenanceRecords \
  --partition-key-path "/equipmentId" \
  --throughput 400
```

## 2. 接続文字列の取得

```bash
# 接続文字列の取得
az cosmosdb keys list \
  --name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --type connection-strings
```

## 3. サンプルデータの準備

### 3.1 必要なツールのインストール

```bash
# Node.js がインストールされていない場合
# Ubuntu/Debian
sudo apt update
sudo apt install nodejs npm

# CentOS/RHEL
sudo yum install nodejs npm

# macOS (Homebrew)
brew install node

# Azure Cosmos DB Data Migration Tool のインストール
npm install -g dt-cosmos
```

### 3.2 サンプルデータファイルの確認

作成されるサンプルデータファイル：
- `equipment-data.json` - 設備マスターデータ
- `sensor-timeseries-sample.json` - センサー時系列データサンプル
- `alerts-sample.json` - アラートデータサンプル
- `maintenance-records-sample.json` - 保守記録データサンプル

## 4. データインポートの実行

### 4.1 Azure Data Factoryを使用したインポート（推奨）

```bash
# Data Factory の作成
az datafactory create \
  --resource-group factory-monitoring-rg \
  --factory-name factory-monitoring-df \
  --location japaneast

# Data Factory と Cosmos DB のリンクサービス作成
# ※ 実際のリンクサービス作成はポータルまたはARM テンプレートを使用
```

### 4.2 Azure CLI を使用した直接インポート

```bash
# 設備データのインポート
az cosmosdb sql container import \
  --account-name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --database-name FactoryMonitoringDB \
  --container-name EquipmentData \
  --src equipment-data.json

# センサーデータのインポート
az cosmosdb sql container import \
  --account-name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --database-name FactoryMonitoringDB \
  --container-name SensorTimeSeries \
  --src sensor-timeseries-sample.json

# アラートデータのインポート
az cosmosdb sql container import \
  --account-name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --database-name FactoryMonitoringDB \
  --container-name Alerts \
  --src alerts-sample.json

# 保守記録データのインポート
az cosmosdb sql container import \
  --account-name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --database-name FactoryMonitoringDB \
  --container-name MaintenanceRecords \
  --src maintenance-records-sample.json
```

### 4.3 プログラムによるデータ投入（Node.js）

```bash
# 必要なパッケージのインストール
npm init -y
npm install @azure/cosmos faker moment

# データ投入スクリプトの実行
node data-import-script.js
```

## 5. データの確認と検証

### 5.1 Azure ポータルでの確認

1. Azure ポータル (https://portal.azure.com) にアクセス
2. Cosmos DB アカウント "factory-monitoring-cosmos" を選択
3. データエクスプローラーでデータを確認

### 5.2 Azure CLI でのデータ確認

```bash
# コンテナ内のアイテム数確認
az cosmosdb sql container show \
  --account-name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --database-name FactoryMonitoringDB \
  --name EquipmentData
```

### 5.3 クエリによるデータ確認

```bash
# サンプルクエリの実行
az cosmosdb sql query \
  --account-name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --database-name FactoryMonitoringDB \
  --container-name EquipmentData \
  --query "SELECT * FROM c WHERE c.factoryId = '1'"
```

## 6. パフォーマンス最適化

### 6.1 RU (Request Unit) の調整

```bash
# 本番環境ではスループットを調整
az cosmosdb sql container throughput update \
  --account-name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --database-name FactoryMonitoringDB \
  --name SensorTimeSeries \
  --throughput 2000
```

### 6.2 インデックスポリシーの最適化

```bash
# カスタムインデックスポリシーの適用（JSONファイルで定義）
az cosmosdb sql container update \
  --account-name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --database-name FactoryMonitoringDB \
  --name SensorTimeSeries \
  --idx-policy @sensor-index-policy.json
```

## 7. セキュリティ設定

### 7.1 ファイアウォール設定

```bash
# 特定のIPアドレスからのアクセスを許可
az cosmosdb update \
  --name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --ip-range-filter "203.0.113.0/24,198.51.100.0/24"
```

### 7.2 仮想ネットワーク統合

```bash
# VNetサービスエンドポイントの設定
az cosmosdb update \
  --name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --enable-virtual-network true \
  --virtual-network-rules "/subscriptions/your-subscription-id/resourceGroups/factory-monitoring-rg/providers/Microsoft.Network/virtualNetworks/factory-vnet/subnets/cosmos-subnet"
```

## 8. 監視とログ設定

### 8.1 診断設定の有効化

```bash
# Log Analytics ワークスペースの作成
az monitor log-analytics workspace create \
  --resource-group factory-monitoring-rg \
  --workspace-name factory-monitoring-logs \
  --location japaneast

# 診断設定の作成
az monitor diagnostic-settings create \
  --name cosmos-diagnostics \
  --resource factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --resource-type Microsoft.DocumentDB/databaseAccounts \
  --workspace factory-monitoring-logs \
  --logs '[{"category": "QueryRuntimeStatistics", "enabled": true}, {"category": "PartitionKeyStatistics", "enabled": true}]' \
  --metrics '[{"category": "Requests", "enabled": true}]'
```

## 9. バックアップと復旧

### 9.1 自動バックアップの確認

```bash
# バックアップポリシーの確認
az cosmosdb show \
  --name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --query backupPolicy
```

### 9.2 ポイントインタイム復旧の有効化

```bash
# 継続バックアップの有効化（ポイントインタイム復旧用）
az cosmosdb update \
  --name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --backup-policy-type Continuous
```

## 10. コスト最適化

### 10.1 自動スケーリングの設定

```bash
# 自動スケーリングの有効化
az cosmosdb sql container throughput update \
  --account-name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --database-name FactoryMonitoringDB \
  --name SensorTimeSeries \
  --max-throughput 4000
```

### 10.2 TTL（Time To Live）の設定

```bash
# 古いセンサーデータの自動削除設定
az cosmosdb sql container update \
  --account-name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --database-name FactoryMonitoringDB \
  --name SensorTimeSeries \
  --ttl 2592000  # 30日（秒単位）
```

## トラブルシューティング

### よくある問題と解決方法

1. **接続エラー**
   - ファイアウォール設定を確認
   - 接続文字列が正しいか確認

2. **パフォーマンス問題**
   - RU消費量を監視
   - パーティションキーの分散を確認

3. **データインポートエラー**
   - JSONフォーマットを確認
   - パーティションキーが正しく設定されているか確認

## 参考リンク

- [Azure Cosmos DB ドキュメント](https://docs.microsoft.com/azure/cosmos-db/)
- [Azure CLI リファレンス](https://docs.microsoft.com/cli/azure/cosmosdb)
- [Cosmos DB ベストプラクティス](https://docs.microsoft.com/azure/cosmos-db/best-practice-java)