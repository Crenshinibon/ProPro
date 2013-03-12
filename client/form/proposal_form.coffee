

Template.project_type.getProjectTypes = ->
    res = ProjectTypes.find().fetch().map((e) ->
        e.desc
    )
    res.push(nothing_selected)
    res

Template.project_type.isSelectedProjectType = (some) ->
    console.log(some.toString())
    if(Meteor.user())
        us = getUserState(Meteor.user())
        if(this in us.openProjects)
            true
        else
            false

    #console.log(context)
    ""