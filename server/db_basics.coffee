databaseConf =
    server: "wiv100a041"
    userName: "user"
    password: "password"


tedious = __meteor_bootstrap__.require("tedious")
Future = __meteor_bootstrap__.require("fibers/future")

getConnection = ->
    new tedious.Connection(databaseConf)
