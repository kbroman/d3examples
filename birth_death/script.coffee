# bl.ocks: 960 x 500; 230x120 thumbnail

w =  960
h =  500
h_button = 50
w_button = 120
gap = 25

# svg and background rectangle
svg = d3.select("div#figure").append("svg").attr("height", h+gap+h_button).attr("width", w)

rect = svg.append("rect")
          .attr("height", h)
          .attr("width", w)
          .attr("class", "background")

# birth/death buttons at the bottom
buttons = svg.selectAll("empty")
   .data([0,1])
   .enter()
   .append("rect")
   .attr("x", (d) -> gap + (w_button+gap)*d)
   .attr("y", (d) -> h+gap)
   .attr("height", h_button)
   .attr("width", w_button)
   .attr("class", "button")

# text for the buttons
svg.selectAll("empty")
   .data([0,1])
   .enter()
   .append("text")
   .attr("class", "button")
   .attr("x", (d) -> gap + (w_button+gap)*d + w_button/2)
   .attr("y", (d) -> h+gap + h_button/2)
   .text((d) -> ["birth", "death"][d])

# to contain note at top left
note = svg.append("text")
          .attr("x", 20)
          .attr("y", 20)

# simulate data
n = 4
generate_point = (i) ->  {x:Math.random()*w, y:Math.random()*h, id:i}
points = d3.range(n).map((i) -> generate_point(i))
points_last = n-1

# function to update circles
update = (data, time=1000) ->
    circles =
    svg.selectAll("circle.points")
       .data(data, (d) -> d.id)
       .attr("cx", (d) -> d.x)
       .attr("cy", (d) -> d.y)
       .attr("r", 10)
       .attr("class", "points")


    circles.enter()
       .append("circle")
       .attr("cx", (d) -> d.x)
       .attr("cy", (d) -> d.y)
       .attr("r", 0)
       .attr("class", "points")
       .transition()
       .duration(time)
       .attr("r", 10)

    circles.exit()
           .classed({"dead":true})
           .transition()
           .duration(time/2)
           .delay(time/2)
           .attr("r", 0)
           .remove()

# create the initial points
update(points)

# button actions
buttons.on "click", (d) ->
    if d==1 and points.length > 0 # death
        to_die = Math.floor(Math.random()*points.length)
        note.text("death to number #{points[to_die].id+1}")
        points.splice(to_die-1, 1)
    else if d==0 # birth
        points_last += 1
        points.push(generate_point(points_last))
        note.text("birth to number #{points_last}")

    update(points)
