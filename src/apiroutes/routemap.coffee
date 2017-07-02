# WARNING
# This routemap object provides
# api access to the models referenced
# therein.

module.exports =
  # WARNING
  # an authenticated user can use all of the
  # routes for these models.
  basic:
    titles: 'ms_titles'
    chapters: 'ms_chapters'
    sections: 'ms_sections'
    sitedocuments: 'document'
  bookRoutes:
    User: 'User'
    Post: 'Post'
    Comment: 'Comment'
    DbDoc: 'DbDoc'
    objects: 'GenObject'
    ebcsvcfg: 'EbCsvConfig'
    ebcsvdsc: 'EbCsvDescription'
    ebclzpage: 'EbClzComicPage'
    
