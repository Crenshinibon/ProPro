databaseConf =
    server: db_server
    userName: db_user
    password: db_password


tedious = __meteor_bootstrap__.require("tedious")
Future = __meteor_bootstrap__.require("fibers/future")

getConnection = ->
    new tedious.Connection(databaseConf)
