fs = require 'fs'
path = require 'path'

_ = require 'underscore'
Promise = require 'bluebird'
express = require 'express'

#router.use hasUserAuth

get_models = (req, res) ->
  modellist = []
  models = req.app.locals.models
  knex = req.app.locals.knex
  names = (m for m of models)
  objs = (new models[m] for m in names)
  columns = (knex(o.tableName).columnInfo() for o in objs)
  Promise.all columns
  .then (result) ->
    ls = _.zip names, objs, result
    for tuple in ls
      obj = tuple[1]
      o =
        name: tuple[0]
        config:
          attributes: Object.keys tuple[2]
        table_name: obj.tableName
      modellist.push o
    res.locals.models = modellist

module.exports = 
  get_models: get_models
  
