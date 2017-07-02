$ = require 'jquery'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
Masonry = require 'masonry-layout'
imagesLoaded = require 'imagesloaded'
tc = require 'teacup'

EmptyView = require 'tbirds/views/empty'
navigate_to_url = require 'tbirds/util/navigate-to-url'
{ make_field_input
  make_field_select } = require 'tbirds/templates/forms'

ComicEntryView = require './comic-entry'
HasMasonryView = require './base-masonry'


MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'ebcsv'


class HasLateImages extends HasMasonryView
  onChildviewShowImage: (child) ->
    @setMasonryLayout()

class ComicCollectionView extends Backbone.Marionette.CollectionView
  childView: ComicEntryView
  emptyView: EmptyView
  # relay show:image event to parent
  childViewTriggers:
    'show:image': 'show:image'
    
listContainer = '#comiclist-container'
class ComicListView extends Backbone.Marionette.View
  options:
    listContainer: listContainer
  ui: ->
    list: @getOption 'listContainer'
  regions:
    list: '@ui.list'
  behaviors:
    HasLateImages:
      behaviorClass: HasLateImages
      listContainer: listContainer
      masonryOptions:
        gutter: 1
        isInitLayout: false
        itemSelector: '.item'
        columnWidth: 10
        horizontalOrder: false
  template: tc.renderable (model) ->
    tc.div '#comiclist-container'
  onRender: ->
    view = new ComicCollectionView
      collection: @collection
    @showChildView 'list', view
    
module.exports = ComicListView


