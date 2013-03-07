if(!Roles)
        Roles = new Meteor.Collection("roles")
        Roles.remove({})
        Roles.insert(
            lu: "visitor"
            desc: "Visitor"
            cats: [
                {cat: "examination", open: true}
                {cat: "approved", open: true}
                {cat: "progress", open: false}
                {cat: "declined", open: false}]
        )
        Roles.insert(
            lu: "requestor"
            desc: "Requestor"
            cats: [
                {cat: "private", open: true}
                {cat: "progress", open: true}
                {cat: "examination", open: false}
                {cat: "approved", open: false}
                {cat: "declined", open: false}]
        )
        Roles.insert(
            lu: "decision_maker"
            desc: "Decision Maker"
            cats: [
                {cat: "examination", open: true}
                {cat: "progress", open: false}
                {cat: "declined", open: false}
                {cat: "approved", open: false}]
        )

if(!Categories)
        Categories = new Meteor.Collection("categories")
        Categories.remove({})
        Categories.insert(
            lu: "examination" 
            desc: "Examination"
        )

        Categories.insert(
            lu: "approved"
            desc: "Approved"
        )

        Categories.insert(
            lu: "drafts"
            desc: "Drafts"
        )

        Categories.insert(
            lu: "private"
            desc: "Private"
        )

        Categories.insert(
            lu: "declined"
            desc: "Declined"
        )