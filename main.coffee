{ app, BrowserWindow } = require 'electron'
path = require 'path'
url = require 'url'
process = require 'process'

console.log "we are here"

win = null

createServer = ->
  process.env.__DEV_MIDDLEWARE__ = 'true'
  process.env.OPENSHIFT_DATA_DIR = "#{__dirname}/"
  require './src/main'
  
createWindow = ->
  win = new BrowserWindow
    width: 800
    height: 600

  console.log "WIN", win
  { server } = createServer()
  server.on 'listening', ->
    win.loadURL 'http://localhost:8081'
    
  #win.loadURL url.format
  #  pathname: path.join __dirname, 'index.html'
  #  protocol: 'file'
  #  slashes: true
  win.on 'closed', =>
    win = null
    

app.on 'ready', createWindow

app.on 'window-all-closed', =>
  if process.platform != 'darwin'
    app.quit()

app.on 'activate', =>
  if win == null
    createWindow()
      
