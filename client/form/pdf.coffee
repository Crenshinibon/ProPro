@pdf = {}
@pdf.generatePdf = (proposal) ->
    doc = new jsPDF
    doc.text(20,20,proposal.title)
    doc.save(proposal.title + ".pdf")