Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
marked = require 'marked'

BootstrapFormView = require 'tbirds/views/bsformview'
navigate_to_url = require 'tbirds/util/navigate-to-url'
{ form_group_input_div } = require 'tbirds/templates/forms'

MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'ebcsv'


mkInputData = (field, label, placeholder) ->
  input_id: "input_#{field}"
  label: label
  input_attributes:
    name: field
    placeholder: placeholder

dsc_template = tc.renderable (model) ->
  input_data = mkInputData 'destname', 'New Description', 'newdescription'
  tc.div '.form-inline', ->
    form_group_input_div input_data
    tc.div '#copy-dsc-btn.btn.btn-default', 'Copy'
    tc.div '#edit-dsc-btn.btn.btn-default', 'Edit'
  tc.div '.listview-header', ->
    tc.text "Viewing Description #{model.name}"
  tc.hr()
  tc.article '.document-view.content', ->
    tc.div '.body', ->
      tc.raw marked model.content
  

########################################
class DscView extends Backbone.Marionette.View
  template: dsc_template
  ui:
    copy_btn: '#copy-dsc-btn'
    edit_btn: '#edit-dsc-btn'
    destname_input: 'input[name="destname"]'
  events:
    'click @ui.copy_btn': 'copy_description'
    'click @ui.edit_btn': 'edit_description'
  edit_description: ->
    navigate_to_url "#ebcsv/dsc/edit/#{@model.id}"
  copy_description: ->
    foo = 'bar'
    destname = @ui.destname_input.val()
    if not destname
      MessageChannel.request 'warning', 'Please input a new description name.'
      return
    ndsc = AppChannel.request 'new-ebdsc'
    ndsc.set 'name', destname
    ndsc.set 'title', @model.get 'title'
    ndsc.set 'content', @model.get 'content'
    collection = AppChannel.request 'ebdsc-collection'
    collection.add ndsc
    response = ndsc.save()
    response.fail ->
      MessageChannel.request 'danger', 'Failed to save new description!'
    response.done ->
      msg = "Copied new description #{ndsc.get 'name'}"
      MessageChannel.request 'success', msg
      navigate_to_url "#ebcsv/dsc/view/#{ndsc.id}"
    
module.exports = DscView

