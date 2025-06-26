import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import App from './App.vue'

// ルーター設定
const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import('./components/Home.vue')
  },
  {
    path: '/about',
    name: 'About', 
    component: () => import('./components/About.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Vueアプリケーションの作成とマウント
const app = createApp(App)
app.use(router)
app.mount('#app')