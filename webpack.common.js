const path = require('path');

module.exports = {
  entry: './src/Main.purs',
  output: {
    filename: 'main.js',
    path: path.resolve(__dirname, 'dist'),
  },
  module: {
    rules: [
      {
        test: /\.purs$/,
        loader: 'purs-loader',
        exclude: /node_modules/,
        query: {
          spago: true,
          pscIde: true,
          src: ['src/**/*.purs']
        }
      },
    ],
  },
};
