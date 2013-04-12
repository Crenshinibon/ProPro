@model = {}

@model.abbreviate = (string, length) ->
    unless length then length = 50
    s = string
    if string.length > length
        s = string.substring(0,length - 4) + ' ...'
    s
    
@model.lang = 'de'
@model.state =
    draft: "draft"
    rejected: "rejected"
    examination: "examination"
    declined: "declined"
    approved: "approved"

@model.category =
    examination:
        lu: "examination"
        desc: labels.cat_examination
        states: [model.state.examination]
    approved:
        lu: "approved"
        desc: labels.cat_approved
        states: [model.state.approved]
    drafts:
        lu: "drafts"
        desc: labels.cat_drafts
        states: [model.state.draft, model.state.rejected]
    private:
        lu: "private"
        desc: labels.cat_private
        states: [model.state.draft]
    declined:
        lu: "declined"
        desc: labels.cat_declined
        states: [model.state.declined]

@model.role =
    decision_maker: 
        lu: "decision_maker"
        desc: labels.role_decision_maker
        cats: [model.category.examination,
            model.category.approved,
            model.category.drafts,
            model.category.declined]
    requestor:
        lu: "requestor"
        desc: labels.role_requestor
        cats: [model.category.private,
            model.category.drafts,
            model.category.examination,
            model.category.approved,
            model.category.declined]
    visitor:
        lu: "visitor"
        desc: labels.role_visitor
        cats: [model.category.approved,
            model.category.examination,
            model.category.drafts,
            model.category.declined]
    admin: 
        lu: "admin"
        desc: labels.role_admin
        cats: []
    
@model.createdProposalTimeout = 60000
@model.editableStates = [@model.state.draft, @model.state.rejected]
@model.rejectCountDisplayRoles = [@model.role.requestor.lu, @model.role.decision_maker.lu]
@model.workflowRoles = [@model.role.requestor.lu, @model.role.decision_maker.lu]

@model.defaultUserRoles = (username) ->
    lu: username
    roles: [model.role.visitor.lu, model.role.requestor.lu]
    
@model.proposalOrderOpts =
    lastChangeDate: 'lastChangeDate'
    title: 'title'
@model.proposalOrderDirections = 
    down: 'down'
    up: 'up'
    
@model.defaultProposalOrder = (category, role) ->
    cat: category.lu
    role: if(role.lu) then role.lu else role
    orderedBy: model.proposalOrderOpts.lastChangeDate
    orderDirection: model.proposalOrderDirections.down

@model.cloneAndAdaptProposalOrder = (currentCatOrder, orderBy, orderDirection) ->
    cat: currentCatOrder.cat
    role: currentCatOrder.role
    orderedBy: orderBy
    orderDirection: orderDirection

@model.toggleProposalOrderDirection = (currentCatOrder, user) ->
    newDir = model.proposalOrderDirections.down
    if(currentCatOrder.orderDirection is model.proposalOrderDirections.down)
        newDir = model.proposalOrderDirections.up
    newCatOrder = model.cloneAndAdaptProposalOrder(currentCatOrder, currentCatOrder.orderedBy, newDir)
    model.updateProposalOrder(currentCatOrder, newCatOrder, user)
    
@model.proposalOrder = (category, user) ->
    us = model.userState(user)
    cpo = model.customProposalOrder(category.lu, us)
    if(cpo)
        cpo
    else
        model.defaultProposalOrder(category, us.selectedRole)

@model.changeProposalOrderBy = (currentCatOrder, newValue, user) ->
    newCatOrder = model.cloneAndAdaptProposalOrder(currentCatOrder, model.proposalOrderOpts[newValue], currentCatOrder.orderDirection)
    model.updateProposalOrder(currentCatOrder, newCatOrder, user)


