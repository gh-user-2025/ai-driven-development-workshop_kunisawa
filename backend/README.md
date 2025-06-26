# 工場設備稼働監視システム - バックエンド実装

## 概要

本プロジェクトは、工場設備稼働監視システムのバックエンド機能を実装するものです。Azure SQL DatabaseとAzure Cosmos DB NoSQL APIを使用したデータ管理機能を提供します。

## 実装内容

### 1. データモデル設計 ✅
- 工場設備監視システムに必要な7つのテーブル設計
- リレーション関係の定義
- インデックス設計とパフォーマンス最適化

### 2. サンプルデータ作成 ✅
- 日本語による現実的なサンプルデータ
- 3つの工場、14台の設備、18個のセンサー
- 時系列データ、アラート、保守記録を含む

### 3. Azure SQL Database実装 ✅
- テーブル作成SQL文
- サンプルデータ登録SQL文
- インデックス、トリガー、ビューの作成

### 4. Azure Cosmos DB NoSQL API実装 ✅
- コンテナ設計（パーティション分割戦略）
- JSONドキュメント形式のサンプルデータ
- 詳細なセットアップ手順書

## ディレクトリ構成

```
backend/
├── docs/
│   └── data-model.md                    # データモデル設計書
├── sql/
│   ├── 01_create_tables.sql            # Azure SQL Database テーブル作成SQL
│   └── 02_insert_sample_data.sql       # サンプルデータ登録SQL
├── sample-data/
│   └── sample-data-specification.md    # サンプルデータ仕様書
├── cosmos-db/
│   ├── setup-instructions.md           # Cosmos DB セットアップ手順書
│   ├── equipment-data.json             # 設備マスターデータ
│   ├── sensor-timeseries-sample.json   # センサー時系列データ
│   ├── alerts-sample.json              # アラートデータ
│   └── maintenance-records-sample.json # 保守記録データ
└── README.md                           # このファイル
```

## Azure SQL Database セットアップ手順

### 1. Azure環境の準備

```bash
# 1. Azureログイン
az login

# 2. リソースグループの作成
az group create --name factory-monitoring-rg --location japaneast

# 3. Azure SQL Serverの作成
az sql server create \
  --name factory-monitoring-sql \
  --resource-group factory-monitoring-rg \
  --location japaneast \
  --admin-user sqladmin \
  --admin-password <強力なパスワード>

# 4. Azure SQL Databaseの作成
az sql db create \
  --resource-group factory-monitoring-rg \
  --server factory-monitoring-sql \
  --name factory-monitoring-db \
  --service-objective S2
```

### 2. ファイアウォール設定

```bash
# クライアントIPからのアクセスを許可
az sql server firewall-rule create \
  --resource-group factory-monitoring-rg \
  --server factory-monitoring-sql \
  --name AllowClientIP \
  --start-ip-address <クライアントIP> \
  --end-ip-address <クライアントIP>

# Azureサービスからのアクセスを許可
az sql server firewall-rule create \
  --resource-group factory-monitoring-rg \
  --server factory-monitoring-sql \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

### 3. データベーススキーマの作成

```bash
# SQL Server Management Studio (SSMS) または Azure Data Studio を使用
# または sqlcmd を使用したコマンドライン実行

sqlcmd -S factory-monitoring-sql.database.windows.net \
  -d factory-monitoring-db \
  -U sqladmin \
  -P <パスワード> \
  -i sql/01_create_tables.sql
```

### 4. サンプルデータの投入

```bash
# サンプルデータの登録
sqlcmd -S factory-monitoring-sql.database.windows.net \
  -d factory-monitoring-db \
  -U sqladmin \
  -P <パスワード> \
  -i sql/02_insert_sample_data.sql
```

## Azure Cosmos DB セットアップ手順

詳細な手順は [`cosmos-db/setup-instructions.md`](cosmos-db/setup-instructions.md) を参照してください。

### 簡易セットアップ

```bash
# 1. Cosmos DB アカウントの作成
az cosmosdb create \
  --name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --location japaneast \
  --kind GlobalDocumentDB

