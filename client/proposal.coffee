toggleOpenProposal = (proposal, actString) ->
    data = 
        openProposals: proposal._id
    action = {}
    action[actString] = data
    
    user = Meteor.user()
    us = getUserState(user)
    
    col = UserStates
    unless(user)
        col = LocalStates
    
    col.update({_id: us._id}, action)

openProposal = (proposal) ->
    toggleOpenProposal(proposal, "$pull")
    
closeProposal = (proposal) ->
    toggleOpenProposal(proposal, "$push")
    

Template.proposal.open = ->
    us = getUserState(Meteor.user())
    this._id in us.openProposals
        
Template.proposal.events(
    "click a.prop-open": (e,t) ->
        openProposal(this)
    "click a.prop-close": (e,t) ->
        closeProposal(this)
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
    
Template.proposal_buttons.submitable = ->
    this.state in ['draft','rejected'] and this.public

Template.proposal_buttons.deleteable = ->
    u = Meteor.user()
    u and this.owner is u.username and this.state is "draft"
    
Template.proposal_buttons.generateButton = ->
    r = getCurrentUserRole(Meteor.user())
    r is "decision_maker" and this.state is "approved"
    
Template.proposal_buttons.printButton = ->
    yes
    
Template.proposal_buttons.events(
    'click button.btn-publish': (e, t) ->
        Proposals.update({_id: this._id},{$set: {public: true}})
    'click button.btn-private': (e, t) ->
        Proposals.update({_id: this._id},{$set: {public: false}})
    'click button.btn-submit': (e, t) ->
        Proposals.update({_id: this._id},{$set: {state: 'examination'}}) 
    'click button.btn-reject': (e, t) ->
        rc = this.rejectCount
        Proposals.update({_id: this._id},{$set: {state: 'rejected', rejectCount: rc + 1}})
    'click button.btn-decline': (e, t) ->
        Proposals.update({_id: this._id},{$set: {state: 'declined'}})
    'click button.btn-approve': (e, t) ->
        Proposals.update({_id: this._id},{$set: {state: 'approved'}})       
)