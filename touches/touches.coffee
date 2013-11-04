# playing with user interactions

width = 920
height = 450
ncircles = 20
colors = ["orchid", "#4DF0A7"]
svg = d3.select("div#chart")
        .append("svg")
        .attr({width: width, height: height})

svg.append("rect") 
   .attr({x:0, y:0, width:width, height:height})
   .attr({"stroke-width": 5, stroke:"black", fill:d3.rgb(200, 200, 200)})
   .style("pointer-events", "none")

random_circles = (number, width, height) ->
  dat = []
  for i in [0...number]
    x = Math.random()*width
    y = Math.random()*height
    dat.push([x,y])
  dat

dat = random_circles(ncircles, width, height)
circolor = []
for i in [0...dat.length]
  circolor[i] = colors[0]

circles = svg.selectAll("empty")
   .data(dat)
   .enter()
     .append("circle")
     .attr("cx", (d) -> d[0])
     .attr("cy", (d) -> d[1])
     .attr({r: 8})
     .attr({stroke:"black", "stroke-width": 2, fill: colors[0]})
   .on "click", (d,i) ->
      print_event("circle click", [i, d[0], d[1]])
      circolor[i] = if circolor[i] == colors[0] then colors[1] else colors[0]
      d3.select(this).transition().ease("linear").duration(500).attr("fill", circolor[i])

ripples = (position) ->
   svg.append("circle")
        .attr({cx:position[0], cy:position[1], r:4})
        .attr({stroke:"slateblue", fill:"slateblue"})
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

svg.on "touchstart", ->
  event = d3.touches(this)
  event.map(ripples)
  print_event("touch", event)

svg.on "touchmove", ->
  event = d3.touches(this)
  event.map(ripples)
  print_event("touchmove", event)

print_event = (type, location) ->
  nevents++
  d3.select("div#console")
    .append("p")
    .text("#{type} #{nevents} : #{location.map(Math.round)}")
  