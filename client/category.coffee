toggleOpenCategory = (cat, current) ->
    user = Meteor.user()    
    us = getUserState(user)
    
    values =
        openCategories:
            cat: cat.lu
            role: getCurrentUserRole(user)
    action =
        $push: values
        
    text = $(current).text()
    if text is 'close'
        action =
            $pull: values
        
    col = UserStates     
    unless(user)
        col = LocalStates
    col.update({_id: us._id}, action)
    
Template.category.proposals = ->
    if(Meteor.user() and getCurrentUserRole(Meteor.user()) is "requestor")
        #only proposals whos author the user is
        Proposals.find(
            visibility: {$in: this.visibility}
            state: {$in: this.states}
            authors: Meteor.user().username
            ).fetch()
    else
        #all matching proposals
        Proposals.find(
            visibility: {$in: this.visibility}
            state: {$in: this.states}
            ).fetch()

Template.category.open = ->
    user = Meteor.user()
    col = LocalStates
    userName = "anon"
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
    'click a': (e, t)->
        toggleOpenCategory(this, e.target)
    )