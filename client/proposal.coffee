Template.proposal.open = ->
    us = model.userState(Meteor.user())
    this._id in us.openProposals

Template.proposal.rendered = ->
    $('.tipified').tooltip({delay: 800})


Template.proposal.events(
    'click a.prop-open': (e,t) ->
        model.openProposal(this._id)
    'click a.prop-close': (e,t) ->
        model.closeProposal(this._id)
    'click div.proposal-state': (e, t) ->
        $("#comment-#{this._id}-Dialog").modal('show')
    )

evaluateRejectCount = (rejectCount) ->
    if rejectCount is 0
        {noticeType: '', tooltip: labels.rejected_never}
    else if rejectCount is 1
        {noticeType: 'badge-info', tooltip: labels.rejected_once}
    else if rejectCount in [2..5]
        {noticeType: 'badge-warning', tooltip: labels.rejected_few}
    else
        {noticeType: 'badge-important', tooltip: labels.rejected_many}
    
Template.proposal_state.displayRejectCount = ->
    r = model.currentUserRole(Meteor.user())
    r in model.rejectCountDisplayRoles

Template.proposal_state.rejectNoticeType = ->
    evaluateRejectCount(this.rejectCount).noticeType


Template.proposal_state.rejectCountTooltip = ->
    evaluateRejectCount(this.rejectCount).tooltip
        
Template.proposal_state.displayComments = ->
    yes

Template.proposal_state.commentsLabel = ->
    comCount = model.commentCount(this._id)
    if(comCount > 0)
        lc = model.latestComment(this._id)
        if lc.type is model.commentTypes.info
            labels.workflow_info_label_info
        else
            labels.workflow_info_label_warning
    else
        labels.workflow_info_label_add

    
Template.proposal_state.commentType = ->
    latest = model.latestComment(this._id)
    if(latest)
        if latest.type is model.commentTypes.reject
            'label-warning'
        else if latest.type is model.commentTypes.decline
            'label-important'
        else
            'label-info'
    
Template.proposal_state.commentTooltip = ->
    latest = model.latestComment(this._id)
    if(latest)
        model.abbreviate($('<p>'+ latest.text + '</p>').text())
    else
        labels.no_comments_exist
    
Template.proposal_state.commentCount = ->
    model.commentCount(this._id)

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
    

workflowComment = (proposal, commentType, callback) ->
    cd = $("#comment-#{proposal._id}-Dialog")
    cd.on('show', () ->
        c = model.commentStub(proposal._id, Meteor.user()?.username)
        c.type = commentType
        c.created = false
        id = Comments.insert(c)
        EditingComments.insert({lu: id})
    )
    cd.on('hidden', callback)
    cd.modal('show')

Template.proposal_buttons.events(
    'click button.btn-publish': (e, t) ->
        Proposals.update({_id: this._id},{$set: {public: true}})
    'click button.btn-private': (e, t) ->
        Proposals.update({_id: this._id},{$set: {public: false}})
    'click button.btn-submit': (e, t) ->
        Proposals.update({_id: this._id},{$set: {state: model.state.examination}}) 
    'click button.btn-reject': (e, t) ->
        proposal = this
        workflowComment(this, model.commentTypes.reject, () ->
            rc = proposal.rejectCount
            Proposals.update({_id: proposal._id},{$set: {state: model.state.rejected, rejectCount: rc + 1}})
        )
    'click button.btn-decline': (e, t) ->
        proposal = this
        workflowComment(this, model.commentTypes.decline, () ->
            Proposals.update({_id: proposal._id},{$set: {state: model.state.declined}})
        )
    'click button.btn-approve': (e, t) ->
        Proposals.update({_id: this._id},{$set: {state: model.state.approved}})
    'click button.btn-delete': (e, t) ->
        $("#delete-#{this._id}-Dialog").modal('show')
    'click button.btn-print': (e, t) ->
        pdf.generatePdf(this)
)

