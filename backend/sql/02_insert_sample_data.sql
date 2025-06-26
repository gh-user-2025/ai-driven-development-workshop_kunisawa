-- =====================================================
-- 工場設備稼働監視システム - サンプルデータ登録SQL文
-- 対象: Azure SQL Database v12
-- 作成日: 2024年
-- =====================================================

-- =====================================================
-- 1. 工場データの挿入
-- =====================================================
INSERT INTO Factories (factory_name, location, contact_person, phone_number) VALUES
(N'東京第一工場', N'東京都大田区羽田1-1-1', N'田中太郎', '03-1234-5678'),
(N'大阪製造工場', N'大阪府堺市西区鳳東町2-2-2', N'佐藤花子', '06-2345-6789'),
(N'名古屋技術センター', N'愛知県名古屋市港区3-3-3', N'鈴木一郎', '052-3456-7890');

-- =====================================================
-- 2. 設備データの挿入
-- =====================================================

-- 東京第一工場の設備
INSERT INTO Equipment (factory_id, equipment_name, equipment_type, model_number, manufacturer, installation_date, status) VALUES
(1, N'射出成形機A-01', N'射出成形機', 'INJ-2000X', N'山田機械工業', '2020-04-15', N'稼働中'),
(1, N'射出成形機A-02', N'射出成形機', 'INJ-2000X', N'山田機械工業', '2020-04-20', N'稼働中'),
(1, N'プレス機B-01', N'プレス機', 'PRESS-500T', N'東京プレス', '2019-03-10', N'稼働中'),
(1, N'コンベアライン1', N'搬送装置', 'CONV-100M', N'搬送システムズ', '2021-01-25', N'稼働中'),
(1, N'品質検査装置1', N'検査装置', 'QC-VISION3', N'品質技研', '2021-07-30', N'稼働中');

-- 大阪製造工場の設備
INSERT INTO Equipment (factory_id, equipment_name, equipment_type, model_number, manufacturer, installation_date, status) VALUES
(2, N'CNC旋盤C-01', N'CNC旋盤', 'CNC-TURN5', N'大阪精機', '2018-12-01', N'稼働中'),
(2, N'CNC旋盤C-02', N'CNC旋盤', 'CNC-TURN5', N'大阪精機', '2019-02-15', N'稼働中'),
(2, N'研磨機D-01', N'研磨機', 'GRIND-AUTO', N'研磨テック', '2020-06-10', N'稼働中'),
(2, N'溶接ロボットE-01', N'溶接ロボット', 'WELD-BOT7', N'関西ロボット', '2021-03-20', N'稼働中'),
(2, N'塗装ブースF-01', N'塗装設備', 'PAINT-BOOTH', N'塗装システム', '2019-11-12', N'稼働中');

-- 名古屋技術センターの設備
INSERT INTO Equipment (factory_id, equipment_name, equipment_type, model_number, manufacturer, installation_date, status) VALUES
(3, N'3Dプリンタ01', N'3Dプリンタ', '3DP-METAL', N'愛知3D', '2022-01-10', N'稼働中'),
(3, N'測定機G-01', N'測定機', 'MEASURE-3D', N'精密測定', '2020-09-05', N'稼働中'),
(3, N'組立ライン2', N'組立装置', 'ASSEM-LINE2', N'組立システム', '2021-05-15', N'稼働中'),
(3, N'包装機H-01', N'包装機', 'PACK-AUTO', N'包装機械', '2021-08-25', N'メンテナンス中');

-- =====================================================
-- 3. センサーデータの挿入
-- =====================================================

-- 射出成形機A-01のセンサー
INSERT INTO Sensors (equipment_id, sensor_name, sensor_type, unit, min_value, max_value, warning_threshold, alert_threshold, location) VALUES
(1, N'シリンダ温度センサー', N'温度', N'℃', 0, 300, 250, 280, N'シリンダヘッド部'),
(1, N'射出圧力センサー', N'圧力', N'MPa', 0, 200, 150, 180, N'射出部'),
(1, N'スクリュー回転数センサー', N'回転数', N'rpm', 0, 300, 250, 280, N'スクリューモーター'),
(1, N'主電動機電流センサー', N'電流', N'A', 0, 100, 80, 90, N'主電動機');

