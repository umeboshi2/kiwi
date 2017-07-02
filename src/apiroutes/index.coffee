path = require 'path'
jwtAuth = require 'express-jwt'

mpath = path.resolve __dirname, '..', 'models'
BSapi = require('bookshelf-api')
  path: mpath
#Promise = require 'bluebird'

env = process.env.NODE_ENV or 'development'
config = require('../../config')[env]

APIPATH = config.apipath

# model routes
basicmodel = require './basicmodel'
misc = require './miscstuff'
bookroutes = require './bookroutes'

setup = (app) ->
  config = app.locals.config
  jwtOptions = config.jwtOptions
  authOpts = secret: jwtOptions.secret
  app.use "#{APIPATH}/bapi", jwtAuth authOpts
  app.use "#{APIPATH}/bapi", BSapi

  app.use "#{APIPATH}/booky", jwtAuth authOpts
  app.use "#{APIPATH}/booky", bookroutes
  
module.exports =
  setup: setup
  
