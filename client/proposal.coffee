Template.proposal.open = ->
    us = model.userState(Meteor.user())
    this._id in us.openProposals

Template.proposal.rendered = ->
    $(".tipified").tooltip({delay: 800})


Template.proposal.events(
    "click a.prop-open": (e,t) ->
        model.openProposal(this._id)
    "click a.prop-close": (e,t) ->
        model.closeProposal(this._id)
    )

Template.proposal_state.displayRejectCount = ->
    r = model.currentUserRole(Meteor.user())
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
    r = model.currentUserRole(Meteor.user())
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
    r = model.currentUserRole(Meteor.user())
    r in model.workflowRoles
    
Template.proposal_buttons.decidingButtons = ->
    r = model.currentUserRole(Meteor.user())
    r is model.role.decision_maker.lu and this.state is model.state.examination
    
Template.proposal_buttons.authorButtons = ->
    u = Meteor.user()
    if u
        r = model.currentUserRole(u)
        
        u.username in this.authors and 
        r is model.role.requestor.lu and 
        this.state in model.editableStates

Template.proposal_buttons.publishable = ->
    this.state is model.state.draft
    
Template.proposal_buttons.submitable = ->
    this.state in [model.state.draft,model.state.rejected] and this.public

Template.proposal_buttons.deleteable = ->
    u = Meteor.user()
    u and this.owner is u.username and this.state is model.state.draft
    
Template.proposal_buttons.generateButton = ->
    r = model.currentUserRole(Meteor.user())
    r is model.role.decision_maker.lu and this.state is model.state.approved
    
Template.proposal_buttons.printButton = ->
    yes
    
Template.proposal_buttons.events(
    'click button.btn-publish': (e, t) ->
        Proposals.update({_id: this._id},{$set: {public: true}})
    'click button.btn-private': (e, t) ->
        Proposals.update({_id: this._id},{$set: {public: false}})
    'click button.btn-submit': (e, t) ->
        Proposals.update({_id: this._id},{$set: {state: model.state.examination}}) 
    'click button.btn-reject': (e, t) ->
        rc = this.rejectCount
        Proposals.update({_id: this._id},{$set: {state: model.state.rejected, rejectCount: rc + 1}})
    'click button.btn-decline': (e, t) ->
        Proposals.update({_id: this._id},{$set: {state: model.state.declined}})
    'click button.btn-approve': (e, t) ->
        Proposals.update({_id: this._id},{$set: {state: model.state.approved}})       
)