<template>
  <div class="about">
    <h2>ワークショップ概要</h2>
    
    <div class="about-content">
      <section>
        <h3>目的</h3>
        <p>AI駆動開発の手法を習得し、効率的なソフトウェア開発スキルを身につけることです。</p>
      </section>
      
      <section>
        <h3>学習内容</h3>
        <ul>
          <li>GitHub Copilot の活用方法</li>
          <li>Vue.js を使ったモダンWebアプリケーション開発</li>
          <li>Azure クラウドサービスとの連携</li>
          <li>AI アシスタントを活用したコード生成とレビュー</li>
          <li>効率的な開発ワークフローの構築</li>
        </ul>
      </section>
      
      <section>
        <h3>対象者</h3>
        <ul>
          <li>Web開発の基礎知識がある方</li>
          <li>JavaScript/Vue.js に興味がある方</li>
          <li>AI を活用した開発手法を学びたい方</li>
          <li>効率的な開発プロセスを構築したい方</li>
        </ul>
      </section>
      
      <section>
        <h3>技術スタック</h3>
        <div class="tech-stack">
          <span class="tech-item">Vue.js 3</span>
          <span class="tech-item">Vue Router</span>
          <span class="tech-item">GitHub Copilot</span>
          <span class="tech-item">Azure CLI</span>
          <span class="tech-item">Node.js</span>
        </div>
      </section>
    </div>
  </div>
</template>

<script>
export default {
  name: 'About'
}
</script>

<style scoped>
.about {
  max-width: 800px;
  margin: 0 auto;
}

.about-content {
  text-align: left;
}

section {
  margin-bottom: 2rem;
  padding: 1.5rem;
  background: #f8f9fa;
  border-radius: 8px;
  border-left: 4px solid #42b883;
}

section h3 {
  margin-top: 0;
  color: #42b883;
}

ul {
  margin: 0;
  padding-left: 1.5rem;
}

li {
  margin-bottom: 0.5rem;
}

.tech-stack {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.tech-item {
  background: #42b883;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: bold;
}
</style>