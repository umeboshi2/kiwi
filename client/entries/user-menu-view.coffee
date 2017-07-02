Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
Toolkit = require 'marionette.toolkit'
tc = require 'teacup'

MainChannel = Backbone.Radio.channel 'global'


guest_menu = tc.renderable (user) ->
  tc.li '.dropdown', ->
    tc.a '.dropdown-toggle', 'data-toggle':'dropdown', ->
      tc.text user.guestUserName
      tc.b '.caret'
    tc.ul '.dropdown-menu', ->
      tc.li ->
        tc.a href:user.loginUrl, 'login'

user_menu = tc.renderable (user) ->
  tc.li '.dropdown', ->
    tc.a '.dropdown-toggle', 'data-toggle':'dropdown', ->
      tc.text user.name
      tc.b '.caret'
    tc.ul '.dropdown-menu', ->
      tc.li ->
        tc.a href:'#profile', 'User Profile'
      # FIXME need better way to figure out admin access
      if user.username is 'admin'
        tc.li ->
          tc.a href:'/admin', 'Administration'
      tc.li ->
        tc.a href:"#frontdoor/logout", 'logout'

class UserMenuView extends Marionette.View
  tagName: 'ul'
  className: "nav navbar-nav"
  templateContext: ->
    loginUrl: @options.appConfig.loginUrl
    guestUserName: @options.appConfig.guestUserName
    # FIXME
    model: @model or new Backbone.Model
    options: @options
  template: (user) ->
    if user?.name
      console.log "We have user: #{user.name}!"
      return user_menu user
    else
      # FIXME
      console.log "We have guest!"
      return guest_menu user
      
class UserMenuApp extends Toolkit.App
  onBeforeStart: ->
    @setRegion @options.parentApp.getView().getRegion 'usermenu'
    token = MainChannel.request "main:app:decode-auth-token"
    console.log "TOKEN", token
    @options.user = token
    
  onStart: ->
    token = MainChannel
    appConfig = @options.appConfig
    view = new UserMenuView
      appConfig: appConfig
      model: new Backbone.Model @options.user
    @showView view

module.exports = UserMenuApp
