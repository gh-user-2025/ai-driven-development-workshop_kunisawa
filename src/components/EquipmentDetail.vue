<template>
  <div class="equipment-detail">
    <div v-if="equipment" class="equipment-info">
      <!-- パンくずナビ -->
      <nav class="breadcrumb">
        <router-link to="/equipment">設備一覧</router-link> > {{ equipment.name }}
      </nav>

      <!-- 設備基本情報 -->
      <div class="equipment-header card">
        <div class="header-content">
          <h2>{{ equipment.name }}</h2>
          <span :class="'status-badge status-' + equipment.status">{{ getStatusText(equipment.status) }}</span>
        </div>
        <div class="equipment-basic-info">
          <div class="info-item">
            <label>設備ID:</label>
            <span>{{ equipment.id }}</span>
          </div>
          <div class="info-item">
            <label>エリア:</label>
            <span>{{ equipment.area }}</span>
          </div>
          <div class="info-item">
            <label>稼働率:</label>
            <span class="efficiency">{{ equipment.efficiency }}%</span>
          </div>
          <div class="info-item">
            <label>最終更新:</label>
            <span>{{ formatDate(equipment.lastUpdate) }}</span>
          </div>
        </div>
      </div>

      <!-- リアルタイム監視データ -->
      <div class="monitoring-section card">
        <h3>リアルタイム監視データ</h3>
        <div class="sensor-grid">
          <div class="sensor-card" v-for="sensor in equipment.sensors" :key="sensor.name">
            <h4>{{ sensor.name }}</h4>
            <div class="sensor-value">
              <span class="value">{{ sensor.value }}</span>
              <span class="unit">{{ sensor.unit }}</span>
            </div>
            <div class="sensor-status">
              <span :class="'status-' + sensor.status">{{ sensor.status === 'normal' ? '正常' : '警告' }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- メンテナンス履歴 -->
      <div class="maintenance-history card">
        <h3>メンテナンス履歴</h3>
        <div class="history-table">
          <table>
            <thead>
              <tr>
                <th>日付</th>
                <th>種類</th>
                <th>内容</th>
                <th>担当者</th>
                <th>ステータス</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="record in equipment.maintenanceHistory" :key="record.id">
                <td>{{ formatDate(record.date) }}</td>
                <td>{{ record.type }}</td>
                <td>{{ record.description }}</td>
                <td>{{ record.technician }}</td>
                <td :class="'status-' + record.status">{{ record.status === 'completed' ? '完了' : '予定' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- アクションボタン -->
      <div class="action-buttons">
        <button class="btn btn-primary" @click="exportData">データエクスポート</button>
        <button class="btn btn-warning" @click="scheduleMainmaintenance">メンテナンス予約</button>
        <router-link to="/equipment" class="btn">一覧に戻る</router-link>
      </div>
    </div>

    <div v-else class="loading">
      設備情報を読み込み中...
    </div>
  </div>
</template>

<script>
export default {
  name: 'EquipmentDetail',
  data() {
    return {
      equipment: null
    }
  },
  methods: {
    getStatusText(status) {
      const statusMap = {
        running: '稼働中',
        stopped: '停止中',
        maintenance: 'メンテナンス中'
      };
      return statusMap[status] || '不明';
    },
    formatDate(date) {
      return date.toLocaleString('ja-JP');
    },
    exportData() {
      alert('データエクスポート機能（実装予定）');
      // 実際の実装では、設備データをCSVやExcelで出力
    },
    scheduleMainmaintenance() {
      alert('メンテナンス予約機能（実装予定）');
      // 実際の実装では、メンテナンス予約フォームを表示
    },
    loadEquipmentData(id) {
      // 実際の実装では、APIから設備詳細データを取得
      // サンプルデータで代用
      const sampleData = {
        'EQ001': {
          id: 'EQ001',
          name: '成型機A-1',
          status: 'running',
          area: 'A',
          efficiency: 85,
          lastUpdate: new Date('2024-01-15T10:30:00'),
          sensors: [
            { name: '温度', value: 245, unit: '°C', status: 'normal' },
            { name: '圧力', value: 120, unit: 'bar', status: 'normal' },
            { name: '振動', value: 0.8, unit: 'mm/s', status: 'normal' },
            { name: '電力消費', value: 85, unit: 'kW', status: 'normal' }
          ],
          maintenanceHistory: [
            {
              id: 1,
              date: new Date('2024-01-10T14:00:00'),
              type: '定期点検',
              description: '月次定期点検実施',
              technician: '田中太郎',
              status: 'completed'
            },
            {
              id: 2,
              date: new Date('2024-01-20T09:00:00'),
              type: '部品交換',
              description: 'フィルター交換予定',
              technician: '佐藤花子',
              status: 'scheduled'
            }
          ]
        },
        'EQ002': {
          id: 'EQ002',
          name: '成型機A-2',
          status: 'stopped',
          area: 'A',
          efficiency: 0,
          lastUpdate: new Date('2024-01-15T09:45:00'),
          sensors: [
            { name: '温度', value: 25, unit: '°C', status: 'normal' },
            { name: '圧力', value: 0, unit: 'bar', status: 'normal' },
            { name: '振動', value: 0, unit: 'mm/s', status: 'normal' },
            { name: '電力消費', value: 5, unit: 'kW', status: 'normal' }
          ],
          maintenanceHistory: [
            {
              id: 3,
              date: new Date('2024-01-15T08:00:00'),
              type: '緊急修理',
              description: 'モーター故障による緊急停止',
              technician: '山田次郎',
              status: 'completed'
            }
          ]
        }
      };

      this.equipment = sampleData[id] || null;
    }
  },
  mounted() {
    const equipmentId = this.$route.params.id;
    console.log(`設備詳細画面を読み込み中: ${equipmentId}`);
    this.loadEquipmentData(equipmentId);
  },
  watch: {
    '$route.params.id'(newId) {
      this.loadEquipmentData(newId);
    }
  }
}
</script>

<style scoped>
.equipment-detail {
  max-width: 1200px;
}

.breadcrumb {
  margin-bottom: 1rem;
  padding: 0.5rem 0;
  border-bottom: 1px solid #eee;
}

.breadcrumb a {
  color: #3498db;
  text-decoration: none;
}

.breadcrumb a:hover {
  text-decoration: underline;
}

.equipment-header {
  margin-bottom: 2rem;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.status-badge {
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-weight: bold;
  font-size: 0.9rem;
}

.status-badge.status-running {
  background-color: #d5f4e6;
  color: #27ae60;
}

.status-badge.status-stopped {
  background-color: #fadad7;
  color: #e74c3c;
}

.status-badge.status-maintenance {
  background-color: #fef9e7;
  color: #f39c12;
}

.equipment-basic-info {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.info-item label {
  font-weight: bold;
  color: #666;
  font-size: 0.9rem;
}

.efficiency {
  font-size: 1.2rem;
  font-weight: bold;
  color: #27ae60;
}

.monitoring-section {
  margin-bottom: 2rem;
}

.sensor-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-top: 1rem;
}

.sensor-card {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 6px;
  text-align: center;
}

.sensor-card h4 {
  margin: 0 0 0.5rem 0;
  color: #2c3e50;
}

.sensor-value {
  font-size: 1.5rem;
  font-weight: bold;
  margin: 0.5rem 0;
}

.sensor-value .value {
  color: #2c3e50;
}

.sensor-value .unit {
  font-size: 1rem;
  color: #7f8c8d;
  margin-left: 0.25rem;
}

.maintenance-history {
  margin-bottom: 2rem;
}

.history-table {
  overflow-x: auto;
  margin-top: 1rem;
}

.history-table table {
  width: 100%;
  border-collapse: collapse;
}

.history-table th,
.history-table td {
  padding: 0.75rem;
  border: 1px solid #ddd;
  text-align: left;
}

.history-table th {
  background-color: #f8f9fa;
  font-weight: bold;
}

.action-buttons {
  display: flex;
  gap: 1rem;
  margin-top: 2rem;
}

.loading {
  text-align: center;
  padding: 2rem;
  color: #666;
}

@media (max-width: 768px) {
  .action-buttons {
    flex-direction: column;
  }
  
  .equipment-basic-info {
    grid-template-columns: 1fr;
  }
  
  .sensor-grid {
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  }
}
</style>