Template.delete_dialog.title = ->
    labels.delete_dialog_title
    
Template.delete_dialog.message = ->
    new Handlebars.SafeString(labels.delete_dialog_message + '<br><b>' + this.title + '</b>')
    
Template.delete_dialog.events(
    "click .btn-ok": (e,t) ->
        model.deleteProposal(this)
    "click .btn-cancel": (e,t) ->
        console.log("deletion canceled")
)


EditingComments = new Meteor.Collection(null)
Template.comments_list.newComments = ->
    nc = Comments.find({proposal: this._id, created: true, deleted: false}).fetch()
    if(nc)
        nc.sort (e, o) ->
            e.lastChangeDate < o.lastChangeDate
        nc
    
Template.comments_list.comments = ->
    wf = Comments.find({proposal: this._id, created: false, deleted: false}).fetch()
    if(wf)
        wf.sort (e, o) ->
            e.lastChangeDate < o.lastChangeDate
        wf

Template.comment_actions.events(
    "click .btn-ok": (e,t) ->
        user = Meteor.user()
        if(user)
            model.commitCommentUpdates(this._id, user.username)
        EditingComments.remove({})
    "click .btn-cancel": (e,t) ->
        user = Meteor.user()
        if(user)
            model.discardCommentUpdates(this._id, user.username)
        EditingComments.remove({})
    "click .btn-add": (e,t) ->
        user = Meteor.user()
        if(user)
            id = model.createComment(this._id, user.username)
            if(id)
                EditingComments.insert({lu: id})
)

Template.comment_view.lastChangeDate = ->
    moment(this.lastChangeDate).fromNow()

Template.comment_view.deletable = ->
    user = Meteor.user()
    if(user)
        this.user is user.username and this.type is model.commentTypes.info

Template.comment_view.highlightClass = ->
    if(this.type is model.commentTypes.reject)
        'reject-comment'
    else if (this.type is model.commentTypes.decline)
        'decline-comment'
    else if (this.created)
        'new-comment'
    else
        ''
Template.comment_view.events(
    'click a.btn-delete': (e, t) ->
        model.deleteComment(this)
)
    
Template.comment_editor.commentEditable = ->
    au = Meteor.user()
    au and this.user is au.username
    
Template.comment_editor.commentEmpty = ->
    not this.text?.length

commentText = (comment) ->
    if(comment.changed)
        comment.newText
    else
        comment.text

Template.comment_editor.text = ->
    new Handlebars.SafeString(commentText(this))

Template.comment_editor.isEditingComment = ->
    EditingComments.find({lu: this._id}).count() > 0
    
Template.comment_editor.isNotEditingComment = ->
    not Template.comment_editor.isEditingComment()

Template.comment_editor.editorContext = ->
    cId = this._id
    
    c = 
        textareaId: cId + "ta"
        placeholder: labels.comment_placeholder
        text: commentText(this)
        events: 
            change: (value) ->
                model.updateComment(cId, value)
    c

Template.comment_editor.events(
    'click div.editable-content': (e, t) ->
        e.preventDefault()
        e.stopImmediatePropagation()
        EditingComments.insert({lu: this._id})
    
)

Template.proposal_vote.numberOfUpVotes = () ->
    model.numberOfVotes(this._id, true)
    
Template.proposal_vote.numberOfDownVotes = () ->
    model.numberOfVotes(this._id, false)

Template.proposal_vote.userVote = () ->
    if(Meteor.user())
        model.userVote(this._id, Meteor.user().username)

Template.proposal_vote.userHasVoted = () ->
    if(Meteor.user())
        model.userHasVoted(this._id, Meteor.user().username)

Template.proposal_vote.rendered = () ->
    $(".tipified").tooltip({delay: 800})

Template.proposal_vote.events(
    'click .up-vote': (e, t) ->
        model.voteUp(this._id, Meteor.user()?.username)
    'click .down-vote': (e, t) ->
        model.voteDown(this._id, Meteor.user()?.username)
)   
