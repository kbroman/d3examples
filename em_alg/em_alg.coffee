# illustration of EM algorithm for QTL mapping

h = 550
w = 650
margin = {left:100, top:40, right:10, bottom: 90, inner:15}
axispos = {xtitle:50, ytitle:85, xlabel:10, ylabel:10}
radius = 4
bigradius = 6
pointcolor = "slateblue"
hilitpointcolor = "Orchid"
pointstrokecolor = "black"
pointstrokewidth = 1
segwidth = 50
segcolor = "violetred"
seglwd = 6
duration = 1500

# permute button
buttonw = 80
buttonh = 40

# back button
buttonw2 = 80

totalh = h + buttonh + margin.bottom*1.5


svg = d3.select("div#chart")
        .append("svg")
        .attr("height", totalh)
        .attr("width", w+margin.left*margin.right)

# globals
permbutton = null
backbutton = null
backbuttontext = null
iteration = 0


d3.json "data.json", (data) ->

    add_buttons()
    
    toplot = {data:{x: data.p[0], y: data.y}, indID:[]}

    for i of data.y
        toplot.indID[i] = d3.format(".3f")(data.p[0][i])

    # using scatterplot just to get the frame, really
    mychart = scatterplot().xvar("x")
                           .yvar("y")
                           .xlab("Pr(AB | marker data)")
                           .ylab("Phenotype")
                           .xlim([-0.025, 1.025])
                           .height(h)
                           .width(w)
                           .margin(margin)
                           .axispos(axispos)
                           .dataByInd(false)
                           .pointcolor(pointcolor)
                           .pointsize(radius)
                           .pointstroke(pointstrokecolor)
                           .title("Iteration 0, LOD = #{d3.format(".2f")(data.lod[0])}")
  
    d3.select("svg")
      .datum(toplot)
      .call(mychart)

    thesvg = d3.select("svg svg g")

    points = mychart.pointsSelect()
                    .on("mouseover", () ->
                                d3.select(this)
                                  .attr("fill", hilitpointcolor)
                                  .attr("r", bigradius))
                    .on("mouseout", () ->
                                d3.select(this)
                                  .attr("fill", pointcolor)
                                  .attr("r", radius))

    segtip = d3.tip()
               .attr('class', 'd3-tip')
               .attr('id', 'violet')
               .html((d,i) -> d3.format(".2f")(data.theta[iteration][i]))
               .direction('e')
               .offset([0,10])
    thesvg.call(segtip)

    segments = thesvg.selectAll("empty")
                     .data([0,1])
                     .enter()
                     .append("line")
                     .attr("x1", (d) -> mychart.xscale()(d)-segwidth/2)
                     .attr("x2", (d) -> mychart.xscale()(d)+segwidth/2)
                     .attr("y1", (d) -> mychart.yscale()(data.theta[0][d]))
                     .attr("y2", (d) -> mychart.yscale()(data.theta[0][d]))
                     .attr("fill", "none")
                     .attr("stroke", segcolor)
                     .attr("stroke-width", seglwd)
                     .on("mouseover", segtip.show)
                     .on("mouseout", segtip.hide)
    

    permbutton.on "click", ->
                      iteration++ unless iteration >= data.lod.length - 1
                      if iteration > 0
                          backbutton.transition()
                                    .duration(250)
                                    .attr("opacity", 1)
                          backbuttontext.transition()
                                        .duration(250)
                                        .attr("opacity", 1)
                      update()

    backbutton.on "click", ->
                      iteration-- unless iteration == 0
                      if iteration == 0
                          backbutton.transition()
                                    .duration(250)
                                    .attr("opacity", 0)
                          backbuttontext.transition()
                                        .duration(250)
                                        .attr("opacity", 0)
                      update()

    update = () ->
                 d3.select("g.title text").text("Iteration #{iteration}, " +
                                     "LOD = #{d3.format(".2f")(data.lod[iteration])}")
                 points.transition().duration(duration)
                       .attr("cx", (d) -> mychart.xscale()(data.p[iteration][d]))
                 segments.transition().duration(duration)
                     .attr("y1", (d) -> mychart.yscale()(data.theta[iteration][d]))
                     .attr("y2", (d) -> mychart.yscale()(data.theta[iteration][d]))
                 d3.select("g.x.axis text.title").text(() ->
                     return "Pr(AB | marker data)" if iteration == 0
                     "Pr(AB | marker data, y, \u03b8)")


add_buttons = () ->
    permbuttong = svg.append("g").attr("id", "random_permutebutton")
                     .attr("transform", "translate(#{margin.left},#{totalh-buttonh*1.1})")
    permbutton = permbuttong.append("rect")
                            .attr("x", 0)
                            .attr("y", 0)
                            .attr("width", buttonw)
                            .attr("height", buttonh)
                            .attr("fill", d3.rgb(152, 254, 152))
                            .attr("stroke", "black")
                            .attr("stroke-width", 1)
    permbuttong.append("text")
               .attr("x", buttonw/2)
               .attr("y", buttonh/2)
               .attr("text-anchor", "middle")
               .attr("dominant-baseline", "middle")
               .text("Next")
               .style("font-size", "28px")
               .style("pointer-events", "none")
               .attr("fill", "black")

    backbuttong = svg.append("g").attr("id", "random_backbutton")
                     .attr("transform", "translate(#{margin.left+buttonw+buttonw2/2},#{totalh-buttonh*1.1})")
    backbutton = backbuttong.append("rect")
                            .attr("x", 0)
                            .attr("y", 0)
                            .attr("width", buttonw2)
                            .attr("height", buttonh)
                            .attr("fill", d3.rgb(254, 152, 254))
                            .attr("stroke", "black")
                            .attr("stroke-width", 1)
                            .attr("opacity", 0)
    backbuttontext = backbuttong.append("text")
                                .attr("x", buttonw2/2)
                                .attr("y", buttonh/2)
                                .attr("text-anchor", "middle")
                                .attr("dominant-baseline", "middle")
                                .text("Back")
                                .style("font-size", "28px")
                                .style("pointer-events", "none")
                                .attr("fill", "black")
                                .attr("opacity", 0)

