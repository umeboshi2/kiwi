path = require 'path'

dbfile = path.join __dirname, '/flathead.sqlite'
#postgresql://$OPENSHIFT_POSTGRESQL_DB_HOST:$OPENSHIFT_POSTGRESQL_DB_PORT
module.exports =
  development:
    database:
      client: 'sqlite3'
      connection: filename: dbfile
      debug: false
    brand: 'Flathead'
    apipath: '/api/dev'
    middleware:
      cookieParser: true
      expressSession: false
      sessionSecret: "This should be secret. Don't look Ethyl!"
      httpsRedirect: false
    jwtOptions:
      secret: process.env.JWT_SECRET or "This is the jwt secret."
      #expiresIn:'7d'
      expiresIn:'1h'
    adminUser:
      name: 'Admin User'
      username: 'admin'
      password: 'admin'
  production:
    database:
      client: 'pg'
      connection:
        host: process.env.OPENSHIFT_POSTGRESQL_DB_HOST
        port: process.env.OPENSHIFT_POSTGRESQL_DB_PORT
        user: process.env.OPENSHIFT_POSTGRESQL_DB_USERNAME
        password: process.env.OPENSHIFT_POSTGRESQL_DB_PASSWORD
        database: process.env.PGDATABASE
      #connection: filename: "#{process.env.OPENSHIFT_DATA_DIR}flathead.sqlite"
      debug: false
    brand: 'Flathead'
    apipath: '/api/dev'
    middleware:
      cookieParser: true
      expressSession: false
      sessionSecret: "This should be secret. Don't look Ethyl!"
      httpsRedirect: true
    jwtOptions:
      secret: process.env.JWT_SECRET or "This is the jwt secret."
      expiresIn:'7d'
    adminUser:
      name: 'Admin User'
      username: 'admin'
      password: 'random'
