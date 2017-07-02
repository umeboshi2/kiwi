exports.up = (knex, Promise) ->
  Promise.all [
    knex.schema.createTable('flathead_todos', (table) ->
      table.increments('id').primary()
      table.text('name').unique()
      table.text 'description'
      table.boolean('completed').defaultTo(false)
      table.timestamps()
      return
    )
  ]
  


exports.down = (knex, Promise) ->
  Promise.all [
    knex.schema.dropTable 'flathead_todos'
  ]

