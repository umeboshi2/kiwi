Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
Leaflet = require 'leaflet'

require 'leaflet/dist/leaflet.css'

navigate_to_url = require 'tbirds/util/navigate-to-url'

MainChannel = Backbone.Radio.channel 'global'

map_view_template = tc.renderable (model) ->
  tc.div ->
    tc.h2 "Map View"
    tc.div "#map-view", style:'height:20em;'

    
class MapView extends Backbone.Marionette.View
  template: map_view_template
  ui:
    map: '#map-view'
  onDomRefresh: ->
    @Map = Leaflet.map 'map-view'
    zoom_level = 13
    location = [31.33, -89.28]
    #@Map.setView location, zoom_level
    @Map.on 'moveend', @getCenter
    @Map.on 'locationerror', @onLocationError
    @Map.locate
      setView: true
      watch: true
    layer = Leaflet.tileLayer 'http://{s}.tile.osm.org/{z}/{x}/{y}.png'
    layer.addTo @Map
    console.log "MAP, LAYER", @Map, layer
    circle = Leaflet.circle location, 200
    circle.addTo @Map
      
  getCenter: (event) =>
    console.log @Map.getCenter()

  onLocationError: (event) =>
    console.log "unable to get location"
    location = [31.33, -89.28]
    @Map.setView location, 13
    
module.exports = MapView