-- プレス機B-01のセンサー
INSERT INTO Sensors (equipment_id, sensor_name, sensor_type, unit, min_value, max_value, warning_threshold, alert_threshold, location) VALUES
(3, N'プレス圧力センサー', N'圧力', N'MPa', 0, 50, 45, 48, N'プレス部'),
(3, N'油圧温度センサー', N'温度', N'℃', 0, 80, 70, 75, N'油圧タンク'),
(3, N'振動センサー', N'振動', N'mm/s', 0, 10, 7, 8.5, N'フレーム部');

-- CNC旋盤C-01のセンサー
INSERT INTO Sensors (equipment_id, sensor_name, sensor_type, unit, min_value, max_value, warning_threshold, alert_threshold, location) VALUES
(6, N'主軸温度センサー', N'温度', N'℃', 0, 100, 80, 90, N'主軸部'),
(6, N'主軸回転数センサー', N'回転数', N'rpm', 0, 4000, 3500, 3800, N'主軸'),
(6, N'切削液温度センサー', N'温度', N'℃', 0, 50, 40, 45, N'切削液タンク'),
(6, N'送り軸電流センサー', N'電流', N'A', 0, 30, 25, 28, N'送り軸モーター');

-- 溶接ロボットE-01のセンサー
INSERT INTO Sensors (equipment_id, sensor_name, sensor_type, unit, min_value, max_value, warning_threshold, alert_threshold, location) VALUES
(9, N'溶接電流センサー', N'電流', N'A', 0, 500, 400, 450, N'溶接部'),
(9, N'溶接電圧センサー', N'電圧', N'V', 0, 50, 40, 45, N'溶接部'),
(9, N'ロボット温度センサー', N'温度', N'℃', 0, 70, 60, 65, N'制御盤内');

-- 3Dプリンタ01のセンサー
INSERT INTO Sensors (equipment_id, sensor_name, sensor_type, unit, min_value, max_value, warning_threshold, alert_threshold, location) VALUES
(11, N'ノズル温度センサー', N'温度', N'℃', 0, 300, 250, 280, N'プリントヘッド'),
(11, N'ベッド温度センサー', N'温度', N'℃', 0, 100, 80, 90, N'プリントベッド'),
(11, N'チャンバー温度センサー', N'温度', N'℃', 0, 200, 150, 180, N'プリントチャンバー');

-- =====================================================
-- 4. ユーザーデータの挿入
-- =====================================================
INSERT INTO Users (username, email, full_name, role, factory_id, phone_number, is_active) VALUES
-- 管理者
('admin001', 'tanaka.taro@factory-monitoring.com', N'田中太郎', N'管理者', 1, '090-1234-5678', 1),
('admin002', 'sato.hanako@factory-monitoring.com', N'佐藤花子', N'管理者', 2, '090-2345-6789', 1),
('admin003', 'suzuki.ichiro@factory-monitoring.com', N'鈴木一郎', N'管理者', 3, '090-3456-7890', 1),

-- オペレータ
('operator001', 'yamada.jiro@factory-monitoring.com', N'山田二郎', N'オペレータ', 1, '090-4567-8901', 1),
('operator002', 'watanabe.sachiko@factory-monitoring.com', N'渡辺幸子', N'オペレータ', 1, '090-5678-9012', 1),
('operator003', 'takahashi.kenji@factory-monitoring.com', N'高橋健二', N'オペレータ', 2, '090-6789-0123', 1),
('operator004', 'matsumoto.yuki@factory-monitoring.com', N'松本雪', N'オペレータ', 2, '090-7890-1234', 1),
('operator005', 'kobayashi.hiroshi@factory-monitoring.com', N'小林寛', N'オペレータ', 3, '090-8901-2345', 1),

-- 閲覧者
('viewer001', 'nakamura.akira@factory-monitoring.com', N'中村明', N'閲覧者', 1, NULL, 1),
('viewer002', 'kimura.mai@factory-monitoring.com', N'木村舞', N'閲覧者', 2, NULL, 1),
('viewer003', 'hayashi.takeshi@factory-monitoring.com', N'林武', N'閲覧者', 3, NULL, 1);

-- =====================================================
-- 5. サンプルのセンサーデータ挿入（直近24時間分）
-- =====================================================

-- 現在時刻から24時間前のデータを5分間隔で生成
DECLARE @StartTime DATETIME2 = DATEADD(HOUR, -24, GETDATE());
DECLARE @CurrentTime DATETIME2 = @StartTime;
DECLARE @EndTime DATETIME2 = GETDATE();

