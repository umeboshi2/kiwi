$ = require 'jquery'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
ms = require 'ms'

{ MainController } = require 'tbirds/controllers'
ToolbarView = require 'tbirds/views/button-toolbar'
ShowInitialEmptyContent = require 'tbirds/behaviors/show-initial-empty'
SlideDownRegion = require 'tbirds/regions/slidedown'

navigate_to_url = require 'tbirds/util/navigate-to-url'
scroll_top_fast = require 'tbirds/util/scroll-top-fast'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
ResourceChannel = Backbone.Radio.channel 'resources'
AppChannel = Backbone.Radio.channel 'ebcsv'



class ToolbarAppletLayout extends Backbone.Marionette.View
  behaviors:
    ShowInitialEmptyContent:
      behaviorClass: ShowInitialEmptyContent
  template: tc.renderable (model) ->
    tc.div '.col-sm-12', ->
      tc.div '.row', ->
        tc.div  '#main-toolbar.col-sm-10.col-sm-offset-1'
      tc.div '.row', ->
        tc.div '#main-content.col-sm-10.col-sm-offset-1'
  regions: ->
    region = new SlideDownRegion
      el: '#main-content'
    region.slide_speed = ms '.01s'
    content: region
    toolbar: '#main-toolbar'

toolbarEntries = [
  {
    id: 'main'
    label: 'Main View'
    url: '#ebcsv'
    icon: '.fa.fa-eye'
  }
  {
    id: 'cfglist'
    label: 'Configs'
    url: '#ebcsv/cfg/list'
    icon: '.fa.fa-list'
  }
  {
    id: 'dsclist'
    label: 'Descriptions'
    url: '#ebcsv/dsc/list'
    icon: '.fa.fa-list'
  }
  {
    id: 'uploadxml'
    label: 'Upload CLZ/XML'
    url: '#ebcsv/xml/upload'
    icon: '.fa.fa-upload'
  }
  {
    id: 'mkcsv'
    label: 'Create CSV'
    url: '#ebcsv/csv/create'
    icon: '.fa.fa-cubes'
  }
  {
    id: 'cached'
    label: 'Cached Images'
    url: '#ebcsv/clzpage'
    icon: '.fa.fa-image'
  }
  ]

toolbarEntryCollection = new Backbone.Collection toolbarEntries
AppChannel.reply 'get-toolbar-entries', ->
  toolbarEntryCollection

button_style = "overflow:hidden;text-overflow:ellipsis;white-space:nowrap;"
  
class EbCsvToolbar extends ToolbarView
  options:
    entryTemplate: tc.renderable (model) ->
      opts =
        style: button_style
      tc.span opts, ->
        tc.i model.icon
        tc.text " "
        tc.text model.label

