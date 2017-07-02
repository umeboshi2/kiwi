exports.up = (knex, Promise) ->
  Promise.all [
    knex.schema.createTable('oauth_tokens', (table) ->
      table.uuid('id').primary()
      table.text 'access_token'
      table.dateTime 'access_token_expires_on'
      table.text 'client_id'
      table.text 'refresh_token'
      table.dateTime 'refresh_token_expires_on'
      table.uuid 'user_id'
      return
    )
    knex.schema.createTable('oauth_clients', (table) ->
      table.text 'client_id'
      table.text 'client_secret'
      table.text 'redirect_uri'
      table.primary ['client_id', 'client_secret']
      return
    )
    knex.schema.createTable('oauth_users', (table) ->
      table.uuid('id').primary()
      table.text 'username'
      table.text 'password'
      return
    )
  ]
  


exports.down = (knex, Promise) ->
  Promise.all [
    knex.schema.dropTable 'oauth_tokens'
    knex.schema.dropTable 'oauth_clients'
    knex.schema.dropTable 'oauth_users'
  ]
