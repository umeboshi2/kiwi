Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
TkApplet = require 'tbirds/tkapplet'

require './dbchannel'
Controller = require './controller'

MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'todos'

class Router extends Marionette.AppRouter
  appRoutes:
    'todos': 'list_todos'
    'todos/completed': 'list_completed_todos'
    'todos/calendar': 'view_calendar'
    'todos/todos/new': 'new_todo'
    'todos/todos/edit/:id': 'edit_todo'
    'todos/todos/view/:id': 'view_todo'

    
class Applet extends TkApplet
  Controller: Controller
  Router: Router

module.exports = Applet
