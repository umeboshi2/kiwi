exports.up = (knex, Promise) ->
  Promise.all [
    knex.schema.createTable('kdocs', (table) ->
      table.increments('id').primary()
      table.string 'name'
      table.string 'title'
      table.string 'description'
      table.string 'doctype'
      table.text 'content'
      table.timestamps()
      return
    )
  ]
  


exports.down = (knex, Promise) ->
  Promise.all [
    knex.schema.dropTable 'kdocs'
  ]
