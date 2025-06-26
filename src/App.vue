<template>
  <div id="app">
    <!-- ヘッダーナビゲーション -->
    <header class="app-header">
      <h1>工場設備管理システム</h1>
      <nav class="main-nav">
        <router-link to="/equipment" class="nav-link">設備一覧</router-link>
        <router-link to="/maintenance" class="nav-link">メンテナンス管理</router-link>
      </nav>
    </header>

    <!-- メインコンテンツエリア -->
    <main class="main-content">
      <router-view></router-view>
    </main>

    <!-- フッター -->
    <footer class="app-footer">
      <p>&copy; 2024 工場設備管理システム - AI-Driven Development Workshop</p>
    </footer>
  </div>
</template>

<script>
export default {
  name: 'App',
  mounted() {
    console.log('工場設備管理アプリが起動しました');
  }
}
</script>

<style>
/* グローバルスタイル */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Arial', 'Helvetica', 'MS Gothic', sans-serif;
  background-color: #f5f5f5;
  color: #333;
}

#app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* ヘッダースタイル */
.app-header {
  background-color: #2c3e50;
  color: white;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.app-header h1 {
  font-size: 1.5rem;
  font-weight: bold;
}

.main-nav {
  display: flex;
  gap: 2rem;
}

.nav-link {
  color: white;
  text-decoration: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.nav-link:hover,
.nav-link.router-link-active {
  background-color: #34495e;
}

/* メインコンテンツ */
.main-content {
  flex: 1;
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
  width: 100%;
}

/* フッター */
.app-footer {
  background-color: #34495e;
  color: white;
  text-align: center;
  padding: 1rem;
  margin-top: auto;
}

/* 共通のカードスタイル */
.card {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 1rem;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

/* ステータス表示 */
.status-running {
  color: #27ae60;
  font-weight: bold;
}

.status-stopped {
  color: #e74c3c;
  font-weight: bold;
}

.status-maintenance {
  color: #f39c12;
  font-weight: bold;
}

/* ボタンスタイル */
.btn {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  text-decoration: none;
  display: inline-block;
  transition: background-color 0.3s;
}

.btn-primary {
  background-color: #3498db;
  color: white;
}

.btn-primary:hover {
  background-color: #2980b9;
}

.btn-success {
  background-color: #27ae60;
  color: white;
}

.btn-success:hover {
  background-color: #219a52;
}

.btn-warning {
  background-color: #f39c12;
  color: white;
}

.btn-warning:hover {
  background-color: #e67e22;
}
</style>