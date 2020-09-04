const HtmlWebpackPlugin = require('html-webpack-plugin');
const common = require('./webpack.common.js');
const { merge } = require('webpack-merge');

module.exports = merge(common, {
  mode: 'development',
  plugins: [
    // Autogenerates an index.html file for our webpack dev server to load.
    new HtmlWebpackPlugin(),
  ],
});
