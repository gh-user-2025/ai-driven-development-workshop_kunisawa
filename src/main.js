// main.js - メインエントリーポイント
import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import App from './App.vue'

// コンポーネントのインポート
import EquipmentList from './components/EquipmentList.vue'
import EquipmentDetail from './components/EquipmentDetail.vue'
import MaintenanceManager from './components/MaintenanceManager.vue'

// ルーター設定
const routes = [
  { path: '/', redirect: '/equipment' },
  { path: '/equipment', component: EquipmentList, name: 'equipment-list' },
  { path: '/equipment/:id', component: EquipmentDetail, name: 'equipment-detail' },
  { path: '/maintenance', component: MaintenanceManager, name: 'maintenance' }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Vueアプリケーションの作成と設定
const app = createApp(App)
app.use(router)
app.mount('#app')