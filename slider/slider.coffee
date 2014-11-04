height = 500
width =  500
n_points = 30
rect_color = "#bbb"
point_color = "slateblue"
point_radius = 5

svg = d3.select("div#chart")
        .append("svg")
        .attr("height", height)
        .attr("width", width)

# rectangle background
svg.append("rect")
   .attr("x", 0)
   .attr("y", 0)
   .attr("height", height)
   .attr("width", width)
   .attr("fill", rect_color)
   .attr("stroke", "black")

# random points
points = []
for i in [1..n_points]
    points.push({x:Math.random()*width, y:Math.random()*height})

# circles at the points
svg.selectAll("empty")
   .data(points)
   .enter()
   .append("circle")
   .attr("cx", (d) -> d.x)
   .attr("cy", (d) -> d.y)
   .attr("r", point_radius)
   .attr("fill", point_color)
   .attr("stroke", "black")
   .attr("class", "points")

# slider controlling opacity of the points
d3.select("input[type=range]#opacity").on "input", () ->
             opacity = this.value
             d3.select("output#opacity")
               .text(d3.format(".2f")(opacity))
             d3.selectAll("circle.points")
               .attr("opacity", opacity)
