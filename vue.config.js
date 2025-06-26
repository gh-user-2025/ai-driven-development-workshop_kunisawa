const { defineConfig } = require('@vue/cli-service')

module.exports = defineConfig({
  transpileDependencies: true,
  publicPath: process.env.NODE_ENV === 'production' ? './' : '/',
  outputDir: 'dist',
  assetsDir: '',
  lintOnSave: false,
  productionSourceMap: false,
  devServer: {
    port: 8080,
    open: true
  }
})