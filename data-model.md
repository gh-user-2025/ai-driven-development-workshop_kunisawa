# データモデル

## 工場設備稼働監視システム データモデル設計

工場設備稼働監視システムの全ユースケースを網羅するデータモデルをMermaid記法で表現します。

### 全体ER図

```mermaid
erDiagram
    USER ||--o{ USER_ROLE : "has"
    ROLE ||--o{ USER_ROLE : "assigned"
    
    FACILITY ||--o{ EQUIPMENT : "contains"
    EQUIPMENT ||--o{ SENSOR : "has"
    EQUIPMENT ||--o{ MAINTENANCE_SCHEDULE : "scheduled for"
    EQUIPMENT ||--o{ MAINTENANCE_HISTORY : "has history"
    EQUIPMENT ||--o{ PRODUCTION_DATA : "generates"
    EQUIPMENT ||--o{ ALERT : "triggers"
    
    SENSOR ||--o{ SENSOR_DATA : "generates"
    SENSOR ||--o{ ALERT_RULE : "monitored by"
    
    ALERT_RULE ||--o{ ALERT : "generates"
    ALERT ||--o{ ALERT_RESPONSE : "has response"
    
    USER ||--o{ ALERT_RESPONSE : "responds to"
    USER ||--o{ MAINTENANCE_HISTORY : "performs"
    
    PRODUCTION_DATA ||--o{ EFFICIENCY_ANALYSIS : "analyzed in"
    SENSOR_DATA ||--o{ PREDICTIVE_MODEL : "feeds into"
    
    PREDICTIVE_MODEL ||--o{ PREDICTION_RESULT : "generates"
    PREDICTION_RESULT ||--o{ MAINTENANCE_SCHEDULE : "creates"
    
    USER {
        int user_id PK
        string username
        string email
        string password_hash
        string full_name
        string department
        datetime created_at
        datetime updated_at
        boolean is_active
    }
    
    ROLE {
        int role_id PK
        string role_name
        string description
        json permissions
        datetime created_at
    }
    
    USER_ROLE {
        int user_id PK
        int role_id PK
        datetime assigned_at
        datetime expires_at
    }
    
    FACILITY {
        int facility_id PK
        string facility_name
        string location
        string description
        json configuration
        datetime created_at
        datetime updated_at
    }
    
    EQUIPMENT {
        int equipment_id PK
        int facility_id FK
        string equipment_name
        string equipment_type
        string model_number
        string serial_number
        date installation_date
        json specifications
        string status
        datetime created_at
        datetime updated_at
    }
    
    SENSOR {
        int sensor_id PK
        int equipment_id FK
        string sensor_name
        string sensor_type
        string unit
        float min_value
        float max_value
        int sampling_interval
        string status
        datetime created_at
        datetime updated_at
    }
    
    SENSOR_DATA {
        bigint data_id PK
        int sensor_id FK
        float value
        string unit
        datetime timestamp
        string quality_status
        json metadata
    }
    
    ALERT_RULE {
        int rule_id PK
        int sensor_id FK
        string rule_name
        string condition_type
        float threshold_min
        float threshold_max
        int severity_level
        string notification_config
        boolean is_active
        datetime created_at
        datetime updated_at
    }
    
    ALERT {
        int alert_id PK
        int equipment_id FK
        int rule_id FK
        string alert_type
        int severity_level
        string message
        datetime triggered_at
        datetime acknowledged_at
        datetime resolved_at
        string status
        json context_data
    }
    
    ALERT_RESPONSE {
        int response_id PK
        int alert_id FK
        int user_id FK
        string action_taken
        string comments
        datetime response_time
        datetime completion_time
        string status
    }
    
    MAINTENANCE_SCHEDULE {
        int schedule_id PK
        int equipment_id FK
        string maintenance_type
        datetime scheduled_date
        datetime estimated_duration
        string description
        string priority
        string status
        int assigned_technician_id FK
        datetime created_at
        datetime updated_at
    }
    
    MAINTENANCE_HISTORY {
        int history_id PK
        int equipment_id FK
        int performed_by FK
        string maintenance_type
        datetime start_time
        datetime end_time
        string description
        string parts_used
        float cost
        string status
        string notes
        datetime created_at
    }
    
    PRODUCTION_DATA {
        int production_id PK
        int equipment_id FK
        datetime production_start
        datetime production_end
        int units_produced
        float production_rate
        float efficiency_percentage
        string product_type
        json quality_metrics
        datetime recorded_at
    }
    
    EFFICIENCY_ANALYSIS {
        int analysis_id PK
        int production_id FK
        float overall_efficiency
        float availability
        float performance
        float quality_rate
        json bottleneck_analysis
        json optimization_suggestions
        datetime analyzed_at
    }
    
    PREDICTIVE_MODEL {
        int model_id PK
        string model_name
        string model_type
        string algorithm
        json parameters
        float accuracy
        datetime trained_at
        datetime last_updated
        boolean is_active
    }
    
    PREDICTION_RESULT {
        int prediction_id PK
        int model_id FK
        int equipment_id FK
        string prediction_type
        float risk_score
        datetime predicted_failure_date
        string confidence_level
        json analysis_details
        datetime predicted_at
    }
```

