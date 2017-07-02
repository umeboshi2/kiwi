Promise = require 'bluebird'
express = require 'express'

routemap = require('./routemap').basic

router = express.Router()

ignored_fields = ['id', 'created_at', 'updated_at']


#router.use hasUserAuth

router.param 'models', (req, res, next, value) ->
  req.ModelClass = sql.models[routemap[value]]
  req.ModelRoute = value
  next()
    
router.get '/:models', (req, res) ->
  req.ModelClass.findAll
    where: req.query
  .then (result) ->
    res.json result

router.get '/:models/include', (req, res) ->
  includes = []
  for rel of req.ModelClass.associations
    includes.push req.ModelClass.associations[rel]
  req.ModelClass.findAll
    where: req.query
    include: includes
  .then (result) ->
    res.json result

router.post '/:models', (req, res) ->
  console.log 'body---->', req.body
  # FIXME sanitize body
  req.ModelClass.create req.body
  .then (model) ->
    # successful create gets a 201 status
    res.status 201
    # and a location header pointing to new object
    res.header 'Location', "/#{req.ModelRoute}/#{model.id}"
    res.json model
    

router.get "/:models/create-cal", (req, res) ->
  req.ModelClass.findAll
    where:
      created_at:
        $between: [req.query.start, req.query.end]
  .then (rows) ->
    cal_events = []
    for model in rows
      item =
        id: model.id
        start: model.created_at
        end: model.created_at
      if 'name' of model
        item.title = model.name
      else if 'title' of model
        item.title = model.title
      else
        item.title = "#{req.ModelRoute}-#{item.id}"
      cal_events.push item
    res.json cal_events


router.param 'id', (req, res, next, value) ->
  options =
    where:
      id: req.params.id
  if 'include' of req.query
    console.log "req.query", req.query
    console.log "req.query.include", req.query.include
    includes = []
    if req.query.include is '*'
      for rel of req.ModelClass.associations
        includes.push req.ModelClass.associations[rel]
      options.include = includes
    else
      for rel in req.query.include
        includes.push req.ModelClass.associations[rel]
      options.include = includes
    console.log 'ModelClass', req.ModelClass, options
  req.ModelClass.find options
  .then (model) ->
    req.model = model
    next()
    
  
router.delete '/:models/:id', (req, res) ->
  req.model.destroy
    where:
      id: req.model.id
  .then (result) ->
    res.json result
    
router.get '/:models/:id', (req, res) ->
  res.json req.model

router.put '/:models/:id', (req, res) ->
  updated = {}
  for field of req.body
    if field not in ignored_fields and req.body[field] != req.model.field
      updated[field] = req.body[field]
  # FIXME do I need to set updated_at? 
  #updated.updated_at = sql.fn 'now'
  req.model.update updated,
    where:
      id: req.model.id
  .then (result) ->
    res.json result
    
  
  

module.exports = router

  
