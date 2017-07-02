fs = require 'fs'
path = require 'path'

_ = require 'underscore'
Promise = require 'bluebird'
express = require 'express'

router = express.Router()



router.get "/:models/hubcal", (req, res) ->
  req.ModelClass.findAll
    attributes: default_attributes
    where:
      date:
        $between: [req.query.start, req.query.end]
  .then (rows) ->
    cal_events = []
    for model in rows
      item =
        id: model.id
        start: model.date
        end: model.date
      if 'name' of model
        item.title = model.name
      else if 'title' of model
        item.title = model.title
      else
        item.title = "#{req.ModelRoute}-#{item.id}"
      cal_events.push item
    res.json cal_events

router.get '/all-models', (req, res) ->
  get_models req, res
  .then ->
    res.json res.locals.models

router.post '/upload-photos', upload.array('zathras', 12), (req, res) ->
  console.log req.files
  res.app.locals.sql.models.uploads.bulkCreate req.files
  .then ->
    res.json
      result: 'success'
      data: req.files


module.exports = router
