###Shared functions and values###
editableEventMap = (updateEvent, tag, modelAttr, actionFun) ->
    map = {}
    map["#{updateEvent} #{tag}"] = (e) ->
        e.preventDefault()
        e.stopImmediatePropagation()
        actionFun(this, event.target.value)
    map['dblclick'] = (e) ->
        e.preventDefault()
        e.stopImmediatePropagation()
        if(model.allowedToEdit(Meteor.user(), this))
            model.updateEditState(Meteor.user(), this._id + modelAttr)
        else
            showMessage(this, labels.not_allowed_to_edit_message)
    map["blur #{tag}"] = (e) ->
        e.preventDefault()
        e.stopImmediatePropagation()
        model.updateEditState(Meteor.user(), '')
    map
    
blurOnEnter = () ->
    'keypress input': (e) ->
        if(e.which is 13)
            e.preventDefault()
            e.stopImmediatePropagation()
            model.updateEditState(Meteor.user(), '')

showMessage = (proposal, message) ->
    pid = proposal._id
    $("##{pid} .message-block-content").text(message)
    $("##{pid} .message-block").fadeIn()
    Meteor.setTimeout(hideMessageBlock,20000)

hideMessageBlock = ->
    $('#message_block').fadeOut('slow')

nothing_lu = 'nothing_selected'

###Proposal form###
Template.proposal_form.showDblClickNotice = () ->
    user = Meteor.user()
    
    user and 
    model.allowedToEdit(user, this) and not 
    model.hasClosedNotice(user,'dblclick')

Template.proposal_form.events(
    'submit form': ->
        false
    'click button.close': (e) ->
        model.closeNotice(Meteor.user(),e.target.name)
    )

###Proposal title display and inupt###
setProposalTitle = (proposal, title) ->
    Proposals.update({_id: proposal._id},
        $set:
            title: title
            lastChange: new Date
    )

Template.title.events(editableEventMap('keyup','input','title',setProposalTitle))
Template.title.events(blurOnEnter())

###Project Types display and input!###
setProjectType = (proposal, type) ->
    Proposals.update({_id: proposal._id},
        $set: 
            type: type
            lastChange: new Date
        )

getProjectTypeDesc = (lu) ->
    pt = ProjectTypes.findOne({lu: lu})
    if(pt) then pt.desc else labels.nothing_selected


Template.project_type.getProjectTypes = ->
    res = ProjectTypes.find().fetch()
    res.push(
        lu: nothing_lu
        desc: labels.nothing_selected)
    res
    
Template.project_type.getActualProjectType = ->
    if(this.type) then getProjectTypeDesc(this.type) else labels.nothing_selected

Template.project_type.isSelectedProjectType = (type, proposal) ->
    if(proposal.type)
        if(proposal.type is type.lu)
            'selected'
    else
        if(type.lu is nothing_lu)
            'selected'    
            
Template.project_type.events(editableEventMap('change','select','type',setProjectType))
