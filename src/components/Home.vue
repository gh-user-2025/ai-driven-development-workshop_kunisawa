<template>
  <div class="home">
    <div class="container">
      <!-- ヘッダーセクション -->
      <section class="hero-section">
        <div class="card">
          <h2>工場設備稼働監視システムへようこそ</h2>
          <p>リアルタイムで工場設備の状況を監視し、効率的な運用をサポートします。</p>
          <div class="hero-actions">
            <router-link to="/equipment-status" class="btn btn-primary">
              設備状況を確認
            </router-link>
          </div>
        </div>
      </section>

      <!-- システム概要セクション -->
      <section class="overview-section">
        <div class="grid grid-3">
          <div class="card feature-card">
            <div class="feature-icon">📊</div>
            <h3>リアルタイム監視</h3>
            <p>工場設備の稼働状況をリアルタイムで監視し、異常を即座に検知します。</p>
          </div>
          <div class="card feature-card">
            <div class="feature-icon">🔧</div>
            <h3>予知保全</h3>
            <p>AIによる予測分析で設備の保全時期を事前に把握し、計画的なメンテナンスを実現します。</p>
          </div>
          <div class="card feature-card">
            <div class="feature-icon">📈</div>
            <h3>効率最適化</h3>
            <p>生産効率を分析し、ボトルネックの特定と最適化提案を行います。</p>
          </div>
        </div>
      </section>

      <!-- クイックステータス -->
      <section class="quick-status">
        <div class="card">
          <h3>本日のシステム概要</h3>
          <div class="grid grid-2">
            <div class="status-item">
              <div class="status-header">
                <span class="status-indicator status-running"></span>
                <h4>稼働中設備</h4>
              </div>
              <div class="status-value">{{ runningEquipment }}/{{ totalEquipment }}</div>
              <div class="status-percentage">{{ runningPercentage }}%</div>
            </div>
            <div class="status-item">
              <div class="status-header">
                <span class="status-indicator status-warning"></span>
                <h4>要注意設備</h4>
              </div>
              <div class="status-value">{{ warningEquipment }}</div>
              <div class="status-description">メンテナンス推奨</div>
            </div>
            <div class="status-item">
              <div class="status-header">
                <span class="status-indicator status-success"></span>
                <h4>稼働効率</h4>
              </div>
              <div class="status-value">{{ efficiency }}%</div>
              <div class="status-description">目標値: 85%</div>
            </div>
            <div class="status-item">
              <div class="status-header">
                <span class="status-indicator status-primary"></span>
                <h4>今日の生産量</h4>
              </div>
              <div class="status-value">{{ todayProduction }}</div>
              <div class="status-description">目標: 1,000台</div>
            </div>
          </div>
        </div>
      </section>

      <!-- 最近のアラート -->
      <section class="recent-alerts">
        <div class="card">
          <h3>最近のアラート</h3>
          <div class="alert-list">
            <div 
              v-for="alert in recentAlerts" 
              :key="alert.id"
              class="alert-item"
              :class="`alert-${alert.level}`"
            >
              <div class="alert-content">
                <div class="alert-title">{{ alert.title }}</div>
                <div class="alert-time">{{ alert.time }}</div>
              </div>
              <div class="alert-status">{{ alert.status }}</div>
            </div>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'

export default {
  name: 'Home',
  setup() {
    // サンプルデータ
    const totalEquipment = ref(15)
    const runningEquipment = ref(12)
    const warningEquipment = ref(2)
    const efficiency = ref(87)
    const todayProduction = ref(847)
    
    const recentAlerts = ref([
      {
        id: 1,
        title: 'プレス機#3 - 温度上昇警告',
        time: '2024-01-15 14:30',
        level: 'warning',
        status: '確認済'
      },
      {
        id: 2,
        title: 'コンベア#1 - 速度低下検知',
        time: '2024-01-15 13:45',
        level: 'info',
        status: '対応中'
      },
      {
        id: 3,
        title: '組立ライン#2 - 正常稼働再開',
        time: '2024-01-15 12:15',
        level: 'success',
        status: '完了'
      }
    ])

    const runningPercentage = computed(() => {
      return Math.round((runningEquipment.value / totalEquipment.value) * 100)
    })

    onMounted(() => {
      // コンポーネントがマウントされた時の処理
      console.log('Home component mounted')
    })

    return {
      totalEquipment,
      runningEquipment,
      warningEquipment,
      efficiency,
      todayProduction,
      runningPercentage,
      recentAlerts
    }
  }
}
</script>

<style scoped>
.hero-section {
  margin-bottom: 2rem;
}

.hero-section .card {
  text-align: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 3rem 2rem;
}

.hero-section h2 {
  font-size: 2.5rem;
  margin-bottom: 1rem;
}

.hero-section p {
  font-size: 1.2rem;
  margin-bottom: 2rem;
  opacity: 0.9;
}

.hero-actions {
  margin-top: 2rem;
}

.feature-card {
  text-align: center;
}

.feature-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.feature-card h3 {
  color: #2c3e50;
  margin-bottom: 1rem;
}

.quick-status {
  margin: 2rem 0;
}

.status-item {
  padding: 1.5rem;
  border-left: 4px solid #007bff;
}

.status-header {
  display: flex;
  align-items: center;
  margin-bottom: 0.5rem;
}

.status-header h4 {
  margin: 0;
  color: #2c3e50;
}

.status-value {
  font-size: 2rem;
  font-weight: bold;
  color: #2c3e50;
  margin: 0.5rem 0;
}

.status-percentage {
  font-size: 1.5rem;
  color: #28a745;
  font-weight: 600;
}

.status-description {
  color: #6c757d;
  font-size: 0.9rem;
}

.status-indicator.status-success {
  background-color: #28a745;
}

.status-indicator.status-primary {
  background-color: #007bff;
}

.alert-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.alert-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  border-radius: 8px;
  border-left: 4px solid;
}

.alert-warning {
  background-color: #fff3cd;
  border-left-color: #ffc107;
}

.alert-info {
  background-color: #d1ecf1;
  border-left-color: #17a2b8;
}

.alert-success {
  background-color: #d4edda;
  border-left-color: #28a745;
}

.alert-title {
  font-weight: 600;
  color: #2c3e50;
}

.alert-time {
  font-size: 0.9rem;
  color: #6c757d;
  margin-top: 0.25rem;
}

.alert-status {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
  background-color: #e9ecef;
  color: #495057;
}

@media (max-width: 768px) {
  .hero-section h2 {
    font-size: 2rem;
  }
  
  .hero-section p {
    font-size: 1rem;
  }
  
  .status-value {
    font-size: 1.5rem;
  }
  
  .alert-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
}
</style>