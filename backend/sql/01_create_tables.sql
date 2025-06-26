-- =====================================================
-- 工場設備稼働監視システム - Azure SQL Database テーブル作成スクリプト
-- 対象: Azure SQL Database v12
-- 作成日: 2024年
-- =====================================================

-- データベース照合順序の確認・設定
-- Azure SQL Databaseでは日本語対応のため Japanese_CI_AS を推奨
-- ALTER DATABASE [factory-monitoring-db] COLLATE Japanese_CI_AS;

-- =====================================================
-- 1. 工場テーブル (Factories)
-- =====================================================
CREATE TABLE Factories (
    factory_id INT IDENTITY(1,1) PRIMARY KEY,
    factory_name NVARCHAR(100) NOT NULL,
    location NVARCHAR(200) NOT NULL,
    contact_person NVARCHAR(50) NULL,
    phone_number NVARCHAR(20) NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- 工場テーブルのインデックス
CREATE INDEX IX_Factories_Name ON Factories(factory_name);

-- =====================================================
-- 2. 設備テーブル (Equipment)
-- =====================================================
CREATE TABLE Equipment (
    equipment_id INT IDENTITY(1,1) PRIMARY KEY,
    factory_id INT NOT NULL,
    equipment_name NVARCHAR(100) NOT NULL,
    equipment_type NVARCHAR(50) NOT NULL,
    model_number NVARCHAR(50) NULL,
    manufacturer NVARCHAR(100) NULL,
    installation_date DATE NULL,
    status NVARCHAR(20) NOT NULL DEFAULT N'稼働中',
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    
    -- 外部キー制約
    CONSTRAINT FK_Equipment_Factory FOREIGN KEY (factory_id) 
        REFERENCES Factories(factory_id) ON DELETE CASCADE,
    
    -- チェック制約
    CONSTRAINT CK_Equipment_Status CHECK (status IN (N'稼働中', N'停止中', N'メンテナンス中'))
);

-- 設備テーブルのインデックス
CREATE INDEX IX_Equipment_FactoryId ON Equipment(factory_id);
CREATE INDEX IX_Equipment_Status ON Equipment(status);
CREATE INDEX IX_Equipment_Type ON Equipment(equipment_type);

-- =====================================================
-- 3. センサーテーブル (Sensors)
-- =====================================================
CREATE TABLE Sensors (
    sensor_id INT IDENTITY(1,1) PRIMARY KEY,
    equipment_id INT NOT NULL,
    sensor_name NVARCHAR(100) NOT NULL,
    sensor_type NVARCHAR(50) NOT NULL,
    unit NVARCHAR(20) NOT NULL,
    min_value DECIMAL(10,2) NULL,
    max_value DECIMAL(10,2) NULL,
    warning_threshold DECIMAL(10,2) NULL,
    alert_threshold DECIMAL(10,2) NULL,
    location NVARCHAR(100) NULL,
    status NVARCHAR(20) NOT NULL DEFAULT N'正常',
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    
    -- 外部キー制約
    CONSTRAINT FK_Sensors_Equipment FOREIGN KEY (equipment_id) 
        REFERENCES Equipment(equipment_id) ON DELETE CASCADE,
    
    -- チェック制約
    CONSTRAINT CK_Sensors_Status CHECK (status IN (N'正常', N'異常', N'メンテナンス中')),
    CONSTRAINT CK_Sensors_ValueRange CHECK (min_value IS NULL OR max_value IS NULL OR min_value <= max_value)
);

-- センサーテーブルのインデックス
CREATE INDEX IX_Sensors_EquipmentId ON Sensors(equipment_id);
CREATE INDEX IX_Sensors_Type ON Sensors(sensor_type);
CREATE INDEX IX_Sensors_Status ON Sensors(status);

-- =====================================================
-- 4. センサーデータテーブル (SensorData)
-- =====================================================
CREATE TABLE SensorData (
    data_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    sensor_id INT NOT NULL,
    value DECIMAL(10,2) NOT NULL,
    timestamp DATETIME2 NOT NULL,
    quality NVARCHAR(20) NOT NULL DEFAULT N'正常',
    
    -- 外部キー制約
    CONSTRAINT FK_SensorData_Sensor FOREIGN KEY (sensor_id) 
        REFERENCES Sensors(sensor_id) ON DELETE CASCADE,
    
    -- チェック制約
    CONSTRAINT CK_SensorData_Quality CHECK (quality IN (N'正常', N'異常', N'推定値'))
);

-- センサーデータテーブルのインデックス（パフォーマンス重要）
CREATE INDEX IX_SensorData_SensorId_Timestamp ON SensorData(sensor_id, timestamp DESC);
CREATE INDEX IX_SensorData_Timestamp ON SensorData(timestamp DESC);

-- =====================================================
-- 5. アラートテーブル (Alerts)
-- =====================================================
CREATE TABLE Alerts (
    alert_id INT IDENTITY(1,1) PRIMARY KEY,
    sensor_id INT NOT NULL,
    alert_type NVARCHAR(20) NOT NULL,
    severity NVARCHAR(20) NOT NULL,
    message NVARCHAR(500) NOT NULL,
    threshold_value DECIMAL(10,2) NULL,
    actual_value DECIMAL(10,2) NULL,
    occurred_at DATETIME2 NOT NULL,
    acknowledged_at DATETIME2 NULL,
    resolved_at DATETIME2 NULL,
    status NVARCHAR(20) NOT NULL DEFAULT N'未確認',
    
    -- 外部キー制約
    CONSTRAINT FK_Alerts_Sensor FOREIGN KEY (sensor_id) 
        REFERENCES Sensors(sensor_id) ON DELETE CASCADE,
    
    -- チェック制約
    CONSTRAINT CK_Alerts_Type CHECK (alert_type IN (N'警告', N'異常', N'故障')),
    CONSTRAINT CK_Alerts_Severity CHECK (severity IN (N'低', N'中', N'高', N'緊急')),
    CONSTRAINT CK_Alerts_Status CHECK (status IN (N'未確認', N'確認済み', N'解決済み'))
);

-- アラートテーブルのインデックス
CREATE INDEX IX_Alerts_SensorId_OccurredAt ON Alerts(sensor_id, occurred_at DESC);
CREATE INDEX IX_Alerts_Status_Severity ON Alerts(status, severity);
CREATE INDEX IX_Alerts_OccurredAt ON Alerts(occurred_at DESC);

-- =====================================================
-- 6. 保守記録テーブル (MaintenanceRecords)
-- =====================================================
CREATE TABLE MaintenanceRecords (
    maintenance_id INT IDENTITY(1,1) PRIMARY KEY,
    equipment_id INT NOT NULL,
    maintenance_type NVARCHAR(50) NOT NULL,
    description NVARCHAR(1000) NOT NULL,
    technician_name NVARCHAR(50) NOT NULL,
    start_time DATETIME2 NOT NULL,
    end_time DATETIME2 NULL,
    cost DECIMAL(10,2) NULL,
    parts_used NVARCHAR(500) NULL,
    status NVARCHAR(20) NOT NULL DEFAULT N'作業中',
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    
    -- 外部キー制約
    CONSTRAINT FK_MaintenanceRecords_Equipment FOREIGN KEY (equipment_id) 
        REFERENCES Equipment(equipment_id) ON DELETE CASCADE,
    
    -- チェック制約
    CONSTRAINT CK_MaintenanceRecords_Status CHECK (status IN (N'予定', N'作業中', N'完了')),
    CONSTRAINT CK_MaintenanceRecords_Time CHECK (end_time IS NULL OR start_time <= end_time)
);

-- 保守記録テーブルのインデックス
CREATE INDEX IX_MaintenanceRecords_EquipmentId ON MaintenanceRecords(equipment_id);
CREATE INDEX IX_MaintenanceRecords_StartTime ON MaintenanceRecords(start_time DESC);
CREATE INDEX IX_MaintenanceRecords_Status ON MaintenanceRecords(status);

-- =====================================================
-- 7. ユーザーテーブル (Users)
-- =====================================================
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) NOT NULL UNIQUE,
    email NVARCHAR(100) NOT NULL UNIQUE,
    full_name NVARCHAR(100) NOT NULL,
    role NVARCHAR(20) NOT NULL,
    factory_id INT NULL,
    phone_number NVARCHAR(20) NULL,
    last_login DATETIME2 NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    
    -- 外部キー制約
    CONSTRAINT FK_Users_Factory FOREIGN KEY (factory_id) 
        REFERENCES Factories(factory_id) ON DELETE SET NULL,
    
    -- チェック制約
    CONSTRAINT CK_Users_Role CHECK (role IN (N'管理者', N'オペレータ', N'閲覧者')),
    CONSTRAINT CK_Users_Email CHECK (email LIKE '%_@_%.__%')
);

