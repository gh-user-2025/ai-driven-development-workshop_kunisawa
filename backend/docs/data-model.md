# 工場設備稼働監視システム データモデル設計書

## 概要

本文書は、工場設備稼働監視システムで使用するデータモデルの設計について記述します。

## データモデル構成

### 1. 工場 (Factories)

工場の基本情報を管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| factory_id | INT | PRIMARY KEY, IDENTITY | 工場ID（自動採番） |
| factory_name | NVARCHAR(100) | NOT NULL | 工場名 |
| location | NVARCHAR(200) | NOT NULL | 所在地 |
| contact_person | NVARCHAR(50) | NULL | 担当者名 |
| phone_number | NVARCHAR(20) | NULL | 電話番号 |
| created_at | DATETIME2 | DEFAULT GETDATE() | 作成日時 |
| updated_at | DATETIME2 | DEFAULT GETDATE() | 更新日時 |

### 2. 設備 (Equipment)

工場内の生産設備情報を管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| equipment_id | INT | PRIMARY KEY, IDENTITY | 設備ID（自動採番） |
| factory_id | INT | FOREIGN KEY | 工場ID |
| equipment_name | NVARCHAR(100) | NOT NULL | 設備名 |
| equipment_type | NVARCHAR(50) | NOT NULL | 設備種別 |
| model_number | NVARCHAR(50) | NULL | 型番 |
| manufacturer | NVARCHAR(100) | NULL | メーカー名 |
| installation_date | DATE | NULL | 設置日 |
| status | NVARCHAR(20) | DEFAULT '稼働中' | 状態（稼働中/停止中/メンテナンス中） |
| created_at | DATETIME2 | DEFAULT GETDATE() | 作成日時 |
| updated_at | DATETIME2 | DEFAULT GETDATE() | 更新日時 |

### 3. センサー (Sensors)

設備に設置されたセンサーの情報を管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| sensor_id | INT | PRIMARY KEY, IDENTITY | センサーID（自動採番） |
| equipment_id | INT | FOREIGN KEY | 設備ID |
| sensor_name | NVARCHAR(100) | NOT NULL | センサー名 |
| sensor_type | NVARCHAR(50) | NOT NULL | センサー種別（温度/圧力/振動/電流等） |
| unit | NVARCHAR(20) | NOT NULL | 単位 |
| min_value | DECIMAL(10,2) | NULL | 最小値 |
| max_value | DECIMAL(10,2) | NULL | 最大値 |
| warning_threshold | DECIMAL(10,2) | NULL | 警告閾値 |
| alert_threshold | DECIMAL(10,2) | NULL | アラート閾値 |
| location | NVARCHAR(100) | NULL | 設置場所 |
| status | NVARCHAR(20) | DEFAULT '正常' | 状態（正常/異常/メンテナンス中） |
| created_at | DATETIME2 | DEFAULT GETDATE() | 作成日時 |
| updated_at | DATETIME2 | DEFAULT GETDATE() | 更新日時 |

### 4. センサーデータ (SensorData)

センサーから収集された時系列データを管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| data_id | BIGINT | PRIMARY KEY, IDENTITY | データID（自動採番） |
| sensor_id | INT | FOREIGN KEY | センサーID |
| value | DECIMAL(10,2) | NOT NULL | 測定値 |
| timestamp | DATETIME2 | NOT NULL | 測定日時 |
| quality | NVARCHAR(20) | DEFAULT '正常' | データ品質（正常/異常/推定値） |

### 5. アラート (Alerts)

システムで発生したアラート情報を管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| alert_id | INT | PRIMARY KEY, IDENTITY | アラートID（自動採番） |
| sensor_id | INT | FOREIGN KEY | センサーID |
| alert_type | NVARCHAR(20) | NOT NULL | アラート種別（警告/異常/故障） |
| severity | NVARCHAR(20) | NOT NULL | 重要度（低/中/高/緊急） |
| message | NVARCHAR(500) | NOT NULL | アラートメッセージ |
| threshold_value | DECIMAL(10,2) | NULL | 閾値 |
| actual_value | DECIMAL(10,2) | NULL | 実測値 |
| occurred_at | DATETIME2 | NOT NULL | 発生日時 |
| acknowledged_at | DATETIME2 | NULL | 確認日時 |
| resolved_at | DATETIME2 | NULL | 解決日時 |
| status | NVARCHAR(20) | DEFAULT '未確認' | 状態（未確認/確認済み/解決済み） |

