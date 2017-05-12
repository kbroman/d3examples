n=100
radius = 5

h = 500
w = 500

svg = d3.select("body").insert("svg")
        .attr("height", h).attr("width", w)

svg.insert("rect").attr("height", h).attr("width", w)
        .attr("x", 0).attr("y", 0).attr("fill", "#ddd")


data = d3.range(n).map((i) -> {x:Math.random()*w,y:Math.random()*h})
data = data.map((d) -> {x:d.x, y:d.y, true_x:d.x, true_y:d.y})

# vertical line
svg.append("line").attr("x1", w/2)
                  .attr("x2", w/2)
                  .attr("y1", 0)
                  .attr("y2", h)
                  .attr("stroke", "white")
                  .attr("stroke-width", 3)

points = svg.selectAll("empty")
            .data(data)
            .enter()
            .insert("circle")
            .attr("cx", (d) -> d.x)
            .attr("cy", (d) -> d.y)
            .attr("r", radius)
            .attr("fill", "slateblue")



# fix y positions
d3.range(n).map((i) -> data[i].fy = data[i].y)

tick_action = () ->
    points.attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)

simulation = d3.forceSimulation(data)
  .force("x", d3.forceX(w/2))
  .force("collide", d3.forceCollide(radius*1.1))
  .on("tick", tick_action)
