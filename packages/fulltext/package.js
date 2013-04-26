Package.describe({
    summary: 'Simple 3-gram based fulltext search.'
});

Npm.depends({'cron': '1.0.0'})

Package.on_use(function (api) {
  api.use('coffeescript',['client','server']);
  api.add_files('fulltext.coffee',['client','server']);
});