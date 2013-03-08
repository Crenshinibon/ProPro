if(Meteor.isClient)
    Accounts.ui.config(
        passwordSignupFields: 'USERNAME_AND_EMAIL'
        )

    Template.userarea.user = ->
        Meteor.user()
        

    Template.role.user = ->
        Meteor.user()

    Template.role.currentUserRole = ->
        cu = currentUserRole(Meteor.user())
        Roles.findOne({lu: cu}).desc


    Template.catArea.cats = ->
        if(Meteor.user())
            Roles.findOne({lu: currentUserRole(Meteor.user())}).cats
        else
            Roles.findOne({lu: "visitor"}).cats


if(Meteor.isServer)
    Meteor.startup( ->
            
        )

