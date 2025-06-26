<template>
  <div id="app">
    <nav class="navigation">
      <h1>AI駆動開発ワークショップ</h1>
      <ul>
        <li><router-link to="/">ホーム</router-link></li>
        <li><router-link to="/about">概要</router-link></li>
      </ul>
    </nav>
    
    <main>
      <router-view />
    </main>
    
    <footer>
      <p>&copy; 2024 AI駆動開発ワークショップテンプレート</p>
    </footer>
  </div>
</template>

<script>
export default {
  name: 'App'
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.navigation {
  background-color: #42b883;
  color: white;
  padding: 1rem;
}

.navigation h1 {
  margin: 0 0 1rem 0;
}

.navigation ul {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  gap: 2rem;
}

.navigation a {
  color: white;
  text-decoration: none;
  font-weight: bold;
}

.navigation a:hover {
  text-decoration: underline;
}

main {
  flex: 1;
  padding: 2rem;
}

footer {
  background-color: #f8f9fa;
  padding: 1rem;
  text-align: center;
  margin-top: auto;
}
</style>