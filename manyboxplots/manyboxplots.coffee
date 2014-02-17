# manyboxplots.coffee
#
# Top panel is like 500 box plots:
#   lines are drawn at the 1, 5, 10, 25, 50, 75, 90, 95, 99 percentiles
#   for each of 500 distributions
# Hover over a column in the top panel and the corresponding distribution
#   is show below; click for it to persist; click again to make it go away.

# function that does all of the work
draw = (data) ->

  # dimensions of SVG
  w = 1000
  h = 450
  pad = {left:60, top:20, right:40, bottom: 40}

  # adjust counts object to make proper histogram
  br2 = []
  for i in data.br
    br2.push(i)
    br2.push(i)

  fix4hist = (d) ->
    x = [0]
    for i in d
       x.push(i)
       x.push(i)
    x.push(0)
    x

  for i of data.counts
    data.counts[i] = fix4hist(data.counts[i])

  # number of quantiles
  nQuant = data.quant.length
  midQuant = (nQuant+1)/2 - 1

  xScale = d3.scale.linear()
             .domain([0, data.ind.length-1])
             .range([pad.left, w-pad.right])

  yScale = d3.scale.linear()
             .domain([-1.1, 1.1])
             .range([h-pad.bottom, pad.top])

  axisFormat2 = d3.format(".2f")
  axisFormat1 = d3.format(".1f")

  quline = (j) ->
    d3.svg.line()
        .x((d,i) -> xScale(i))
        .y((d) -> yScale(data.quant[j][d]))

  svg = d3.select("body").append("svg")
          .attr("width", w)
          .attr("height", h)

  # gray background
  svg.append("rect")
     .attr("x", pad.left)
     .attr("y", pad.top)
     .attr("height", h-pad.top-pad.bottom)
     .attr("width", w-pad.left-pad.right)
     .attr("stroke", "none")
     .attr("fill", d3.rgb(200, 200, 200))

  # axis on left
  LaxisData = [-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1]
  Laxis = svg.append("g")

  # axis: white lines
  Laxis.append("g").selectAll("empty")
     .data(LaxisData)
     .enter()
     .append("line")
     .attr("class", "line")
     .attr("class", "axis")
     .attr("x1", pad.left)
     .attr("x2", w-pad.right)
     .attr("y1", (d) -> yScale(d))
     .attr("y2", (d) -> yScale(d))
     .attr("stroke", "white")

  # axis: labels
  Laxis.append("g").selectAll("empty")
     .data(LaxisData)
     .enter()
     .append("text")
     .attr("class", "axis")
     .text((d) -> axisFormat2(d))
     .attr("x", pad.left*0.9)
     .attr("y", (d) -> yScale(d))
     .attr("dominant-baseline", "middle")
     .attr("text-anchor", "end")


  # axis on left
  BaxisData = [50, 100, 150, 200, 250, 300, 350, 400, 450]
  Baxis = svg.append("g")

  # axis: white lines
  Baxis.append("g").selectAll("empty")
     .data(BaxisData)
     .enter()
     .append("line")
     .attr("class", "line")
     .attr("class", "axis")
     .attr("y1", pad.top)
     .attr("y2", h-pad.bottom)
     .attr("x1", (d) -> xScale(d))
     .attr("x2", (d) -> xScale(d))
     .attr("stroke", "white")

  # axis: labels
  Baxis.append("g").selectAll("empty")
     .data(BaxisData)
     .enter()
     .append("text")
     .attr("class", "axis")
     .text((d) -> d)
     .attr("y", h-pad.bottom*0.75)
     .attr("x", (d) -> xScale(d))
     .attr("dominant-baseline", "middle")
     .attr("text-anchor", "middle")


  # curves for quantiles
  colors = ["blue", "green", "orange", "red", "black"]
  for j in [3..0]
    colors.push(colors[j])

  curves = svg.append("g")

  for j in [0...nQuant]
    curves.append("path")
       .datum(data.ind)
       .attr("d", quline(j))
       .attr("class", "line")
       .attr("stroke", colors[j])

  # special rectangles in the background
  clickStatus = {}
  index = {}
  specialrects = svg.append("g")
  for d,i in data.ind
    clickStatus[d] = 0
    specialrects.append("rect")
       .attr("x", xScale(i-0.5))
       .attr("y", yScale(data.quant[nQuant-1][d]))
       .attr("width", 2)
       .attr("id", d)
       .attr("height", yScale(data.quant[0][d]) - yScale(data.quant[nQuant-1][d]))
       .attr("opacity", 0)
       .attr("stroke", "none")

  # vertical rectangles representing each array
  indRectGrp = svg.append("g")

  indRect = indRectGrp.selectAll("empty")
                 .data(data.ind)
                 .enter()
                 .append("rect")
                 .attr("x", (d,i) -> xScale(i-0.5))
                 .attr("y", (d) -> yScale(data.quant[nQuant-1][d]))
                 .attr("width", 2)
                 .attr("height", (d) ->
                    yScale(data.quant[0][d]) - yScale(data.quant[nQuant-1][d]))
                 .attr("fill", "purple")
                 .attr("stroke", "none")
                 .attr("opacity", "0")

  # label quantiles on right
  rightAxis = svg.append("g")

  rightAxis.selectAll("empty")
       .data(data.qu)
       .enter()
       .append("text")
       .attr("class", "qu")
       .text( (d) -> "#{d*100}%")
       .attr("x", w-pad.right*0.1)
       .attr("y", (d,i) -> yScale((i+0.5)/nQuant - 0.5))
       .attr("fill", (d,i) -> colors[i])
       .attr("text-anchor", "end")
       .attr("dominant-baseline", "middle")


  # white box above to smother overlap
  svg.append("rect")
     .attr("x", 0)
     .attr("y", 0)
     .attr("width", w)
     .attr("height", pad.top)
     .attr("stroke", "none")
     .attr("fill", "white")

  # box around the outside
  svg.append("rect")
     .attr("x", pad.left)
     .attr("y", pad.top)
     .attr("height", h-pad.top-pad.bottom)
     .attr("width", w-pad.left-pad.right)
     .attr("stroke", "black")
     .attr("stroke-width", 2)
     .attr("fill", "none")

  # lower svg
  lowsvg = d3.select("body").append("svg")
             .attr("height", h)
             .attr("width", w)

  low = data.br[0] - (data.br[1] - data.br[0])

  lowxScale = d3.scale.linear()
             .domain([-1.25, -low])
             .range([pad.left, w-pad.right])

  maxCount = 0
  for i of data.counts
    for j of data.counts[i]
      maxCount = data.counts[i][j] if data.counts[i][j] > maxCount
  maxCount *= 0.5

  lowyScale = d3.scale.linear()
             .domain([0, maxCount+0.5])
             .range([h-pad.bottom, pad.top])

  # gray background
  lowsvg.append("rect")
     .attr("x", pad.left)
     .attr("y", pad.top)
     .attr("height", h-pad.top-pad.bottom)
     .attr("width", w-pad.left-pad.right)
     .attr("stroke", "none")
     .attr("fill", d3.rgb(200, 200, 200))

  # axis on left
  lowBaxisData = [-1, -0.5, 0, 0.5, 1, 1.5, 2]
  lowBaxis = lowsvg.append("g")

  # axis: white lines
  lowBaxis.append("g").selectAll("empty")
     .data(lowBaxisData)
     .enter()
     .append("line")
     .attr("class", "line")
     .attr("class", "axis")
     .attr("y1", pad.top)
     .attr("y2", h-pad.bottom)
     .attr("x1", (d) -> lowxScale(d))
     .attr("x2", (d) -> lowxScale(d))
     .attr("stroke", (d) ->
           return "white" if d != 0
           "rgb(255,220,255)")

  # axis: labels
  lowBaxis.append("g").selectAll("empty")
     .data(lowBaxisData)
     .enter()
     .append("text")
     .attr("class", "axis")
     .text((d) -> axisFormat1(d))
     .attr("y", h-pad.bottom*0.75)
     .attr("x", (d) -> lowxScale(d))
     .attr("dominant-baseline", "middle")
     .attr("text-anchor", "middle")

  grp4BkgdHist = lowsvg.append("g")

  histline = d3.svg.line()
        .x((d,i) -> lowxScale(br2[i]))
        .y((d) -> lowyScale(d))

  randomInd = data.ind[Math.floor(Math.random()*data.ind.length)]

  hist = lowsvg.append("path")
    .datum(data.counts[randomInd])
       .attr("d", histline)
       .attr("id", "histline")
       .attr("fill", "none")
       .attr("stroke", "purple")
       .attr("stroke-width", "2")


  histColors = ["blue", "red", "green", "orange", "black"]

  lowsvg.append("text")
        .datum(randomInd)
        .attr("x", lowxScale(-1.75))
        .attr("y", pad.top*2)
        .text((d) -> d)
        .attr("id", "histtitle")
        .attr("text-anchor", "middle")
        .attr("dominant-baseline", "middle")
        .attr("fill", "blue")

  # Using https://github.com/Caged/d3-tip
  #   [slightly modified in https://github.com/kbroman/d3-tip]
  tip = d3.tip()
          .attr("class", "d3-tip")
          .html((z) -> z)
          .direction("e")
          .offset([0,10])

  lowsvg.call(tip)

  indRect
    .on "mouseover", (d) ->
              d3.select(this)
                 .attr("opacity", "1")
              d3.select("#histline")
                 .datum(data.counts[d])
                 .attr("d", histline)
              d3.select("#histtitle")
                 .datum(d)
                 .text((d) -> d)
              tip.show(d)

    .on "mouseout", (d) ->
              d3.select(this).attr("opacity", "0")
              tip.hide(d)

    .on "click", (d) ->
              console.log(d)
              clickStatus[d] = 1 - clickStatus[d]
              svg.select("rect##{d}").attr("opacity", clickStatus[d])
              if clickStatus[d]
                curcolor = histColors.shift()
                histColors.push(curcolor)

                d3.select(this).attr("opacity", "0")
                svg.select("rect##{d}").attr("fill", curcolor)

                grp4BkgdHist.append("path")
                      .datum(data.counts[d])
                      .attr("d", histline)
                      .attr("id", d)
                      .attr("fill", "none")
                      .attr("stroke", curcolor)
                      .attr("stroke-width", "2")
              else
                grp4BkgdHist.select("path##{d}").remove()

  # white box above to smother overlap
  lowsvg.append("rect")
     .attr("x", 0)
     .attr("y", 0)
     .attr("width", w)
     .attr("height", pad.top)
     .attr("stroke", "none")
     .attr("fill", "white")

  # white box to left smother overlap
  lowsvg.append("rect")
     .attr("x", 0)
     .attr("y", 0)
     .attr("width", pad.left)
     .attr("height", h)
     .attr("stroke", "none")
     .attr("fill", "white")

  # box around the outside
  lowsvg.append("rect")
     .attr("x", pad.left)
     .attr("y", pad.top)
     .attr("height", h-pad.bottom-pad.top)
     .attr("width", w-pad.left-pad.right)
     .attr("stroke", "black")
     .attr("stroke-width", 2)
     .attr("fill", "none")


  svg.append("text")
     .text("Gene expression (mlratio)")
     .attr("x", pad.left*0.2)
     .attr("y", h/2)
     .attr("fill", "blue")
     .attr("transform", "rotate(270 #{pad.left*0.2} #{h/2})")
     .attr("dominant-baseline", "middle")
     .attr("text-anchor", "middle")

  lowsvg.append("text")
     .text("Gene expression (mlratio)")
     .attr("x", (w-pad.left-pad.bottom)/2+pad.left)
     .attr("y", h-pad.bottom*0.2)
     .attr("fill", "blue")
     .attr("dominant-baseline", "middle")
     .attr("text-anchor", "middle")

  svg.append("text")
     .text("Arrays, sorted by median expression")
     .attr("x", (w-pad.left-pad.bottom)/2+pad.left)
     .attr("y", h-pad.bottom*0.2)
     .attr("fill", "blue")
     .attr("dominant-baseline", "middle")
     .attr("text-anchor", "middle")


# load json file and call draw function
d3.json("hypo.json", draw)