@model.updateProposalOrder = (formerCatOrder, actualCatOrder, user) ->
    userState = model.userState(user)
    col = UserStates
    unless user
        col = LocalStates
    
    unless(userState.changedProposalOrder)
        col.update({_id: userState._id},{$set: {changedProposalOrder: [actualCatOrder]}})
    else
        col.update({_id: userState._id},{$pull: {changedProposalOrder: formerCatOrder}})
        col.update({_id: userState._id},{$push: {changedProposalOrder: actualCatOrder}})
    

@model.customProposalOrder = (categoryName, userState) ->
    cpo = [] 
    if(userState.changedProposalOrder)
        cpo = userState.changedProposalOrder.filter((e) ->
            e.cat is categoryName and
            e.role is userState.selectedRole
        )
    if(cpo.length == 1)
        cpo[0]
    else if(cpo.length > 1)
        console.log("Cleaning proposal custom order objects!")
    else
        no

@model.defaultUserState = (username) ->
    lu: username
    openProposals: []
    changedProposalOrder: []
    openCategories: [
        {cat: model.category.examination.lu, role: model.role.visitor.lu}
        {cat: model.category.approved.lu, role: model.role.visitor.lu}
        {cat: model.category.private.lu, role: model.role.requestor.lu}
        {cat: model.category.drafts.lu, role: model.role.requestor.lu}
        {cat: model.category.examination.lu, role: model.role.decision_maker.lu}
    ]
    closedNotices: []
    editing: ""
    selectedRole: model.role.visitor.lu
    
@model.defaultProjectType = () ->
    ProjectTypes.find().fetch()[0]
    
@model.createProposal = (creator) ->
    t = model.proposalStub(creator.username)
    Proposals.insert(t)
    
@model.deleteProposal = (proposal) ->
    model.deleteComments(proposal._id)
    Proposals.remove({_id: proposal._id})

    
@model.proposalStub = (username) ->
    created: true
    title: labels.new_proposals_title
    type: model.defaultProjectType.lu
    state: model.state.draft
    public: false
    rejectCount: 0
    authors: [username]
    owner: username
    createDate: new Date
    lastChangeDate: new Date
    
@model.commentTypes =
    reject: "reject"
    decline: "decline"
    info: "info"

@model.commentStub = (proposalId, username) ->
    created: true
    changed: false
    deleted: false
    proposal: proposalId
    type: model.commentTypes.info
    user: username
    text: ""
    newText: ""
    createDate: new Date
    lastChangeDate: new Date
    
@model.createComment = (proposalId, username, text, commentType) ->
    s = model.commentStub(proposalId, username)
    if(commentType)
        s.type = commentType
    if(text)
        s.text = text
    Comments.insert(s)
    
@model.deleteComments = (proposalId) ->
    c = Comments.find({proposal: proposalId}).fetch()
    c.forEach (e) ->
        Comments.remove({_id: c._id})

@model.commentsForUser = (proposalId, username, state, fun) ->
    q = {}
    q.proposal = proposalId
    q.user = username
    q[state] = true
    
    comments = Comments.find(q).fetch()
    if(fun)
        comments.forEach (c) ->
            fun(c)
    comments
    

@model.commitCreatedComments = (proposalId, username) ->
    model.commentsForUser(proposalId, username, "created", (c) ->
        Comments.update({_id: c._id}, {$set: {created: false}})
    )

@model.discardCreatedComments = (proposalId, username) ->
    model.commentsForUser(proposalId, username, "created", (c) ->
        Comments.remove({_id: c._id})
    )  

@model.commitChangedComments = (proposalId, username) ->
    model.commentsForUser(proposalId, username, "changed", (c) ->
        Comments.update({_id: c._id}, {$set: 
            changed: false
            text: c.newText
            newText: ""
            })
        )
        
@model.discardChangedComments = (proposalId, username) ->
    model.commentsForUser(proposalId, username, "changed", (c) ->
        Comments.update({_id: c._id}, {$set: 
            changed: false
            newText: ""
        })
    )

@model.commitDeletedComments = (proposalId, username) ->
    model.commentsForUser(proposalId, username, "deleted", (c) ->
        Comments.remove({_id: c._id})
    )