-- ユーザーテーブルのインデックス
CREATE INDEX IX_Users_Username ON Users(username);
CREATE INDEX IX_Users_Email ON Users(email);
CREATE INDEX IX_Users_FactoryId ON Users(factory_id);
CREATE INDEX IX_Users_Role ON Users(role);

-- =====================================================
-- 8. 更新日時自動更新のためのトリガー作成
-- =====================================================

-- 工場テーブルの更新トリガー
CREATE TRIGGER TR_Factories_UpdatedAt
ON Factories
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Factories 
    SET updated_at = GETDATE()
    FROM Factories f
    INNER JOIN inserted i ON f.factory_id = i.factory_id;
END;

-- 設備テーブルの更新トリガー
CREATE TRIGGER TR_Equipment_UpdatedAt
ON Equipment
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Equipment 
    SET updated_at = GETDATE()
    FROM Equipment e
    INNER JOIN inserted i ON e.equipment_id = i.equipment_id;
END;

-- センサーテーブルの更新トリガー
CREATE TRIGGER TR_Sensors_UpdatedAt
ON Sensors
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Sensors 
    SET updated_at = GETDATE()
    FROM Sensors s
    INNER JOIN inserted i ON s.sensor_id = i.sensor_id;
END;

-- ユーザーテーブルの更新トリガー
CREATE TRIGGER TR_Users_UpdatedAt
ON Users
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Users 
    SET updated_at = GETDATE()
    FROM Users u
    INNER JOIN inserted i ON u.user_id = i.user_id;
