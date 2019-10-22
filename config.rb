###
# Blog settings
###


activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  blog.prefix = "blog"

  blog.permalink = "{title}.html"
  # Matcher for blog source files
  blog.sources = "{title}.html"
  # blog.taglink = "tags/{tag}.html"
  # blog.layout = "article_layout"
  blog.summary_separator = /READMORE/
  blog.summary_length = 500
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  blog.default_extension = ".md"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  blog.paginate = true
  blog.per_page = 7
  blog.page_link = "page/{num}"
end

page '/feed.xml', layout: false
page '/sitemap.xml', layout: false
page '/robots.txt', layout: false

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", layout: false
#
# With alternative layout
# page "/path/to/file.html", layout: :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

# Markdown settings
set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true
# set :markdown_engine, :kramdown
# set :markdown,
#     layout_engine: :slim,
#     tables: true,
#     autolink: true,
#     smartypants: true,
#     input: 'GFM'

# Ignore stylesheet bundle because it is handled by webpack
# ignore 'stylesheets/style'

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  activate :asset_hash

  # Use relative URLs
  activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"

  activate :gzip
end

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

# Syntax highlight settings
activate :syntax

# Not sure why I have to do this
proxy "/stylesheets/style.css", "/stylesheets/style"

# Activate Directory Indexes
# activate :directory_indexes

# Activate Deploy
# activate :deploy do |deploy|
#   deploy.deploy_method = :git
#   deploy.branch = 'master'
#   deploy.build_before = true
# end

# activate :external_pipeline,
#          name: :webpack,
#          command: build? ? '$(npm bin)/webpack --bail -p' : '$(npm bin)/webpack --watch -d --progress --color',
#          source: '.tmp/dist',
#          latency: 1

 # activate :external_pipeline,
 #   name: :webpack,
 #   command: build? ? './node_modules/webpack/bin/webpack.js --bail' : './node_modules/webpack/bin/webpack.js --watch -d',
 #   source: ".tmp/dist",
 #   latency: 1
