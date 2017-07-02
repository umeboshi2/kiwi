# proxies for devserver
#
os = require 'os'
module.exports =
  '/api/*':
    target: "http://#{os.hostname()}:8081"
    secure: false
  '/rest/*':
    target: "http://#{os.hostname()}:8081"
    secure: false
  '/hello/*':
    target: "http://#{os.hostname()}:8081"
    secure: false
  '/health/*':
    target: "http://#{os.hostname()}:8081"
    secure: false
  '/login/*':
    target: "http://#{os.hostname()}:8081"
    secure: false
  '/logout/*':
    target: "http://#{os.hostname()}:8081"
    secure: false
        
