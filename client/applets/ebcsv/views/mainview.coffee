$ = require 'jquery'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
Masonry = require 'masonry-layout'
tc = require 'teacup'

navigate_to_url = require 'tbirds/util/navigate-to-url'
{ make_field_input
  make_field_select } = require 'tbirds/templates/forms'

ComicEntryView = require './comic-entry'
ComicListView = require './comic-list'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'ebcsv'

#class ComicListView extends Backbone.Marionette.CollectionView
#  childView: ComicEntryView

class ComicsView extends Backbone.Marionette.View
  regions:
    #list: '#comiclist-container'
    body: '.body'
  template: tc.renderable (model) ->
    tc.div '.listview-header', ->
      tc.text "CLZ XML to EBay File Exchange CSV"
    tc.div '.body'
  onRender: ->
    view = new ComicListView
      collection: @collection
    @showChildView 'body', view
    
module.exports = ComicsView


