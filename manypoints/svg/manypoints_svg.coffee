w = 800
h = 800

# function to move an element to the front
d3.selection.prototype.moveToFront = () ->
    this.each () -> this.parentNode.appendChild(this)

# add SVG
svg = d3.select("div#chart")
        .append("svg")
        .attr("width",  w)
        .attr("height", h)

# add background rectangle
svg.append("rect")
   .attr("height", h)
   .attr("width", w)
   .attr("stroke", "black")
   .attr("stroke-width", 2)
   .attr("fill", "#bbb")

# function to create a circle object
createCircle = () ->
    circ = {r:Math.random()*3+3}
    circ.x = circ.r + Math.random()*(w - circ.r*2)
    circ.y = circ.r + Math.random()*(h - circ.r*2)
    circ

# generate 100,000 circles
n_circles = 100000
circles = []
for i in [1..n_circles]
    circles.push(createCircle())

# draw the circles
svg.selectAll("empty")
   .data(circles)
   .enter()
   .append("circle")
   .attr("cx", (d) -> d.x)
   .attr("cy", (d) -> d.y)
   .attr("r", (d) -> d.r)
   .attr("stroke", "black")
   .attr("fill", "slateblue")
   .attr("stroke-width", 1)
   .on("mouseover", () ->
       d3.select(this).attr("fill", "Orchid").moveToFront())
   .on("mouseout", () ->
       d3.select(this).attr("fill", "slateblue"))
