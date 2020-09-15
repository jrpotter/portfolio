'use strict';

const CopyPlugin = require('copy-webpack-plugin');
const path = require('path');

module.exports = {
  entry: {
    common: {
      import: 'static/js/common.js',
      filename: 'common.js',
    },
  },
  plugins: [
    new CopyPlugin({
      patterns: [
        { from: 'static/index.html', to: 'index.html' },
      ],
    }),
  ],
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
      {
        test: /\.css$/,
        use: [
          'style-loader',
          {
            loader: 'css-loader',
            options: {importLoaders: 1}
          },
          'postcss-loader',
        ],
      },
      {
        test: /\.(svg|eot|otf|woff|woff2|ttf)$/,
        use: ['file-loader']
      },
    ],
  },
  resolve: {
    alias: {
      src: path.resolve(__dirname, 'src'),
      static: path.resolve(__dirname, 'static'),
    },
    extensions: ['.purs', '.js'],
    modules: ['node_modules'],
  },
};
