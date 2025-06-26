<template>
  <div class="home">
    <h2>AI駆動開発ワークショップへようこそ</h2>
    
    <div class="workshop-intro">
      <p>このワークショップでは、AI を活用した開発手法を学びます。</p>
      
      <div class="features">
        <div class="feature-card">
          <h3>🤖 AI プログラミング</h3>
          <p>AIアシスタントを使った効率的なコード生成</p>
        </div>
        
        <div class="feature-card">
          <h3>🔧 Vue.js 開発</h3>
          <p>モダンなフロントエンド開発フレームワーク</p>
        </div>
        
        <div class="feature-card">
          <h3>☁️ Azure 連携</h3>
          <p>クラウドサービスとの統合開発</p>
        </div>
      </div>
      
      <div class="getting-started">
        <h3>はじめる</h3>
        <ol>
          <li>開発環境の準備</li>
          <li>プロジェクトのセットアップ</li>
          <li>AI アシスタントの活用</li>
          <li>実践的な開発演習</li>
        </ol>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Home'
}
</script>

<style scoped>
.home {
  max-width: 800px;
  margin: 0 auto;
}

.workshop-intro {
  text-align: left;
}

.features {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.feature-card {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 8px;
  border: 1px solid #e9ecef;
}

.feature-card h3 {
  margin-top: 0;
  color: #42b883;
}

.getting-started {
  background: #e8f5e8;
  padding: 1.5rem;
  border-radius: 8px;
  margin-top: 2rem;
}

.getting-started h3 {
  margin-top: 0;
  color: #2d5a36;
}

.getting-started ol {
  margin: 0;
  padding-left: 1.5rem;
}

.getting-started li {
  margin-bottom: 0.5rem;
}
</style>