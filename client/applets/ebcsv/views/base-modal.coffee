$ = require 'jquery'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'ebcsv'

class BaseModalView extends Marionette.View
  ui:
    close_btn: '#close-modal div'
    
  keydownHandler: (event_object) =>
    keyCode = event_object.keyCode
    #console.log "keyCode", keyCode
    # handle escape('esc') key
    if keyCode == 27
      @ui.close_btn.click()
      
  onDomRefresh: ->
    $('html').keydown @keydownHandler
  onBeforeDestroy: ->
    $('html').unbind 'keydown', @keydownHandler
    
  
module.exports = BaseModalView


