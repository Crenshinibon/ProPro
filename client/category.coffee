Template.category.desc = ->
    rc = Categories.findOne({lu: this.cat})
    rc.desc
        