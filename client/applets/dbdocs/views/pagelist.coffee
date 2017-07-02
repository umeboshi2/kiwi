Backbone = require 'backbone'
Marionette = require 'backbone.marionette'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
ResourceChannel = Backbone.Radio.channel 'resources'


Templates = require 'tbirds/templates/basecrud'

Views = require 'tbirds/crud/basecrudviews'

ItemTemplate = Templates.base_item_template 'document', 'dbdocs'
        
ListTemplate = Templates.base_list_template 'document'

class ItemView extends Views.BaseItemView
  route_name: 'dbdocs'
  template: ItemTemplate
  item_type: 'document'
  

  
class ListView extends Views.BaseListView
  route_name: 'dbdocs'
  childView: ItemView
  template: ListTemplate
  childViewContainer: '#document-container'
  item_type: 'document'
    

module.exports = ListView

