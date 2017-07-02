Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'


class HasHeader extends Marionette.Behavior
  onSetHeader: (text) ->
    @ui.header.text text
    
module.exports = HasHeader
