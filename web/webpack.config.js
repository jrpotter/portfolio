'use strict';

const path = require('path');

const output = '../static';

module.exports = {
  devServer: {
    contentBase: path.resolve(__dirname, output),
    port: 8080,
  },
  entry: {
    common: {
      import: './src/common.js',
      filename: path.join('..', output, 'common.js'),
    },
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
