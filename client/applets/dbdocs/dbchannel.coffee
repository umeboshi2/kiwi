Backbone = require 'backbone'

{ make_dbchannel } = require 'tbirds/crud/basecrudchannel'

MainChannel = Backbone.Radio.channel 'global'
ResourceChannel = Backbone.Radio.channel 'resources'

apipath = "/api/dev/booky/DbDoc"


AuthModel = MainChannel.request 'main:app:AuthModel'
AuthCollection = MainChannel.request 'main:app:AuthCollection'

class Document extends AuthModel
  urlRoot: apipath
  
class DocumentCollection extends AuthCollection
  url: apipath
  model: Document

make_dbchannel ResourceChannel, 'document', Document, DocumentCollection

module.exports =
  DocumentCollection: DocumentCollection

