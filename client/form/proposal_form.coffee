nothing_lu = 'nothing_selected'

Template.project_type.getProjectTypes = ->
    res = ProjectTypes.find().fetch()
    res.push(
        lu: nothing_lu
        desc: nothing_selected)
    res.reverse()
    res

Template.project_type.isSelectedProjectType = (type, project) ->
    if(project.type)
        if(project.type is type.lu)
            'selected'