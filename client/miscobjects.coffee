Backbone = require 'backbone'

MainChannel = Backbone.Radio.channel 'global'
apiroot = '/api/dev/booky'

class MiscObject extends Backbone.Model
  urlRoot: "#{apiroot}/objects"

class MiscObjectCollection extends Backbone.Collection
  url: "#{apiroot}/objects"
  model: MiscObject



MainChannel.reply 'new-miscobj-collection', ->
  return new MiscObjectCollection
  
miscobj_collection = new MiscObjectCollection
MainChannel.reply 'get-miscobj-collection', ->
  miscobj_collection
   

MainChannel.reply 'get-miscobj', (id) ->
  return new MiscObject id: id

MainChannel.reply 'new-miscobj', ->
  return new MiscObject
  
  

module.exports = null
