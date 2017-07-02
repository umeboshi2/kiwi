Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
navigate_to_url = require 'tbirds/util/navigate-to-url'

MainChannel = Backbone.Radio.channel 'global'

user_profile_template = tc.renderable (model) ->
  tc.div ->
    tc.h2 "User Name: #{model.name}"
    tc.br()
    tc.h2 "Config:"
    tc.table ->
      for prop of model.config
        tc.tr ->
          tc.td ->
            tc.h3 prop
          tc.td ->
            tc.span model.config[prop]

    
class UserMainView extends Backbone.Marionette.View
  template: user_profile_template
  ui:
    edit: '#edit-userconfig'
    chpass: '#change-password'
  
  events: ->
    'click @ui.edit': -> navigate_to_url '#profile/editconfig'
    'click @ui.chpass': -> navigate_to_url '#profile/chpassword'

    
  


module.exports = UserMainView

