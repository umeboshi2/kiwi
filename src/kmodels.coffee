bookshelf = require './bookshelf'

User = bookshelf.Model.extend
  tableName: 'users'
  idAttribute: 'uid'
  bcrypt:
    field: 'password'
  posts: ->
    @hasMany Post


Post = bookshelf.Model.extend
  tableName: 'posts'
  comments: ->
    @hasMany Comment
    
Comment = bookshelf.Model.extend
  tableName: 'comments'

DbDoc = bookshelf.Model.extend
  tableName: 'kdocs'

GenObject = bookshelf.Model.extend
  tableName: 'miscobjects'
,
  jsonColumns: ['content']
  

EbCsvConfig = bookshelf.Model.extend
  tableName: 'ebcsv_configs'
,
  jsonColumns: ['content']
  
EbCsvDescription = bookshelf.Model.extend
  tableName: 'ebcsv_descriptions'

EbClzComicPage = bookshelf.Model.extend
  tableName: 'ebcsv_clz_comic_pages'

models =
  User: User
  Post: Post
  Comment: Comment
  DbDoc: DbDoc
  GenObject: GenObject
  EbCsvConfig: EbCsvConfig
  EbCsvDescription: EbCsvDescription
  EbClzComicPage: EbClzComicPage
  
module.exports =
  knex: bookshelf.knex
  bookshelf: bookshelf
  models: models
