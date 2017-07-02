exports.up = (knex, Promise) ->
  Promise.all [
    knex.schema.createTable('ebcsv_configs', (table) ->
      table.increments('id').primary()
      table.text('name').unique()
      table.text 'content'
      table.timestamps()
      return
    )
    knex.schema.createTable('ebcsv_descriptions', (table) ->
      table.increments('id').primary()
      table.text('name').unique()
      table.text 'title'
      table.text 'content'
      table.timestamps()
      return
    )
    knex.schema.createTable('ebcsv_clz_comic_pages', (table) ->
      table.increments('id').primary()
      table.text('url').unique()
      table.text 'image_src'
      return
    )
  ]
  


exports.down = (knex, Promise) ->
  Promise.all [
    knex.schema.dropTable 'ebcsv_configs'
    knex.schema.dropTable 'ebcsv_descriptions'
    knex.schema.dropTable 'ebcsv_clz_comic_pages'
  ]

