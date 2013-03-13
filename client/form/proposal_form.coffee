Template.project_type.getProjectTypes = ->
    res = ProjectTypes.find().fetch().map((e) ->
        e.desc
    )
    res.push(nothing_selected)
    res

Template.project_type.isSelectedProjectType = (project) ->
    console.log(project)
    if(Meteor.user())
        us = getUserState(Meteor.user())
        