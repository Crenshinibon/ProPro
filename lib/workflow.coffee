workflow =
    workflowInfoLabel: (proposal, user) ->
        if getCurrentUserRole(user) is 'requestor'
            labels.workflow_info_label_warning
        else
            labels.workflow_info_label_info
    workflowInfoType: (proposal, user) ->
        if getCurrentUserRole(user) is 'requestor'
            'label-warning'
        else
            'label-info'
    workflowInfoTooltip: (proposal, user) ->
        if getCurrentUserRole(user) is 'requestor'
            'Missing requirements.'
        else
            'Other requirements.'
    