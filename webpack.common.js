'use strict';

const CopyPlugin = require('copy-webpack-plugin');
const path = require('path');

module.exports = {
  entry: {
    'index': {
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
        // HTML notebooks generated using nbconvert.
        {
          from: 'notebooks/*.html',
          to: 'notebooks/[name].[ext]'
        },
        // We copy MathJax fonts over from `node_modules` into our static
        // folder. The MathJax lib expects this to exist in a certain path
        // though, which we configure here.
        {
          from: 'static/fonts/MathJax_*',
          to: 'output/chtml/fonts/woff-v2/[name].[ext]',
        },
        // This is the mustache template we swap some Javascript file (those
        // listed in `entry` above) into.
        {
          from: 'static/index.html',
          to: 'index.html',
        },
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
