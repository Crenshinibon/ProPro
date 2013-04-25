if Meteor.isClient
    Handlebars.registerHelper("label", (lu) ->
        labels[lu]
    )
        
    Handlebars.registerHelper("isEditable", () ->
        Meteor.user() and model.allowedToEdit(Meteor.user(), this)
    )
    
    Handlebars.registerHelper("isEditing", (modelAttr) ->
        Meteor.user() and model.userState(Meteor.user()).editing is (this._id + modelAttr)
    )
    
    Accounts.ui.config(
        passwordSignupFields: 'USERNAME_AND_EMAIL'
    )
    
    Meteor.subscribe('allUsers')
    
    Template.role.userRoles = ->
        user = Meteor.user()
        if(user)
            model.userRoles(user.username).roles.map((e) -> model.role[e])
        else
            [model.role.visitor]
    
    Template.role.selectedRole = ->
        user = Meteor.user()
        if(user)
            urole = model.currentUserRole(user)
            if(urole is this.lu)
                "selected"
        else
            "selected"
            
    Template.role.events(
            'change select': (e) ->
                model.updateCurrentUserRole(Meteor.user(), e.target.value)
    )
    
    Template.cat_area.cats = ->
        r = model.currentUserRole(Meteor.user())
        model.role[r].cats
        
        
    Template.search.events(
        'keyup input': (e,t) ->
            r = Search(e.target.value)
            console.log(r)
    )
        
if Meteor.isServer
    Meteor.publish("allUsers", () ->
        Meteor.users.find({},{fields:
            emails: 1
            username: 1
            createdAt: 1
        })
    )
    
