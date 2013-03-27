model = {}
model.lang = 'de'
model.state =
    draft: "draft"
    rejected: "rejected"
    examination: "examination"
    declined: "declined"
    approved: "approved"

model.category =
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

model.role =
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
    
model.createdProposalTimeout = 60000
model.editableStates = [model.state.draft, model.state.rejected]
model.rejectCountDisplayRoles = [model.role.requestor.lu, model.role.decision_maker.lu]
model.workflowRoles = [model.role.requestor.lu, model.role.decision_maker.lu]

model.defaultUserRoles = (username) ->
    lu: username
    roles: [model.role.visitor.lu, model.role.requestor.lu]
    
model.proposalOrderOpts =
    lastChangeDate: 'lastChangeDate'
    title: 'title'
model.proposalOrderDirections = 
    down: 'down'
    up: 'up'
    
model.defaultProposalOrder = (category, role) ->
    cat: category.lu
    role: if(role.lu) then role.lu else role
    orderedBy: model.proposalOrderOpts.lastChangeDate
    orderDirection: model.proposalOrderDirections.down

model.cloneAndAdaptProposalOrder = (currentCatOrder, orderBy, orderDirection) ->
    cat: currentCatOrder.cat
    role: currentCatOrder.role
    orderedBy: orderBy
    orderDirection: orderDirection

model.toggleProposalOrderDirection = (currentCatOrder, user) ->
    newDir = model.proposalOrderDirections.down
    if(currentCatOrder.orderDirection is model.proposalOrderDirections.down)
        newDir = model.proposalOrderDirections.up
    newCatOrder = model.cloneAndAdaptProposalOrder(currentCatOrder, currentCatOrder.orderedBy, newDir)
    model.updateProposalOrder(currentCatOrder, newCatOrder, user)
    
model.proposalOrder = (category, user) ->
    us = model.userState(user)
    cpo = model.customProposalOrder(category.lu, us)
    if(cpo)
        cpo
    else
        model.defaultProposalOrder(category, us.selectedRole)

model.changeProposalOrderBy = (currentCatOrder, newValue, user) ->
    newCatOrder = model.cloneAndAdaptProposalOrder(currentCatOrder, model.proposalOrderOpts[newValue], currentCatOrder.orderDirection)
    model.updateProposalOrder(currentCatOrder, newCatOrder, user)


model.updateProposalOrder = (formerCatOrder, actualCatOrder, user) ->
    userState = model.userState(user)
    col = UserStates
    unless user
        col = LocalStates
    
    unless(userState.changedProposalOrder)
        col.update({_id: userState._id},{$set: {changedProposalOrder: [actualCatOrder]}})
    else
        col.update({_id: userState._id},{$pull: {changedProposalOrder: formerCatOrder}})
        col.update({_id: userState._id},{$push: {changedProposalOrder: actualCatOrder}})
    

model.customProposalOrder = (categoryName, userState) ->
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

model.defaultUserState = (username) ->
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
    
model.defaultProjectType = () ->
    ProjectTypes.find().fetch()[0]
    
model.createProposal = (creator) ->
    t = model.proposalStub(creator.username)
    Proposals.insert(t)
    
model.proposalStub = (username) ->
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

model.cleanupUserRoles = (cursor) ->
    deleteList = cursor.fetch().map((e) -> e._id)
    deleteList.forEach((e) ->
        UserRoles.remove({_id: e})
    )
    
model.createUserRoles = (username) ->
    UserRoles.insert(model.defaultUserRoles(username))

model.userRoles = (username) ->
    cursor = UserRoles.find({lu: username})
    if cursor.count() > 1
        model.cleanupUserRoles(cursor)
        console.log("UserRoles were cleaned!")
        model.userRoles(username)
    else if cursor.count() is 0
        model.createUserRoles(username)
        model.userRoles(username)
            
    UserRoles.findOne({lu: username})

model.currentUserRole = (user) ->
    us = model.userState(user)
    us.selectedRole
    
model.updateCurrentUserRole = (user, lu) ->
    if(user)
        us = model.userState(user)
        UserStates.update({_id: us._id},{$set: {selectedRole: lu}})

model.userRoleExists = (username) ->
    UserRoles.find({lu: username}).count() > 0    

model.cleanupUserStates = (cursor) ->
    deleteList = cursor.fetch().map((e) -> e._id)
    deleteList.forEach((e) ->
        UserStates.remove({_id: e})
    )

model.createUserState = (user) ->
    UserStates.insert(model.defaultUserState(user.username))

model.userState = (user) ->
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
        
model.updateEditState = (user, value) ->
    us = model.userState(user)
    UserStates.update({_id: us._id}, {$set: {editing: value}})
    
model.allowedToEdit = (user, proposal) ->
    user and user.username in proposal.authors and 
    proposal.state in model.editableStates and 
    model.currentUserRole(user) is "requestor"
        
model.closeNotice = (user, notice) ->
    us = model.userState(user)
    if(user)
        col = UserStates
    else
        col = LocalStates
    col.update({_id: us._id}, {$push: {closedNotices: notice}})
    yes
        
model.hasClosedNotice = (user, notice) ->
    us = model.userState(user)
    notice in us.closedNotices
    
model.toggleOpenProposal = (pid, actString) ->
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

model.closeProposal = (pid) ->
    model.toggleOpenProposal(pid, "$pull")
    
model.openProposal = (pid) ->
    model.toggleOpenProposal(pid, "$push")


#variable data
unless UserRoles
    UserRoles = new Meteor.Collection("userroles")

unless UserStates
    UserStates = new Meteor.Collection("userstates")

unless LocalStates
    LocalStates = new Meteor.Collection(null)
    LocalStates.insert(
        lu: "anon"
        openProposals: []
        openCategories: [{cat: model.category.approved.lu, role: model.role.visitor.lu}]
        closedNotices: []
        editing: ""
        selectedRole: model.role.visitor.lu
    )

unless Proposals
    Proposals = new Meteor.Collection("proposals")

unless ProjectTypes
    ProjectTypes = new Meteor.Collection("projecttypes")

if(Meteor.isServer)
    Meteor.startup () -> 
        initProjectTypes()
        
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
        #Meteor.users.remove({})