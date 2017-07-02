Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'

BootstrapFormView = require 'tbirds/views/bsformview'
{ form_group_input_div } = require 'tbirds/templates/forms'
navigate_to_url = require 'tbirds/util/navigate-to-url'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'ebcsv'

########################################
new_cfg_form_view = tc.renderable (model) ->
  form_group_input_div
    input_id: 'input_cfgname'
    label: 'Config Name'
    input_attributes:
      name: 'cfg_name'
      placeholder: 'Type a config name'
      value: 'default'
  tc.input '.btn.btn-default.btn-xs', type:'submit', value:'Add Cfg'

########################################

class NewCfgFormView extends BootstrapFormView
  template: new_cfg_form_view
  ui:
    cfg_name: '[name="cfg_name"]'

  updateModel: ->
    #console.log 'updateModel'
    @collection = AppChannel.request 'get_local_configs'
    @model = @collection.add_cfg @ui.cfg_name.val()

  onSuccess: ->
    #console.log 'onSuccess called'
    navigate_to_url '#ebcsv/cfg/list'

  createModel: ->
    return new Backbone.Model url:'/'



module.exports = NewCfgFormView


