bodyParser = require 'body-parser'

morgan = require 'morgan'
proxy = require 'express-http-proxy'

env = process.env.NODE_ENV or 'development'

setup = (app) ->
  config = app.locals.config
  # logging
  app.use morgan 'combined'

  # parsing
  if config.middleware.cookieParser
    cookieParser = require 'cookie-parser'
    app.use cookieParser()
  app.use bodyParser.json limit: '10mb'
  app.use bodyParser.urlencoded({ extended: true })
  # session handling
  if config.middleware.expressSession
    expressSession = require 'express-session'
    app.use expressSession
      secret: config.middleware.sessionSecret
      resave: false
      saveUninitialized: false

  # redirect to https
  #if '__DEV__' of process.env and process.env.__DEV__ is 'true'
  if config.middleware.httpsRedirect
    httpsRedirect = require 'express-https-redirect'
    app.use '/', httpsRedirect()
  else
    console.warn 'skipping httpsRedirect'

  # proxies
  app.use '/clzcore', proxy('http://core.collectorz.com')
  
module.exports =
  setup: setup
  
