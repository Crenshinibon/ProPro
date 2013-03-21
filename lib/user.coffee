getUserRoles = (user) ->
    c = UserRoles.find({lu: user.username})
    if c.count() == 0
        model.defaultUserRoles(user.username)
    else
        c.fetch()

userHasRole = (user, lu) ->
    UserRoles.find({lu: user.username, role: lu}).count() > 0

getCurrentUserRole = (user) ->
    us = getUserState(user)
    us.selectedRole
    
setCurrentUserRole = (user, lu) ->
    us = getUserState(user)
    if(user)
        col = UserStates
    else
        col = LocalStates
    col.update({_id: us._id},{$set: {selectedRole: lu}})

cleanupUserStates = (cursor) ->
    deleteList = cursor.fetch().map((e) -> e._id)
    deleteList.forEach((e) ->
        UserStates.remove({_id: e})
    )

createUserState = (user) ->
    UserStates.insert(model.defaultUserState(user.username))

getUserState = (user) ->
    if(user)
        cursor = UserStates.find({lu: user.username})
        if cursor.count() > 1
            console.log("UserStates were cleaned!")
            cleanupUserStates(cursor)
            getUserState(user)
        else if cursor.count() is 0
            createUserState(user)
            getUserState(user)
        
        UserStates.findOne({lu: user.username})
    else
        LocalStates.findOne({lu: "anon"})
        
updateEditState = (user, value) ->
    us = getUserState(user)
    UserStates.update({_id: us._id}, {$set: {editing: value}})
    
allowedToEdit = (user, proposal) ->
    user and user.username in proposal.authors and 
    proposal.state in model.editableStates and 
    getCurrentUserRole(user) is "requestor"
        
userClosesNotice = (user, notice) ->
    us = getUserState(user)
    if(user)
        col = UserStates
    else
        col = LocalStates
    col.update({_id: us._id}, {$push: {closedNotices: notice}})
    yes
        
userHasClosedNotice = (user, notice) ->
    us = getUserState(user)
    notice in us.closedNotices
    
toggleOpenProposal = (pid, actString) ->
    data = 
        openProposals: pid
    action = {}
    action[actString] = data
    
    user = Meteor.user()
    us = getUserState(user)
    
    col = UserStates
    unless(user)
        col = LocalStates
    
    col.update({_id: us._id}, action)

closeProposal = (pid) ->
    toggleOpenProposal(pid, "$pull")
    
openProposal = (pid) ->
    toggleOpenProposal(pid, "$push")