# 2. データベースの作成
az cosmosdb sql database create \
  --account-name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --name FactoryMonitoringDB \
  --throughput 400

# 3. コンテナの作成（設備データ用）
az cosmosdb sql container create \
  --account-name factory-monitoring-cosmos \
  --resource-group factory-monitoring-rg \
  --database-name FactoryMonitoringDB \
  --name EquipmentData \
  --partition-key-path "/factoryId" \
  --throughput 400
```

## データ構造の概要

### Azure SQL Database テーブル

1. **Factories** - 工場マスター
2. **Equipment** - 設備マスター
3. **Sensors** - センサーマスター
4. **SensorData** - センサー時系列データ
5. **Alerts** - アラート情報
6. **MaintenanceRecords** - 保守記録
7. **Users** - ユーザー情報

### Azure Cosmos DB コンテナ

1. **EquipmentData** - 設備とセンサーの統合データ
2. **SensorTimeSeries** - センサー時系列データ（TTL付き）
3. **Alerts** - アラート情報
4. **MaintenanceRecords** - 保守記録

## サンプルデータの特徴

### 工場構成
- **東京第一工場** - 射出成形、プレス加工中心
- **大阪製造工場** - 精密加工、溶接作業中心
- **名古屋技術センター** - 試作開発、品質管理中心

### センサーデータ
- 5分間隔での測定データ
- 正常値95%、異常値4%、推定値1%の分布
- 稼働時間を考慮した現実的なパターン

### アラート機能
- 警告、異常、故障の3段階
- 重要度：低、中、高、緊急の4レベル
- 確認・解決フローの実装

## 使用技術

### データベース
- **Azure SQL Database v12** - リレーショナルデータ
- **Azure Cosmos DB NoSQL API** - ドキュメントデータ

### 開発ツール
- **Azure CLI** - インフラ構築
- **SQL Server Management Studio (SSMS)** - SQL管理
- **Azure Data Studio** - クロスプラットフォームSQL管理

## セキュリティ対策

### Azure SQL Database
- 管理者アカウントの強力なパスワード設定
- ファイアウォールによるIP制限
- Azure Active Directory認証（推奨）

### Azure Cosmos DB
- アクセスキーの適切な管理
- VNetサービスエンドポイント
- ロールベースアクセス制御（RBAC）

## 監視とロギング

### Azure Monitor
- SQL Databaseのパフォーマンス監視
- Cosmos DBのRU消費量監視
- アラート設定

### Log Analytics
- クエリパフォーマンスの分析
- 異常なアクセスパターンの検出

## パフォーマンス最適化

### Azure SQL Database
- 時系列データ用の最適化されたインデックス
- パーティション分割戦略
- 自動チューニングの活用

### Azure Cosmos DB
- 適切なパーティションキーの選択
- RU（Request Unit）の最適化
- TTLによる古いデータの自動削除

## 運用・保守

### バックアップ戦略
- SQL Database: 自動バックアップ + 長期保管
- Cosmos DB: 継続バックアップでポイントインタイム復旧

### コスト最適化
- 自動スケーリングの設定
- 未使用時間帯のスループット調整
- リザーブドキャパシティの活用

## トラブルシューティング

### よくある問題
1. **接続エラー** - ファイアウォール設定を確認
2. **パフォーマンス低下** - インデックス使用状況を確認
3. **容量不足** - データ保持ポリシーを見直し

### ログ確認方法
```bash
# SQL Databaseの接続状況確認
az sql db show-connection-string \
  --client sqlcmd \
  --name factory-monitoring-db \
  --server factory-monitoring-sql

# Cosmos DBのメトリクス確認
az monitor metrics list \
  --resource factory-monitoring-cosmos \
  --metric "TotalRequests"
```

## 参考資料

- [Azure SQL Database ドキュメント](https://docs.microsoft.com/azure/azure-sql/)
- [Azure Cosmos DB ドキュメント](https://docs.microsoft.com/azure/cosmos-db/)
- [データモデル設計書](docs/data-model.md)
- [Cosmos DB セットアップ手順](cosmos-db/setup-instructions.md)