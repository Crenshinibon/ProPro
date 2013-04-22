Template.collections_editor.elements = () ->
    model.collectionElements(this.proposal._id, this.type)
    
Template.collections_editor.empty = () ->
    model.collectionElements(this.proposal._id, this.type).length is 0
    
Template.collections_editor.isEditable = () ->
    model.allowedToEdit(Meteor.user(), this.proposal)
    
Template.collections_editor.events(
    'click button.add-collection-element': () ->
        model.insertElement(this.proposal._id, this.type)
)

editable = (proposalId) ->
    proposal = Proposals.findOne({_id: proposalId})
    proposal? and model.allowedToEdit(Meteor.user(), proposal)

Template.element.offset = () ->
    if this.depth > 0
        "offset#{this.depth}"

Template.element.span = () ->
    "span#{12 - this.depth}"
    
Template.element.addable = () ->
    this.addable and editable(this.proposal)
    
Template.element.isEditable = () ->
    editable(this.proposal)

Template.element.deletable = () ->
    this.deletable and editable(this.proposal)
    
Template.element.up = () ->
    this.up and editable(this.proposal)
    
Template.element.down = () ->
    this.down and editable(this.proposal)

Template.element.higher = () ->
    this.higher and editable(this.proposal)

Template.element.deeper = () ->
    this.deeper and editable(this.proposal)
    
Template.element.events(
    'click button.btn-add-element': () ->
        model.insertElement(this.proposal, model.collectionTypes[this.type], this)
    'click button.btn-remove': () ->
        model.removeElement(this)
    'click button.btn-up': () ->
        model.moveElementUp(this)
    'click button.btn-down': () ->
        model.moveElementDown(this)
    'click button.btn-deeper': () ->
        model.increaseElementDepth(this)
    'click button.btn-higher': () ->
        model.decreaseElementDepth(this)
)
