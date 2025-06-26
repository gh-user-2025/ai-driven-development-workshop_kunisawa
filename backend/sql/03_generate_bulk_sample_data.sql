-- =====================================================
-- 工場設備稼働監視システム - 大量サンプルデータ生成SQL文
-- 対象: Azure SQL Database v12
-- 用途: 過去30日分の詳細なセンサーデータとアラートを生成
-- =====================================================

-- =====================================================
-- 1. 一時テーブルとカーソルを使用した大量データ生成
-- =====================================================

-- センサーデータを30日分生成（5分間隔）
DECLARE @StartDate DATETIME2 = DATEADD(DAY, -30, GETDATE());
DECLARE @EndDate DATETIME2 = GETDATE();
DECLARE @CurrentDate DATETIME2;
DECLARE @SensorId INT;
DECLARE @BaseValue DECIMAL(10,2);
DECLARE @Variance DECIMAL(10,2);
DECLARE @WarningThreshold DECIMAL(10,2);
DECLARE @AlertThreshold DECIMAL(10,2);
DECLARE @RandomValue DECIMAL(10,2);
DECLARE @Quality NVARCHAR(20);

PRINT '大量サンプルデータの生成を開始します...';

-- センサー情報のカーソル
DECLARE sensor_cursor CURSOR FOR
SELECT sensor_id, warning_threshold, alert_threshold,
       CASE 
           WHEN sensor_type = N'温度' THEN 220 + (sensor_id * 10)
           WHEN sensor_type = N'圧力' THEN 30 + (sensor_id * 2)
           WHEN sensor_type = N'回転数' THEN 2000 + (sensor_id * 100)
           WHEN sensor_type = N'電流' THEN 25 + (sensor_id * 5)
           WHEN sensor_type = N'電圧' THEN 24 + (sensor_id * 2)
           ELSE 100
       END as base_value,
       CASE 
           WHEN sensor_type = N'温度' THEN 15
           WHEN sensor_type = N'圧力' THEN 5
           WHEN sensor_type = N'回転数' THEN 200
           WHEN sensor_type = N'電流' THEN 5
           WHEN sensor_type = N'電圧' THEN 3
           ELSE 10
       END as variance
FROM Sensors;

OPEN sensor_cursor;

FETCH NEXT FROM sensor_cursor INTO @SensorId, @WarningThreshold, @AlertThreshold, @BaseValue, @Variance;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @CurrentDate = @StartDate;
    
    WHILE @CurrentDate <= @EndDate
    BEGIN
        -- 稼働時間内のみデータ生成（平日8-17時、土曜8-12時）
        IF (DATEPART(WEEKDAY, @CurrentDate) BETWEEN 2 AND 6 AND DATEPART(HOUR, @CurrentDate) BETWEEN 8 AND 16)
           OR (DATEPART(WEEKDAY, @CurrentDate) = 7 AND DATEPART(HOUR, @CurrentDate) BETWEEN 8 AND 11)
        BEGIN
            -- 正規分布っぽい乱数生成
            SET @RandomValue = @BaseValue + (RAND() - 0.5) * 2 * @Variance;
            
            -- 品質判定
            SET @Quality = CASE 
                WHEN RAND() < 0.01 THEN N'推定値'
                WHEN RAND() < 0.05 THEN N'異常'
                ELSE N'正常'
            END;
            
            -- 異常値の場合は閾値を超える値を設定
            IF @Quality = N'異常' AND RAND() < 0.3
            BEGIN
                SET @RandomValue = @WarningThreshold + (RAND() * (@AlertThreshold - @WarningThreshold));
            END;
            
            -- データ挿入
            INSERT INTO SensorData (sensor_id, value, timestamp, quality)
            VALUES (@SensorId, @RandomValue, @CurrentDate, @Quality);
            
            -- 閾値超過時のアラート生成
            IF @RandomValue >= @WarningThreshold
            BEGIN
                DECLARE @AlertType NVARCHAR(20) = CASE 
                    WHEN @RandomValue >= @AlertThreshold THEN N'異常'
                    ELSE N'警告'
                END;
                
                DECLARE @Severity NVARCHAR(20) = CASE 
                    WHEN @RandomValue >= @AlertThreshold THEN N'高'
                    WHEN @RandomValue >= @WarningThreshold THEN N'中'
                    ELSE N'低'
                END;
                
                DECLARE @Message NVARCHAR(500) = 
                    (SELECT sensor_name FROM Sensors WHERE sensor_id = @SensorId) + 
                    N'が' + @AlertType + N'レベルに達しました（値: ' + 
                    CAST(@RandomValue AS NVARCHAR(10)) + N'）';
                
                INSERT INTO Alerts (sensor_id, alert_type, severity, message, threshold_value, actual_value, occurred_at, status)
                VALUES (@SensorId, @AlertType, @Severity, @Message, @WarningThreshold, @RandomValue, @CurrentDate, N'未確認');
            END;
        END;
        
        -- 5分進める
        SET @CurrentDate = DATEADD(MINUTE, 5, @CurrentDate);
    END;
    
    PRINT 'センサーID ' + CAST(@SensorId AS NVARCHAR(10)) + ' のデータ生成完了';
    
    FETCH NEXT FROM sensor_cursor INTO @SensorId, @WarningThreshold, @AlertThreshold, @BaseValue, @Variance;
END;

CLOSE sensor_cursor;
DEALLOCATE sensor_cursor;

-- =====================================================
-- 2. 追加の保守記録データ生成
-- =====================================================

-- 過去6ヶ月分の保守記録を生成
DECLARE @MaintenanceDate DATETIME2 = DATEADD(MONTH, -6, GETDATE());
DECLARE @EquipmentId INT;
DECLARE @MaintenanceCounter INT = 1;

