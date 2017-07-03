os = require 'os'
path = require 'path'
http = require 'http'

express = require 'express'
favicon = require 'serve-favicon'
knex = require 'knex'

# Set the default environment to be `development`
process.env.NODE_ENV = process.env.NODE_ENV || 'development'

env = process.env.NODE_ENV or 'development'
configPath = process.env.OPENSHIFT_DATA_DIR + 'config'
#config = require('../config')[env]
config = require(configPath)[env]

Middleware = require './middleware'
UserAuth = require './userauth'

pages = require './pages'

webpackManifest = require '../build/manifest.json'


UseMiddleware = false or process.env.__DEV_MIDDLEWARE__ is 'true'
PORT = process.env.NODE_PORT or 8081
HOST = process.env.NODE_IP or 'localhost'
#HOST = process.env.NODE_IP or '0.0.0.0'

# create express app
app = express()
app.use favicon path.join __dirname, '../assets/favicon.ico'

# health url required for openshift
app.get '/health', (req, res, next) ->
  res.end()

{ knex
  bookshelf
  models } = require './kmodels'
      


app.locals.config = config
app.locals.knex = knex
app.locals.bookshelf = bookshelf
app.locals.models = models

Middleware.setup app
UserAuth.setup app
  
ApiRoutes = require './apiroutes'
ApiRoutes.setup app

app.use '/assets', express.static(path.join __dirname, '../assets')
# FIXME, don't use this long....
tmpimages_dir = process.env.OPENSHIFT_DATA_DIR + 'tmpimages'
app.use '/tmpimages', express.static tmpimages_dir
if UseMiddleware
  #require 'coffee-script/register'
  webpack = require 'webpack'
  middleware = require 'webpack-dev-middleware'
  config = require '../webpack.config'
  compiler = webpack config
  app.use middleware compiler,
    #publicPath: config.output.publicPath
    # FIXME using abosule path?
    publicPath: '/build/'
    stats:
      colors: true
      modules: false
      chunks: true
      #reasons: true
      maxModules: 9999
  console.log "Using webpack middleware"
else
  app.use '/build', express.static(path.join __dirname, '../build')

# serve thumbnails
if process.env.NODE_ENV == 'development'
  thumbsdir = path.join __dirname, '../thumbs'
else
  thumbsdir = "#{process.env.OPENSHIFT_DATA_DIR}thumbs"
app.use '/thumbs', express.static(thumbsdir)
  
app.get '/', pages.make_page 'index'
app.get '/oldindex', pages.make_page 'oldindex'

check_for_admin_user = (app, cb) ->
  user = new app.locals.models.User
  users = app.locals.models.User.collection().count()
  .then (count) ->
    # coerce to int
    # https://github.com/tgriesser/bookshelf/issues/1275
    count = parseInt count
    if not count
      config = app.locals.config
      admin = new app.locals.models.User
      password = config.adminUser.password
      if password == 'random'
        console.log "Using random password for admin user"
        uuid = require 'uuid'
        password = uuid()
      user_atts =
        name: config.adminUser.name
        username: config.adminUser.username
        password: password
      app.locals.models.User.forge user_atts
      .save()
      .then (user) ->
        cb count
    else
      cb count
      

server = http.createServer app
serving_msg = "#{config.brand} server running on #{HOST}:#{PORT}."

check_for_admin_and_start = ->
  check_for_admin_user app, (count) ->
    console.log "There are #{count} users."
    if not count
      console.log "admin account created."
    server.listen PORT, HOST, ->
      console.log serving_msg
  

if process.env.NO_DB_SYNC
  server.listen PORT, HOST, ->
    console.log serving_msg
else
  console.log "calling knex.migrate()"
  knex.migrate.latest config.database
  .then ->
    console.log "Migration finished"
    knex.seed.run config.database
  .then ->
    console.log "Seed finished"
    check_for_admin_and_start()
  .catch (err) ->
    if err.message.startsWith 'insert into "photos"'
      console.log "fantasy seed not needed"
      check_for_admin_and_start()
    else
      console.log "EM IS", err.message
      throw err
          
module.exports =
  app: app
  server: server
  
  
