<template>
  <div class="equipment-status">
    <div class="container">
      <!-- ページヘッダー -->
      <section class="page-header">
        <div class="card">
          <h2>設備稼働状況</h2>
          <p>リアルタイムで各設備の稼働状況を監視します</p>
          <div class="last-updated">
            最終更新: {{ lastUpdated }}
          </div>
        </div>
      </section>

      <!-- 設備概要 -->
      <section class="equipment-overview">
        <div class="grid grid-3">
          <div class="card metric-card">
            <div class="metric-icon running">▶</div>
            <div class="metric-content">
              <div class="metric-value">{{ runningCount }}</div>
              <div class="metric-label">稼働中</div>
            </div>
          </div>
          <div class="card metric-card">
            <div class="metric-icon warning">⚠</div>
            <div class="metric-content">
              <div class="metric-value">{{ warningCount }}</div>
              <div class="metric-label">要注意</div>
            </div>
          </div>
          <div class="card metric-card">
            <div class="metric-icon stopped">⏹</div>
            <div class="metric-content">
              <div class="metric-value">{{ stoppedCount }}</div>
              <div class="metric-label">停止中</div>
            </div>
          </div>
        </div>
      </section>

      <!-- 稼働率チャート -->
      <section class="chart-section">
        <div class="card">
          <h3>設備稼働率推移</h3>
          <div class="chart-container">
            <canvas ref="chartCanvas"></canvas>
          </div>
        </div>
      </section>

      <!-- 設備一覧 -->
      <section class="equipment-list">
        <div class="card">
          <div class="section-header">
            <h3>設備一覧</h3>
            <div class="filter-controls">
              <select v-model="statusFilter" class="filter-select">
                <option value="all">全ての設備</option>
                <option value="running">稼働中</option>
                <option value="warning">要注意</option>
                <option value="stopped">停止中</option>
              </select>
            </div>
          </div>
          
          <div class="equipment-grid">
            <div 
              v-for="equipment in filteredEquipment" 
              :key="equipment.id"
              class="equipment-card"
              :class="`status-${equipment.status}`"
            >
              <div class="equipment-header">
                <div class="equipment-name">{{ equipment.name }}</div>
                <div class="equipment-status">
                  <span 
                    class="status-indicator" 
                    :class="`status-${equipment.status}`"
                  ></span>
                  {{ getStatusText(equipment.status) }}
                </div>
              </div>
              
              <div class="equipment-metrics">
                <div class="metric">
                  <label>稼働率</label>
                  <div class="metric-value">{{ equipment.efficiency }}%</div>
                  <div class="metric-bar">
                    <div 
                      class="metric-fill"
                      :style="`width: ${equipment.efficiency}%`"
                    ></div>
                  </div>
                </div>
                
                <div class="metric">
                  <label>温度</label>
                  <div class="metric-value">{{ equipment.temperature }}°C</div>
                </div>
                
                <div class="metric">
                  <label>振動</label>
                  <div class="metric-value">{{ equipment.vibration }} Hz</div>
                </div>
              </div>
              
              <div class="equipment-actions">
                <button 
                  class="btn btn-sm"
                  :class="equipment.status === 'running' ? 'btn-warning' : 'btn-success'"
                  @click="toggleEquipment(equipment)"
                >
                  {{ equipment.status === 'running' ? '停止' : '開始' }}
                </button>
                <button class="btn btn-sm btn-primary" @click="showDetails(equipment)">
                  詳細
                </button>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- アラート履歴 -->
      <section class="alert-history">
        <div class="card">
          <h3>アラート履歴</h3>
          <div class="alert-timeline">
            <div 
              v-for="alert in alertHistory" 
              :key="alert.id"
              class="timeline-item"
              :class="`alert-${alert.level}`"
            >
              <div class="timeline-dot"></div>
              <div class="timeline-content">
                <div class="alert-title">{{ alert.title }}</div>
                <div class="alert-description">{{ alert.description }}</div>
                <div class="alert-time">{{ alert.timestamp }}</div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, nextTick } from 'vue'

