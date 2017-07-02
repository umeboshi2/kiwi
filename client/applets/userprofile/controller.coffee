tc = require 'teacup'

navigate_to_url = require 'tbirds/util/navigate-to-url'
{ MainController } = require 'tbirds/controllers'
{ ToolbarAppletLayout } = require 'tbirds/views/layout'


MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'userprofile'


side_bar_data = new Backbone.Model
  entries: [
    {
      name: 'Profile'
      url: '#profile'
    }
    {
      name: 'Map'
      url: '#profile/mapview'
    }
    {
      name: 'Settings'
      url: '#profile/editconfig'
    }
    {
      name: 'Change Password'
      url: '#profile/chpassword'
    }
    ]


toolbar_template = tc.renderable (model) ->
  tc.div '.btn-group.btn-group-justified', ->
    for entry in model.entries
      icon = entry?.icon or 'info'
      tc.div '.toolbar-button.btn.btn-default',
      'button-url': entry.url, ->
        tc.span ".fa.fa-#{icon}", ' ' + entry.name

class ToolbarView extends Backbone.Marionette.View
  template: toolbar_template
  ui:
    toolbarButton: '.toolbar-button'
  events:
    'click @ui.toolbarButton': 'toolbarButtonPressed'
  toolbarButtonPressed: (event) ->
    console.log "toolbarButtonPressed", event
    url = event.currentTarget.getAttribute 'button-url'
    navigate_to_url url
    
class Controller extends MainController
  #sidebarclass: SidebarView
  #sidebar_model: side_bar_data
  layoutClass: ToolbarAppletLayout
  setup_layout_if_needed: ->
    super()
    view = new ToolbarView
      model: side_bar_data
    @layout.showChildView 'toolbar', view
  
  show_profile: ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      ViewClass = require './mainview'
      # current-user is always there when app is
      # running
      user = MainChannel.request 'current-user'
      view = new ViewClass
        model: user
      @layout.showChildView 'content', view
    # name the chunk
    , 'userprofile-view-show-profile'

  view_map: ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      ViewClass = require './mapview'
      # current-user is always there when app is
      # running
      user = MainChannel.request 'current-user'
      view = new ViewClass
        model: user
      @_show_content view
    # name the chunk
    , 'userprofile-view-map-view'

  edit_config: ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      ViewClass = require './configview'
      # current-user is always there when app is
      # running
      user = MainChannel.request 'current-user'
      view = new ViewClass
        model: user
      @layout.showChildView 'content', view
    # name the chunk
    , 'userprofile-view-edit-config'
      
  change_password: ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      ViewClass = require './chpassview'
      view = new ViewClass
        model: AppChannel.request 'new-password-model'
      @layout.showChildView 'content', view
    # name the chunk
    , 'userprofile-view-chpasswd'
      
      
module.exports = Controller

