'use strict';

const CopyPlugin = require('copy-webpack-plugin');
const path = require('path');

module.exports = {
  entry: {
    index: {
      import: 'static/js/index.js',
      filename: 'index.js',
    },
    'spot-it': {
      import: 'static/js/spot-it.js',
      filename: 'spot-it.js',
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
        use: [
          {
            loader: 'file-loader',
            options: {
              publicPath: '/',
            },
          },
        ],
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
