# Spreedly Engineering Blog

[Middleman](https://middlemanapp.com) app for the [Spreedly Engineering Blog](https://engineering.spreedly.com).

## Run

To run the app locally:

```bash
$ gem install bundler
$ bundle
$ bundle exec middleman
```

Then open http://localhost:4567 in your browser to view the site or write/design for the site.

## Deploy

_Assumes the [Heroku Toolbelt](https://toolbelt.heroku.com) is installed and authenticated_

If you've never deployed to Heroku before, you'll need to setup the Heroku git remote first. From the project directory:

```shell
$ heroku git:remote -a spreedly-engineering-staging -r staging
$ heroku git:remote -a spreedly-engineering -r prod
```

### Deploy to production

When you're ready to deploy, you can run this:

```shell
$ git push prod master
```

After deploying, the production docs should then be visible at https://spreedly-engineering.spreedly.com (or https://spreedly-engineering.herokuapp.com if DNS is not yet configured or in flux).

There are two doc app instances on Heroku, `spreedly-engineering-staging` (staging) and `spreedly-engineering` (production).

### Deploy to staging

This is the same as deploying to production, except the command looks like this:

```shell
$ git push staging master
```

To view the staging docs go to http://spreedly-engineering-staging.herokuapp.com/, or invoke `$ heroku open -r staging`.
