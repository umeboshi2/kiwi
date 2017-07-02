Backbone = require 'backbone'

{ make_dbchannel } = require 'tbirds/crud/basecrudchannel'

MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'todos'
TodoChannel = AppChannel

AuthModel = MainChannel.request 'main:app:AuthModel'
AuthCollection = MainChannel.request 'main:app:AuthCollection'


apiroot = "/api/dev/bapi"
url = "#{apiroot}/fhtodos"

class Todo extends AuthModel
  urlRoot: url
  defaults:
    completed: false
    

class TodoCollection extends AuthCollection
  url: url
  model: Todo


todo_collection = new TodoCollection()

make_dbchannel TodoChannel, 'todo', Todo, TodoCollection

class TodoCalendar extends AuthCollection
  url: "/api/dev/basic/todos/create-cal"
  model: Todo

todo_cal = new TodoCalendar
TodoChannel.reply 'todocal-collection', ->
  todo_cal


current_calendar_date = undefined
TodoChannel.reply 'maincalendar:set-date', () ->
  cal = $ '#maincalendar'
  current_calendar_date = cal.fullCalendar 'getDate'

TodoChannel.reply 'maincalendar:get-date', () ->
  current_calendar_date
  
if __DEV__
  window.todo_collection = todo_collection

module.exports =
  TodoCollection: TodoCollection
