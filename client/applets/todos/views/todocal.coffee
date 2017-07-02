Backbone = require 'backbone'
tc = require 'teacup'

FullCalendar = require 'fullcalendar'

require 'fullcalendar/dist/fullcalendar.css'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'todos'

apiroot = "/api/dev/bapi"
url = "#{apiroot}/fhtodos"

todo_calendar = tc.renderable () ->
  tc.div '.listview-header', 'Todos'
  tc.div '#loading', ->
    tc.h2 'Loading Todos'
  tc.div '#maincalendar'

loading_calendar_events = (bool) ->
  loading = $ '#loading'
  header = $ '.fc-header'
  if bool
    loading.show()
    header.hide()
  else
    loading.hide()
    header.show()
  

render_calendar_event = (calEvent, element) ->
  calEvent.url = "#todos/todos/view/#{calEvent.id}"
  element.css
    'font-size' : '0.9em'

calendar_view_render = (view, element) ->
  AppChannel.request 'maincalendar:set-date'
        
  
class TodoCalendarView extends Backbone.Marionette.View
  template: todo_calendar
  ui:
    calendar: '#maincalendar'
    
  onDomRefresh: () ->
    auth = MainChannel.request 'main:app:authBeforeSend'
    date = AppChannel.request 'maincalendar:get-date'
    cal = @ui.calendar
    cal.fullCalendar
      header:
        left: 'month, today, agendaWeek'
        center: 'title'
        right: 'prev, next'
      theme: false
      defaultView: 'month'
      eventSources:
        [
          url: "/api/dev/basic/todos/create-cal"
          beforeSend: auth.sendAuthHeader
        ]
      eventRender: render_calendar_event
      viewRender: calendar_view_render
      loading: loading_calendar_events
      eventClick: (event) ->
        url = event.url
        Backbone.history.navigate url, trigger: true
    # if the current calendar date that has been set,
    # go to that date
    if date != undefined
      cal.fullCalendar('gotoDate', date)
        
      
module.exports = TodoCalendarView

