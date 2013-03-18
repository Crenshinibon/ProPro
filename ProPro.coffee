if(Meteor.isClient)
    Handlebars.registerHelper("label", (lu) ->
        labels[lu]
    )
        
    Handlebars.registerHelper("isEditable", () ->
        Meteor.user() and allowedToEdit(Meteor.user(), this)
    )
    
    Handlebars.registerHelper("isEditing", (modelAttr) ->
        Meteor.user() and getUserState(Meteor.user()).editing is modelAttr
    )
    
    Accounts.ui.config(
        passwordSignupFields: 'USERNAME_AND_EMAIL'
    )

    Template.userarea.user = ->
        Meteor.user()

    Template.role.user = ->
        Meteor.user()
        
    Template.role.userRoles = ->
        if(Meteor.user())
            roles = (r.role for r in getUserRoles(Meteor.user()))
            Roles.find({lu: {$in: roles}}).fetch()
        else
            Roles.findOne({lu: "visitor"})
    
    Template.role.selectedRole = ->
        if(Meteor.user())
            urole = getCurrentUserRole(Meteor.user())
            if(urole is this.lu)
                "selected"
        else
            ""
            
    Template.role.events(
            'change select': (e) ->
                setCurrentUserRole(Meteor.user(), e.target.value)
    )
    
    Template.catArea.cats = ->
        if(Meteor.user())
            cu = getCurrentUserRole(Meteor.user())
            Roles.findOne({lu: cu}).cats
        else
            r = Roles.findOne({lu: "visitor"})
            if r then r.cats else NE_ROLE.cats
            
    Template.search.events(
        'submit form': ->
            false
    )

