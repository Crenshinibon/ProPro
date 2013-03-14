getUserRoles = (user) ->
###    unless UserRoles.find({lu: user}).fetch().size == 0
        UserRoles.insert(
            lu: user
            role: "visitor"
        )
    ur.role for ur in UserRoles.find({lu: user}).fetch()
###
getCurrentUserRole = (user) ->
    us = getUserState(user)
    us.selectedRole


getUserState = (user) ->
    cur = UserStates.findOne({lu: user})
    unless cur
        UserStates.insert(defaultUserState(user))
    UserStates.findOne({lu: user})