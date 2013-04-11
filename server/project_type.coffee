@ref =
    initProjectTypes: ->
        unless conf.mockdata
            fut = new Future()

            con = getConnection()
            con.on('connect', (err) ->
                if(err)
                    console.log('connect error: ' + err)
                executeStatement()
            )

            sql = 'select structure_code, description from structure
            where structure_name = \'Wbs22\' and depth = 2
            and structure_code not in (\'188\',\'189\',\'836\')'

            executeStatement = ->
                result = []
                req = new tedious.Request(sql, (err, rowCount) ->
                    if(err)
                        console.log(err)
                    else
                        fut.ret(result)
                )
                req.on('row', (columns) ->
                    result.push(
                        structureCode: columns.structure_code.value
                        description: columns.description.value
                    )
                )
                con.execSql(req)

            result = fut.wait()
            ProjectTypes.remove({})
                        
            result.forEach (e) ->
                ProjectTypes.insert(
                    lu: e.structureCode
                    desc: e.description
                )
        else
            ProjectTypes.remove({})
            ProjectTypes.insert(
                lu: '1234'
                desc: 'Standard'
            )
            ProjectTypes.insert(
                lu: '1235'
                desc: 'Critical'
            )