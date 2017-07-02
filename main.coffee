{ app, BrowserWindow } = require 'electron'
path = require 'path'
url = require 'url'
process = require 'process'

console.log "we are here"

win = null

createWindow = ->
  win = new BrowserWindow
    width: 800
    height: 600

  console.log "WIN", win
  win.loadURL url.format
    pathname: path.join __dirname, 'index.html'
    protocol: 'file'
    slashes: true
  win.on 'closed', =>
    win = null
    

app.on 'ready', createWindow

app.on 'window-all-closed', =>
  if process.platform != 'darwin'
    app.quit()

app.on 'activate', =>
  if win == null
    createWindow()
      
