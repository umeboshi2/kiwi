Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
Masonry = require 'masonry-layout'
tc = require 'teacup'

navigate_to_url = require 'tbirds/util/navigate-to-url'
{ make_field_input
  make_field_select } = require 'tbirds/templates/forms'
{ form_group_input_div } = require 'tbirds/templates/forms'

ComicEntryView = require './comic-entry'
ComicListView = require './comic-list'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'ebcsv'


mkInputData = (field, label, placeholder) ->
  input_id: "input_#{field}"
  label: label
  input_attributes:
    name: field
    placeholder: placeholder

csv_action_select = tc.renderable () ->
  tc.div '.form-group', ->
    tc.label '.control-label', for:'select_action', 'Action'
  tc.select '.form-control', name:'select_action', ->
    for action in ['Add', 'VerifyAdd']
      tc.option selected:null, value:action, action
    
csv_cfg_select = tc.renderable (collection) ->
  tc.div '.form-group', ->
    tc.label '.control-label', for:'select_cfg', 'Config'
  tc.select '.form-control', name:'select_cfg', ->
    for m in collection.models
      name = m.get 'name'
      options =
        value:m.id
      if name is 'default'
        options.selected = ''
      tc.option options, name
    
csv_dsc_select = tc.renderable (collection) ->
  tc.div '.form-group', ->
    tc.label '.control-label', for:'select_dsc', 'Description'
  tc.select '.form-control', name:'select_dsc', ->
    for m in collection.models
      name = m.get 'name'
      options =
        value:m.id
      if name is 'default'
        options.selected = ''
      tc.option options, name



########################################
class ComicsView extends Backbone.Marionette.View
  templateContext: ->
    options = @options
    options.ebcfg_collection = AppChannel.request 'ebcfg-collection'
    options.ebdsc_collection = AppChannel.request 'ebdsc-collection'
    options
  regions:
    body: '.body'
  template: tc.renderable (model) ->
    tc.div '.listview-header', ->
      tc.text "Create CSV"
    tc.div '.mkcsv-form', ->
      csv_action_select()
      csv_cfg_select model.ebcfg_collection
      csv_dsc_select model.ebdsc_collection
    tc.div '.mkcsv-button.btn.btn-default', "Preview CSV Data"
    tc.div '.show-comics-button.btn.btn-default', "Show Comics"
    tc.div '.body'
  ui:
    mkcsv_btn: '.mkcsv-button'
    show_btn: '.show-comics-button'
    action_sel: 'select[name="select_action"]'
    cfg_sel: 'select[name="select_cfg"]'
    dsc_sel: 'select[name="select_dsc"]'
  events:
    'click @ui.mkcsv_btn': 'make_csv'
    'click @ui.show_btn': 'show_comics'

  make_csv: ->
    action = @ui.action_sel.val()
    cfg = AppChannel.request 'get-ebcfg', @ui.cfg_sel.val()
    dsc = AppChannel.request 'get-ebdsc', @ui.dsc_sel.val()
    AppChannel.request 'set-current-csv-action', action
    AppChannel.request 'set-current-csv-cfg', cfg
    AppChannel.request 'set-current-csv-dsc', dsc
    navigate_to_url '#ebcsv/csv/preview'
    
  show_comics: ->
    view = new ComicListView
      collection: @collection
    @showChildView 'body', view
    
module.exports = ComicsView


