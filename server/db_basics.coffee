unless conf.mockdata
    if conf.testing
        @databaseConf =
            server: conf.db_test_server
            userName: conf.db_test_user
            password: conf.db_test_password
    else
        @databaseConf =
            server: conf.db_server
            userName: conf.db_user
            password: conf.db_password
    @tedious = Npm.require('tedious')
    @Future = Npm.require('fibers/future')

    @getConnection = ->
        new tedious.Connection(databaseConf)
