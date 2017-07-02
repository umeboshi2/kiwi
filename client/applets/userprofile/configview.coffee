Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'

BootstrapFormView = require 'tbirds/views/bsformview'
capitalize = require 'tbirds/util/capitalize'
make_field_input_ui = require 'tbirds/util/make-field-input-ui'
navigate_to_url = require 'tbirds/util/navigate-to-url'

MainChannel = Backbone.Radio.channel 'global'

# FIXME, make a css manifest
themes = [
  'vanilla'
  'cornsilk'
  'BlanchedAlmond'
  'DarkSeaGreen'
  'LavenderBlush'
  ]

config_template = tc.renderable (model) ->
  current_theme = MainChannel.request 'main:app:get-theme'
  tc.div '.form-group', ->
    tc.label '.control-label',
      for: 'select_theme'
      "Theme"
    tc.select '.form-control', name:'select_theme', ->
      for opt in themes
        if opt is current_theme
          tc.option selected:null, value:opt, opt
        else
          tc.option value:opt, opt
  tc.input '.btn.btn-default', type:'submit', value:"Submit"
  tc.div '.spinner.fa.fa-spinner.fa-spin'

class UserConfigView extends BootstrapFormView
  template: config_template
  ui:
    theme: 'select[name="select_theme"]'
    
  createModel: ->
    @model
    
  updateModel: ->
    config = @model.get 'config'
    changed_config = false
    selected_theme = @ui.theme.val()
    MainChannel.request 'main:app:set-theme', selected_theme

  saveModel: ->
    theme = MainChannel.request 'main:app:get-theme'
    MainChannel.request 'main:app:switch-theme', theme
    @trigger 'save:form:success', @model
    
    
  onSuccess: (model) ->
    navigate_to_url '#profile'
    

module.exports = UserConfigView

