Backbone = require 'backbone'

{ make_dbchannel } = require 'tbirds/crud/basecrudchannel'

AppChannel = Backbone.Radio.channel 'ebcsv'

ComicAges =
  platinum:
    start: 1897
    end: 1937
  golden:
    start: 1938
    end: 1955
  silver:
    start: 1956
    end: 1969
  bronze:
    start: 1970
    end: 1983
  copper:
    start: 1984
    end: 1991
  modern:
    start: 1992
    # FIXME magic number for end of modern age
    end: 2100

get_comic_age = (year) ->
  for age of ComicAges
    ad = ComicAges[age]
    #console.log "Checking age", age, ad.start, ad.end
    if (year >= ad.start and year <= ad.end)
      return age
  return false
  
AppChannel.reply 'get-comic-ages', ->
  ComicAges

AppChannel.reply 'get-age', (year) ->
  get_comic_age year
  
  
class BaseLocalStorageModel extends Backbone.Model
  initialize: () ->
    @fetch()
    @on 'change', @save, @
  fetch: () ->
    #console.log '===== FETCH FIRED LOADING LOCAL STORAGE ===='
    @set JSON.parse localStorage.getItem @id
  save: (attributes, options) ->
    #console.log '===== CHANGE FIRED SAVING LOCAL STORAGE ===='
    localStorage.setItem(@id, JSON.stringify(@toJSON()))
    return $.ajax
      success: options.success
      error: options.error
  destroy: (options) ->
    #console.log '===== DESTROY LOCAL STORAGE ===='
    localStorage.removeItem @id
  isEmpty: () ->
    _.size @attributes <= 1


class BaseLocalStorageCollection extends Backbone.Collection
  local_storage_key: null
  initialize: () ->
    #console.log "initialize DocumentCollection"
    @fetch()
    @on 'change', @save, @
    
  fetch: () ->
    #console.log 'fetching documents'
    docs = JSON.parse(localStorage.getItem(@local_storage_key)) || []
    @set docs

  # FIXME!
  save: (collection) ->
    #console.log 'saving documents'
    localStorage.setItem(@local_storage_key, JSON.stringify(@toJSON()))


class LocalCfgCollection extends BaseLocalStorageCollection
  local_storage_key: 'csv_configlist'
  model: BaseLocalStorageModel
   # FIXME: This is ugly!
  add_cfg: (name) ->
    sitename = "#{name}.tumblr.com"
    model = new BaseLocalStorageModel
      id: "cfg_#{name}"
    model.set 'name', name
    @add model
    @save()
    model.fetch()
    return model
  
local_configs = new LocalCfgCollection
AppChannel.reply 'get_local_configs', ->
  local_configs
      
ReqFieldNames = [
  'format'
  'location'
  'returnsacceptedoption'
  'duration'
  'quantity'
  'startprice'
  'dispatchtimemax'
  'conditionid'
  ]

AppChannel.reply 'csv-req-fieldnames', ->
  ReqFieldNames

OptFieldNames = [
  'postalcode'
  'paymentprofilename'
  'returnprofilename'
  'shippingprofilename'
  'scheduletime'
  ]
  
AppChannel.reply 'csv-opt-fieldnames', ->
  OptFieldNames
  
class BaseCsvFieldsModel extends BaseLocalStorageModel

class BaseReqFieldsModel extends BaseCsvFieldsModel
  fieldType: 'required'
  fieldNames: ReqFieldNames
  
class BaseOptFieldsModel extends BaseCsvFieldsModel
  fieldType: 'optional'
  fieldNames: OptFieldNames



AppChannel.reply 'get-ebcsv-config', (name) ->
  model = new BaseLocalStorageModel
    id: "cfg_#{name}"
  model.fetch()
  return model
  

#class EbCsvSettings extends BaseLocalStorageModel
#  id: 'ebcsv_settings'
#
#consumer_key = '4mhV8B1YQK6PUA2NW8eZZXVHjU55TPJ3UZnZGrbSoCnqJaxDyH'
#ebcsv_settings = new EbCsvSettings consumer_key:consumer_key

#AppChannel.reply 'get_ebcsv_settings', ->
#  ebcsv_settings


module.exports = {}
