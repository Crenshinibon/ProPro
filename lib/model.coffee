model = {}
model.state =
    draft: "draft"
    rejected: "rejected"
    examination: "examination"
    declined: "declined"
    approved: "approved"

model.category =
    examination:
        lu: "examination"
        desc: labels.cat_private
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
    

model.editableStates = [model.state.draft, model.state.rejected]
model.rejectCountDisplayRoles = ["requestor","decision_maker"]
model.workflowRoles = ["requestor","decision_maker"]
model.defaultUserRoles = (user) -> 
    v = {lu: user, role: "visitor"}
    r = {lu: user, role: "requestor"}
    UserRoles.insert(v)
    UserRoles.insert(r)
    UserRoles.find({lu: user.username}).fetch()
model.defaultUserState = (username) ->
    lu: username
    openProposals: []
    openCategories: [
        {cat: 'examination', role: 'visitor'}
        {cat: 'approved', role: 'visitor'}
        {cat: 'private', role: 'requestor'}
        {cat: 'drafts', role: 'requestor'}
        {cat: 'examination', role: 'decision_maker'}
    ]
    closedNotices: []
    editing: ""
    selectedRole: "visitor"
model.defaultProjectType = () ->
    ProjectTypes.findOne()
    
model.createProposal = (creator) ->
    t = model.proposalStub(creator)
    Proposals.insert(t)
    
model.proposalStub = (creator) ->
    created: true
    title: labels.new_proposals_title
    type: model.defaultProjectType.lu
    state: model.state.draft
    public: false
    rejectCount: 0
    authors: [creator.username]
    owner: creator.username
    createDate: new Date
    lastChangeDate: new Date


#fixed data
unless Roles
    Roles = new Meteor.Collection("roles")
NE_ROLE = 
    lu: "not_existing"
    desc: "not existing"
    cats: []
    
unless Categories
    Categories = new Meteor.Collection("categories")
NE_CATEGORY =
    lu: "not_existing"
    states: []
    visibility: []
    desc: "not existing"
    
#variable data
unless UserRoles
    UserRoles = new Meteor.Collection("userroles")

unless UserStates
    UserStates = new Meteor.Collection("userstates")

unless LocalStates
    LocalStates = new Meteor.Collection(null)
    UserRoles.insert({lu: "anon", role: "visitor"})
    LocalStates.insert(
        lu: "anon"
        openProposals: []
        openCategories: [{cat: "approved", role: "visitor"}]
        closedNotices: []
        editing: ""
        selectedRole: "visitor"
    )

unless Proposals
    Proposals = new Meteor.Collection("proposals")

unless ProjectTypes
    ProjectTypes = new Meteor.Collection("projecttypes")


if(Meteor.isServer)
    Meteor.startup () -> 
        Roles.remove({})
        setupRoles()
        
        Categories.remove({})
        setupCategories()
        
        initProjectTypes()
        
        if(conf.testing)
            cleanupVariableData()
            insertDummyProposals()
            
        if(Meteor.users.find().count() is 0)
            initUsers()
        

    initUsers = ->
        Accounts.createUser(
            username: "admin"
            email: conf.admin_email
            password: conf.admin_password
        )
        UserRoles.insert({lu: "admin", role: "admin"})
        UserStates.insert(
            lu: "admin"
            openProposals: []
            openCategories: []
            closedNotices: []
            editing: ""
            selectedRole: "admin"
        )
        Accounts.createUser(
            username: "dirk"
            email: "dirkporsche78@googlemail.com"
            password: "test"
        )
        UserRoles.insert({lu: "dirk", role: "requestor"})
        UserRoles.insert({lu: "dirk", role: "visitor"})
        UserRoles.insert({lu: "dirk", role: "decision_maker"})
        UserStates.insert(model.defaultUserState("dirk"))
        

    insertDummyProposals = ->
        Proposals.insert(
            title: "Special Project"
            type: "1235"
            state: model.state.rejected
            public: true
            rejectCount: 1
            authors: ["dirk"]
            owner: "dirk"
            createDate: new Date
            lastChangeDate: new Date
        )
        Proposals.insert(
            title: "Another Draft"
            type: "1235"
            state: model.state.draft
            public: true
            rejectCount: 0
            authors: ["dirk"]
            owner: "dirk"
            createDate: new Date
            lastChangeDate: new Date
        )
        
        Proposals.insert(
            title: "Private Project"
            type: "1234"
            state: model.state.draft
            public: false
            rejectCount: 0
            authors: ["dirk"]
            owner: "admin"
            createDate: new Date
            lastChangeDate: new Date
        )
        
        Proposals.insert(
            title: "Another Private Project"
            type: "1234"
            state: model.state.draft
            public: false
            rejectCount: 0
            authors: ["dirk"]
            owner: "dirk"
            createDate: new Date
            lastChangeDate: new Date
        )
        
        Proposals.insert(
            title: "Important Project"
            type: "1234"
            state: model.state.approved
            public: true
            rejectCount: 0
            authors: ["dirk"]
            owner: "dirk"
            createDate: new Date
            lastChangeDate: new Date
        )
        
        Proposals.insert(
            title: "Approved Project"
            type: "1236"
            state: model.state.approved
            public: true
            rejectCount: 2
            authors: ["dirk"]
            owner: "dirk"
            createDate: new Date
            lastChangeDate: new Date
        )

    cleanupVariableData = ->
        #UserRoles.remove({})
        #UserStates.remove({})
        Proposals.remove({})
        #Meteor.users.remove({})

    setupCategories = ->
        Categories.insert(
            lu: "examination"
            private: false
            states: [model.state.examination]
            desc: labels.cat_examination
        )

        Categories.insert(
            lu: "approved"
            private: false
            states: [model.state.approved]
            desc: labels.cat_approved
        )

        Categories.insert(
            lu: "drafts"
            private: false
            states: [model.state.draft,model.state.rejected]
            desc: labels.cat_drafts
        )

        Categories.insert(
            lu: "private"
            private: true
            states: [model.state.draft]
            desc: labels.cat_private
        )

        Categories.insert(
            lu: "declined"
            private: false
            states: [model.state.declined]
            desc: labels.cat_declined
        )

    setupRoles = ->
        Roles.insert(
            lu: "visitor"
            desc: labels.role_visitor
            
        )
        Roles.insert(
            lu: "requestor"
            desc: labels.role_requestor
            cats: ["private","drafts","examination","approved","declined"]
        )
        Roles.insert(
            lu: "decision_maker"
            desc: labels.role_decision_maker
            cats: ["examination","drafts","declined","approved"]
        )
        Roles.insert(
            lu: "admin"
            desc: labels.role_admin
            cats: []
        )
    