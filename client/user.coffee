getUserRoles = (user) ->
    c = UserRoles.find({lu: user.username})
    if c.count() == 0
        defaultUserRoles(user.username)
    else
        c.fetch()

getCurrentUserRole = (user) ->
    us = getUserState(user)
    us.selectedRole


getUserState = (user) ->
    cur = UserStates.findOne({lu: user.username})
    unless cur
        dus = defaultUserState(user.username)
        UserStates.insert(dus)
        dus
    else
        cur
