# 工場設備管理システム - Azure インフラストラクチャ設定手順

## 概要

このドキュメントでは、工場設備管理システムをAzureクラウド上にデプロイするための詳細な手順を説明します。
Azure初心者の方でも実行できるよう、各ステップを詳細に記述しています。

## 前提条件

- Azureアカウントが作成済みであること
- Azure CLIがインストール済みであること
- 適切な権限（リソース作成権限）を持っていること

## 1. Azure環境の初期設定

### 1.1 Azure CLIでのログイン

```bash
# Azureアカウントにログイン
az login

# 利用可能なサブスクリプション一覧を表示
az account list --output table

# 使用するサブスクリプションを設定（必要に応じて）
az account set --subscription "サブスクリプション名またはID"
```

### 1.2 リソースグループの作成

```bash
# リソースグループの作成
az group create \
    --name rg-factory-equipment \
    --location japaneast \
    --tags environment=demo project=factory-management
```

## 2. Azure SQL Databaseの設定

### 2.1 SQL Serverの作成

```bash
# SQLサーバーの作成
az sql server create \
    --name sql-factory-equipment-server \
    --resource-group rg-factory-equipment \
    --location japaneast \
    --admin-user sqladmin \
    --admin-password "P@ssw0rd2024!"
```

### 2.2 ファイアウォール規則の設定

```bash
# Azure サービスのアクセスを許可
az sql server firewall-rule create \
    --resource-group rg-factory-equipment \
    --server sql-factory-equipment-server \
    --name AllowAzureServices \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

# 開発環境からのアクセスを許可（IPアドレスは適宜変更）
az sql server firewall-rule create \
    --resource-group rg-factory-equipment \
    --server sql-factory-equipment-server \
    --name AllowDevelopmentAccess \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 255.255.255.255
```

### 2.3 SQL Databaseの作成

```bash
# SQLデータベースの作成
az sql db create \
    --resource-group rg-factory-equipment \
    --server sql-factory-equipment-server \
    --name db-factory-equipment \
    --service-objective Basic \
    --max-size 2GB
```

## 3. Azure Cosmos DBの設定

### 3.1 Cosmos DBアカウントの作成

```bash
# Cosmos DBアカウントの作成
az cosmosdb create \
    --name cosmos-factory-equipment \
    --resource-group rg-factory-equipment \
    --location japaneast \
    --kind GlobalDocumentDB \
    --default-consistency-level Session \
    --enable-automatic-failover false
```

### 3.2 データベースとコンテナの作成

```bash
# データベースの作成
az cosmosdb sql database create \
    --account-name cosmos-factory-equipment \
    --resource-group rg-factory-equipment \
    --name SensorData

# コンテナの作成（IoTデータ用）
az cosmosdb sql container create \
    --account-name cosmos-factory-equipment \
    --resource-group rg-factory-equipment \
    --database-name SensorData \
    --name EquipmentSensors \
    --partition-key-path "/equipmentId" \
    --throughput 400
```

## 4. Azure Functionsの設定

### 4.1 Storage Accountの作成

```bash
# Storage Accountの作成（Functions用）
az storage account create \
    --name stfactoryequipment \
    --resource-group rg-factory-equipment \
    --location japaneast \
    --sku Standard_LRS \
    --kind StorageV2
```

### 4.2 Function Appの作成

```bash
# Function Appの作成
az functionapp create \
    --resource-group rg-factory-equipment \
    --consumption-plan-location japaneast \
    --runtime python \
    --runtime-version 3.9 \
    --functions-version 4 \
    --name func-factory-equipment \
    --storage-account stfactoryequipment \
    --os-type Linux
```

### 4.3 Application Settingsの設定