@model.discardDeletedComments = (proposalId, username) ->
    model.commentsForUser(proposalId, username, "deleted", (c) ->
        Comments.update({_id: c._id}, {$set: {deleted: false}})
    )
    
@model.commitCommentUpdates = (proposalId, username) ->
    model.commitDeletedComments(proposalId, username)
    model.commitChangedComments(proposalId, username)
    model.commitCreatedComments(proposalId, username)
    
@model.discardCommentUpdates = (proposalId, username) ->
    model.discardDeletedComments(proposalId, username)
    model.discardChangedComments(proposalId, username)
    model.discardCreatedComments(proposalId, username)

@model.updateComment = (commentId, text) ->
    Comments.update({_id: commentId},{$set: 
        newText: text
        changed: true
        lastChangeDate: new Date
    })
    
@model.deleteComment = (comment) ->
    Comments.update({_id: comment._id},{$set: {deleted: true}})
    
@model.latestComment = (proposalId) ->
    wc = Comments.find({proposal: proposalId}).fetch()
    if(wc)
        wc.sort (e,o) -> 
            e.lastChangeDate < o.lastChangeDate
        wc[0]
    
@model.commentCount = (proposalId) ->
    Comments.find({proposal: proposalId}).count()

@model.voteUp = (proposalId, username) ->
    Votes.insert({proposal: proposalId, user: username, up: true})

@model.voteDown = (proposalId, username) ->
    Votes.insert({proposal: proposalId, user: username, up: false})
    
@model.numberOfVotes = (proposalId, up) ->
    Votes.find({proposal: proposalId, up: up}).count()
    
@model.userHasVoted = (proposalId, username) ->
    Votes.find({proposal: proposalId, user: username}).count() > 0
    
@model.userVote = (proposalId, username) ->
    v = Votes.find({proposal: proposalId, user: username}).fetch()
    if(v.length > 0)
        if(v[0].up)
            labels.up_vote
        else
            labels.down_vote
            

@model.maxCollectionElementDepth = 6

@model.collectionTypes =
    milestone: 
        lu: 'milestone'
        maxDepth: 1
    activity: 
        lu: 'activity'
        maxDepth: 6

@model.collectionsElementStub = (proposalId, type, pos, depth) ->
    proposal: proposalId
    deeper: false
    higher: false
    up: false
    down: false
    addable: true
    deletable: true
    data: undefined
    type: type.lu
    position: pos
    depth: depth

@model.collectionElements = (proposalId, type, cond) ->
    q = {proposal: proposalId, type: type.lu}
    if cond? then q[p] = cond[p] for p of cond
    CollectionElements.find(q, {sort: {position: 1}}).fetch()
    
@model.moveCollectionElements = (elements, down) ->
    dir = (curPos) -> 
        if down
            curPos + 1 
        else 
            curPos - 1
    elements.forEach (e) ->
        CollectionElements.update({_id: e._id}, {$set: {position: dir(e.position)}})
    

@model.relativeCollectionElement = (element, below) ->
    dir = (curPos) ->
        if below
            curPos + 1
        else
            curPos - 1
    c = {position: dir(element.position),depth: element.depth}
    model.collectionElements(element.proposal, model.collectionTypes[element.type], c)[0]


@model.collectionChildElements = (proposalId, type, pos, depth) ->
    result = []
    following = model.collectionElements(proposalId, type, {position: {$gt: pos}})
    following.every (e) ->
        if(e.depth > depth)
            result.push(e)
            true
        else
            false
    result
    

