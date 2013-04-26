@Search = (query) ->
    tokens = tokenize(query)
    console.log(tokens)
    "searched for: #{query}"

    
cron = Npm.require('cron')
scheduleIndexing = () ->
    

collections = {}
@SearchConf =
    makeSearchable: (options) ->
        colName = options.collection._name
        if(FulltextCollections.find({collection: colName}).count() is 0)
            FulltextCollections.insert({collection: colName})
            index(options)
        collections[colName] = options.collection
        monitorCollection(options)
    nGram: 3


tokenize = (text) ->
    #frequency
    tokens = {}
    
    if text.length > (SearchConf.nGram - 2)
        #first clean the text
        text = (" " + text + " ").toLowerCase().replace /[^a-z]/g, ' '
        text = text.replace /\s{2,}/g, ' '
    
        #iterate over every character
        current = []
        for i in [0 .. text.length]
            l = text[i]
            if (i >= SearchConf.nGram)
                ng = current.join ''
                if tokens[ng]?
                    tokens[ng] = tokens[ng] + 1
                else
                    tokens[ng] = 1
            
                current = current[1..]
                current.push l
            else
                current.push l
            
    tokens

docStub = (collectionName, docId, fieldPath, length) ->
    collection: collectionName
    doc: docId
    field: fieldPath
    length: length
    boost: 1

index = (options) ->
    tokens = tokenize('some text')
    
monitorCollection = (options) ->
    col = options.collection
    
    col.find().observeChanges(
        changed: (id, fields) ->
            console.log('Changed', fields, id)
        added: (id, fields) ->
            console.log('Added', fields, id)
        removed: (id) ->
            console.log('Removed', fields, id)
    )

    
unless FulltextIndex
    FulltextIndex = new Meteor.Collection('fulltextindex')
unless FulltextCollections
    FulltextCollections = new Meteor.Collection('fulltextcollections')
unless FulltextDocuments
    FulltextDocuments = new Meteor.Collection('fulltextdocument')
    
