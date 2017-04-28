module.exports = (env, callback) ->

  # directory containing contents
  defaults = articles: 'articles' 

  # assign defaults any option not set in the config file
  options = {}
  for key, value of defaults
    options[key] ?= defaults[key]

  getArticles = (contents, author) ->
    console.log author
    # helper that returns a list of articles found in the contents folder
    # note that each article is assumed to have its own directory in the articles directory
    articles = contents[options.articles]._.directories.map (item) -> item.index
    articles = articles.filter (i)->  return i.metadata.draft isnt true
    articles.sort (a, b) -> b.date - a.date
    
    articles = articles.filter((i)->  return i.metadata.author == author)

    return articles

  # add the article helper to the environment so we can use it later
  env.helpers.getArticles = getArticles

  # tell the plugin manager we are done
  callback()