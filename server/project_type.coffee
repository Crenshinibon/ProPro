
initProjectTypes = (callback) ->
    result = {}

    con = getConnection()
    con.on('connect', (err) ->
        executeStatement()
    )

    sql = 'select structure_code, description from structure where structure_name = \'Wbs22\' and depth = 2'
    executeStatement = ->
        req = new tedious.Request(sql, (err, rowCount) ->
            if(err)
                console.log(err)
            else
                console.log('Fetched ' + rowCount + ' project types.')
        )
        req.on('row', (columns) ->
            result[columns.structure_code.value] = columns.description.value
        )
        req.on('done', (rowCount, more) ->
            console.log('done called')
            callback(result)
        )
        
        con.execSql(req)
    