### 6. 保守記録 (MaintenanceRecords)

設備の保守・メンテナンス履歴を管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| maintenance_id | INT | PRIMARY KEY, IDENTITY | 保守記録ID（自動採番） |
| equipment_id | INT | FOREIGN KEY | 設備ID |
| maintenance_type | NVARCHAR(50) | NOT NULL | 保守種別（定期点検/緊急修理/部品交換等） |
| description | NVARCHAR(1000) | NOT NULL | 作業内容 |
| technician_name | NVARCHAR(50) | NOT NULL | 作業者名 |
| start_time | DATETIME2 | NOT NULL | 開始日時 |
| end_time | DATETIME2 | NULL | 終了日時 |
| cost | DECIMAL(10,2) | NULL | 費用 |
| parts_used | NVARCHAR(500) | NULL | 使用部品 |
| status | NVARCHAR(20) | DEFAULT '作業中' | 状態（予定/作業中/完了） |
| created_at | DATETIME2 | DEFAULT GETDATE() | 作成日時 |

### 7. ユーザー (Users)

システム利用者の情報を管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| user_id | INT | PRIMARY KEY, IDENTITY | ユーザーID（自動採番） |
| username | NVARCHAR(50) | UNIQUE, NOT NULL | ユーザー名 |
| email | NVARCHAR(100) | UNIQUE, NOT NULL | メールアドレス |
| full_name | NVARCHAR(100) | NOT NULL | 氏名 |
| role | NVARCHAR(20) | NOT NULL | 役割（管理者/オペレータ/閲覧者） |
| factory_id | INT | FOREIGN KEY | 所属工場ID |
| phone_number | NVARCHAR(20) | NULL | 電話番号 |
| last_login | DATETIME2 | NULL | 最終ログイン日時 |
| is_active | BIT | DEFAULT 1 | アクティブフラグ |
| created_at | DATETIME2 | DEFAULT GETDATE() | 作成日時 |
| updated_at | DATETIME2 | DEFAULT GETDATE() | 更新日時 |

## リレーション関係

```
Factories (1) ←→ (N) Equipment
Equipment (1) ←→ (N) Sensors
Sensors (1) ←→ (N) SensorData
Sensors (1) ←→ (N) Alerts
Equipment (1) ←→ (N) MaintenanceRecords
Factories (1) ←→ (N) Users
```

## インデックス設計

### パフォーマンス向上のための推奨インデックス

1. **SensorData テーブル**
   - `IX_SensorData_SensorId_Timestamp` (sensor_id, timestamp DESC)
   - `IX_SensorData_Timestamp` (timestamp DESC)

2. **Alerts テーブル**
   - `IX_Alerts_SensorId_OccurredAt` (sensor_id, occurred_at DESC)
   - `IX_Alerts_Status_Severity` (status, severity)

3. **Sensors テーブル**
   - `IX_Sensors_EquipmentId` (equipment_id)
   - `IX_Sensors_Type` (sensor_type)

4. **Equipment テーブル**
   - `IX_Equipment_FactoryId` (factory_id)
   - `IX_Equipment_Status` (status)

## データ保持ポリシー

### センサーデータ
- **リアルタイムデータ**: 直近1ヶ月分をAzure SQL Databaseに保持
- **履歴データ**: 1ヶ月以上古いデータはAzure Data Lakeに移行
- **集約データ**: 時間別、日別、月別の集約データを別途保存

### アラートデータ
- **アクティブアラート**: 無期限保持
- **解決済みアラート**: 2年間保持後アーカイブ

### 保守記録
- 全記録を5年間保持（法的要件により）