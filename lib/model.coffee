unless Roles
    Roles = new Meteor.Collection("roles")
    Roles.remove({})
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

unless States
    States = new Meteor.Collection("states")
    States.remove({})
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

unless Categories
    Categories = new Meteor.Collection("categories")
    Categories.remove({})
    Categories.insert(
        lu: "examination"
        states: ["examination"]
        visibility: ["public"]
        desc: "Examination"
    )

    Categories.insert(
        lu: "approved"
        states: ["approved"]
        visibility: ["public"]
        desc: "Approved"
    )

    Categories.insert(
        lu: "drafts"
        states: ["draft","rejected"]
        visibility: ["public"]
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
        visibility: ["public"]
        desc: "Declined"
    )


###
# Live Data!
# don't forget to remove later, otherwise all 
# projects will get delete on initialization 
###

unless UserRoles
    UserRoles = new Meteor.Collection("userroles")
    UserRoles.remove({})


unless UserStates
    UserStates = new Meteor.Collection("userstates")
    UserStates.remove({})

defaultUserState = (user) ->
    lu: user
    openProjects: []
    selectedRole: "visitor"


unless Projects
    Projects = new Meteor.Collection("projects")
    Projects.remove({})
    
    Projects.insert(
        title: "Special Project"
        state: "draft"
        visibility: "public"
        owner: "dirk"
        rejectCount: 0
        created: new Date
        lastChange: new Date
    )
    
    Projects.insert(
        title: "Important Project"
        state: "examination"
        visibility: "public"
        owner: "dirk"
        rejectCount: 0
        created: new Date
        lastChange: new Date
    )

unless ProjectTypes
    ProjectTypes = new Meteor.Collection("projecttypes")
    ProjectTypes.remove({})