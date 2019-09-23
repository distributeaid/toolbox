const path = require('path');
const glob = require('glob');
const webpack = require('webpack');

const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');

module.exports = (env, options) => ({

  entry: {
    app: glob.sync('./vendor/**/*.min.js').concat(['./js/app.js']),
    '../stillsuit': './js/stillsuit.js'
  },

  output: {
    path: path.resolve(__dirname, '../priv/static/js'),
    filename: '[name].js'
  },

  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, 'css-loader']
      }
    ]
  },

  optimization: {
    minimizer: [
      new UglifyJsPlugin({ cache: true, parallel: true, sourceMap: false }),
      new OptimizeCSSAssetsPlugin({})
    ],

    // based on: https://medium.com/hackernoon/the-100-correct-way-to-split-your-chunks-with-webpack-f8a9df5b7758
    splitChunks: {
      chunks: 'all',
    },
  },

  plugins: [
    new CleanWebpackPlugin(),
    new CopyWebpackPlugin([{ from: 'static/', to: '../' }]),
    new MiniCssExtractPlugin({ filename: '../css/[name].css' }),
    new webpack.ProvidePlugin({
      $: 'jquery'
    })
  ]

});
