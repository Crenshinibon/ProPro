if(Meteor.isClient)
    Accounts.ui.config(
        passwordSignupFields: 'USERNAME_AND_EMAIL'
        )

    Template.userarea.user = ->
        Meteor.user()

    Template.role.user = ->
        Meteor.user()
        
    Template.role.userRoles = ->
        #if(Meteor.user())
        #    roles = userRoles(Meteor.user())
        #    console.log(roles)
        ["visitor","requestor","decision_maker"]
        
    Template.role.descFor = (role) ->
        Roles.findOne({lu: role}).desc
    
    Template.role.selectedRole = (role)->
        if(Meteor.user())
            urole = currentUserRole(Meteor.user())
            if(urole is role)
                "selected"
        else
            ""
    
    Template.catArea.cats = ->
        if(Meteor.user())
            Roles.findOne({lu: currentUserRole(Meteor.user())}).cats
        else
            Roles.findOne({lu: "visitor"}).cats



if(Meteor.isServer)
    Meteor.startup( ->
        initProjectTypes()
    )

