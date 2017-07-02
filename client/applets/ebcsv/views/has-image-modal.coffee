Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'



{ make_field_input
  make_field_select } = require 'tbirds/templates/forms'
{ modal_close_button } = require 'tbirds/templates/buttons'

BaseModalView = require './base-modal'

AppChannel = Backbone.Radio.channel 'ebcsv'

class ImageModalView extends BaseModalView
  template: tc.renderable (model) ->
    main = model.mainsection
    tc.div '.modal-dialog', ->
      tc.div '.modal-content', ->
        tc.div '.modal-body', ->
          tc.img src: model.image_src
        tc.div '.modal-footer', ->
          tc.ul '.list-inline', ->
            btnclass = 'btn.btn-default.btn-sm'
            tc.li "#close-modal", ->
              modal_close_button 'Close', 'check'

class HasImageModal extends Marionette.Behavior
  onShowImageModal: ->
    view = new ImageModalView
      model: @view.model
    AppChannel.request 'show-modal', view

    
module.exports = HasImageModal
