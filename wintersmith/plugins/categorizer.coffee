
_ = require('lodash')
_categories_ = null

module.exports = (env, callback) ->
  
  ### Paginator plugin. Defaults can be overridden in config.json
      e.g. "paginator": {"perPage": 10} ###

  defaults =
    template: 'category.jade' # template that renders pages
    articles: 'articles' # directory containing contents to paginate
    index_filename: '/' # filename for all listing
    filtered_filename: '/category/%category/index.html' # filename for rest of pages

  # assign defaults any option not set in the config file
  options = env.config.categorizer or {}
  for key, value of defaults
    options[key] ?= defaults[key]

  getCategories = (articles) ->
    # categorize articles
    categories = []
    for article in articles by 1
      if article.metadata.categories
        article_categories = _.map article.metadata.categories.split(','), (cat) ->
          category: cat.trim().toLowerCase()

        categories.push article_categories

    return _.chain(categories)
            .flatten()
            .uniqBy( (cat) -> cat.category )
            .map((cat) -> cat.category)
            .value()

  getArticles = (contents) -> 
    if contents[options.articles] 
    then contents[options.articles]._.directories.map (item) -> item.index
    else []
  getFilename = (category) ->
    if category isnt 'Home'
      options.filtered_filename.replace '%category', category
    else

      options.index_filename
      '/'

  getPageCategory = (article) ->
    cats= _.map article.metadata.categories.split(','), (cat) ->
          category: cat.trim().toLowerCase()
    cats
  getArticlesByCategory = (contents, category) ->
    articles = getArticles contents
    articles.sort (a, b) -> b.date - a.date
    return articles.filter (a) -> a.metadata.categories and a.metadata.categories.split(/,\s*/).indexOf(category) > -1

  getCategoryArticles = (contents) ->
    
    # helper that returns a list of articles found in *contents*
    # note that each article is assumed to have its own directory in the articles directory
    articles = contents[options.articles]._.directories.map (item) -> item.index
    articlesByCategory = {}
    # console.log _.chain(articles).map( (art) -> art.metadata.title).value()
    # articlesByCategory = {}
    # skip articles that does not have a template associated
    articles = articles.filter (item) ->
      item.template isnt 'none' and !!item.metadata.categories

    categories = getCategories(articles)

    for category in categories by 1
      articlesByCategory[category] = {}
      articlesByCategory[category]['articles'] = _.filter articles, (article) ->
        article_categories = _.map article.metadata.categories.split(','), (cat) ->
          cat.trim().toLowerCase()
        return category in article_categories

      articlesByCategory[category]['url'] = getFilename(category)

      # sort article by date
      articlesByCategory[category]['articles'].sort (a, b) -> b.date - a.date

    return articlesByCategory

  class Categorizer extends env.plugins.Page
    ### A page has a number and a list of articles ###

    constructor: (@articles , @category, @categoriesArticles) ->

    getFilename: -> getFilename(@category)

    getView: -> (env, locals, contents, templates, callback) ->
      # simple view to pass articles and pagenum to the paginator template
      # note that this function returns a funciton

      # get the pagination template
      template = templates[options.template]
      if not template?
        return callback new Error "unknown paginator template '#{ options.template }'"


      # setup the template context
      ctx = {@articles, @category, @categoriesArticles}

      # extend the template context with the enviroment locals
      env.utils.extend ctx, locals

      # finally render the template
      template.render ctx, callback

  env.registerGenerator 'categorizer', (contents, callback) ->

    # find all articles
    articlesByCategory = getCategoryArticles contents
    ctree = {categories: {}}

    for category, catObj of articlesByCategory
      articles = catObj.articles
      ctree.categories[category] = new Categorizer articles, category, articlesByCategory

    # callback with the generated contents
    _categories_ = ctree
    callback null, ctree

  # add the article helper to the environment so we can use it later
  env.helpers.getArticlesPerCategory = -> _categories_.categories
  env.helpers.getArticlesByCategory =  getArticlesByCategory
  env.helpers.getPageCategory =  getPageCategory


  # tell the plugin manager we are done
  callback()