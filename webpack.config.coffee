path = require 'path'

webpack = require 'webpack'

ManifestPlugin = require 'webpack-manifest-plugin'
StatsPlugin = require 'stats-webpack-plugin'

loaders = require 'tbirds/src/webpack/loaders'
vendor = require 'tbirds/src/webpack/vendor'
resolve = require './webpack-config/resolve'

local_build_dir = "build"

BuildEnvironment = 'dev'
if process.env.PRODUCTION_BUILD
  BuildEnvironment = 'production'
  Clean = require 'clean-webpack-plugin'
  CompressionPlugin = require 'compression-webpack-plugin'
  ChunkManifestPlugin = require 'chunk-manifest-webpack-plugin'
  console.log "==============PRODUCTION BUILD=============="
  
WebPackOutputFilename =
  dev: '[name].js'
  production: '[name]-[chunkhash].js'
  
WebPackOutput =
  filename: WebPackOutputFilename[BuildEnvironment]
  path: path.join __dirname, local_build_dir
  publicPath: 'build/'

DefinePluginOpts =
  dev:
    __DEV__: 'true'
    DEBUG: JSON.stringify(JSON.parse(process.env.DEBUG || 'false'))
  production:
    __DEV__: 'false'
    DEBUG: 'false'
    'process.env':
      'NODE_ENV': JSON.stringify 'production'
    
StatsPluginFilename =
  dev: 'stats-dev.json'
  production: 'stats.json'

common_plugins = [
  new webpack.DefinePlugin DefinePluginOpts[BuildEnvironment]
  # FIXME common chunk names in reverse order
  # https://github.com/webpack/webpack/issues/1016#issuecomment-182093533
  new webpack.optimize.CommonsChunkPlugin
    names: ['common', 'vendor']
    filename: WebPackOutputFilename[BuildEnvironment]
  new webpack.optimize.AggressiveMergingPlugin()
  new StatsPlugin StatsPluginFilename[BuildEnvironment], chunkModules: true
  new ManifestPlugin()
  # This is to ignore moment locales with fullcalendar
  # https://github.com/moment/moment/issues/2416#issuecomment-111713308
  new webpack.IgnorePlugin /^\.\/locale$/, /moment$/
  ]

if BuildEnvironment is 'dev'
  dev_only_plugins = []
  AllPlugins = common_plugins.concat dev_only_plugins
else if BuildEnvironment is 'production'
  prod_only_plugins = [
    # production only plugins below
    new webpack.HashedModuleIdsPlugin()
    new webpack.optimize.UglifyJsPlugin
      compress:
        warnings: true
    new CompressionPlugin()
    #new ChunkManifestPlugin
    #  filename: 'chunk-manifest.json'
    #  manifestVariable: 'webpackManifest'
    new Clean local_build_dir
    ]
  AllPlugins = common_plugins.concat prod_only_plugins
else
  console.error "Bad BuildEnvironment", BuildEnvironment
  


WebPackConfig =
  entry:
    vendor: vendor
    index: './client/entries/index.coffee'
    admin: './client/entries/admin.coffee'
  output: WebPackOutput
  plugins: AllPlugins
  module:
    loaders: loaders
  resolve: resolve
  target: 'electron-renderer'
if BuildEnvironment is 'dev'
  #proxy = require './webpack-config/devserver-proxies'
  WebPackConfig.devServer =
    host: 'localhost'
    #proxy: proxy
    proxy:
      #'/assets/*': 'http://localhost:8081'
      '/api/*': 'http://localhost:8081'
      '/auth/*': 'http://localhost:8081'
      '/clzcore/*': 'http://localhost:8081'
      '/login': 'http://localhost:8081'
    historyApiFallback:
      rewrites: [
        {from: /^\/$/, to: '/_devpages/index.html'}
        {from: /^\/admin/, to: '/_devpages/admin.html'}
        ]
    stats:
      colors: true
      modules: false
      chunks: true
      #reasons: true
      maxModules: 9999
  WebPackConfig.devtool = 'source-map'

  # http://stackoverflow.com/a/11276104
  #console.log JSON.stringify proxy, null, 4
  # http://stackoverflow.com/a/33707230
  #console.dir proxy, { depth:null, colors:true}

  #console.log "=====================WEBPACK PROXY CONFIG================="
  #prettyjson = require 'prettyjson'
  #console.log prettyjson.render proxy
  #console.log "=====================WEBPACK PROXY CONFIG================="
  
module.exports = WebPackConfig