@model.insertElement = (proposalId, type, originElement) ->
    #simply insert the very first
    if(model.collectionElements(proposalId, type).length is 0)
        s = model.collectionsElementStub(proposalId, type, 0, 0)
        s.data = {name: "First element!"}
        CollectionElements.insert(s)
    else
        #find children of the originating Element
        children = model.collectionChildElements(proposalId, type, originElement.position, originElement.depth)
        insertPos = originElement.position + 1
        if(children.length > 0)
            #move the insertion position behind those children
            insertPos = originElement.position + children.length
        
        s = model.collectionsElementStub(proposalId, type, insertPos, originElement.depth)
        s.data = {name: "Element number: " + (model.collectionElements(proposalId, type).length + 1)}
        s.up = true
        
        if(originElement.depth < model.maxCollectionElementDepth)
            s.deeper = true
        
        if(originElement.depth > 0)
            s.higher = true
        
        #let the origin element be down-moveable
        CollectionElements.update({_id: originElement._id},{$set: {down: true}})
        
        #if there is a following element on the same level, allow this one to
        #down moveable.
        next = model.relativeCollectionElement(originElement, true)
        if(next?)
            s.down = true
        
        #move all following down
        following = model.collectionElements(proposalId, type, {position: {$gte: insertPos}})
        if(following.length > 0)
            model.moveCollectionElements(following, true)
        
        #insert the created element
        CollectionElements.insert(s)
    
@model.removeElement = (element) ->
    CollectionElements.remove({_id: element._id})
    
    #move following elements up, if there are any
    following = model.collectionElements(element.proposal, model.collectionTypes[element.type], {position: {$gt: element.position}})
    if(following.length > 0)
        model.moveCollectionElements(following, false)
        
        #if the first element was deleted, make a new first
        if(element.position is 0)
            CollectionElements.update({_id: following[0]._id},{$set: {deeper: false, up: false}})
    else
        #if the last element was deleted, make a new last
        prev = model.relativeCollectionElement(element, false)
        if(prev?)
            CollectionElements.update({_id: prev._id},{$set: {down: false}})
    
    
@model.moveElementUp = (element) ->
    prev = model.relativeCollectionElement(element, false)
    CollectionElements.update({_id: element._id}, 
        $set: 
            position: prev.position
            up: prev.up
            higher: prev.higher
            deeper: prev.deeper
            down: true
    )
    
    CollectionElements.update({_id: prev._id},
        $set: 
            position: element.position
            up: true
            higher: element.higher
            deeper: element.deeper
            down: element.down
    )    
    
@model.moveElementDown = (element) ->
    next = model.relativeCollectionElement(element, true)
    CollectionElements.update({_id: element._id},
        $set:
            position: next.position
            down: next.down
            higher: next.higher
            deeper: next.deeper
            up: true
            
    )
    
    CollectionElements.update({_id: next._id}
        $set:
            position: element.position
            up: element.up
            higher: element.higher
            deeper: element.deeper
            down: true
    )
    
    
@model.increaseElementDepth = (element) ->
    
    
@model.decreaseElementDepth = (element) ->
    
    
@model.cleanupUserRoles = (cursor) ->
    deleteList = cursor.fetch().map((e) -> e._id)
    deleteList.forEach((e) ->
        UserRoles.remove({_id: e})
    )
    
@model.createUserRoles = (username) ->
    UserRoles.insert(model.defaultUserRoles(username))

@model.userRoles = (username) ->
    cursor = UserRoles.find({lu: username})
    if cursor.count() > 1
        model.cleanupUserRoles(cursor)
        console.log("UserRoles were cleaned!")
        model.userRoles(username)
    else if cursor.count() is 0
        model.createUserRoles(username)
        model.userRoles(username)
            
    UserRoles.findOne({lu: username})

@model.currentUserRole = (user) ->
    us = model.userState(user)
    us.selectedRole
    
@model.updateCurrentUserRole = (user, lu) ->
    if(user)
        us = model.userState(user)
        UserStates.update({_id: us._id},{$set: {selectedRole: lu}})

@model.userRoleExists = (username) ->
    UserRoles.find({lu: username}).count() > 0    

@model.cleanupUserStates = (cursor) ->
    deleteList = cursor.fetch().map((e) -> e._id)
    deleteList.forEach((e) ->
        UserStates.remove({_id: e})
    )

@model.createUserState = (user) ->
    UserStates.insert(model.defaultUserState(user.username))

