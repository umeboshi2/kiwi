$= require 'jquery'
Backbone = require 'backbone'
require 'bootstrap'

if __DEV__
  console.warn "__DEV__", __DEV__, "DEBUG", DEBUG
  Backbone.Radio.DEBUG = true

require 'tbirds/applet-router'
require '../authmodels'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'

MainChannel.reply 'main:app:switch-theme', (theme) ->
  href = "assets/stylesheets/bootstrap-#{theme}.css"
  ss = $ 'head link[href^="assets/stylesheets/bootstrap-"]'
  ss.attr 'href', href

MainChannel.reply 'main:app:set-theme', (theme) ->
  localStorage.setItem 'main-theme', theme

MainChannel.reply 'main:app:get-theme', ->
  localStorage.getItem 'main-theme'
  

module.exports = {}



