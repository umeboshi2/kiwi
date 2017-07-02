fs = require 'fs'
path = require 'path'

_ = require 'underscore'
Promise = require 'bluebird'
express = require 'express'

router = express.Router()


multer = require 'multer'
upload = multer
  dest: 'uploads/'

{ get_models } = require './common'


#router.use hasUserAuth

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
