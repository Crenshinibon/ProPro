Package.describe({
    summary: 'Including tedious library for access of the MS SQL database.'
});

Npm.depends({'tedious': '0.1.3'});

Package.on_use(function (api) {
    api.add_files('load_tedious.js','server')
});