'use strict';

const HtmlWebpackPlugin = require('html-webpack-plugin');
const path = require('path');
const webpack = require('webpack');

module.exports = {
  devServer: {
    contentBase: path.resolve(__dirname, 'dist'),
    port: 8080,
    stats: 'errors-only'
  },
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js',
  },
  module: {
    rules: [
      {
        test: /\.purs$/,
        use: [
          {
            loader: 'purs-loader',
            options: {
              src: ['src/**/*.purs'],
              spago: true,
              pscIde: true,
            },
          },
        ],
      },
    ],
  },
  resolve: {
    modules: ['node_modules'],
    extensions: ['.purs', '.js'],
  },
  plugins: [
    new HtmlWebpackPlugin({
      title: 'portfolio',
      template: 'dist/index.html',
      inject: false,
    }),
  ],
};