### ユースケース別データフロー

#### 1. リアルタイム設備監視データフロー

```mermaid
graph TB
    A[IoTセンサー] --> B[SENSOR_DATA]
    B --> C[リアルタイム処理]
    C --> D[ALERT_RULE評価]
    D --> E{閾値チェック}
    E -->|異常検知| F[ALERT生成]
    E -->|正常| G[ダッシュボード更新]
    F --> H[ALERT_RESPONSE]
    H --> I[MAINTENANCE_HISTORY]
```

#### 2. 予知保全データフロー

```mermaid
graph TB
    A[SENSOR_DATA] --> B[データ蓄積]
    A --> C[EQUIPMENT履歴]
    B --> D[PREDICTIVE_MODEL]
    C --> D
    D --> E[PREDICTION_RESULT]
    E --> F[MAINTENANCE_SCHEDULE]
    F --> G[MAINTENANCE_HISTORY]
```

#### 3. 生産効率最適化データフロー

```mermaid
graph TB
    A[PRODUCTION_DATA] --> B[効率分析エンジン]
    C[SENSOR_DATA] --> B
    B --> D[EFFICIENCY_ANALYSIS]
    D --> E[最適化提案]
    E --> F[生産計画調整]
```

### データ分類とライフサイクル

```mermaid
graph TB
    subgraph "リアルタイムデータ"
        A[SENSOR_DATA]
        B[ALERT]
        C[PRODUCTION_DATA]
    end
    
    subgraph "マスターデータ"
        D[USER]
        E[EQUIPMENT]
        F[FACILITY]
        G[SENSOR]
    end
    
    subgraph "履歴データ"
        H[MAINTENANCE_HISTORY]
        I[ALERT_RESPONSE]
        J[EFFICIENCY_ANALYSIS]
    end
    
    subgraph "設定データ"
        K[ALERT_RULE]
        L[MAINTENANCE_SCHEDULE]
        M[PREDICTIVE_MODEL]
    end
    
    A --> |1年後| N[アーカイブストレージ]
    C --> |3年後| N
    H --> |5年後| N
```

### データ品質管理

```mermaid
graph TB
    A[データ入力] --> B[品質チェック]
    B --> C{品質OK?}
    C -->|Yes| D[データ保存]
    C -->|No| E[エラーログ]
    E --> F[データ修正]
    F --> B
    D --> G[データ利用]
```

### セキュリティとアクセス制御

```mermaid
graph TB
    subgraph "データアクセス制御"
        A[USER] --> B[ROLE]
        B --> C[権限チェック]
        C --> D{アクセス許可?}
        D -->|Yes| E[データアクセス]
        D -->|No| F[アクセス拒否]
    end
    
    subgraph "データ暗号化"
        G[機密データ] --> H[暗号化]
        H --> I[暗号化済みデータ]
        I --> J[復号化]
        J --> K[利用]
    end
```

### データバックアップ戦略

```mermaid
graph TB
    A[本番データ] --> B[日次バックアップ]
    A --> C[リアルタイムレプリケーション]
    B --> D[週次フルバックアップ]
    C --> E[災害復旧サイト]
    D --> F[月次アーカイブ]
    F --> G[長期保存]
```