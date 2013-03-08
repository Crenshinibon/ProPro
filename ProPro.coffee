if(Meteor.isClient)
    Accounts.ui.config(
        passwordSignupFields: 'USERNAME_AND_EMAIL'
        )

    Template.userarea.user = ->
        Meteor.user()
        

    Template.role.user = ->
        Meteor.user()
        

    Template.catArea.cats = ->
        if(Meteor.user())
           Roles.find(
               lu: Meteor.user().role).cats
        else
            Roles.findOne({lu: "visitor"}).cats


if(Meteor.isServer)
    Meteor.startup( ->
		
        )

