Backbone = require 'backbone'
Marionette = require 'backbone.marionette'

{ MainController } = require 'tbirds/controllers'
{ login_form } = require 'tbirds/templates/forms'
SlideDownRegion = require 'tbirds/regions/slidedown'
navigate_to_url = require 'tbirds/util/navigate-to-url'

# require this for ResourceChannel
require '../dbdocs/dbchannel'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
DocChannel = Backbone.Radio.channel 'static-documents'
ResourceChannel = Backbone.Radio.channel 'resources'

tc = require 'teacup'

class ReadMeModel extends Backbone.Model
  url: "https://raw.githubusercontent.com/umeboshi2/flathead/master/README.md"
  fetch: (options) ->
    options = options or {}
    options.dataType = 'text'
    super options
  parse: (response) ->
    content: response
    
frontdoor_template = tc.renderable () ->
  tc.div '#main-content.col-sm-10.col-sm-offset-1'
  
class FrontdoorLayout extends Backbone.Marionette.View
  template: frontdoor_template
  regions: ->
    content: new SlideDownRegion
      el: '#main-content'
      speed: 'slow'
  onBeforeDestroy: (view) ->
    if __DEV__
      console.log "FrontdoorLayout onBeforeDestroy!!!!", view
      console.log "Determine what to do with child apps when changing"

class Controller extends MainController
  layoutClass: FrontdoorLayout

  setup_layout_if_needed: ->
    super()
    @layout.controller = @
    
  _view_resource: (doc) ->
    @setup_layout_if_needed()
    { FrontDoorMainView } = require './views'
    view = new FrontDoorMainView
      model: doc
    @layout.showChildView 'content', view

  _view_login: ->
    LoginView = require './loginview'
    view = new LoginView
    @layout.showChildView 'content', view
    
  _view_upload: ->
    require.ensure [], () =>
      UploadView = require './uploadview'
      view = new UploadView
      @layout.showChildView 'content', view
    # name the chunk
    , 'frontdoor-upload-view'

  upload_view: ->
    @setup_layout_if_needed()
    @_view_upload()
    
  view_page: (name) ->
    doc = ResourceChannel.request 'get-document', name
    response = doc.fetch()
    response.done =>
      if not doc.get 'content'
        doc.set 'content', '# Need a front page.'
      @_view_resource doc
    response.fail ->
      MessageChannel.request 'danger', 'Failed to get document'
      

  frontdoor_needuser: ->
    user = MainChannel.request 'current-user'
    if user.has 'name'
      @frontdoor_hasuser user
    else
      @show_login()
      
  show_login: ->
    @setup_layout_if_needed()
    @_view_login()
    
  show_logout: ->
    MainChannel.request 'main:app:destroy-auth-token'
    navigate_to_url '/'
    
  frontdoor_hasuser: (user) ->
    @default_view()

  view_readme: ->
    @setup_layout_if_needed()
    model = new ReadMeModel
    if true and __DEV__
      readme = require 'raw-loader!../../../README.md'
      model = new Backbone.Model content:readme
      @_view_resource model
      return
    response = model.fetch()
    response.done =>
      @_view_resource model
    response.fail ->
      MessageChannel.request 'warning', 'failed to get readme'
      
  default_view: ->
    @setup_layout_if_needed()
    #@show_login()
    @view_readme()
    
  frontdoor: ->
    config = MainChannel.request 'main:app:config'
    if config?.needLogin
      @frontdoor_needuser()
    else
      @default_view()
      
  themeSwitcher: ->
    @setup_layout_if_needed()
    { ThemeSwitchView } = require './views'
    view = new ThemeSwitchView
    @layout.showChildView 'content', view
    console.log "themeSwitcher"
    
module.exports = Controller