-- 射出成形機A-01の温度データ（センサーID: 1）
WHILE @CurrentTime <= @EndTime
BEGIN
    INSERT INTO SensorData (sensor_id, value, timestamp, quality)
    VALUES (1, 220 + (RAND() * 20) - 10, @CurrentTime, N'正常');
    
    SET @CurrentTime = DATEADD(MINUTE, 5, @CurrentTime);
END;

-- プレス機B-01の圧力データ（センサーID: 5）
SET @CurrentTime = @StartTime;
WHILE @CurrentTime <= @EndTime
BEGIN
    INSERT INTO SensorData (sensor_id, value, timestamp, quality)
    VALUES (5, 30 + (RAND() * 10) - 5, @CurrentTime, N'正常');
    
    SET @CurrentTime = DATEADD(MINUTE, 5, @CurrentTime);
END;

-- CNC旋盤C-01の回転数データ（センサーID: 9）
SET @CurrentTime = @StartTime;
WHILE @CurrentTime <= @EndTime
BEGIN
    INSERT INTO SensorData (sensor_id, value, timestamp, quality)
    VALUES (9, 2000 + (RAND() * 1000) - 500, @CurrentTime, N'正常');
    
    SET @CurrentTime = DATEADD(MINUTE, 5, @CurrentTime);
END;

-- =====================================================
-- 6. サンプルアラートデータの挿入
-- =====================================================
INSERT INTO Alerts (sensor_id, alert_type, severity, message, threshold_value, actual_value, occurred_at, status) VALUES
(1, N'警告', N'中', N'シリンダ温度が警告レベルに達しました', 250, 255, DATEADD(HOUR, -2, GETDATE()), N'確認済み'),
(5, N'異常', N'高', N'プレス圧力が異常値を示しています', 45, 47, DATEADD(HOUR, -1, GETDATE()), N'未確認'),
(9, N'警告', N'低', N'主軸回転数が低下しています', 3500, 3200, DATEADD(MINUTE, -30, GETDATE()), N'未確認'),
(13, N'異常', N'緊急', N'溶接電流が規定値を大幅に超過', 400, 480, DATEADD(MINUTE, -15, GETDATE()), N'未確認');

-- =====================================================
-- 7. サンプル保守記録データの挿入
-- =====================================================
INSERT INTO MaintenanceRecords (equipment_id, maintenance_type, description, technician_name, start_time, end_time, cost, parts_used, status) VALUES
(1, N'定期点検', N'月次定期点検を実施。シリンダヘッド部の清掃、潤滑油の補充を行いました。', N'田中太郎', DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, DATEADD(HOUR, 2, GETDATE())), 15000, N'潤滑油 2L', N'完了'),
(3, N'部品交換', N'油圧ポンプのシールを交換しました。', N'山田二郎', DATEADD(DAY, -3, GETDATE()), DATEADD(DAY, -3, DATEADD(HOUR, 4, GETDATE())), 45000, N'油圧シール一式', N'完了'),
(6, N'緊急修理', N'主軸ベアリングの異音により緊急停止。ベアリング交換を実施。', N'高橋健二', DATEADD(DAY, -1, GETDATE()), NULL, NULL, N'主軸ベアリング', N'作業中'),
(11, N'予防保全', N'プリントヘッドのノズル清掃とキャリブレーション調整', N'小林寛', DATEADD(HOUR, -6, GETDATE()), DATEADD(HOUR, -4, GETDATE()), 8000, N'清掃キット', N'完了');

-- =====================================================
-- データ挿入完了の確認
-- =====================================================
PRINT 'サンプルデータの挿入が完了しました。';
PRINT '挿入されたデータ:';
SELECT 'Factories' AS TableName, COUNT(*) AS RecordCount FROM Factories
UNION ALL
SELECT 'Equipment', COUNT(*) FROM Equipment
UNION ALL
SELECT 'Sensors', COUNT(*) FROM Sensors
UNION ALL
SELECT 'SensorData', COUNT(*) FROM SensorData
UNION ALL
SELECT 'Users', COUNT(*) FROM Users
UNION ALL
SELECT 'Alerts', COUNT(*) FROM Alerts
UNION ALL
SELECT 'MaintenanceRecords', COUNT(*) FROM MaintenanceRecords;