@model.userState = (user) ->
    if(user)
        cursor = UserStates.find({lu: user.username})
        if cursor.count() > 1
            model.cleanupUserStates(cursor)
            console.log("UserStates were cleaned!")
            model.userState(user)
        else if cursor.count() is 0
            model.createUserState(user)
            model.userState(user)
        
        UserStates.findOne({lu: user.username})
    else
        LocalStates.findOne({lu: "anon"})
        
@model.updateEditState = (user, value) ->
    us = model.userState(user)
    UserStates.update({_id: us._id}, {$set: {editing: value}})
    
@model.allowedToEdit = (user, proposal) ->
    user and user.username in proposal.authors and 
    proposal.state in model.editableStates and 
    model.currentUserRole(user) is "requestor"
        
@model.closeNotice = (user, notice) ->
    us = model.userState(user)
    if(user)
        col = @UserStates
    else
        col = @LocalStates
    col.update({_id: us._id}, {$push: {closedNotices: notice}})
    yes
        
@model.hasClosedNotice = (user, notice) ->
    us = model.userState(user)
    notice in us.closedNotices
    
@model.toggleOpenProposal = (pid, actString) ->
    data = 
        openProposals: pid
    action = {}
    action[actString] = data
    
    user = Meteor.user()
    us = model.userState(user)
    
    col = UserStates
    unless(user)
        col = LocalStates
    
    col.update({_id: us._id}, action)

@model.closeProposal = (pid) ->
    model.toggleOpenProposal(pid, "$pull")
    
@model.openProposal = (pid) ->
    model.toggleOpenProposal(pid, "$push")


#variable data
unless @UserRoles
    @UserRoles = new Meteor.Collection("userroles")

unless @UserStates
    @UserStates = new Meteor.Collection("userstates")

unless @LocalStates
    @LocalStates = new Meteor.Collection(null)
    @LocalStates.insert(
        lu: "anon"
        openProposals: []
        openCategories: [{cat: model.category.approved.lu, role: model.role.visitor.lu}]
        closedNotices: []
        editing: ""
        selectedRole: model.role.visitor.lu
    )

unless @Proposals
    @Proposals = new Meteor.Collection("proposals")

unless @Comments
    @Comments = new Meteor.Collection("comments")
    
unless @Votes
    @Votes = new Meteor.Collection("votes")

unless @CollectionElements
    @CollectionElements = new Meteor.Collection("collectionelements")

unless @ProjectTypes
    @ProjectTypes = new Meteor.Collection("projecttypes")

if(Meteor.isServer)
    Meteor.startup () -> 
        ref.initProjectTypes()
        
        if(conf.testing)
            cleanupVariableData()
            #insertDummyProposals()
            
        #initUsers()
        

    initUsers = ->
        Accounts.createUser(
            username: "admin"
            email: conf.admin_email
            password: conf.admin_password
        )
        UserRoles.insert(
            lu: "admin"
            roles: [model.role.admin.lu]
        )
        UserStates.insert(
            lu: "admin"
            openProposals: []
            openCategories: []
            closedNotices: []
            editing: ""
            selectedRole: model.role.admin.lu
        )
        Accounts.createUser(
            username: "dirk"
            email: "dirkporsche78@googlemail.com"
            password: "test"
        )
        UserRoles.insert(
            lu: "dirk"
            roles: [model.role.visitor.lu, 
                model.role.requestor.lu, 
                model.role.decision_maker.lu]
        )
        UserStates.insert(model.defaultUserState("dirk"))
        Accounts.createUser(
            username: "marc"
            email: "marcfeuster@googlemail.com"
            password: "test"
        )
        UserRoles.insert(model.defaultUserRoles("marc"))
        UserStates.insert(model.defaultUserState("marc"))

    insertDummyProposals = ->
        p = model.proposalStub("dirk")
        for i in [1..10]
            p.title = "Project " + i
            p.created = false
            Proposals.insert(p)
        
    cleanupVariableData = ->
        #UserRoles.remove({})
        #UserStates.remove({})
        #Proposals.remove({})
        #Comments.remove({})
        #Meteor.users.remove({})    