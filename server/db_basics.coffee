databaseConf =
    server: conf.db_server
    userName: conf.db_user
    password: conf.db_password


tedious = __meteor_bootstrap__.require("tedious")
Future = __meteor_bootstrap__.require("fibers/future")

getConnection = ->
    new tedious.Connection(databaseConf)
