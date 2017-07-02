Promise = require 'bluebird'
express = require 'express'

routemap = require('./routemap').bookRoutes

router = express.Router()

router.param 'models', (req, res, next, value) ->
  models = req.app.locals.models
  res.locals.ModelClass = models[routemap[value]]
  res.locals.ModelRoute = value
  next()

router.get '/:models', (req, res) ->
  model = new res.locals.ModelClass
  model.fetchAll()
  .then (models) ->
    res.json models

router.get '/:models/search', (req, res) ->
  model = new res.locals.ModelClass
  model.fetchAll()
  .then (models) ->
    res.json models

router.post '/:models', (req, res) ->
  #console.log 'body---->', req.body
  model = new res.locals.ModelClass req.body
  model.save()
  .then (result) ->
    # successful create gets a 201 status
    res.status 201
    # and a location header pointing to new object
    res.header 'Location', "/#{req.ModelRoute}/#{result.id}"
    res.json result
  
router.delete '/:models/:id', (req, res) ->
  new res.locals.ModelClass
    id: req.params.id
  .destroy()
  .then (result) ->
    res.json result
    
router.get '/:models/:id', (req, res) ->
  new res.locals.ModelClass
    id: req.params.id
  .fetch()
  .then (result) ->
    res.json result

router.put '/:models/:id', (req, res) ->
  model = new res.locals.ModelClass
    id: req.params.id
  .save req.body
  .then (result) ->
    res.json result

module.exports = router

  
