exports.up = (knex, Promise) ->
  Promise.all [
    knex.schema.createTable('miscobjects', (table) ->
      table.increments('id').primary()
      table.string 'name'
      table.text 'content'
      table.timestamps()
      return
    )
  ]
  


exports.down = (knex, Promise) ->
  Promise.all [
    knex.schema.dropTable 'miscobjects'
  ]

