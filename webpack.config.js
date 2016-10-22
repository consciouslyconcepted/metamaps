const webpack = require('webpack')

const NODE_ENV = process.env.NODE_ENV || 'development'

const plugins = [
  new webpack.DefinePlugin({
    "process.env.NODE_ENV": `"${NODE_ENV}"`
  })
]
if (NODE_ENV === 'production') {
  plugins.push(new webpack.optimize.DedupePlugin())
  plugins.push(new webpack.optimize.UglifyJsPlugin({
    compress: { warnings: false }
  }))
}

const devtool = NODE_ENV === 'production' ? undefined : 'cheap-module-eval-source-map'

const config = module.exports = {
  context: __dirname,
  plugins,
  devtool,
  module: {
    preLoaders: [
      { test: /\.json$/, loader: 'json' }
    ],
    loaders: [
      {
        test: /\.(js|jsx)?$/,
        exclude: /node_modules/,
        loaders: [
          'babel-loader?cacheDirectory&retainLines=true'
        ]
      }
    ]
  },
  entry: {
    'metamaps.bundle': './frontend/src/index.js'
  },
  output: {
    path: './app/assets/javascripts/webpacked',
    filename: '[name].js',
    devtoolModuleFilenameTemplate: '[absolute-resource-path]'
  }
}
