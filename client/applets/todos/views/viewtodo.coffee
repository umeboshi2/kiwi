Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'

{ navigate_to_url } = require 'tbirds/util/navigate-to-url'

view_template = tc.renderable (model) ->
  tc.div '.row.listview-list-entry', ->
    tc.span "Name: #{model.name}"
    tc.br()
    tc.span "Full Name: #{model.fullname}"
    tc.br()
    tc.span "Description"
    tc.br()
    tc.div model.description
    tc.span ".glyphicon.glyphicon-grain"
    
class MainView extends Backbone.Marionette.View
  template: view_template
    
module.exports = MainView

