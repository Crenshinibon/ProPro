if(Meteor.isClient)
    Accounts.ui.config(
        passwordSignupFields: 'USERNAME_AND_EMAIL'
        )

    Template.hello.greeting = -> 
        "Welcome to ProPro."

    Template.hello.events(
        'click input' : ->
            # template data, if any, is available in 'this'
            if(console)
                console.log("You pressed the button"))

    Template.userarea.user = ->
        Meteor.user()


if(Meteor.isServer)
    Meteor.startup( ->
        # code to run on server at startup
        )

