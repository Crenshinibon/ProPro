workflow =
    workflowInfoLabel: (proposal, user) ->
        if model.currentUserRole(user) is model.role.requestor
            labels.workflow_info_label_warning
        else
            labels.workflow_info_label_info
    workflowInfoType: (proposal, user) ->
        if model.currentUserRole(user) is model.role.requestor
            'label-warning'
        else
            'label-info'
    workflowInfoTooltip: (proposal, user) ->
        if model.currentUserRole(user) is model.role.requestor
            'Missing requirements.'
        else
            'Other requirements.'
    