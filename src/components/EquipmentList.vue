<template>
  <div class="equipment-list">
    <h2>設備一覧</h2>
    <p class="page-description">工場内の全設備の稼働状況をリアルタイムで監視できます。</p>
    
    <!-- フィルターセクション -->
    <div class="filter-section card">
      <h3>フィルター</h3>
      <div class="filter-controls">
        <label>
          ステータス：
          <select v-model="statusFilter">
            <option value="">すべて</option>
            <option value="running">稼働中</option>
            <option value="stopped">停止中</option>
            <option value="maintenance">メンテナンス中</option>
          </select>
        </label>
        <label>
          エリア：
          <select v-model="areaFilter">
            <option value="">すべて</option>
            <option value="A">エリアA</option>
            <option value="B">エリアB</option>
            <option value="C">エリアC</option>
          </select>
        </label>
      </div>
    </div>

    <!-- 設備一覧 -->
    <div class="equipment-grid">
      <div v-for="equipment in filteredEquipment" :key="equipment.id" class="equipment-card card">
        <div class="equipment-header">
          <h3>{{ equipment.name }}</h3>
          <span :class="'status-' + equipment.status">{{ getStatusText(equipment.status) }}</span>
        </div>
        <div class="equipment-info">
          <p><strong>ID:</strong> {{ equipment.id }}</p>
          <p><strong>エリア:</strong> {{ equipment.area }}</p>
          <p><strong>稼働率:</strong> {{ equipment.efficiency }}%</p>
          <p><strong>最終更新:</strong> {{ formatDate(equipment.lastUpdate) }}</p>
        </div>
        <div class="equipment-actions">
          <router-link :to="'/equipment/' + equipment.id" class="btn btn-primary">詳細表示</router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EquipmentList',
  data() {
    return {
      statusFilter: '',
      areaFilter: '',
      equipment: [
        {
          id: 'EQ001',
          name: '成型機A-1',
          status: 'running',
          area: 'A',
          efficiency: 85,
          lastUpdate: new Date('2024-01-15T10:30:00')
        },
        {
          id: 'EQ002',
          name: '成型機A-2',
          status: 'stopped',
          area: 'A',
          efficiency: 0,
          lastUpdate: new Date('2024-01-15T09:45:00')
        },
        {
          id: 'EQ003',
          name: '組立ライン B-1',
          status: 'running',
          area: 'B',
          efficiency: 92,
          lastUpdate: new Date('2024-01-15T10:25:00')
        },
        {
          id: 'EQ004',
          name: '検査装置 C-1',
          status: 'maintenance',
          area: 'C',
          efficiency: 0,
          lastUpdate: new Date('2024-01-15T08:00:00')
        },
        {
          id: 'EQ005',
          name: '包装機 C-2',
          status: 'running',
          area: 'C',
          efficiency: 78,
          lastUpdate: new Date('2024-01-15T10:32:00')
        }
      ]
    }
  },
  computed: {
    filteredEquipment() {
      return this.equipment.filter(eq => {
        const statusMatch = !this.statusFilter || eq.status === this.statusFilter;
        const areaMatch = !this.areaFilter || eq.area === this.areaFilter;
        return statusMatch && areaMatch;
      });
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
    }
  },
  mounted() {
    console.log('設備一覧コンポーネントが読み込まれました');
    // 実際の実装では、ここでAPIからデータを取得
    // this.fetchEquipmentData();
  }
}
</script>

<style scoped>
.equipment-list {
  max-width: 1200px;
}

.page-description {
  margin-bottom: 2rem;
  color: #666;
  font-size: 1.1rem;
}

.filter-section {
  margin-bottom: 2rem;
}

.filter-controls {
  display: flex;
  gap: 2rem;
  margin-top: 1rem;
}

.filter-controls label {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.filter-controls select {
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.equipment-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

.equipment-card {
  border-left: 4px solid #3498db;
}

.equipment-card .equipment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.equipment-card h3 {
  margin: 0;
  color: #2c3e50;
}

.equipment-info p {
  margin: 0.5rem 0;
}

.equipment-actions {
  margin-top: 1rem;
  text-align: right;
}
</style>