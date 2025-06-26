<template>
  <div class="maintenance-manager">
    <h2>メンテナンス管理</h2>
    <p class="page-description">設備のメンテナンススケジュールを管理し、予防保全を実現します。</p>

    <!-- サマリーカード -->
    <div class="summary-cards">
      <div class="card summary-card">
        <h3>今日の予定</h3>
        <div class="summary-number">{{ todayTasks.length }}</div>
        <p>件のメンテナンス</p>
      </div>
      <div class="card summary-card">
        <h3>今週の予定</h3>
        <div class="summary-number">{{ weekTasks.length }}</div>
        <p>件のメンテナンス</p>
      </div>
      <div class="card summary-card">
        <h3>期限切れ</h3>
        <div class="summary-number overdue">{{ overdueTasks.length }}</div>
        <p>件のメンテナンス</p>
      </div>
    </div>

    <!-- フィルターセクション -->
    <div class="filter-section card">
      <h3>フィルター・検索</h3>
      <div class="filter-controls">
        <label>
          ステータス：
          <select v-model="statusFilter">
            <option value="">すべて</option>
            <option value="scheduled">予定</option>
            <option value="inProgress">進行中</option>
            <option value="completed">完了</option>
            <option value="overdue">期限切れ</option>
          </select>
        </label>
        <label>
          優先度：
          <select v-model="priorityFilter">
            <option value="">すべて</option>
            <option value="high">高</option>
            <option value="medium">中</option>
            <option value="low">低</option>
          </select>
        </label>
        <label>
          設備検索：
          <input type="text" v-model="equipmentFilter" placeholder="設備名で検索">
        </label>
      </div>
    </div>

    <!-- 新規メンテナンス追加ボタン -->
    <div class="add-maintenance">
      <button class="btn btn-success" @click="showAddForm = true">新規メンテナンス追加</button>
    </div>

    <!-- メンテナンスタスク一覧 -->
    <div class="tasks-section card">
      <h3>メンテナンス一覧</h3>
      <div class="tasks-list">
        <div v-for="task in filteredTasks" :key="task.id" class="task-item" :class="'priority-' + task.priority">
          <div class="task-header">
            <h4>{{ task.title }}</h4>
            <span :class="'status-badge status-' + task.status">{{ getStatusText(task.status) }}</span>
          </div>
          <div class="task-details">
            <div class="task-info">
              <p><strong>設備:</strong> {{ task.equipment }}</p>
              <p><strong>担当者:</strong> {{ task.assignee }}</p>
              <p><strong>予定日:</strong> {{ formatDate(task.scheduledDate) }}</p>
              <p><strong>優先度:</strong> {{ getPriorityText(task.priority) }}</p>
            </div>
            <div class="task-description">
              <p>{{ task.description }}</p>
            </div>
          </div>
          <div class="task-actions">
            <button class="btn btn-primary" @click="editTask(task)">編集</button>
            <button v-if="task.status === 'scheduled'" class="btn btn-warning" @click="startTask(task)">開始</button>
            <button v-if="task.status === 'inProgress'" class="btn btn-success" @click="completeTask(task)">完了</button>
          </div>
        </div>
      </div>
    </div>

    <!-- 新規追加フォーム（モーダル風） -->
    <div v-if="showAddForm" class="modal-overlay" @click="showAddForm = false">
      <div class="modal-content" @click.stop>
        <h3>新規メンテナンス追加</h3>
        <form @submit.prevent="addTask">
          <div class="form-group">
            <label>タイトル:</label>
            <input type="text" v-model="newTask.title" required>
          </div>
          <div class="form-group">
            <label>設備:</label>
            <select v-model="newTask.equipment" required>
              <option value="">選択してください</option>
              <option value="成型機A-1">成型機A-1</option>
              <option value="成型機A-2">成型機A-2</option>
              <option value="組立ライン B-1">組立ライン B-1</option>
              <option value="検査装置 C-1">検査装置 C-1</option>
              <option value="包装機 C-2">包装機 C-2</option>
            </select>
          </div>
          <div class="form-group">
            <label>担当者:</label>
            <input type="text" v-model="newTask.assignee" required>
          </div>
          <div class="form-group">
            <label>予定日:</label>
            <input type="datetime-local" v-model="newTask.scheduledDate" required>
          </div>
          <div class="form-group">
            <label>優先度:</label>
            <select v-model="newTask.priority" required>
              <option value="low">低</option>
              <option value="medium">中</option>
              <option value="high">高</option>
            </select>
          </div>
          <div class="form-group">
            <label>内容:</label>
            <textarea v-model="newTask.description" rows="3" required></textarea>
          </div>
          <div class="form-actions">
            <button type="submit" class="btn btn-success">追加</button>
            <button type="button" class="btn" @click="cancelAdd">キャンセル</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'MaintenanceManager',
  data() {
    return {
      statusFilter: '',
      priorityFilter: '',
      equipmentFilter: '',
      showAddForm: false,
      newTask: {
        title: '',
        equipment: '',
        assignee: '',
        scheduledDate: '',
        priority: 'medium',
        description: ''
      },
      tasks: [
        {
          id: 1,
          title: '成型機A-1 定期点検',
          equipment: '成型機A-1',
          assignee: '田中太郎',
          scheduledDate: new Date('2024-01-16T09:00:00'),
          priority: 'high',
          status: 'scheduled',
          description: '月次定期点検の実施。フィルター清掃、オイル交換を含む。'
        },
        {
          id: 2,
          title: '組立ライン B-1 ベルト交換',
          equipment: '組立ライン B-1',
          assignee: '佐藤花子',
          scheduledDate: new Date('2024-01-17T14:00:00'),
          priority: 'medium',
          status: 'scheduled',
          description: 'コンベアベルトの定期交換作業。'
        },
        {
          id: 3,
          title: '検査装置 C-1 センサー校正',
          equipment: '検査装置 C-1',
          assignee: '山田次郎',
          scheduledDate: new Date('2024-01-15T11:00:00'),
          priority: 'high',
          status: 'inProgress',
          description: '検査精度維持のためのセンサー校正作業。'
        },
        {
          id: 4,
          title: '包装機 C-2 清掃',
          equipment: '包装機 C-2',
          assignee: '鈴木一郎',
          scheduledDate: new Date('2024-01-14T16:00:00'),
          priority: 'low',
          status: 'completed',
          description: '週次清掃作業を完了。'
        },
        {
          id: 5,
          title: '成型機A-2 緊急修理',
          equipment: '成型機A-2',
          assignee: '高橋美咲',
          scheduledDate: new Date('2024-01-13T10:00:00'),
          priority: 'high',
          status: 'overdue',
          description: 'モーター故障の修理が遅延中。'
        }
      ]
    }
  },
  computed: {
    filteredTasks() {
      return this.tasks.filter(task => {
        const statusMatch = !this.statusFilter || task.status === this.statusFilter;
        const priorityMatch = !this.priorityFilter || task.priority === this.priorityFilter;
        const equipmentMatch = !this.equipmentFilter || 
          task.equipment.toLowerCase().includes(this.equipmentFilter.toLowerCase());
        return statusMatch && priorityMatch && equipmentMatch;
      });
    },
    todayTasks() {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);
      
      return this.tasks.filter(task => {
        const taskDate = new Date(task.scheduledDate);
        return taskDate >= today && taskDate < tomorrow;
      });
    },
    weekTasks() {
      const today = new Date();
      const weekLater = new Date(today);
      weekLater.setDate(weekLater.getDate() + 7);
      
      return this.tasks.filter(task => {
        const taskDate = new Date(task.scheduledDate);
        return taskDate >= today && taskDate <= weekLater;
      });
    },
    overdueTasks() {
      const now = new Date();
      return this.tasks.filter(task => {
        return task.status !== 'completed' && new Date(task.scheduledDate) < now;
      });
    }
  },
  methods: {
    getStatusText(status) {
      const statusMap = {
        scheduled: '予定',
        inProgress: '進行中',
        completed: '完了',
        overdue: '期限切れ'
      };
      return statusMap[status] || '不明';
    },
    getPriorityText(priority) {
      const priorityMap = {
        high: '高',
        medium: '中',
        low: '低'
      };
      return priorityMap[priority] || '不明';
    },
    formatDate(date) {
      return new Date(date).toLocaleString('ja-JP');
    },
    editTask(task) {
      alert(`タスク編集機能（実装予定）: ${task.title}`);
      // 実際の実装では、編集フォームを表示
    },
    startTask(task) {
      task.status = 'inProgress';
      console.log(`タスク開始: ${task.title}`);
    },
    completeTask(task) {
      task.status = 'completed';
      console.log(`タスク完了: ${task.title}`);
    },
    addTask() {
      const newId = Math.max(...this.tasks.map(t => t.id)) + 1;
      this.tasks.push({
        id: newId,
        title: this.newTask.title,
        equipment: this.newTask.equipment,
        assignee: this.newTask.assignee,
        scheduledDate: new Date(this.newTask.scheduledDate),
        priority: this.newTask.priority,
        status: 'scheduled',
        description: this.newTask.description
      });
      this.cancelAdd();
      alert('新しいメンテナンスタスクを追加しました');
    },
    cancelAdd() {
      this.showAddForm = false;
      this.newTask = {
        title: '',
        equipment: '',
        assignee: '',
        scheduledDate: '',
        priority: 'medium',
        description: ''
      };
    }
  },
  mounted() {
    console.log('メンテナンス管理コンポーネントが読み込まれました');
  }
}
</script>

