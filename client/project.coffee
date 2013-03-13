Template.project.open = ->
    if(Meteor.user())
        us = getUserState(Meteor.user())
        if(this.lu in us.openProjects)
            true
        else
            false
    else
        false


