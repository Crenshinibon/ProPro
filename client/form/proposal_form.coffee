###Shared functions and values###
editableEventMap = (updateEvent, tag, modelAttr, actionFun) ->
    map = {}
    map["#{updateEvent} #{tag}"] = (e) ->
        e.preventDefault()
        e.stopImmediatePropagation()
        actionFun(this, event.target.value)
    map['dblclick'] = (e) ->
        e.preventDefault()
        e.stopImmediatePropagation()
        if(model.allowedToEdit(Meteor.user(), this))
            model.updateEditState(Meteor.user(), this._id + modelAttr)
        else
            showMessage(this, labels.not_allowed_to_edit_message)
    map["blur #{tag}"] = (e) ->
        e.preventDefault()
        e.stopImmediatePropagation()
        model.updateEditState(Meteor.user(), '')
    map
    
blurOnEnter = () ->
    'keypress input': (e) ->
        if(e.which is 13)
            e.preventDefault()
            e.stopImmediatePropagation()
            model.updateEditState(Meteor.user(), '')

showMessage = (proposal, message) ->
    pid = proposal._id
    $("##{pid} .message-block-content").text(message)
    $("##{pid} .message-block").fadeIn()
    Meteor.setTimeout(hideMessageBlock,20000)

hideMessageBlock = ->
    $('#message_block').fadeOut('slow')

nothing_lu = 'nothing_selected'

###Proposal form###
Template.proposal_form.showDblClickNotice = () ->
    user = Meteor.user()
    
    user and 
    model.allowedToEdit(user, this) and not 
    model.hasClosedNotice(user,'dblclick')

Template.proposal_form.events(
    'submit form': ->
        false
    'click button.close': (e) ->
        model.closeNotice(Meteor.user(),e.target.name)
    )

###Proposal title display and inupt###
setProposalTitle = (proposal, title) ->
    Proposals.update({_id: proposal._id},
        $set:
            title: title
            lastChangeDate: new Date
    )

Template.title.events(editableEventMap('keyup','input','title',setProposalTitle))
Template.title.events(blurOnEnter())

###Project Types display and input!###
setProjectType = (proposal, type) ->
    Proposals.update({_id: proposal._id},
        $set: 
            type: type
            lastChangeDate: new Date
        )

getProjectTypeDesc = (lu) ->
    pt = ProjectTypes.findOne({lu: lu})
    if(pt) then pt.desc else labels.nothing_selected


Template.project_type.getProjectTypes = ->
    res = ProjectTypes.find().fetch()
    res.push(
        lu: nothing_lu
        desc: labels.nothing_selected)
    res
    
Template.project_type.getActualProjectType = ->
    if(this.type) then getProjectTypeDesc(this.type) else labels.nothing_selected

Template.project_type.isSelectedProjectType = (proposal) ->
    if(proposal.type)
        if(proposal.type is this.lu)
            'selected'
    else
        if(this.lu is nothing_lu)
            'selected'    
            
Template.project_type.events(editableEventMap('change','select','type',setProjectType))


Template.meta.lastChangeDate = ->
    moment(this.lastChangeDate).fromNow()
    
Template.meta.authorsList = ->
    owner = this.owner
    proposalId = this._id
    this.authors.map((e) ->
        email = 'none@none.org'
        if emails = Meteor.users.findOne({username: e}).emails
            email = emails[0]
        
        {name: e
        email: email.address
        deletable: owner isnt e
        proposalId: proposalId}
    )

#query users only ones.
_users = []
refreshMeta = ()->
    _users = Meteor.users.find({},{username: 1, emails: 1}).fetch()

findAuthors = (q) ->
    matches = []
    rx = new RegExp(q,"i")
    _users.forEach((e) ->
        if rx.test(e.username)
            matches.push 
                id: e._id
                username: e.username
                toString: ->
                    JSON.stringify(this)
        else if(e.emails)
            e.emails.forEach( (m) ->
                if rx.test(m.address)
                    matches.push
                        id: e._id
                        username: e.username
                        email: m.address
                        toString: ->
                            JSON.stringify(this)
            )
    )
    matches

filterAuthors = (proposal, author) ->
    author.username isnt 'admin' and
    author.username not in proposal.authors

