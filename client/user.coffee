userRoles = (user) ->
    unless UserRoles.find({lu: user}.count() == 0)
        UserRoles.insert(
            user: user
            role: "visitor"
        )
    ur.role for ur in UserRoles.find({lu: user}).fetch()

currentUserRole = (user) ->
    cur = CurrentUserRoles.findOne({lu: user})
    #console.log(cur)
    #unless CurrentUserRoles.findOne({lu: user})
    #    CurrentUserRoles.insert(
    #        user: user
    #        role: "visitor"
    #    )
    #cur = CurrentUserRoles.findOne({lu: user})
    "visitor"
