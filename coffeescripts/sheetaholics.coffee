
fillConfigIntoForm = (config) ->
    config ?=
        gridSize: 8
        dotColor: '000000'
        dotDiameter: 0.4
        lineColor: '000000'
        lineWidth: 0.2
        marginInner: 20
        marginOuter: 15
        marginTop: 15
        marginBottom: 15
        pageFormat: 'a4'
        pageCount: 2

    document.getElementById('gridSize').value = config['gridSize']
    document.getElementById('marginInner').value = config['marginInner']
    document.getElementById('marginOuter').value = config['marginOuter']
    document.getElementById('marginTop').value = config['marginTop']
    document.getElementById('marginBottom').value = config['marginBottom']
    document.getElementById('dotDiameter').value = config['dotDiameter']
    document.getElementById('dotColor').value = config['dotColor']
    document.getElementById('lineWidth').value = config['lineWidth']
    document.getElementById('lineColor').value = config['lineColor']

    for option in document.getElementById('pageFormat').childNodes
        if option.value is config['pageFormat'] and option.selected is false
            option.selected = true
        else if option.value isnt config['pageFormat'] and option.selected is true
            option.selected = false

loadConfigFromForm = () ->
    config =
        gridSize: parseFloat(document.getElementById('gridSize').value)
        marginInner: parseFloat(document.getElementById('marginInner').value)
        marginOuter: parseFloat(document.getElementById('marginOuter').value)
        marginTop: parseFloat(document.getElementById('marginTop').value)
        marginBottom: parseFloat(document.getElementById('marginBottom').value)
        dotDiameter: parseFloat(document.getElementById('dotDiameter').value)
        dotColorR: parseInt(document.getElementById('dotColor').color.rgb[0] * 255)
        dotColorG: parseInt(document.getElementById('dotColor').color.rgb[1] * 255)
        dotColorB: parseInt(document.getElementById('dotColor').color.rgb[2] * 255)
        lineWidth: parseFloat(document.getElementById('lineWidth').value)
        lineColorR: parseInt(document.getElementById('lineColor').color.rgb[0] * 255)
        lineColorG: parseInt(document.getElementById('lineColor').color.rgb[1] * 255)
        lineColorB: parseInt(document.getElementById('lineColor').color.rgb[2] * 255)
        pageFormat: document.getElementById('pageFormat').value

    config['dotRadius'] = config['dotDiameter'] / 2

    if config['pageFormat'] is 'a3'
        config['pageWidth'] = 297
        config['pageHeight'] = 420
    else if config['pageFormat'] is 'a4'
        config['pageWidth'] = 210
        config['pageHeight'] = 297
    else if config['pageFormat'] is 'a5'
        config['pageWidth'] = 148
        config['pageHeight'] = 210
    else if config['pageFormat'] is 'letter'
        config['pageWidth'] = 216
        config['pageHeight'] = 279
    else if config['pageFormat'] is 'legal'
        config['pageWidth'] = 216
        config['pageHeight'] = 356

    return config

