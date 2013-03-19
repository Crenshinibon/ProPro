if(Meteor.isClient)
    Handlebars.registerHelper("label", (lu) ->
        labels[lu]
    )
        
    Handlebars.registerHelper("isEditable", () ->
        Meteor.user() and allowedToEdit(Meteor.user(), this)
    )
    
    Handlebars.registerHelper("isEditing", (modelAttr) ->
        Meteor.user() and getUserState(Meteor.user()).editing is (this._id + modelAttr)
    )
    
    Accounts.ui.config(
        passwordSignupFields: 'USERNAME_AND_EMAIL'
    )
    
        
    Template.role.userRoles = ->
        user = Meteor.user()
        if(user)
            roles = (r.role for r in getUserRoles(user))
            Roles.find({lu: {$in: roles}}).fetch()
        else
            Roles.find({lu: "visitor"}).fetch()
    
    Template.role.selectedRole = ->
        user = Meteor.user()
        if(user)
            urole = getCurrentUserRole(user)
            if(urole is this.lu)
                "selected"
        else
            "selected"
            
    Template.role.events(
            'change select': (e) ->
                setCurrentUserRole(Meteor.user(), e.target.value)
    )
    
    Template.catArea.cats = ->
        user = Meteor.user()
        cu = getCurrentUserRole(Meteor.user())
        r = Roles.findOne({lu: cu})
        if(r)
            Categories.find({lu: {$in: r.cats}}).fetch()
