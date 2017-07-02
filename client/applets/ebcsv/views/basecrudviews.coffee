Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'

navigate_to_url = require 'tbirds/util/navigate-to-url'
require 'tbirds/regions/bsmodal'
{ modal_close_button } = require 'tbirds/templates/buttons'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'



ConfirmDeleteTemplate = tc.renderable (model) ->
  tc.div '.modal-dialog', ->
    tc.div '.modal-content', ->
      tc.h3 "Do you really want to delete #{model.name}?"
      tc.div '.modal-body', ->
        tc.div '#selected-children'
      tc.div '.modal-footer', ->
        tc.ul '.list-inline', ->
          btnclass = 'btn.btn-default.btn-sm'
          tc.li "#confirm-delete-button", ->
            modal_close_button 'OK', 'check'
          tc.li "#cancel-delete-button", ->
            modal_close_button 'Cancel'
    

class ConfirmDeleteModal extends Backbone.Marionette.View
  template: ConfirmDeleteTemplate
  ui:
    confirm_delete: '#confirm-delete-button'
    cancel_button: '#cancel-delete-button'
    
  events: ->
    'click @ui.confirm_delete': 'confirm_delete'

  confirm_delete: ->
    name = @model.get 'name'
    response = @model.destroy()
    response.done =>
      MessageChannel.request 'success', "#{name} deleted.",
    response.fail =>
      MessageChannel.request 'danger', "#{name} NOT deleted."
      
class BaseItemView extends Backbone.Marionette.View
  ui:
    edit_item: '.edit-item'
    delete_item: '.delete-item'
    item: '.list-item'
    
  events: ->
    'click @ui.edit_item': 'edit_item'
    'click @ui.delete_item': 'delete_item'
    
  edit_item: ->
    navigate_to_url "##{@route_name}/#{@item_type}s/edit/#{@model.id}"
    
  _show_modal: (view, backdrop) ->
    app = MainChannel.request 'main:app:object'
    layout = app.getView()
    modal_region = layout.getRegion 'modal'
    modal_region.backdrop = backdrop
    modal_region.show view

  
  delete_item: ->
    if __DEV__
      console.log "delete_#{@item_type}", @model
    view = new ConfirmDeleteModal
      model: @model
    if __DEV__
      console.log 'modal view', view
    @_show_modal view, true
    #MainChannel.request 'main:app:show-modal', view, {backdrop:true}
    

class BaseListView extends Backbone.Marionette.CompositeView
  childViewContainer: "##{@item_type}-container"
  ui: ->
    make_new_item: "#new-#{@item_type}"
    
  events: ->
    'click @ui.make_new_item': 'make_new_item'

  make_new_item: ->
    # FIXME - fix url dont't add 's'
    navigate_to_url "##{@route_name}/#{@item_type}s/new"
    
  

module.exports =
  BaseItemView: BaseItemView
  BaseListView: BaseListView
  

