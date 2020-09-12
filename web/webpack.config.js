'use strict';

const path = require('path');

module.exports = {
  devServer: {
    contentBase: path.resolve(__dirname, 'dist'),
    port: 8080,
  },
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, '../static'),
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
    modules: ['node_modules'],
    extensions: ['.purs', '.js'],
  },
};