```bash
# Cosmos DB接続文字列の取得
COSMOS_CONNECTION_STRING=$(az cosmosdb keys list \
    --name cosmos-factory-equipment \
    --resource-group rg-factory-equipment \
    --type connection-strings \
    --query "connectionStrings[0].connectionString" \
    --output tsv)

# SQL Database接続文字列の作成
SQL_CONNECTION_STRING="Server=tcp:sql-factory-equipment-server.database.windows.net,1433;Initial Catalog=db-factory-equipment;Persist Security Info=False;User ID=sqladmin;Password=P@ssw0rd2024!;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

# Function Appに環境変数を設定
az functionapp config appsettings set \
    --name func-factory-equipment \
    --resource-group rg-factory-equipment \
    --settings \
    "CosmosDBConnectionString=$COSMOS_CONNECTION_STRING" \
    "SQLConnectionString=$SQL_CONNECTION_STRING"
```

## 5. Power BIの設定準備

### 5.1 Power BI Premium容量の準備

Power BIについては、Azure PortalまたはPower BI管理センターから設定を行います。

```bash
# Power BI Embedded の作成（オプション）
az powerbi embedded-capacity create \
    --resource-group rg-factory-equipment \
    --name pbi-factory-equipment \
    --location japaneast \
    --sku A1 \
    --administrator "your-email@domain.com"
```

## 6. IoT Hubの設定（オプション）

### 6.1 IoT Hubの作成

```bash
# IoT Hubの作成
az iot hub create \
    --resource-group rg-factory-equipment \
    --name iot-factory-equipment \
    --location japaneast \
    --sku S1 \
    --partition-count 4
```

### 6.2 IoTデバイスの登録

```bash
# IoTデバイスの作成（例：成型機A-1）
az iot hub device-identity create \
    --hub-name iot-factory-equipment \
    --device-id equipment-EQ001 \
    --edge-enabled false

# デバイス接続文字列の取得
az iot hub device-identity connection-string show \
    --hub-name iot-factory-equipment \
    --device-id equipment-EQ001 \
    --output table
```

## 7. ネットワークセキュリティの設定

### 7.1 Virtual Networkの作成（オプション）

```bash
# Virtual Networkの作成
az network vnet create \
    --resource-group rg-factory-equipment \
    --name vnet-factory-equipment \
    --location japaneast \
    --address-prefix 10.0.0.0/16 \
    --subnet-name subnet-services \
    --subnet-prefix 10.0.1.0/24
```

## 8. 設定の確認

### 8.1 作成されたリソースの確認

```bash
# リソースグループ内のリソース一覧表示
az resource list \
    --resource-group rg-factory-equipment \
    --output table
```

### 8.2 接続文字列とキーの取得

```bash
# Cosmos DB プライマリキーの取得
az cosmosdb keys list \
    --name cosmos-factory-equipment \
    --resource-group rg-factory-equipment \
    --query primaryMasterKey \
    --output tsv

# Storage Account 接続文字列の取得
az storage account show-connection-string \
    --name stfactoryequipment \
    --resource-group rg-factory-equipment \
    --query connectionString \
    --output tsv
```

## 9. クリーンアップ手順

プロジェクト終了時には、以下のコマンドでリソースを削除できます：

```bash
# リソースグループ全体の削除
az group delete \
    --name rg-factory-equipment \
    --yes \
    --no-wait
```

## 注意事項

1. **セキュリティ**: 本手順では開発・デモ用の設定となっています。本番環境では適切なセキュリティ設定を行ってください。
2. **コスト**: 作成したリソースは使用に応じて課金されます。不要な場合は適時削除してください。
3. **リージョン**: 本手順では Japan East リージョンを使用していますが、必要に応じて変更してください。
4. **命名規則**: リソース名は一意である必要があります。必要に応じて末尾に数字等を追加してください。

## 次のステップ

1. Azure Functions にデータ処理ロジックをデプロイ
2. Power BI でダッシュボードを作成
3. Vue.js アプリケーションをAzure Static Web Apps にデプロイ
4. IoTデバイスシミュレータの実装