_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
JView = require 'json-view'
require 'json-view/devtools.css'
marked = require 'marked'

{ modal_close_button } = require 'tbirds/templates/buttons'

MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'ebcsv'

class JsonView extends Backbone.Marionette.View
  template: tc.renderable (model) ->
    main = model.mainsection
    tc.div '.modal-dialog', ->
      tc.div '.modal-content', ->
        tc.h3 "#{main.series.displayname} ##{main.issue}"
        tc.div '.modal-body', ->
          tc.div '.expand-button.btn.btn-default', 'Expand'
          tc.div '.panel'
        tc.div '.modal-footer', ->
          tc.ul '.list-inline', ->
            btnclass = 'btn.btn-default.btn-sm'
            tc.li "#close-modal", ->
              modal_close_button 'Close', 'check'
  ui:
    body: '.panel'
    expand_btn: '.expand-button'
    close_btn: '#close-modal div'
  events:
    'click @ui.expand_btn': 'expand_view'

  expand_view: ->
    if @expanded_view
      @json_view.collapse true
      @expanded_view = false
      @ui.expand_btn.text 'Expand'
    else
      @json_view.expand true
      @expanded_view = true
      @ui.expand_btn.text 'Collapse'
    
  keydownHandler: (event_object) =>
    keyCode = event_object.keyCode
    #console.log "keyCode", keyCode
    if keyCode == 27
      @ui.close_btn.click()
      
  onDomRefresh: ->
    $('html').keydown @keydownHandler
    @expanded_view = false
    @json_view = new JView @model.toJSON()
    @ui.body.prepend @json_view.dom

  onBeforeDestroy: ->
    $('html').unbind 'keydown', @keydownHandler
    

module.exports = JsonView