class Controller extends MainController
  layoutClass: ToolbarAppletLayout
  setup_layout_if_needed: ->
    super()
    toolbar = new EbCsvToolbar
      collection: toolbarEntryCollection
    @layout.showChildView 'toolbar', toolbar

  
  ############################################
  # ebcsv main views
  ############################################
  _show_main_view: =>
    require.ensure [], () =>
      comics = AppChannel.request 'get-comics'
      View = require './views/mainview'
      view = new View
        collection: comics
      @layout.showChildView 'content', view
    # name the chunk
    , 'ebcsv-view-main-view-helper'

  _show_create_csv_view: =>
    require.ensure [], () =>
      comics = AppChannel.request 'get-comics'
      View = require './views/mkcsv'
      view = new View
        collection: comics
      @layout.showChildView 'content', view
    # name the chunk
    , 'ebcsv-view-mkcsv-view-helper'
    
  _show_preview_csv_view: =>
    require.ensure [], () =>
      comics = AppChannel.request 'get-comics'
      View = require './views/csvpreview'
      view = new View
        collection: comics
      @layout.showChildView 'content', view
    # name the chunk
    , 'ebcsv-view-csvpreview-view-helper'
    
  _need_comics_view: (cb) ->
    comics = AppChannel.request 'get-comics'
    if not comics.length
      if __DEV__ and false
        window.comics = comics
        xml_url = '/assets/dev/comics.xml'
        xhr = Backbone.ajax
          type: 'GET'
          dataType: 'text'
          url: xml_url
        xhr.done ->
          content = xhr.responseText
          AppChannel.request 'parse-comics-xml', content, (err, json) ->
            #@_show_main_view()
            cb()
        xhr.fail ->
          navigate_to_url '#ebcsv/xml/upload'
      else
        navigate_to_url '#ebcsv/xml/upload'
    else
      cb()
      
  create_csv: =>
    @setup_layout_if_needed()
    cfgs = AppChannel.request 'ebcfg-collection'
    dscs = AppChannel.request 'ebdsc-collection'
    cfgs.fetch().then =>
      dscs.fetch().then =>
        @_need_comics_view @_show_create_csv_view
    
  preview_csv: ->
    @setup_layout_if_needed()
    cfg = AppChannel.request 'get-current-csv-cfg'
    dsc = AppChannel.request 'get-current-csv-dsc'
    hlist = AppChannel.request 'get-superheroes-model'
    if cfg is undefined
      if __DEV__
        cfg = AppChannel.request 'get-ebcfg', 1
        dsc = AppChannel.request 'get-ebdsc', 1
        AppChannel.request 'set-current-csv-cfg', cfg
        AppChannel.request 'set-current-csv-dsc', dsc
        cfg.fetch().then =>
          dsc.fetch().then =>
            hlist.fetch().then =>
              @_need_comics_view @_show_preview_csv_view
      else
        navigate_to_url '#ebcsv'
        return
    else
      cfg.fetch().then =>
        dsc.fetch().then =>
          hlist.fetch().then =>
            @_need_comics_view @_show_preview_csv_view
    
  main_view: ->
    @setup_layout_if_needed()
    @_need_comics_view @_show_main_view
    
  upload_xml: ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      comics = AppChannel.request 'get-comics'
      View = require './views/uploadxml'
      view = new View
        collection: comics
      @layout.showChildView 'content', view
    # name the chunk
    , 'ebcsv-view-upload-xml-view'
    
  view_cached_comics: ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      View = require './views/cachedcomics'
      view = new View
      @layout.showChildView 'content', view
    # name the chunk
    , 'ebcsv-view-cached-comics-view'
    
    
  ############################################
  # ebcsv configs
  ############################################
  list_configs: ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      cfgs = AppChannel.request 'ebcfg-collection'
      response = cfgs.fetch()
      response.done =>
        View = require './views/cfglist'
        view = new View
          collection: cfgs
        @layout.showChildView 'content', view
      response.fail ->
        MessageChannel.request 'danger', 'Failed to get configs'
    # name the chunk
    , 'ebcsv-view-list-configs'
    
  add_new_config: ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      Views = require './views/cfgedit'
      view = new Views.NewFormView
      @layout.showChildView 'content', view
      scroll_top_fast()
    # name the chunk
    , 'ebcsv-view-add-cfg'

  view_config: (id) ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      View = require './views/cfgview'
      model = AppChannel.request 'get-ebcfg', id
      response = model.fetch()
      response.done =>
        view = new View
          model: model
        @layout.showChildView 'content', view
        scroll_top_fast()
      response.fail ->
        MessageChannel.request 'danger', 'Failed to get configs'
    # name the chunk
    , 'ebcsv-view-config'
    
  edit_config: (id) ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      Views = require './views/cfgedit'
      model = AppChannel.request 'get-ebcfg', id
      response = model.fetch()
      response.done =>
        view = new Views.EditFormView
          model: model
        @layout.showChildView 'content', view
      response.fail ->
        MessageChannel.request 'danger', 'Failed to get configs'
    # name the chunk
    , 'ebcsv-edit-config'




  ############################################
  # ebcsv descriptions
  ############################################
  list_descriptions: ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      dscs = AppChannel.request 'ebdsc-collection'
      response = dscs.fetch()
      response.done =>
        View = require './views/dsclist'
        view = new View
          collection: dscs
        @layout.showChildView 'content', view
      response.fail ->
        MessageChannel.request 'danger', 'Failed to get descriptions'
    # name the chunk
    , 'ebcsv-view-list-descriptions'
    
  add_new_description: ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      Views = require './views/dscedit'
      view = new Views.NewFormView
      @layout.showChildView 'content', view
      scroll_top_fast()
    # name the chunk
    , 'ebcsv-view-add-dsc'

  view_description: (id) ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      View = require './views/dscview'
      model = AppChannel.request 'get-ebdsc', id
      response = model.fetch()
      response.done =>
        view = new View
          model: model
        @layout.showChildView 'content', view
        scroll_top_fast()
      response.fail ->
        MessageChannel.request 'danger', 'Failed to get descriptions'
    # name the chunk
    , 'ebcsv-view-description'
    
  edit_description: (id) ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      Views = require './views/dscedit'
      model = AppChannel.request 'get-ebdsc', id
      response = model.fetch()
      response.done =>
        view = new Views.EditFormView
          model: model
        @layout.showChildView 'content', view
      response.fail ->
        MessageChannel.request 'danger', 'Failed to get descriptions'
    # name the chunk
    , 'ebcsv-edit-description'

module.exports = Controller

