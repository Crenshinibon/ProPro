model =
    editableStates: ["draft","rejected"]
    rejectCountDisplayRoles: ["requestor","decision_maker"]
    workflowRoles: ["requestor","decision_maker"]
    
    defaultUserRoles: (user) -> 
        v = {lu: user, role: "visitor"}
        r = {lu: user, role: "requestor"}
        UserRoles.insert(v)
        UserRoles.insert(r)
        UserRoles.find({lu: user.username}).fetch()
    defaultUserState: (user) ->
        lu: user
        openProposals: []
        openCategories: [
            {cat: 'examination', role: 'visitor'}
            {cat: 'approved', role: 'visitor'}
            {cat: 'private', role: 'requestor'}
            {cat: 'drafts', role: 'requestor'}
        ]
        closedNotices: []
        editing: ""
        selectedRole: "visitor"
    

#fixed data
unless Roles
    Roles = new Meteor.Collection("roles")
NE_ROLE = 
    lu: "not_existing"
    desc: "not existing"
    cats: []

unless States
    States = new Meteor.Collection("states")
NE_STATE =
    lu: "not_existing"
    desc: "not existing"
    
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
        
        States.remove({})
        setupStates()

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
        UserStates.insert(model.defaultUserState(Meteor.users.findOne({username: "dirk"})))
        

    insertDummyProposals = ->
        Proposals.insert(
            title: "Special Project"
            type: "1235"
            state: "rejected"
            public: true
            rejectCount: 1
            authors: ["dirk"]
            owner: "dirk"
            created: new Date
            lastChange: new Date
        )
        Proposals.insert(
            title: "Another Draft"
            type: "1235"
            state: "draft"
            public: true
            rejectCount: 0
            authors: ["dirk"]
            owner: "dirk"
            created: new Date
            lastChange: new Date
        )
        
        Proposals.insert(
            title: "Private Project"
            type: "1234"
            state: "draft"
            public: false
            rejectCount: 0
            authors: ["dirk"]
            owner: "admin"
            created: new Date
            lastChange: new Date
        )
        
        Proposals.insert(
            title: "Another Private Project"
            type: "1234"
            state: "draft"
            public: false
            rejectCount: 0
            authors: ["dirk"]
            owner: "dirk"
            created: new Date
            lastChange: new Date
        )
        
        Proposals.insert(
            title: "Important Project"
            type: "1234"
            state: "examination"
            public: true
            rejectCount: 0
            authors: ["dirk"]
            owner: "dirk"
            created: new Date
            lastChange: new Date
        )
        
        Proposals.insert(
            title: "Approved Project"
            type: "1236"
            state: "approved"
            public: true
            rejectCount: 2
            authors: ["dirk"]
            owner: "dirk"
            created: new Date
            lastChange: new Date
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
            states: ["examination"]
            desc: "Examination"
        )

        Categories.insert(
            lu: "approved"
            private: false
            states: ["approved"]
            desc: "Approved"
        )

        Categories.insert(
            lu: "drafts"
            private: false
            states: ["draft","rejected"]
            desc: "Drafts"
        )

        Categories.insert(
            lu: "private"
            private: true
            states: ["draft"]
            desc: "Private"
        )

        Categories.insert(
            lu: "declined"
            private: false
            states: ["declined"]
            desc: "Declined"
        )

    setupStates = ->
        States.insert(
            lu: "draft"
            desc: labels.state_draft
        )
        States.insert(
            lu: "examination"
            desc: labels.state_examination
        )
        States.insert(
            lu: "rejected"
            desc: labels.state_rejected
        )
        States.insert(
            lu: "approved"
            desc: labels.state_approved
        )
        States.insert(
            lu: "declined"
            desc: labels.state_declined
        )

    setupRoles = ->
        Roles.insert(
            lu: "visitor"
            desc: "Visitor"
            cats: ["examination","approved","drafts","declined"]
        )
        Roles.insert(
            lu: "requestor"
            desc: "Requestor"
            cats: ["private","drafts","examination","approved","declined"]
        )
        Roles.insert(
            lu: "decision_maker"
            desc: "Decision Maker"
            cats: ["examination","drafts","declined","approved"]
        )
        Roles.insert(
            lu: "admin"
            desc: "Administrator"
            cats: []
        )
    