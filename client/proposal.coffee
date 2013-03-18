toggleOpenProposal = (proposal, element) ->
    text = $(element).text()
    data = 
        openProposals: proposal._id
        
    action =
        $push: data
    if(text is 'close')
        action =
            $pull: data
    user = Meteor.user()
    us = getUserState(user)
    col = UserStates
    unless(user)
        col = LocalStates
    col.update({_id: us._id}, action)

Template.proposal.open = ->
    us = getUserState(Meteor.user())
    this._id in us.openProposals
        
Template.proposal.events(
    "click a": (e,t) ->
        toggleOpenProposal(this, e.target)
    )

