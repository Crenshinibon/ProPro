tedious = __meteor_bootstrap__.require('tedious')

TEST = true

server = ->
    if(TEST)
        'wiv100a041'
    else
        'win100a105'

getConnection = ->
    new tedious.Connection(
        userName: 'ip'
        password: 'planview'
        server: 'wiv100a041'
    )
