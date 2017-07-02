exports.up = (knex, Promise) ->
  Promise.all [
    knex.schema.createTable('uploads', (table) ->
      table.increments('id').primary()
      table.text 'fieldname'
      table.text 'originalname'
      table.text 'encoding'
      table.text 'mimetype'
      table.text 'destination'
      table.text 'filename'
      table.text 'path'
      table.bigint 'size'
      table.timestamps()
      return
    )
  ]
  


exports.down = (knex, Promise) ->
  Promise.all [
    knex.schema.dropTable 'uploads'
  ]

