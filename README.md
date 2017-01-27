# Spreedly Engineering Blog

[Middleman](https://middlemanapp.com) app for the [Spreedly Engineering Blog](https://engineering.spreedly.com) loosely based on the [Drops middleman template](https://github.com/5t111111/middleman-blog-drops-template).

## Install

To configure and run the app locally:

```bash
$ gem install bundler
$ bundle
$ bundle exec middleman
```

Then open http://localhost:4567 in your browser to view the site or write/design for the site.

## Publish

_This is part of the larger [Engineering Blog program](https://paper.dropbox.com/doc/Engineering-Blog-Program-0otO65Rt9y1qXkR7INHdX) process_

To create a new post, create a new file in the `source/blog` directory. Name it using dasherized form of the title. This will become the URL path so it should be contain the major keywords for the article.

```bash
$ touch source/blog/my-blog-title.md
```

In the post, add this front matter to the top of the file, and add your content below it:

```markdown
---
title: Programming Puzzles Are Not the Answer
author: Ryan Daigle
author_email: ryan@spreedly.com
author_url: https://twitter.com/rwdaigle
date: 2016-06-10
tags: hiring
next_label: Want to understand more about the philosophy that got us thinking about work samples in the first place?
next_path: /blog/stop-hazing-your-potential-hires.html
---

*A guide to creating fair and effective hiring work samples.*

It’s a common topic of discussion amongst technical organizations that the traditional, in-person,
...
```

You can preview the post locally using the "Install" instructions above.

## Deploy

_Assumes the [Heroku Toolbelt](https://toolbelt.heroku.com) is installed and authenticated_

If you've never deployed to Heroku before, you'll need to setup the Heroku git remote first. From the project directory:

```shell
$ heroku git:remote -a spreedly-engineering-staging -r staging
$ heroku git:remote -a spreedly-engineering -r prod
```

### Deploy to staging

When you're ready to deploy, you can run this:

```shell
$ git push staging master
```

To view the staging docs go to http://spreedly-engineering-staging.herokuapp.com/, or invoke `$ heroku open -r staging`.

### Deploy to production

This is the same as deploying to staging, except the command looks like this:

```shell
$ git push prod master
```

After deploying, the site should then be visible at https://engineering.spreedly.com.
