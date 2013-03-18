getUserRoles = (user) ->
    c = UserRoles.find({lu: user.username})
    if c.count() == 0
        defaultUserRoles(user.username)
    else
        c.fetch()

userHasRole = (user, lu) ->
    UserRoles.find({lu: user.username, role: lu}).count() > 0

getCurrentUserRole = (user) ->
    us = getUserState(user)
    us.selectedRole

setCurrentUserRole = (user, lu) ->
    us = getUserState(user)
    UserStates.update({_id: us._id},{$set: {selectedRole: lu}})

getUserState = (user) ->
    cur = UserStates.findOne({lu: user.username})
    unless cur
        dus = defaultUserState(user.username)
        UserStates.insert(dus)
        dus
    else
        cur

updateEditState = (user, value) ->
    us = getUserState(user)
    UserStates.update({_id: us._id}, {$set: {editing: value}})
    
allowedToEdit = (user, proposal) ->
    if (user.username in proposal.authors and proposal.state in editableStates)
        yes
    else if (userHasRole(user, 'admin'))
        yes
    else
        no
        
userClosesNotice = (user, notice) ->
    us = getUserState(user)
    UserStates.update({_id: us._id}, {$push: {closedNotices: notice}})
    yes
        
userHasClosedNotice = (user, notice) ->
    us = getUserState(user)
    notice in us.closedNotices
