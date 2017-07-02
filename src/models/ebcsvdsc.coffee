bookshelf = require '../bookshelf'

module.exports = bookshelf.Model.extend
  tableName: 'ebcsv_descriptions'
  hasTimestamps: true
