# manyboxplots2.coffee
#
# Top panel is like ~500 box plots:
#   lines are drawn at the 0.1 1, 10, 25, 50, 75, 90, 99, 99.9 percentiles
#   for each of ~500 distributions
# Hover over a column in the top panel and the corresponding distribution
#   is show below; click for it to persist; click again to make it go away.
#

d3.json "data.json", (data) ->

  # dimensions of SVG
  h = 450
  w = h
  pad = {left:40, top:40, right:20, bottom: 40}
  innerPad = 5
  animationDuration = 500

  totalh = h + pad.top + pad.bottom
  totalw = (w + pad.left + pad.right)*2

  svg = d3.select("div#plot")
          .append("svg")
          .attr("height", totalh)
          .attr("width", totalw)

  # panel for correlation image
  corrplot = svg.append("g")
               .attr("id", "corrplot")
               .attr("transform", "translate(#{pad.left},#{pad.top})")

  # panel for scatterplot
  scatterplot = svg.append("g")
                   .attr("id", "scatterplot")
                   .attr("transform", "translate(#{pad.left*2+pad.right+w},#{pad.top})")

  # no. data points
  nind = data.ind.length
  nvar = data.var.length

  corXscale = d3.scale.ordinal().domain(d3.range(nvar)).rangeBands([0, w])
  corYscale = d3.scale.ordinal().domain(d3.range(nvar)).rangeBands([h, 0])
  corZscale = d3.scale.linear().domain([-1, 0, 1]).range(["darkslateblue", "white", "crimson"])

  # create list with correlations
  corr = []
  for i of data.corr
    for j of data.corr[i]
      corr.push({row:i, col:j, value:data.corr[i][j]})


  # gray background on scatterplot
  scatterplot.append("rect")
             .attr("height", h)
             .attr("width", w)
             .attr("fill", d3.rgb(200, 200, 200))
             .attr("stroke", "black")
             .attr("stroke-width", 1)
             .attr("pointer-events", "none")

  # colors for scatterplot
  colors = ["crimson", "green", "darkslateblue"]

  initialDrawn = false
  drawInitialScatter = (i,j) ->
    initialDrawn = true
    xScale = d3.scale.linear()
                     .domain(d3.extent(data.dat[i]))
                     .range([innerPad, w-innerPad]) 
    yScale = d3.scale.linear()
                     .domain(d3.extent(data.dat[j]))
                     .range([h-innerPad, innerPad])
    scatterplot.selectAll("empty")
               .data(d3.range(nind))
               .enter()
               .append("circle")
               .attr("class", "points")
               .attr("cx", (d) -> xScale(data.dat[i][d]))
               .attr("cy", (d) -> yScale(data.dat[j][d]))
               .attr("r", 3)
               .attr("stroke", "black")
               .attr("stroke-width", 1)
               .attr("fill", (d) -> colors[data.group[d]-1])
    scatterplot.append("text").attr("id", "xaxis")
               .attr("x", w/2)
               .attr("y", h+pad.bottom*0.7)
               .text(data.var[i])
               .attr("dominant-baseline", "middle")
               .attr("text-anchor", "middle")
    scatterplot.append("text").attr("id", "yaxis")
               .attr("x", -pad.left*0.7)
               .attr("y", h/2)
               .text(data.var[j])
               .attr("dominant-baseline", "middle")
               .attr("text-anchor", "middle")
               .attr("transform", "rotate(270,#{-pad.left*0.7},#{h/2})")

  # scatterplot points
  drawScatter = (i,j) ->
    xScale = d3.scale.linear()
                     .domain(d3.extent(data.dat[i]))
                     .range([innerPad, w-innerPad]) 
    yScale = d3.scale.linear()
                     .domain(d3.extent(data.dat[j]))
                     .range([h-innerPad, innerPad])
    d3.selectAll("circle.points")
      .transition()
      .duration(animationDuration)
      .attr("cx", (d) -> xScale(data.dat[i][d]))
      .attr("cy", (d) -> yScale(data.dat[j][d]))
    
    d3.select("text#xaxis")
      .text(data.var[i])
    d3.select("text#yaxis")
      .text(data.var[j])


  cells = corrplot.selectAll("empty")
             .data(corr)
             .enter().append("rect")
             .attr("class", "cell")
             .attr("x", (d) -> corXscale(d.col))
             .attr("y", (d) -> corYscale(d.row))
             .attr("width", corXscale.rangeBand())
             .attr("height", corYscale.rangeBand())
             .attr("fill", (d) -> corZscale(d.value))
             .attr("stroke", "none")
             .attr("stroke-width", 2)
             .on("mouseover", (d) ->
                 d3.select(this).attr("stroke", "white")
                 corrplot.append("text").attr("id", "corrtext")
                         .text(d3.format(".2f")(d.value))
                         .attr("x", ->
                             mult = -1
                             mult = +1 if d.col < nvar/2
                             corXscale(d.col) + mult * corXscale.rangeBand()*5)
                         .attr("y", ->
                             mult = +1
                             mult = -1 if d.row < nvar/2
                             corYscale(d.row) + (mult+0.5) * corYscale.rangeBand()*2)
                         .attr("fill", "white")
                         .attr("dominant-baseline", "middle")
                         .attr("text-anchor", "middle"))
             .on("mouseout", ->
                 d3.select(this).attr("stroke","none")
                 corrplot.selectAll("text#corrtext").remove())
             .on("click",(d) ->
                  if initialDrawn
                    drawScatter(d.col, d.row)
                  else
                    drawInitialScatter(d.col, d.row))



  # boxes around panels
  corrplot.append("rect")
         .attr("height", h)
         .attr("width", w)
         .attr("fill", "none")
         .attr("stroke", "black")
         .attr("stroke-width", 1)
         .attr("pointer-events", "none")

  scatterplot.append("rect")
             .attr("height", h)
             .attr("width", w)
             .attr("fill", "none")
             .attr("stroke", "black")
             .attr("stroke-width", 1)
             .attr("pointer-events", "none")

  # text above
  corrplot.append("text")
          .text("Correlation matrix")
          .attr("id", "corrtitle")
          .attr("x", w/2)
          .attr("y", -pad.top/2)
          .attr("dominant-baseline", "middle")
          .attr("text-anchor", "middle")

  scatterplot.append("text")
             .text("Scatterplot")
             .attr("id", "corrtitle")
             .attr("x", w/2)
             .attr("y", -pad.top/2)
             .attr("dominant-baseline", "middle")
             .attr("text-anchor", "middle")
