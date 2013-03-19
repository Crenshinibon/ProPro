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
        e.stopImmediatePropagation()
        e.preventDefault()
        toggleOpenProposal(this, e.target)
    )

Template.proposal_state.displayRejectCount = ->
    r = getCurrentUserRole(Meteor.user())
    r in model.rejectCountDisplayRoles

addRejectNoticeTypeTooltip = (proposal) ->
    $(".proposal-state .badge").tooltip({title: "Das ist der ganze Tooltip", delay: 800})

Template.proposal_state.rejectNoticeType = ->
    addRejectNoticeTypeTooltip(this)
    evaluateRejectCount(this.rejectCount).noticeType

evaluateRejectCount = (rejectCount) ->
    if rejectCount is 0
        {noticeType: '', tooltip: labels.rejected_never}
    else if rejectCount is 1
        {noticeType: 'badge-info', tooltip: labels.rejected_once}
    else if rejectCount in [2..5]
        {noticeType: 'badge-warning', tooltip: labels.rejected_few}
    else
        {noticeType: 'badge-important', tooltip: labels.rejected_many}
    

Template.proposal_state.rejectCountTooltip = ->
    evaluateRejectCount(this.rejectCount).tooltip
        
Template.proposal_state.displayWorkflowInfo = ->
    r = getCurrentUserRole(Meteor.user())
    r in model.workflowRoles

Template.proposal_state.workflowInfoLabel = ->
    workflow.workflowInfoLabel(this, Meteor.user())
    
Template.proposal_state.workflowInfoType = ->
    workflow.workflowInfoType(this, Meteor.user())
    
Template.proposal_state.workflowInfoTooltip = ->
    workflow.workflowInfoTooltip(this, Meteor.user())
    
Template.proposal_state.rendered = ->
    $(".tipified").tooltip({delay: 800})
    
    
Template.proposal_buttons.displayButtons = ->
    r = getCurrentUserRole(Meteor.user())
    r in model.workflowRoles
    
Template.proposal_buttons.decidingButtons = ->
    r = getCurrentUserRole(Meteor.user())
    r is "decision_maker" and this.state is "examination"
    
Template.proposal_buttons.authorButtons = ->
    u = Meteor.user()
    if u
        r = getCurrentUserRole(u)
        
        u.username in this.authors and 
        r is "requestor" and 
        this.state in model.editableStates

Template.proposal_buttons.publishable = ->
    this.state is 'draft'

Template.proposal_buttons.deleteButton = ->
    u = Meteor.user()
    u and this.owner is u.username and this.state is "draft"
    
Template.proposal_buttons.generateButton = ->
    r = getCurrentUserRole(Meteor.user())
    r is "decision_maker" and this.state is "approved"
    
Template.proposal_buttons.printButton = ->
    yes
    
Template.proposal_buttons.events(
    'click button': (e, t) ->
        type = e.target.id.replace(this._id,'')
        console.log(type)
        console.log(this)
)