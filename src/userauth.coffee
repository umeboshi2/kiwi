bcrypt = require 'bcryptjs'

_ = require 'underscore'
jwt = require 'jsonwebtoken'

jwtAuth = require 'express-jwt'

#auth = (req, res, next) ->
#  if req.isAuthenticated()
#    next()
#  else
#    res.redirect '/#frontdoor/login'

auth = (req, res, next) ->
  config = req.app.locals.config
  secret = config.jwtOptions.secret
  jwtAuth secret: secret
  next()
  
  
setup = (app) ->
  config = app.locals.config
  jwtOptions = config.jwtOptions
  authOpts = secret: jwtOptions.secret
  app.get '/login', (req, res) ->
    res.redirect '/'

  app.get '/auth/refresh', jwtAuth authOpts
  app.get '/auth/refresh', (req, res) ->
    #console.log "Success!", req.user
    payload =
      uid: req.user.uid
      username: req.user.username
      name: req.user.name
    #console.log "TOKEN PAYLOAD", payload
    token = jwt.sign payload, jwtOptions.secret, expiresIn:jwtOptions.expiresIn
    res.json
      msg: 'ok'
      token: token
    
  app.post '/auth/chpass', jwtAuth authOpts
  app.post '/auth/chpass', (req, res) ->
    if req.body.password != req.body.confirm
      # we expect this to have been done using
      # client side validation.  Profess teapottery
      # on malformed requests.
      res.sendStatus 418
      return
    users = req.app.locals.models.User.collection()
    users.query
      where:
        uid: req.user.uid
    .fetchOne().then (model) ->
      #console.log "MODEL", model
      if model is null
        res.sendStatus 401
        return
      values =
        password: req.body.password
      where =
        uid: req.user.uid
      #model.update values, where
      model.save values
      .then (result) ->
        res.json result
    
  app.post '/login', (req, res) ->
    #console.log "req.body", req.body
    name = req.body.username
    password = req.body.password
    #tuser = new req.app.locals.models.User.forge(password:password)
    users = req.app.locals.models.User.collection()
    users.query
      where:
        username:name
    .fetchOne().then (model) ->
      #console.log "MODEL", model
      if model is null
        res.sendStatus 401
        return
      password = model.get 'password'
      #console.log "password", password
      model.compare req.body.password, password
      .then (isValid) ->
        if isValid
          uid = model.get 'uid'
          console.log "UID IS", uid
          payload =
            uid: model.get 'uid'
            username: model.get 'username'
            name: model.get 'name'
          #console.log "TOKEN PAYLOAD", payload
          token = jwt.sign(payload,
            jwtOptions.secret, expiresIn:jwtOptions.expiresIn)
          res.json
            msg: 'ok'
            token: token
        else
          res.sendStatus 401
        

module.exports =
  setup: setup
  auth: auth
  
