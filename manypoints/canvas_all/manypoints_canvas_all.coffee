canvasApp = () ->

    w = 800
    h = 800

    d3.select("div#chart")
      .append("canvas")
      .attr("id", "canvasOne")
      .attr("width",  w)
      .attr("height", h)

    createCircle = () ->
        circ = {r:Math.random()*3+3}
        circ.x = circ.r + Math.random()*(w - circ.r*2)
        circ.y = circ.r + Math.random()*(h - circ.r*2)
        circ

    n_circles = 100000
    circles = []
    for i in [1..n_circles]
        circles.push(createCircle())

    canvas = d3.select("canvas#canvasOne").node()
    context = canvas.getContext("2d")

    drawCircle = (circ, color) ->
        context.fillStyle = color
        context.lineWidth = 2
        context.beginPath()
        context.moveTo(circ.x, circ.y)
        context.arc(circ.x, circ.y, circ.r, 0, 2*Math.PI, false)
        context.closePath()
        context.stroke()
        context.fill()

    drawScreen = () ->
        context.fillStyle = "#bbb"
        context.strokeStyle = "black"
        context.lineWidth = 2
        context.fillRect(0,0,w,h)
        context.strokeRect(0,0,w,h)

        circles.map (circ) -> drawCircle(circ, "slateblue")

    drawScreen()

    getMousePos = (canvas, event) ->
        rect = canvas.getBoundingClientRect()
        {x: event.clientX - rect.left, y:event.clientY - rect.top}

    theseCircles = []
    lastCircles = []

    canvas.addEventListener "mousemove", (event) ->
        lastCircles = theseCircles
        theseCircles = []
        mousePos = getMousePos(canvas, event)
        overlap = 0
        for i in [0...circles.length]
            circ = circles[i]
            d = Math.sqrt(Math.pow(circ.x - mousePos.x, 2) + Math.pow(circ.y - mousePos.y, 2))
            theseCircles.push(circ) if d <= circ.r
        message = "On #{theseCircles.length} points"
        d3.select("p#message").text(message)
        lastCircles.map (circ) -> drawCircle(circ, "slateblue")
        theseCircles.map (circ) -> drawCircle(circ, "Orchid")

window.onload = canvasApp
