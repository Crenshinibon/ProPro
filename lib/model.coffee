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

defaultUserRoles = (user) -> 
    [{lu: user, role: "visitor"},{lu: user, role: "requestor"}] 

unless UserStates
    UserStates = new Meteor.Collection("userstates")

defaultUserState = (user) ->
    lu: user
    openProposals: []
    selectedRole: "visitor"

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
        
insertDummyProposals = ->
    Proposals.insert(
        title: "Special Project"
        type: "1235"
        state: "draft"
        visibility: "public"
        owner: "dirk"
        rejectCount: 0
        created: new Date
        lastChange: new Date
    )

    Proposals.insert(
        title: "Important Project"
        type: "1234"
        state: "examination"
        visibility: "public"
        owner: "dirk"
        rejectCount: 0
        created: new Date
        lastChange: new Date
    )


cleanupVariableData = ->
    UserRoles.remove({})
    UserStates.remove({})
    Proposals.remove({})


setupCategories = ->
    Categories.insert(
        lu: "examination"
        states: ["examination"]
        visibility: ["public","private"]
        desc: "Examination"
    )

    Categories.insert(
        lu: "approved"
        states: ["approved"]
        visibility: ["public","private"]
        desc: "Approved"
    )

    Categories.insert(
        lu: "drafts"
        states: ["draft","rejected"]
        visibility: ["public","private"]
        desc: "Drafts"
    )

    Categories.insert(
        lu: "private"
        states: ["draft"]
        visibility: ["private"]
        desc: "Private"
    )

    Categories.insert(
        lu: "declined"
        states: ["declined"]
        visibility: ["public","private"]
        desc: "Declined"
    )

setupStates = ->
    States.insert(
        lu: "draft"
        desc: "Draft"
    )
    States.insert(
        lu: "examination"
        desc: "Examination"
    )
    States.insert(
        lu: "rejected"
        desc: "Rejected"
    )
    States.insert(
        lu: "approved"
        desc: "Approved"
    )
    States.insert(
        lu: "declined"
        desc: "Declined"
    )
    
setupRoles = ->
    Roles.insert(
        lu: "visitor"
        desc: "Visitor"
        cats: [
            {cat: "examination", open: true}
            {cat: "approved", open: true}
            {cat: "drafts", open: false}
            {cat: "declined", open: false}]
    )
    Roles.insert(
        lu: "requestor"
        desc: "Requestor"
        cats: [
            {cat: "private", open: true}
            {cat: "drafts", open: true}
            {cat: "examination", open: false}
            {cat: "approved", open: false}
            {cat: "declined", open: false}]
    )
    Roles.insert(
        lu: "decision_maker"
        desc: "Decision Maker"
        cats: [
            {cat: "examination", open: true}
            {cat: "drafts", open: false}
            {cat: "declined", open: false}
            {cat: "approved", open: false}]
    )
    