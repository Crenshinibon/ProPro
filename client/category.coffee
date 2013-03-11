Template.category.desc = ->
    rc = Categories.findOne({lu: this.cat})
    rc.desc

Template.category.projects = ->
    rc = Categories.findOne({lu: this.cat})
    if(Meteor.user() and currentUserRole(Meteor.user()) is "requestor")
        #only personal projects
        res = Projects.find(
            visibility: {$in: rc.visibility}
            state: {$in: rc.states}
            owner: Meteor.user()
            ).fetch()
    else
        #all matching projects
        res = Projects.find(
            visibility: {$in: rc.visibility}
            state: {$in: rc.states}
            ).fetch()
    