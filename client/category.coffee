Template.category.desc = ->
    rc = Categories.findOne({lu: this.cat})
    rc.desc

Template.category.projects = ->
    rc = Categories.findOne({lu: this.cat})
    if(currentUserRole(Meteor.user()) == "requestor")
        #only personal projects
        res = Projects.find(
            visibility: {$in: rc.visibility}
            state: {$in: rc.states}
            owner: Meteor.user()
            ).fetch()
    else
        #all mathing projects
        res = Projects.find(
            visibility: {$in: rc.visibility}
            state: {$in: rc.states}
            ).fetch()
    