<template>
  <div id="app">
    <!-- ナビゲーションバー -->
    <nav class="navbar">
      <div class="container">
        <div class="nav-brand">
          <h1>工場設備稼働監視システム</h1>
        </div>
        <ul class="nav-menu">
          <li class="nav-item">
            <router-link to="/" class="nav-link">ホーム</router-link>
          </li>
          <li class="nav-item">
            <router-link to="/equipment-status" class="nav-link">設備稼働状況</router-link>
          </li>
        </ul>
      </div>
    </nav>

    <!-- メインコンテンツ -->
    <main class="main-content">
      <router-view></router-view>
    </main>

    <!-- フッター -->
    <footer class="footer">
      <div class="container">
        <p>&copy; 2024 工場設備稼働監視システム. All rights reserved.</p>
      </div>
    </footer>
  </div>
</template>

<script>
export default {
  name: 'App',
  components: {}
}
</script>

<style scoped>
.navbar {
  background-color: #2c3e50;
  color: white;
  padding: 1rem 0;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.navbar .container {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.nav-brand h1 {
  font-size: 1.5rem;
  font-weight: 600;
}

.nav-menu {
  display: flex;
  list-style: none;
  gap: 2rem;
}

.nav-link {
  color: white;
  text-decoration: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  transition: background-color 0.3s ease;
}

.nav-link:hover,
.nav-link.router-link-active {
  background-color: #34495e;
}

.main-content {
  min-height: calc(100vh - 140px);
  padding: 2rem 0;
}

.footer {
  background-color: #34495e;
  color: white;
  text-align: center;
  padding: 1rem 0;
  margin-top: auto;
}

@media (max-width: 768px) {
  .navbar .container {
    flex-direction: column;
    gap: 1rem;
  }
  
  .nav-menu {
    gap: 1rem;
  }
  
  .nav-brand h1 {
    font-size: 1.2rem;
  }
}
</style>