# illustration of EM algorithm for QTL mapping

h = 600
w = 800
margin = {left:70, top:40, right:40, bottom: 70, inner:5}

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

permbutton = null
backbutton = null
backbuttontext = null
iteration = 0
radius = 4
bigradius = 6


d3.json "data.json", (data) ->

    add_buttons()
    
    toplot = {x: data.p[0], y: data.y}

    # using scatterplot just to get the frame, really
    mychart = scatterplot().xvar("x")
                           .yvar("y")
                           .xlab("Pr(AB | marker data)")
                           .ylab("Phenotype")
                           .xlim([-0.05, 1.05])
                           .height(h)
                           .width(w)
                           .margin(margin)
                           .dataByInd(false)
                           .title("Iteration 0, LOD = #{d3.format(".2f")(data.lod[0])}")
  
    d3.select("svg")
      .datum({data:toplot})
      .call(mychart)

    # x and y axis labels
    d3.select("g.x.axis text.title").text(() ->
                         return "Pr(AB | marker data)" if iteration == 0
                         "Pr(AB | marker data, y, theta-hat)")
    d3.select("g.y.axis text.title").text("Phenotype")

    # erase the points produced by scatterplot
    mychart.pointsSelect().remove()
    
    thesvg = d3.select("svg svg")

    indtip = d3.tip()
               .attr('class', 'd3-tip')
               .html((d,i) -> d3.format(".3f")(data.p[0][i]))
               .direction('e')
               .offset([0,10])
    thesvg.call(indtip)

    pointg = thesvg.append("g").attr("id", "newpoints")
    points = pointg.selectAll("empty")
                   .data(d3.range(data.y.length))
                   .enter()
                   .append("circle")
                   .attr("cx", (d) -> mychart.xscale()(data.p[0][d]))
                   .attr("cy", (d) -> mychart.yscale()(data.y[d]))
                   .attr("r", radius)
                   .attr("fill", "slateblue")
                   .attr("stroke", "black")
                   .attr("stroke-width", "1")
                   .on("mouseover.newtip", indtip.show)
                   .on("mouseout.newtip", indtip.hide)
                   .on("mouseover", () -> d3.select(this).attr("fill", "Orchid").attr("r", bigradius))
                   .on("mouseout", () -> d3.select(this).attr("fill", "slateblue").attr("r", radius))

    permbutton.on "click", ->
                      iteration++ unless iteration >= data.lod.length - 1
                      update_points()

    backbutton.on "click", ->
                      iteration-- unless iteration == 0
                      update_points()

    backbutton.on("mouseover", ->
                      if iteration > 0
                          d3.select(this).transition().duration(250).attr("opacity", 1)
                          backbuttontext.transition().duration(250).attr("opacity", 1)
                  )
              .on("mouseout", ->
                      d3.select(this).transition().duration(1000).attr("opacity", 0)
                      backbuttontext.transition().duration(1000).attr("opacity", 0))


    update_points = () ->
                 d3.select("g.title text").text("Iteration #{iteration}, LOD = #{d3.format(".2f")(data.lod[iteration])}")
                 points.transition().duration(1500)
                       .attr("cx", (d) -> mychart.xscale()(data.p[iteration][d]))
                 d3.select("g.x.axis text.title").text(() ->
                     return "Pr(AB | marker data)" if iteration == 0
                     "Pr(AB | marker data, y, theta-hat)")

                 console.log(iteration)
       


add_buttons = () ->
    permbuttong = svg.append("g").attr("id", "random_permutebutton")
                     .attr("transform", "translate(#{margin.left},#{totalh-buttonh})")
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
                     .attr("transform", "translate(#{margin.left+buttonw+buttonw2/2},#{totalh-buttonh})")
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