export default {
  name: 'EquipmentStatus',
  setup() {
    const chartCanvas = ref(null)
    const statusFilter = ref('all')
    const lastUpdated = ref(new Date().toLocaleString('ja-JP'))
    
    // サンプル設備データ
    const equipment = ref([
      {
        id: 1,
        name: 'プレス機#1',
        status: 'running',
        efficiency: 95,
        temperature: 68,
        vibration: 12
      },
      {
        id: 2,
        name: 'プレス機#2',
        status: 'running',
        efficiency: 87,
        temperature: 72,
        vibration: 15
      },
      {
        id: 3,
        name: 'プレス機#3',
        status: 'warning',
        efficiency: 78,
        temperature: 85,
        vibration: 22
      },
      {
        id: 4,
        name: 'コンベア#1',
        status: 'running',
        efficiency: 92,
        temperature: 45,
        vibration: 8
      },
      {
        id: 5,
        name: 'コンベア#2',
        status: 'stopped',
        efficiency: 0,
        temperature: 25,
        vibration: 0
      },
      {
        id: 6,
        name: '組立ライン#1',
        status: 'running',
        efficiency: 89,
        temperature: 55,
        vibration: 10
      },
      {
        id: 7,
        name: '組立ライン#2',
        status: 'warning',
        efficiency: 65,
        temperature: 78,
        vibration: 18
      },
      {
        id: 8,
        name: '検査装置#1',
        status: 'running',
        efficiency: 94,
        temperature: 42,
        vibration: 5
      }
    ])

    // アラート履歴データ
    const alertHistory = ref([
      {
        id: 1,
        title: 'プレス機#3 温度異常',
        description: '設定温度を超過しました（85°C）',
        timestamp: '2024-01-15 14:30:15',
        level: 'warning'
      },
      {
        id: 2,
        title: 'コンベア#2 緊急停止',
        description: 'オペレーターにより緊急停止されました',
        timestamp: '2024-01-15 13:45:22',
        level: 'error'
      },
      {
        id: 3,
        title: '組立ライン#2 効率低下',
        description: '稼働効率が基準値を下回りました（65%）',
        timestamp: '2024-01-15 12:15:44',
        level: 'warning'
      },
      {
        id: 4,
        title: '検査装置#1 定期点検完了',
        description: '予定されていた定期点検が完了しました',
        timestamp: '2024-01-15 11:00:00',
        level: 'info'
      }
    ])

    // 計算されたプロパティ
    const runningCount = computed(() => 
      equipment.value.filter(eq => eq.status === 'running').length
    )
    
    const warningCount = computed(() => 
      equipment.value.filter(eq => eq.status === 'warning').length
    )
    
    const stoppedCount = computed(() => 
      equipment.value.filter(eq => eq.status === 'stopped').length
    )

    const filteredEquipment = computed(() => {
      if (statusFilter.value === 'all') {
        return equipment.value
      }
      return equipment.value.filter(eq => eq.status === statusFilter.value)
    })

    // メソッド
    const getStatusText = (status) => {
      const statusMap = {
        running: '稼働中',
        warning: '要注意',
        stopped: '停止中'
      }
      return statusMap[status] || '不明'
    }

    const toggleEquipment = (eq) => {
      if (eq.status === 'running') {
        eq.status = 'stopped'
        eq.efficiency = 0
      } else if (eq.status === 'stopped') {
        eq.status = 'running'
        eq.efficiency = Math.floor(Math.random() * 20) + 80 // 80-100%の範囲
      }
      lastUpdated.value = new Date().toLocaleString('ja-JP')
    }

    const showDetails = (eq) => {
      alert(`${eq.name}の詳細情報:\n\n稼働率: ${eq.efficiency}%\n温度: ${eq.temperature}°C\n振動: ${eq.vibration} Hz\nステータス: ${getStatusText(eq.status)}`)
    }

    const initChart = () => {
      if (!chartCanvas.value) return

      const ctx = chartCanvas.value.getContext('2d')
      
      // 簡単なChart.jsの代替実装
      const width = chartCanvas.value.width = chartCanvas.value.offsetWidth * 2
      const height = chartCanvas.value.height = 400
      ctx.scale(2, 2)
      
      // チャートの描画
      ctx.fillStyle = '#f8f9fa'
      ctx.fillRect(0, 0, width / 2, height / 2)
      
      // グリッド線
      ctx.strokeStyle = '#e9ecef'
      ctx.lineWidth = 1
      
      for (let i = 0; i <= 10; i++) {
        const y = (height / 2) * (i / 10)
        ctx.beginPath()
        ctx.moveTo(40, y)
        ctx.lineTo(width / 2 - 20, y)
        ctx.stroke()
      }
      
      // サンプルデータでライン描画
      ctx.strokeStyle = '#007bff'
      ctx.lineWidth = 3
      ctx.beginPath()
      
      const dataPoints = [85, 87, 89, 92, 88, 90, 93, 95, 91, 89]
      dataPoints.forEach((point, index) => {
        const x = 40 + (index * ((width / 2 - 60) / (dataPoints.length - 1)))
        const y = (height / 2 - 40) - ((point - 70) / 30) * (height / 2 - 80)
        
        if (index === 0) {
          ctx.moveTo(x, y)
        } else {
          ctx.lineTo(x, y)
        }
      })
      ctx.stroke()
      
      // ラベル
      ctx.fillStyle = '#6c757d'
      ctx.font = '12px sans-serif'
      ctx.fillText('時間経過', width / 4, height / 2 - 10)
      
      ctx.save()
      ctx.translate(15, height / 4)
      ctx.rotate(-Math.PI / 2)
      ctx.fillText('稼働率 (%)', 0, 0)
      ctx.restore()
    }

    onMounted(async () => {
      await nextTick()
      initChart()
      
      // 定期的にデータを更新
      setInterval(() => {
        equipment.value.forEach(eq => {
          if (eq.status === 'running') {
            // 小さなランダム変動を追加
            eq.efficiency = Math.max(0, Math.min(100, eq.efficiency + (Math.random() - 0.5) * 2))
            eq.temperature = Math.max(20, eq.temperature + (Math.random() - 0.5) * 3)
            eq.vibration = Math.max(0, eq.vibration + (Math.random() - 0.5) * 1)
          }
        })
        lastUpdated.value = new Date().toLocaleString('ja-JP')
      }, 5000) // 5秒ごとに更新
    })

    return {
      chartCanvas,
      statusFilter,
      lastUpdated,
      equipment,
      alertHistory,
      runningCount,
      warningCount,
      stoppedCount,
      filteredEquipment,
      getStatusText,
      toggleEquipment,
      showDetails
    }
  }
}
</script>

