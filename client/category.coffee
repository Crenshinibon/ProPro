
toggleCategory = (cat, actString) ->
    user = Meteor.user()    
    us = getUserState(user)
    
    values =
        openCategories:
            cat: cat.lu
            role: getCurrentUserRole(user)
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
    
Template.category.proposals = ->
    if(Meteor.user() and getCurrentUserRole(Meteor.user()) is "requestor")
        #only proposals whos author the user is
        Proposals.find(
            public: not this.private
            state: {$in: this.states}
            authors: Meteor.user().username
            ).fetch()
    else
        #all matching proposals
        Proposals.find(
            public: not this.private
            state: {$in: this.states}
            ).fetch()


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
                role: getCurrentUserRole(user)
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
    user and this.lu is 'private' and getCurrentUserRole(user) is 'requestor'

Template.category_toolbar.events = (
    'click button.btn-create': (e, t) ->
        id = model.createProposal(Meteor.user())
        openProposal(id, Meteor.user)
)