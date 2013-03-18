Template.category.desc = ->
    rc = Categories.findOne({lu: this.cat})
    if rc then rc.desc else NE_CATEGORY.desc

Template.category.proposals = ->
    rc = Categories.findOne({lu: this.cat})
    unless rc then rc = NE_CATEGORY
    if(Meteor.user() and getCurrentUserRole(Meteor.user()) is "requestor")
        #only proposals whos author you are
        Proposals.find(
            visibility: {$in: rc.visibility}
            state: {$in: rc.states}
            authors: Meteor.user().username
            ).fetch()
    else
        #all matching proposals
        Proposals.find(
            visibility: {$in: rc.visibility}
            state: {$in: rc.states}
            ).fetch()
        