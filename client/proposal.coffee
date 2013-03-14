Template.proposal.open = ->
    if(Meteor.user())
        us = getUserState(Meteor.user())
        if(this.lu in us.openProposals)
            true
        else
            false
    else
        false


