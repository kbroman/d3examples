# playing with user interactions

width = 1000
height = 800
svg = d3.select("div#chart")
        .append("svg")
        .attr({width: width, height: height})

svg.append("rect") 
   .attr({x:0, y:0, width:width, height:height})
   .attr({"stroke-width": 5, stroke:"black", fill:d3.rgb(200, 200, 200)})

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

svg.on("click", -> ripples(d3.mouse(this)))
svg.on("touchstart", -> d3.touches(this).map(ripples))