genpdf = (config) ->
    gridSize = config['gridSize']
    marginInner = config['marginInner']
    marginOuter = config['marginOuter']
    marginTop = config['marginTop']
    marginBottom = config['marginBottom']
    dotDiameter = config['dotDiameter']
    dotRadius = config['dotRadius']
    dotColorR = config['dotColorR']
    dotColorG = config['dotColorG']
    dotColorB = config['dotColorB']
    lineWidth = config['lineWidth']
    lineColorR = config['lineColorR']
    lineColorG = config['lineColorG']
    lineColorB = config['lineColorB']
    pageFormat = config['pageFormat']
    pageWidth = config['pageWidth']
    pageHeight = config['pageHeight']

    # Create the document
    pdf = new jsPDF('p','mm',pageFormat)

    col_count = parseInt(Math.floor((pageWidth - marginInner - marginOuter) / gridSize)) + 1
    row_count = parseInt(Math.floor((pageHeight - marginTop - marginBottom) / gridSize)) + 1


    for i in [1..2] # 2 pages for 2 sides shall be enough
        # Swap marginOuter & marginInner alternatively for even & odd pages
        if i > 1
            _tmp = marginOuter
            marginOuter = marginInner
            marginInner = _tmp

        x_adjust = ((pageWidth - marginInner - marginOuter) - (col_count - 1) * gridSize) / 2
        y_adjust = ((pageHeight - marginTop - marginBottom) - (row_count - 1) * gridSize) / 2

        # Draw lines
        if lineWidth > 0
            lineLength = (pageWidth - marginInner - marginOuter)
            x_offset = marginInner
            y_offset = y_adjust + marginTop - lineWidth / 2

            pdf.setDrawColor(lineColorR, lineColorG, lineColorB)
            for j in [1..row_count]
                isFirstLine = (j == 1)
                isLastLine = (j == row_count)

                y = y_offset + (j-1) * gridSize

                if isFirstLine or isLastLine
                    pdf.setLineWidth(lineWidth * 2)
                else
                    pdf.setLineWidth(lineWidth)

                pdf.line(x_offset, y, x_offset + lineLength, y)

        # Draw dots
        if dotRadius > 0
            x_offset = x_adjust + marginInner
            y_offset = y_adjust + marginTop - lineWidth / 2

            pdf.setFillColor(dotColorR, dotColorG, dotColorB)

            for j in [1..row_count]
                y = y_offset + (j-1) * gridSize

                for k in [1..col_count]
                    x = x_offset + (k-1) * gridSize
                    pdf.circle(x, y, dotRadius, 'F')

        if i < 2
            pdf.addPage()
    return pdf

isBrowser =
    #See more at: http://www.codekhan.com/2012/12/how-to-detect-different-browsers-using.html#sthash.sSBc7ake.dpuf

    firefox: () ->
        return navigator.userAgent.toLowerCase().indexOf("firefox") > -1
    chrome: () ->
        return navigator.userAgent.toLowerCase().indexOf("chrome") > -1
    opera: () ->
        return navigator.userAgent.toLowerCase().indexOf("opera") > -1
    msie: () ->
        return navigator.userAgent.toLowerCase().indexOf("msie") > -1
    safari: () ->
        return navigator.userAgent.toLowerCase().indexOf("safari") > -1

isMobile =
    Android: () ->
        return navigator.userAgent.match(/Android/i)
    BlackBerry: () ->
        return navigator.userAgent.match(/BlackBerry/i)
    iOS: () ->
        return navigator.userAgent.match(/iPhone|iPad|iPod/i)
    Opera: () ->
        return navigator.userAgent.match(/Opera Mini/i)
    Windows: () ->
        return navigator.userAgent.match(/IEMobile/i)
    any: () ->
        return (isMobile.Android() || isMobile.BlackBerry() || isMobile.iOS() || isMobile.Opera() || isMobile.Windows())

clickBtnGenPdf = () ->
    pdf = genpdf( loadConfigFromForm() )
    window.location.href = pdf.output('datauristring')

updatePreview = () ->
    if document.getElementById("iShowPDF") isnt null
        pdf = genpdf( loadConfigFromForm() )
        string = pdf.output('datauristring')
        document.getElementById("iShowPDF").src = string

document.getElementById("btnGeneratePDF").onclick = clickBtnGenPdf
document.getElementById("btnGeneratePDF2").onclick = clickBtnGenPdf

if isMobile.any() or isBrowser.firefox()
    ePreviewPDF = document.getElementById("previewPDF")
    ePreviewPDF.parentNode.removeChild(ePreviewPDF)
else
    for form_input in document.getElementsByTagName("input")
        form_input.onchange = updatePreview
    for form_select in document.getElementsByTagName("select")
        form_select.onchange = updatePreview

    window.onload = () ->
        fillConfigIntoForm()
        updatePreview()
