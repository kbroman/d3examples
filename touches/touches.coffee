# playing with user interactions

width = 920
height = 450
ncircles = 20
colors = ["orchid", "#4DF0A7"]
bgcolor = d3.rgb(200, 200, 200)
radius = 8
bigradius = 16
svg = d3.select("div#chart")
        .append("svg")
        .attr({width: width, height: height})

svg.append("rect") 
   .attr({x:0, y:0, width:width, height:height})
   .attr({"stroke-width": 5, stroke:"black", fill:bgcolor})
   .style("pointer-events", "none")

random_circles = (number, width, height) ->
  dat = []
  for i in [0...number]
    dat.push([width,height].map((d) -> Math.floor(Math.random()*d)))
  dat

dat = random_circles(ncircles, width, height)
circolor = []
for i in [0...dat.length]
  circolor[i] = colors[0]

circles2touch = svg.selectAll("empty")
   .data(dat)
   .enter()
     .append("circle")
     .attr("cx", (d) -> d[0])
     .attr("cy", (d) -> d[1])
     .attr({r: bigradius})
     .attr("opacity", 0)
   .on "click", (d,i) ->
      print_event("circle click", [i, d[0], d[1]])
      circolor[i] = if circolor[i] == colors[0] then colors[1] else colors[0]
      svg.selectAll("#circ#{i}").transition().ease("linear").duration(500).attr("fill", circolor[i])

circles = svg.selectAll("empty")
   .data(dat)
   .enter()
     .append("circle")
     .attr("id", (d,i) -> "circ#{i}")
     .attr("cx", (d) -> d[0])
     .attr("cy", (d) -> d[1])
     .attr({r: radius})
     .attr({stroke:"black", "stroke-width": 2, fill: colors[0]})
     .style("pointer-events", "none")


ripples = (position) ->
   svg.append("circle")
        .attr({cx:position[0], cy:position[1], r:4})
        .attr({stroke:"slateblue", fill:"slateblue"})
        .style("pointer-events", "none")
      .transition()
        .delay(500)
        .remove()

   svg.selectAll("empty")
      .data([0,1,2,3,4])
      .enter()
        .append("circle")
        .attr({cx:position[0], cy:position[1], r:0})
        .attr({stroke:"slateblue", "stroke-width":2, fill:"none"})
        .style({opacity: 1})
        .style("pointer-events", "none")
      .transition()   
        .ease("linear")
        .duration(500)
        .delay((d) -> d*50)
        .attr("r", 100)
        .style("opacity", 0)
        .remove()

nevents = 0

svg.on "click", ->
  event = d3.mouse(this)
  ripples(event)
  print_event("click", event)

print_event = (type, location) ->
  nevents++
  d3.select("div#console")
    .append("p")
    .text("#{type} #{nevents} : #{location}")
  