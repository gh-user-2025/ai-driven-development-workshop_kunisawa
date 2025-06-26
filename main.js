import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import App from './App.vue'
import Home from './components/Home.vue'
import EquipmentStatus from './components/EquipmentStatus.vue'

// ルーター設定
const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/equipment-status',
    name: 'EquipmentStatus',
    component: EquipmentStatus
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Vueアプリケーションの作成と設定
const app = createApp(App)
app.use(router)
app.mount('#app')