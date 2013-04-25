Package.describe({
    summary: 'Simple 3-gram based fulltext search.'
});

Npm.depends({"coffee-script": "1.5.0"});

var compileFile = function(fileName, context) {
  //console.log(context)
  var fs = Npm.require('fs');
  var path = Npm.require('path');
  var coffee = Npm.require('coffee-script');
  
  var filePath = path.join(context.source_root, fileName);
  //console.log(filePath)
  var contents = fs.readFileSync(filePath);
  var options = {bare: true, filename: fileName, literate: false};
  contents = coffee.compile(contents.toString('utf8'), options);
  
  contents = new Buffer(contents);
  //console.log(contents)
  var newFileName = fileName + ".js"
  var newFilePath = path.join(context.source_root, newFileName);
  fs.writeFileSync(newFilePath, contents);
  return newFileName;
}


Package.on_use(function (api) {
  api.add_files(compileFile('fulltext.coffee',this),['client','server'])
});