<style scoped>
.page-header .card {
  text-align: center;
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
  color: white;
  padding: 2rem;
}

.page-header h2 {
  font-size: 2rem;
  margin-bottom: 0.5rem;
}

.last-updated {
  margin-top: 1rem;
  opacity: 0.9;
  font-size: 0.9rem;
}

.metric-card {
  display: flex;
  align-items: center;
  padding: 1.5rem;
}

.metric-icon {
  font-size: 2rem;
  margin-right: 1rem;
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.metric-icon.running {
  background-color: #28a745;
}

.metric-icon.warning {
  background-color: #ffc107;
}

.metric-icon.stopped {
  background-color: #dc3545;
}

.metric-content {
  flex: 1;
}

.metric-value {
  font-size: 2rem;
  font-weight: bold;
  color: #2c3e50;
}

.metric-label {
  color: #6c757d;
  font-size: 0.9rem;
}

.chart-container {
  margin: 1rem 0;
  text-align: center;
}

.chart-container canvas {
  max-width: 100%;
  height: 200px;
  border: 1px solid #e9ecef;
  border-radius: 4px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.filter-select {
  padding: 0.5rem;
  border: 1px solid #ced4da;
  border-radius: 4px;
  background-color: white;
}

.equipment-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1rem;
}

.equipment-card {
  border: 1px solid #e9ecef;
  border-radius: 8px;
  padding: 1rem;
  background-color: white;
}

.equipment-card.status-warning {
  border-left-color: #ffc107;
  border-left-width: 4px;
}

.equipment-card.status-stopped {
  border-left-color: #dc3545;
  border-left-width: 4px;
}

.equipment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.equipment-name {
  font-size: 1.1rem;
  font-weight: 600;
  color: #2c3e50;
}

.equipment-status {
  display: flex;
  align-items: center;
  font-size: 0.9rem;
  color: #6c757d;
}

.equipment-metrics {
  margin-bottom: 1rem;
}

.metric {
  margin-bottom: 0.75rem;
}

.metric label {
  display: block;
  font-size: 0.8rem;
  color: #6c757d;
  margin-bottom: 0.25rem;
}

.metric .metric-value {
  font-size: 1rem;
  font-weight: 600;
  color: #2c3e50;
}

.metric-bar {
  height: 4px;
  background-color: #e9ecef;
  border-radius: 2px;
  margin-top: 0.25rem;
  overflow: hidden;
}

.metric-fill {
  height: 100%;
  background-color: #28a745;
  transition: width 0.3s ease;
}

.equipment-actions {
  display: flex;
  gap: 0.5rem;
}

.btn-sm {
  padding: 0.375rem 0.75rem;
  font-size: 0.875rem;
}

.alert-timeline {
  position: relative;
  padding-left: 2rem;
}

.timeline-item {
  position: relative;
  margin-bottom: 1.5rem;
  padding-left: 1rem;
}

.timeline-dot {
  position: absolute;
  left: -2rem;
  top: 0.25rem;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background-color: #007bff;
}

.timeline-item.alert-warning .timeline-dot {
  background-color: #ffc107;
}

.timeline-item.alert-error .timeline-dot {
  background-color: #dc3545;
}

.timeline-item.alert-info .timeline-dot {
  background-color: #17a2b8;
}

.alert-title {
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 0.25rem;
}

.alert-description {
  color: #6c757d;
  margin-bottom: 0.25rem;
}

.alert-time {
  font-size: 0.8rem;
  color: #6c757d;
}

@media (max-width: 768px) {
  .section-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }
  
  .equipment-grid {
    grid-template-columns: 1fr;
  }
  
  .equipment-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
}
</style>