colorMatchedParts = (input, pattern) ->
    parts = input.split(pattern)
    parts.reduce((s, e) ->
        s + '<span style="color: lightgrey">' + pattern + '</span>' + e
        )

highlightAuthors = (item) ->
    if item.email
        colorMatchedParts(item.email, this.query) + ' (' + item.username + ')'
    else
        colorMatchedParts(item.username, this.query)

addAuthor = (proposal, author) -> 
    Proposals.update({_id: proposal._id},{$push: {authors: author.username}})

Template.meta.rendered = ->
    proposal = this.data
    $("input.s-#{proposal._id}-authors").typeahead(
        source: findAuthors 
        updater: (item) ->
            author = JSON.parse(item)
            addAuthor(proposal, author)
            author.username
        sorter: (items) ->
            items.sort (e,o) ->
                e.username > o.username
        matcher: (item) ->
            filterAuthors(proposal, item)
        highlighter: highlightAuthors
    )
    $('.tipified').tooltip({delay: 800})

Template.meta.events(
    'click button.add-author-button': (e, t) ->
        if(model.allowedToEdit(Meteor.user(), this))
            model.updateEditState(Meteor.user(), this._id + "authors")
            refreshMeta()
        else
            showMessage(this, labels.not_allowed_to_add_authors)
    'blur input.search-users':  ->
        model.updateEditState(Meteor.user(), '')
    'keypress input.search-users': (e,t)->
        if e.which is 13
            value = e.target.value
            prop = this
            matches = findAuthors(value).filter (a) ->
                filterAuthors(prop, a)
            if matches.length is 1 
                addAuthor(this, matches[0])
                model.updateEditState(Meteor.user(), '')
            else if matches.length is 0
                showMessage(prop, labels.no_author)
            else
                showMessage(prop, labels.ambigous_author)
    'mouseenter i.icon-remove': (e, t) ->
        $(e.target).css('color','grey')
    'mouseout i.icon-remove': (e, t) ->
        $(e.target).css('color','white')
    'click i.icon-remove': (e, t) ->
        Proposals.update({_id: this.proposalId},{$pull: {authors: this.name}})
)

Template.project_goals.goalsExist = () ->
    this.goals? and this.goals.length

Template.project_goals.goals = () ->
    new Handlebars.SafeString(this.goals)

Template.project_goals.editorContext = () ->
    cId = this._id
    c = 
        textareaId: cId + "goals"
        placeholder: labels.value_placeholder
        text: if this.goals then this.goals else ""
        events: 
            change: (value) ->
                Proposals.update({_id: cId}, {$set: {goals: value}})
            blur: () ->
                model.updateEditState(Meteor.user(), '')
    c
    
Template.project_goals.events(
    "dblclick div.editable-content, click button.btn-goals": (e, t) ->
        e.preventDefault()
        e.stopImmediatePropagation()
        if(model.allowedToEdit(Meteor.user(), this))
            model.updateEditState(Meteor.user(), this._id + "goals")
        else
            showMessage(this, labels.not_allowed_to_edit_message)
)

Template.activities.elementsEditorContext = () ->
    proposal: this
    type: model.collectionTypes.activity

Template.element_editor.isEditing = () ->
    Meteor.user() and model.userState(Meteor.user()).editing is this._id
    
Template.element_editor.isAllowedToEdit = () ->
    p = Proposals.findOne({_id: this.proposal})
    model.allowedToEdit(Meteor.user(), p)
    
Template.element_editor.events(
    'dblclick div.editable-content': (e, t) ->
        e.preventDefault()
        e.stopImmediatePropagation()
        p = Proposals.findOne({_id: this.proposal})
        u = Meteor.user()
        if u and p and model.allowedToEdit(u, p)
            us = model.userState(u)
            UserStates.update({_id: us._id}, {$set: {editing: this._id}})
        else
            showMessage(this, labels.not_allowed_to_edit_message)
    'keyup input': (e, t) ->
        e.preventDefault()
        e.stopImmediatePropagation()
        Proposals.update({_id: this.proposal},{$set: {lastChangeDate: new Date}})
        model.updateCollectionElement(this, "name", e.target.value)
    'blur input': (e, t) ->
        e.preventDefault()
        e.stopImmediatePropagation()
        model.updateEditState(Meteor.user(), '')
)
Template.element_editor.events(blurOnEnter())

    