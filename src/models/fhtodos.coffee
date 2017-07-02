bookshelf = require '../bookshelf'

module.exports = bookshelf.Model.extend
  tableName: 'flathead_todos'
  hasTimestamps: true
