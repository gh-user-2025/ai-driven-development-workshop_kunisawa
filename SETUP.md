# Vue.js セットアップガイド

## プロジェクト概要

このプロジェクトは AI駆動開発ワークショップのためのVue.js アプリケーションテンプレートです。

## 前提条件

- Node.js (バージョン 14 以上)
- npm または yarn
- Git

## セットアップ手順

### 1. 依存関係のインストール

```bash
npm install
```

### 2. 開発サーバーの起動

```bash
npm run serve
```

または

```bash
npm run dev
```

開発サーバーが起動すると、以下のURLでアプリケーションにアクセスできます：
- ローカル: http://localhost:8080/
- ネットワーク: http://[IPアドレス]:8080/

### 3. プロダクションビルド

```bash
npm run build
```

ビルド成果物は `dist` ディレクトリに出力されます。

## プロジェクト構成

```
/
├── public/
│   └── index.html          # HTMLテンプレート
├── src/
│   ├── components/         # Vueコンポーネント
│   │   ├── Home.vue       # ホームページコンポーネント
│   │   └── About.vue      # 概要ページコンポーネント
│   ├── App.vue            # ルートコンポーネント
│   └── main.js            # アプリケーションエントリーポイント
├── package.json           # 依存関係とスクリプト定義
└── README.md              # このファイル
```

## 主な機能

### ページ構成
- **ホームページ** (`/`): ワークショップの概要と特徴を表示
- **概要ページ** (`/about`): 詳細な学習内容と技術スタック

### 技術スタック
- Vue.js 3 (Composition API対応)
- Vue Router 4 (ページ遷移)
- Vue CLI Service (ビルドツール)

## 開発のヒント

### コンポーネントの追加
新しいページやコンポーネントを追加する場合：

1. `src/components/` ディレクトリに新しい `.vue` ファイルを作成
2. `src/main.js` でルートを追加
3. 必要に応じて `src/App.vue` のナビゲーションを更新

### スタイリング
- 各コンポーネントは `<style scoped>` を使用してスコープ付きスタイルを適用
- グローバルスタイルは `public/index.html` または `src/App.vue` で定義

## デプロイ

### Azure Static Web Apps への デプロイ

```bash
# Azure CLI にログイン
az login

# Static Web App の作成
az staticwebapp create \
  --name your-app-name \
  --resource-group your-resource-group \
  --source https://github.com/your-username/your-repo \
  --location "West US 2" \
  --branch main \
  --app-location "/" \
  --output-location "dist"
```

## トラブルシューティング

### よくある問題

1. **ビルドエラー**: `node_modules` を削除して再インストール
   ```bash
   rm -rf node_modules package-lock.json
   npm install
   ```

2. **ポート競合**: 別のポートを指定
   ```bash
   npm run serve -- --port 3000
   ```

3. **ルーティングエラー**: Vue Router の設定を確認

## 次のステップ

1. 新しいコンポーネントやページの追加
2. Vuex または Pinia を使用した状態管理の実装
3. API との連携機能の追加
4. テストの作成
5. CI/CD パイプラインの設定

## 参考リンク

- [Vue.js 公式ドキュメント](https://vuejs.org/)
- [Vue Router ドキュメント](https://router.vuejs.org/)
- [Vue CLI ドキュメント](https://cli.vuejs.org/)
- [Azure Static Web Apps ドキュメント](https://docs.microsoft.com/azure/static-web-apps/)