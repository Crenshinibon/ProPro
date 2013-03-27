toggleCategory = (cat, actString) ->
    user = Meteor.user()    
    us = model.userState(user)
    
    values =
        openCategories:
            cat: cat.lu
            role: model.currentUserRole(user)
    action = {}
    action[actString] = 
        values
        
    col = UserStates     
    unless(user)
        col = LocalStates
        
    col.update({_id: us._id}, action)

openCategory = (cat) ->
    toggleCategory(cat, '$pull')
    
closeCategory = (cat) ->
    toggleCategory(cat, '$push')
    
checkTimeoutCreated = (proposals) ->
    proposals.forEach((e) ->
        if(e.created)
            deadline = e.createDate.getTime() + model.createdProposalTimeout 
            if(deadline < new Date) 
                Proposals.update({_id: e._id},{$set: {created: false}})
    )

categorySortSpec = (category, user) ->
    propOrder = model.proposalOrder(category, user)
    dir = if propOrder.orderDirection is model.proposalOrderDirections.down then -1 else 1
    r = {}
    r[propOrder.orderedBy] = dir
    r
    

findProposals = (category, user) ->
    q = 
        public: true
        state: {$in: category.states}
    if (user and model.currentUserRole(user) is "requestor")
        q.authors = user.username
        if model.category.private is category
            q.public = false
    
    sorter = categorySortSpec(category, user)
    console.log(sorter)
    Proposals.find(q, {sort: sorter}).fetch()

Template.category.proposals = ->
    p = findProposals(this, Meteor.user())
    checkTimeoutCreated(p)
    p

Template.category.open = ->
    col = LocalStates
    userName = "anon"
    
    user = Meteor.user()
    if(user)
        col = UserStates
        userName = user.username
    
    us = col.find(
        lu: userName
        openCategories: 
            $elemMatch:
                cat: this.lu
                role: model.currentUserRole(user)
    )
    us.count() > 0
    
Template.category.events = (
    'click a.cat-open': (e, t) ->
        openCategory(this)
    'click a.cat-close': (e, t) ->
        closeCategory(this)
    )

Template.category_toolbar.createProposals = ->
    user = Meteor.user()
    user and this.lu is 'private' and model.currentUserRole(user) is 'requestor'

Template.category_toolbar.proposalOrder = ->
    model.proposalOrder(this, Meteor.user())

Template.category_toolbar.orderOptions = ->
    e for e of model.proposalOrderOpts
    
Template.category_toolbar.orderOptionsLabel = (option) ->
    labels["order_by_#{option}"]

Template.category_toolbar.hasProposals = ->
    findProposals(this, Meteor.user()).length > 0

Template.category_toolbar.events = (
    'click button.btn-create': (e, t) ->
        id = model.createProposal(Meteor.user())
        model.openProposal(id, Meteor.user)
        Meteor.setTimeout(->
                Proposals.update({_id: id},{$set: {created: false}})
            , model.createdProposalTimeout)
    'click button.btn-order-dir': (e, t) ->
        model.toggleProposalOrderDirection(this, Meteor.user())
    'click a.order-by-value': (e, t) ->
        currentOrder = model.proposalOrder(t.data, Meteor.user())
        model.changeProposalOrderBy(currentOrder, this, Meteor.user())
)