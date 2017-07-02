Marionette = require 'backbone.marionette'
TkApplet = require 'tbirds/tkapplet'

require './dbchannel'
Controller = require './controller'

MainChannel = Backbone.Radio.channel 'global'
ResourceChannel = Backbone.Radio.channel 'resources'



class Router extends Marionette.AppRouter
  appRoutes:
    'dbdocs': 'list_pages'
    'dbdocs/documents': 'list_pages'
    'dbdocs/documents/new': 'new_page'
    'dbdocs/documents/view/:id': 'view_page'
    'dbdocs/documents/edit/:id': 'edit_page'
    
class Applet extends TkApplet
  Controller: Controller
  Router: Router

  onBeforeStart: ->
    super arguments
    MainChannel.reply 'applet:dbdocs:router', =>
      @router
    MainChannel.reply 'applet:dbdocs:controller', =>
      @router.controller

module.exports = Applet
