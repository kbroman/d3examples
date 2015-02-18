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

buttons = svg.selectAll("empty")
   .data([0,1])
   .enter()
   .append("rect")
   .attr("x", (d) -> gap + (w_button+gap)*d)
   .attr("y", (d) -> h+gap)
   .attr("height", h_button)
   .attr("width", w_button)
   .attr("class", "button")

svg.selectAll("empty")
   .data([0,1])
   .enter()
   .append("text")
   .attr("class", "button")
   .attr("x", (d) -> gap + (w_button+gap)*d + w_button/2)
   .attr("y", (d) -> h+gap + h_button/2)
   .text((d) -> ["birth", "death"][d])


# simulate data
n = 10

generate_point = () ->  {x:Math.random()*w, y:Math.random()*h}
points = d3.range(n).map((i) -> generate_point())

# function to update circles
update = (data, time=3000) ->
    circles =
    svg.selectAll("circle.points")
       .data(data)
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
           .duration(time)
           .attr("r", 0)
           .transition()
           .delay(time)
           .remove()

update(points)

#setTimeout( (-> update(points)), 4000)

note = svg.append("text")
          .attr("x", 20)
          .attr("y", 20)


buttons.on "click", (d) ->
    if d==1 # death
#        to_die = Math.floor(Math.random()*points.length)
#        points.splice(to_die, 1)
        points.pop()
#        note.text("death to number #{to_die+1}")
        note.text("death to number #{points.length+1}")
        console.log(points.length)
    else # birth
        points.push(generate_point())
        note.text("birth to number #{points.length+1}")

    update(points)
