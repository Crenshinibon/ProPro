toggleCategory = (cat, actString) ->
    user = Meteor.user()    
    us = model.userState(user)
    
    values =
        openCategories:
            cat: cat.lu
            role: model.currentUserRole(user)
    action = {}
    action[actString] = 
        values
        
    col = UserStates     
    unless(user)
        col = LocalStates
        
    col.update({_id: us._id}, action)

openCategory = (cat) ->
    toggleCategory(cat, '$pull')
    
closeCategory = (cat) ->
    toggleCategory(cat, '$push')
    
checkTimeoutCreated = (proposals) ->
    proposals.forEach((e) ->
        if(e.created)
            deadline = e.createDate.getTime() + model.createdProposalTimeout 
            if(deadline < new Date) 
                Proposals.update({_id: e._id},{$set: {created: false}})
    )
    
Template.category.proposals = ->
    q = 
        public: true
        state: {$in: this.states}
    if (Meteor.user() and 
            model.currentUserRole(Meteor.user()) is "requestor")
        
        q.authors = Meteor.user().username
        if model.category.private is this
            q.public = false
        
    p = Proposals.find(q).fetch()
    checkTimeoutCreated(p)
    p

Template.category.open = ->
    col = LocalStates
    userName = "anon"
    
    user = Meteor.user()
    if(user)
        col = UserStates
        userName = user.username
    
    us = col.find(
        lu: userName
        openCategories: 
            $elemMatch:
                cat: this.lu
                role: model.currentUserRole(user)
    )
    us.count() > 0
    
Template.category.events = (
    'click a.cat-open': (e, t) ->
        openCategory(this)
    'click a.cat-close': (e, t) ->
        closeCategory(this)
    )

Template.category_toolbar.createProposals = ->
    user = Meteor.user()
    user and this.lu is 'private' and model.currentUserRole(user) is 'requestor'

Template.category_toolbar.events = (
    'click button.btn-create': (e, t) ->
        id = model.createProposal(Meteor.user())
        model.openProposal(id, Meteor.user)
        Meteor.setTimeout(->
                Proposals.update({_id: id},{$set: {created: false}})
            , model.createdProposalTimeout)
)