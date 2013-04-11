Template.editor.rendered = ->
    events = this.data.events
    taId = this.data.textareaId
    $("##{taId}").wysihtml5(
        'font-styles': true
        'emphasis': true
        'lists': true
        'html': false
        'link': false
        'image': false
        'color': false
        events:
            'change': ->
                value = $("##{taId}").val()
                events.change?(value, taId)
            'blur': ->
                value = $("##{taId}").val()
                events.blur?(value, taId)
            'focus': ->
                value = $("##{taId}").val()
                events.focus?(value, taId)
            
    )
