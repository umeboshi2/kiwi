Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'

BootstrapFormView = require 'tbirds/views/bsformview'
capitalize = require 'tbirds/util/capitalize'
make_field_input_ui = require 'tbirds/util/make-field-input-ui'
navigate_to_url = require 'tbirds/util/navigate-to-url'

{ form_group_input_div } = require 'tbirds/templates/forms'

MainChannel = Backbone.Radio.channel 'global'

# FIXME, make a css manifest
themes = [
  'cornsilk'
  'BlanchedAlmond'
  'DarkSeaGreen'
  'LavenderBlush'
  ]

chpass_form = tc.renderable () ->
  form_group_input_div
    input_id: 'input_password'
    label: 'Password'
    input_attributes:
      name: 'password'
      type: 'password'
      placeholder: 'Enter new password'
      'data-validation': 'password'
  form_group_input_div
    input_id: 'input_confirm'
    label: 'Confirm Password'
    input_attributes:
      name: 'confirm'
      type: 'password'
      placeholder: 'Confirm your new password'
      'data-validation': 'confirm'
  tc.input '.btn.btn-default.btn-xs', type:'submit', value:"Change Password"
      

class ChangePasswordView extends BootstrapFormView
  template: chpass_form
  fieldList: ['password', 'confirm']
  ui: ->
    uiobject = make_field_input_ui @fieldList
    uiobject.submit = 'input[type="submit"]'
    return uiobject
  onDomRefresh: ->
    @ui.submit.hide()
    
  createModel: ->
    @model
    
  updateModel: ->
    console.log "model", @model
    password = @ui.password.val()
    confirm = @ui.confirm.val()
    if password == confirm
      @model.set 'password', password
      @model.set 'confirm', confirm
    else
      console.log "MISMATCH"
      @trigger 'save:form:failure', @model
      
  onSuccess: (model) ->
    navigate_to_url '#profile'
  onFailure: (model) ->
    @ui.submit.hide()

module.exports = ChangePasswordView

