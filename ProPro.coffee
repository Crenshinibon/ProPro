if(Meteor.isClient)
    Accounts.ui.config(
        passwordSignupFields: 'USERNAME_AND_EMAIL'
        )

    Template.userarea.user = ->
        Meteor.user()

    Template.role.user = ->
        Meteor.user()
        
    Template.role.userRoles = ->
        if(Meteor.user())
            us = getUserRoles(Meteor.user())
            e.role for e in us
        else
            ["visitor"]
        #["visitor","requestor","decision_maker"]
        
    Template.role.descFor = (role) ->
        r = Roles.findOne({lu: role})
        if r then r.desc else NE_ROLE.desc
    
    Template.role.selectedRole = (role)->
        if(Meteor.user())
            urole = getCurrentUserRole(Meteor.user())
            if(urole is role)
                "selected"
        else
            ""
    
    Template.catArea.cats = ->
        if(Meteor.user())
            cu = getCurrentUserRole(Meteor.user())
            Roles.findOne({lu: cu}).cats
        else
            r = Roles.findOne({lu: "visitor"})
            if r then r.cats else NE_ROLE.cats

