Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
marked = require 'marked'

BootstrapFormView = require 'tbirds/views/bsformview'
navigate_to_url = require 'tbirds/util/navigate-to-url'
{ form_group_input_div } = require 'tbirds/templates/forms'

MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'ebcsv'

ReqFieldNames = AppChannel.request 'csv-req-fieldnames'
OptFieldNames = AppChannel.request 'csv-opt-fieldnames'

mkInputData = (field, label, placeholder) ->
  input_id: "input_#{field}"
  label: label
  input_attributes:
    name: field
    placeholder: placeholder

cfg_template = tc.renderable (model) ->
  tc.div '.form-inline', ->
    form_group_input_div mkInputData 'destname', 'New Config', 'newconfig'
    tc.div '#copy-cfg-btn.btn.btn-default', 'Copy Config'
    tc.div '#edit-cfg-btn.btn.btn-default', 'Edit Config'
  tc.div '.listview-header', ->
    tc.text "Viewing Config #{model.name}"
  tc.hr()
  tc.article '.document-view.content', ->
    tc.div '.body', ->
      tc.dl '.dl-horizontal', ->
        for field in ReqFieldNames
          tc.dt field
          tc.dd model.content[field]
      tc.dl '.dl-horizontal', ->
        for field in OptFieldNames
          tc.dt field
          tc.dd model.content[field]
  

########################################
class CfgView extends Backbone.Marionette.View
  template: cfg_template
  ui:
    copy_btn: '#copy-cfg-btn'
    edit_btn: '#edit-cfg-btn'
    destname_input: 'input[name="destname"]'
  events:
    'click @ui.copy_btn': 'copy_config'
    'click @ui.edit_btn': 'edit_config'
  edit_config: ->
    navigate_to_url "#ebcsv/cfg/edit/#{@model.id}"
  copy_config: ->
    foo = 'bar'
    destname = @ui.destname_input.val()
    if not destname
      MessageChannel.request 'warning', 'Please input a new config name.'
      return
    ncfg = AppChannel.request 'new-ebcfg'
    ncfg.set 'name', destname
    ncfg.set 'content', @model.get 'content'
    collection = AppChannel.request 'ebcfg-collection'
    collection.add ncfg
    response = ncfg.save()
    response.fail ->
      MessageChannel.request 'danger', 'Failed to save new config!'
    response.done ->
      msg = "Copied new config #{ncfg.get 'name'}"
      MessageChannel.request 'success', msg
      navigate_to_url "#ebcsv/cfg/view/#{ncfg.id}"
    
module.exports = CfgView