END;

-- =====================================================
-- 9. ビューの作成（よく使用されるクエリの最適化）
-- =====================================================

-- 設備監視概要ビュー
CREATE VIEW VW_EquipmentMonitoringOverview
AS
SELECT 
    f.factory_name,
    e.equipment_name,
    e.equipment_type,
    e.status AS equipment_status,
    COUNT(s.sensor_id) AS sensor_count,
    COUNT(CASE WHEN s.status = N'正常' THEN 1 END) AS normal_sensors,
    COUNT(CASE WHEN s.status = N'異常' THEN 1 END) AS abnormal_sensors,
    MAX(sd.timestamp) AS last_data_time
FROM Factories f
    INNER JOIN Equipment e ON f.factory_id = e.factory_id
    LEFT JOIN Sensors s ON e.equipment_id = s.equipment_id
    LEFT JOIN SensorData sd ON s.sensor_id = sd.sensor_id
GROUP BY f.factory_name, e.equipment_name, e.equipment_type, e.status;

-- 未解決アラート一覧ビュー
CREATE VIEW VW_ActiveAlerts
AS
SELECT 
    a.alert_id,
    f.factory_name,
    e.equipment_name,
    s.sensor_name,
    a.alert_type,
    a.severity,
    a.message,
    a.occurred_at,
    DATEDIFF(HOUR, a.occurred_at, GETDATE()) AS hours_since_occurred
FROM Alerts a
    INNER JOIN Sensors s ON a.sensor_id = s.sensor_id
    INNER JOIN Equipment e ON s.equipment_id = e.equipment_id
    INNER JOIN Factories f ON e.factory_id = f.factory_id
WHERE a.status IN (N'未確認', N'確認済み');

-- =====================================================
-- スクリプト実行完了
-- =====================================================
PRINT '工場設備稼働監視システムのテーブル作成が完了しました。';
PRINT '作成されたオブジェクト:';
PRINT '- テーブル: 7個';
PRINT '- インデックス: 15個';
PRINT '- トリガー: 4個';
PRINT '- ビュー: 2個';