<style scoped>
.maintenance-manager {
  max-width: 1200px;
}

.page-description {
  margin-bottom: 2rem;
  color: #666;
  font-size: 1.1rem;
}

.summary-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.summary-card {
  text-align: center;
  padding: 1.5rem;
}

.summary-number {
  font-size: 2.5rem;
  font-weight: bold;
  color: #3498db;
  margin: 0.5rem 0;
}

.summary-number.overdue {
  color: #e74c3c;
}

.filter-section {
  margin-bottom: 2rem;
}

.filter-controls {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-top: 1rem;
}

.filter-controls label {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.filter-controls select,
.filter-controls input {
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.add-maintenance {
  margin-bottom: 2rem;
  text-align: right;
}

.tasks-list {
  margin-top: 1rem;
}

.task-item {
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  padding: 1rem;
  margin-bottom: 1rem;
  border-left: 4px solid #3498db;
}

.task-item.priority-high {
  border-left-color: #e74c3c;
}

.task-item.priority-medium {
  border-left-color: #f39c12;
}

.task-item.priority-low {
  border-left-color: #27ae60;
}

.task-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.task-header h4 {
  margin: 0;
  color: #2c3e50;
}

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: bold;
}

.status-badge.status-scheduled {
  background-color: #e3f2fd;
  color: #1976d2;
}

.status-badge.status-inProgress {
  background-color: #fff3e0;
  color: #f57c00;
}

.status-badge.status-completed {
  background-color: #e8f5e8;
  color: #2e7d32;
}

.status-badge.status-overdue {
  background-color: #ffebee;
  color: #c62828;
}

.task-details {
  display: grid;
  grid-template-columns: 1fr 2fr;
  gap: 1rem;
  margin-bottom: 1rem;
}

.task-info p {
  margin: 0.25rem 0;
  font-size: 0.9rem;
}

.task-description {
  color: #666;
  font-size: 0.9rem;
}

.task-actions {
  display: flex;
  gap: 0.5rem;
}

.task-actions .btn {
  font-size: 0.8rem;
  padding: 0.25rem 0.75rem;
}

/* モーダルスタイル */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  width: 90%;
  max-width: 500px;
  max-height: 80vh;
  overflow-y: auto;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: bold;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.form-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 1.5rem;
}

@media (max-width: 768px) {
  .task-details {
    grid-template-columns: 1fr;
  }
  
  .task-actions {
    flex-direction: column;
  }
  
  .filter-controls {
    grid-template-columns: 1fr;
  }
}
</style>