const { defineConfig } = require('@vue/cli-service')
const path = require('path')

module.exports = defineConfig({
  transpileDependencies: true,
  configureWebpack: {
    resolve: {
      alias: {
        '@': path.resolve(__dirname, 'src')
      }
    }
  },
  devServer: {
    port: 8080,
    host: '0.0.0.0',
    allowedHosts: 'all',
    historyApiFallback: true
  },
  publicPath: process.env.NODE_ENV === 'production' ? './' : '/'
})