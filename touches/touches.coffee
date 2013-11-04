# playing with user interactions

width = 920
height = 450
svg = d3.select("div#chart")
        .append("svg")
        .attr({width: width, height: height})

svg.append("rect") 
   .attr({x:0, y:0, width:width, height:height})
   .attr({"stroke-width": 5, stroke:"black", fill:d3.rgb(200, 200, 200)})
   .style("pointer-events", "none")

ripples = (position) ->
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
        .attr("r", 50)
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
    .text("#{type} #{nevents} : #{location}")
  