DECLARE equipment_cursor CURSOR FOR
SELECT equipment_id FROM Equipment;

OPEN equipment_cursor;
FETCH NEXT FROM equipment_cursor INTO @EquipmentId;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- 月次定期点検
    DECLARE @MonthlyDate DATETIME2 = @MaintenanceDate;
    WHILE @MonthlyDate <= GETDATE()
    BEGIN
        INSERT INTO MaintenanceRecords (
            equipment_id, 
            maintenance_type, 
            description, 
            technician_name, 
            start_time, 
            end_time, 
            cost, 
            parts_used, 
            status
        ) VALUES (
            @EquipmentId,
            N'定期点検',
            N'月次定期点検を実施。外観確認、潤滑油補充、各部点検を行いました。',
            CASE (@EquipmentId % 3)
                WHEN 0 THEN N'田中太郎'
                WHEN 1 THEN N'山田二郎'
                ELSE N'高橋健二'
            END,
            @MonthlyDate,
            DATEADD(HOUR, 2, @MonthlyDate),
            15000,
            N'潤滑油 1L, フィルター 1個',
            N'完了'
        );
        
        SET @MonthlyDate = DATEADD(MONTH, 1, @MonthlyDate);
    END;
    
    -- ランダムな緊急修理記録
    IF RAND() < 0.3  -- 30%の確率で緊急修理が発生
    BEGIN
        DECLARE @EmergencyDate DATETIME2 = DATEADD(DAY, -(RAND() * 30), GETDATE());
        
        INSERT INTO MaintenanceRecords (
            equipment_id, 
            maintenance_type, 
            description, 
            technician_name, 
            start_time, 
            end_time, 
            cost, 
            parts_used, 
            status
        ) VALUES (
            @EquipmentId,
            N'緊急修理',
            N'センサー異常により緊急停止。部品交換を実施しました。',
            N'緊急対応チーム',
            @EmergencyDate,
            DATEADD(HOUR, 4, @EmergencyDate),
            85000,
            N'センサー部品一式',
            N'完了'
        );
    END;
    
    FETCH NEXT FROM equipment_cursor INTO @EquipmentId;
END;

CLOSE equipment_cursor;
DEALLOCATE equipment_cursor;

-- =====================================================
-- 3. 一部のアラートの確認・解決状態更新
-- =====================================================

-- 古いアラートの一部を確認済み・解決済みに更新
UPDATE Alerts 
SET 
    acknowledged_at = DATEADD(MINUTE, 10, occurred_at),
    status = N'確認済み'
WHERE 
    occurred_at < DATEADD(DAY, -1, GETDATE())
    AND RAND() < 0.7  -- 70%のアラートを確認済みに
    AND status = N'未確認';

-- さらに古いアラートの一部を解決済みに更新
UPDATE Alerts 
SET 
    resolved_at = DATEADD(HOUR, 2, acknowledged_at),
    status = N'解決済み'
WHERE 
    occurred_at < DATEADD(DAY, -2, GETDATE())
    AND acknowledged_at IS NOT NULL
    AND RAND() < 0.8  -- 80%の確認済みアラートを解決済みに
    AND status = N'確認済み';

-- =====================================================
-- 4. ユーザーの最終ログイン時刻を更新
-- =====================================================

UPDATE Users 
SET last_login = DATEADD(HOUR, -(RAND() * 24), GETDATE())
WHERE is_active = 1;

-- =====================================================
-- 5. 設備の稼働状況をランダムに更新
-- =====================================================

-- 一部の設備をメンテナンス中に設定
UPDATE Equipment 
SET status = N'メンテナンス中'
WHERE equipment_id IN (
    SELECT TOP 2 equipment_id 
    FROM Equipment 
    WHERE status = N'稼働中'
    ORDER BY NEWID()  -- ランダム選択
);

-- =====================================================
-- 6. データ生成結果の確認
-- =====================================================

PRINT '=== データ生成結果 ===';

SELECT 
    'Factories' AS TableName, 
    COUNT(*) AS RecordCount,
    MIN(created_at) AS OldestRecord,
    MAX(created_at) AS NewestRecord
FROM Factories

UNION ALL

SELECT 
    'Equipment', 
    COUNT(*), 
    MIN(created_at),
    MAX(created_at)
FROM Equipment

UNION ALL

SELECT 
    'Sensors', 
    COUNT(*), 
    MIN(created_at),
    MAX(created_at)
FROM Sensors

UNION ALL

SELECT 
    'SensorData', 
    COUNT(*), 
    MIN(timestamp),
    MAX(timestamp)
FROM SensorData

UNION ALL

SELECT 
    'Alerts', 
    COUNT(*), 
    MIN(occurred_at),
    MAX(occurred_at)
FROM Alerts

UNION ALL

SELECT 
    'MaintenanceRecords', 
    COUNT(*), 
    MIN(start_time),
    MAX(start_time)
FROM MaintenanceRecords

UNION ALL

SELECT 
    'Users', 
    COUNT(*), 
    MIN(created_at),
    MAX(created_at)
FROM Users;

-- アラート状態別集計
PRINT '=== アラート状態別集計 ===';
SELECT 
    status,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Alerts), 2) as percentage
FROM Alerts
GROUP BY status;

-- 設備状態別集計
PRINT '=== 設備状態別集計 ===';
SELECT 
    status,
    COUNT(*) as count
FROM Equipment
GROUP BY status;

-- センサーデータ品質別集計
PRINT '=== センサーデータ品質別集計 ===';
SELECT 
    quality,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM SensorData), 2) as percentage
FROM SensorData
GROUP BY quality;

PRINT '大量サンプルデータの生成が完了しました。';
PRINT '※ 実際の環境では、このスクリプトの実行に数分から数十分かかる場合があります。';