_ = require 'underscore'
Backbone = require 'backbone'

BootstrapFormView = require 'tbirds/views/bsformview'

make_field_input_ui = require 'tbirds/util/make-field-input-ui'
navigate_to_url = require 'tbirds/util/navigate-to-url'
HasAceEditor = require 'tbirds/behaviors/ace'

tc = require 'teacup'
{ make_field_input
  make_field_select } = require 'tbirds/templates/forms'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
ResourceChannel = Backbone.Radio.channel 'resources'

EditForm = tc.renderable (model) ->
  tc.div '.listview-header', 'Document'
  for field in ['name', 'title', 'description']
    make_field_input(field)(model)
  make_field_select(field, ['html', 'markdown'])(model)
  tc.div '#ace-editor', style:'position:relative;width:100%;height:40em;'
  tc.input '.btn.btn-default', type:'submit', value:"Submit"
  tc.div '.spinner.fa.fa-spinner.fa-spin'
  

class BaseFormView extends BootstrapFormView
  editorMode: 'markdown'
  editorContainer: 'ace-editor'
  fieldList: ['name', 'title', 'description']
  template: EditForm
  ui: ->
    uiobject = make_field_input_ui @fieldList
    _.extend uiobject, {'editor': '#ace-editor'}
    return uiobject
  
  behaviors:
    HasAceEditor:
      behaviorClass: HasAceEditor
      
  afterDomRefresh: () ->
    if @model.has 'content'
      content = @model.get 'content'
      @editor.setValue content

  updateModel: ->
    for field in ['name', 'title', 'description']
      @model.set field, @ui[field].val()
    # update from ace-editor
    @model.set 'content', @editor.getValue()

  onSuccess: (model) ->
    name = @model.get 'name'
    MessageChannel.request 'success', "#{name} saved successfully."
    
    
class NewPageView extends BaseFormView
  createModel: ->
    ResourceChannel.request 'new-document'
    
  saveModel: ->
    docs = ResourceChannel.request 'document-collection'
    docs.add @model
    super

class EditPageView extends BaseFormView
  # the model should be assigned in the controller
  createModel: ->
    @model
    
module.exports =
  NewPageView: NewPageView
  EditPageView: EditPageView
  

