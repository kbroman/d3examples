# manycurves.coffee
#
# Interactive plot with a set of curves measured over time
#
# I'm thinking of a phenotype measured over time, so in the code below
# phe/Phe/pheno concerns the curve
#
# (I'm trying to pitch this to be a bit more general, but I don't want
# to re-name all of the variables.)

# function that does all of the work
draw = (data) ->

  d3.select("p#loading").remove()
  d3.select("div#legend").style("opacity", 1)
  d3.select("div#geneinput").style("opacity", 1)

  # colors
  darkBlue = "darkslateblue"
  lightGray = d3.rgb(230, 230, 230)
  darkGray = d3.rgb(200, 200, 200)
  pink = "hotpink"
  altpink = "#E9CFEC"
  purple = "#8C4374"
  darkRed = "crimson"
  labelcolor = "black"
  titlecolor = "blue"
  maincolor = "blue"

  # rounding functions
  nodig = d3.format(".0f")
  onedig = d3.format(".1f")
  twodig = d3.format(".2f")

  # size of data set
  nTimes = data.times.length
  nInd = data.curves.length

  # min and max phenotype plus rearrange data
  phenoList = []
  minPhe = 999
  maxPhe = -999
  avePhe = []
  for i of data.curves
    avePhe[i] = 0
    for j of data.curves[i]
      phe = data.curves[i][j]
      avePhe[i] += phe
      phenoList.push({row: i, col:j, value:phe})
      minPhe = phe if minPhe > phe
      maxPhe = phe if maxPhe < phe
    avePhe[i] /= nTimes

  # order individuals by average phenotype
  orderedInd = d3.range(nInd).sort (a,b) ->
    return -1 if avePhe[a] < avePhe[b]
    return +1 if avePhe[b] < avePhe[a]
    return 0

  # create index
  indexInd = orderedInd[0..]
  for i of orderedInd
    indexInd[orderedInd[i]] = i
  
  # dimensions of panels
  pixelsPer = 3
  w = nTimes * pixelsPer
  h = [nInd * pixelsPer, 200]
  pad = {left:60, top:15, right:25, bottom: 40, inner: 0}

  # total size
  totalw = w + pad.left + pad.right
  totalh = h[0] + h[1] + pad.top*2 + pad.bottom*2

  # svg to contain upper and lower panels
  svg = d3.select("div#curvesfig")
          .append("svg")
          .attr("height", totalh)
          .attr("width", totalw)

  # groups for the two panels, translated to have origin = (0,0)
  image = svg.append("g").attr("id", "imagepanel")
             .attr("transform", "translate(#{pad.left},#{pad.top})")
  curve = svg.append("g").attr("id", "curvepanel")
             .attr("transform", "translate(#{pad.left},#{pad.top*2+pad.bottom+h[0]})")
                  
  # background rectangle for upper panel
  image.append("rect")
       .attr("height", h[0])
       .attr("width", w)
       .attr("fill", "white")
       .attr("stroke", "black")
       .attr("stroke-width", 1)

  # background rectangle for lower panel
  curve.append("rect")
       .attr("height", h[1])
       .attr("width", w)
       .attr("fill", lightGray)
       .attr("stroke", "black")
       .attr("stroke-width", 1)

  # scales for upper panel
  xScaleImg = d3.scale.ordinal()
                .domain(d3.range(nTimes))
                .rangePoints([0, pixelsPer*(nTimes-1)+1], 0)
  yScaleImg = d3.scale.ordinal()
                .domain(d3.range(nInd))
                .rangePoints([0, pixelsPer*(nInd-1)+1], 0)
  dif = maxPhe + 45 # center color at -45
  difdown = -45 - minPhe
  dif = difdown if dif < difdown

  n_colors = 128
  colorseq = [0..n_colors]
  for i of colorseq
    colorseq[i] /= n_colors
  redblue = []
  for i in colorseq
    redblue.push(d3.interpolateRgb("#2166ac", "#f7f7f7")(i))
  for i in colorseq[1..]
    redblue.push(d3.interpolateRgb("#f7f7f7", "#b2182b")(i))

  zScaleImg = d3.scale.quantile() # controls opacity
                .domain([-45 - dif, -45 + dif])
                .range(redblue)

  # scales for lower panel
  xScaleCurve = d3.scale.linear()
                  .domain([0, d3.max(data.times)])
                  .range([pixelsPer/2, w-pixelsPer/2])
  yScaleCurve = d3.scale.linear()
                  .domain([minPhe, maxPhe])
                  .range([h[1]-pad.inner, pad.inner])

  # add axes
  xTicks = [0..8]
  topAxes = image.append("g").attr("id", "topAxes").attr("pointer-events", "none")
  topAxes.selectAll("empty")
        .data(xTicks)
        .enter()
        .append("line")
        .attr("x1", (d) -> xScaleImg(d*30-1)+pixelsPer/2)
        .attr("x2", (d) -> xScaleImg(d*30-1)+pixelsPer/2)
        .attr("y1", h[0])
        .attr("y2", h[0]+pad.bottom*0.1)
        .attr("stroke", labelcolor)
  topAxes.selectAll("empty")
        .data(xTicks)
        .enter()
        .append("text")
        .text((d) -> d)
        .attr("x", (d) -> xScaleImg(d*30-1)+pixelsPer/2)
        .attr("y", h[0]+pad.bottom*0.2)
        .attr("fill", labelcolor)
        .attr("text-anchor", "middle")
        .attr("dominant-baseline", "hanging")
  topAxes.append("text")
        .attr("x", w/2)
        .attr("y", h[0] + pad.bottom*0.75)
        .text("Time (hours)")
        .attr("fill", titlecolor)
        .attr("text-anchor", "middle")
        .attr("dominant-baseline", "hanging")
  topyTicks = [49, 99, 149]
  topAxes.selectAll("empty")
        .data(topyTicks)
        .enter()
        .append("line")
        .attr("x1", 0)
        .attr("x2", -pad.left*0.1)
        .attr("y1", (d) -> yScaleImg(d))
        .attr("y2", (d) -> yScaleImg(d))
        .attr("stroke", labelcolor)
  topAxes.selectAll("empty")
        .data(topyTicks)
        .enter()
        .append("text")
        .text((d) -> d*1+1)
        .attr("x", -pad.left*0.2)
        .attr("y", (d) -> yScaleImg(d))
        .attr("fill", labelcolor)
        .attr("text-anchor", "end")
        .attr("dominant-baseline", "middle")
  xloc = -pad.left*0.75
  yloc = h[0]/2
  topAxes.append("text")
        .attr("x", xloc)
        .attr("y", yloc)
        .text("Lines (sorted)")
        .attr("fill", titlecolor)
        .attr("text-anchor", "middle")
        .attr("transform", "rotate(270,#{xloc},#{yloc})")

  botAxes = curve.append("g").attr("id", "botAxes").attr("pointer-events", "none")
  botAxes.selectAll("empty")
        .data(xTicks)
        .enter()
        .append("line")
        .attr("x1", (d) -> xScaleCurve(d*60))
        .attr("x2", (d) -> xScaleCurve(d*60))
        .attr("y1", h[1])
        .attr("y2", 0)
        .attr("stroke", darkGray)
  botAxes.selectAll("empty")
        .data(xTicks)
        .enter()
        .append("text")
        .text((d) -> d)
        .attr("x", (d) -> xScaleCurve(d*60))
        .attr("y", h[1]+pad.bottom*0.1)
        .attr("fill", labelcolor)
        .attr("text-anchor", "middle")
        .attr("dominant-baseline", "hanging")
  botAxes.append("text")
        .attr("x", w/2)
        .attr("y", h[1] + pad.bottom*0.65)
        .text("Time (hours)")
        .attr("fill", titlecolor)
        .attr("text-anchor", "middle")
        .attr("dominant-baseline", "hanging")
  botyTicks = yScaleCurve.ticks(5)
  botAxes.selectAll("empty")
        .data(botyTicks)
        .enter()
        .append("line")
        .attr("x1", 0)
        .attr("x2", w)
        .attr("y1", (d) -> yScaleCurve(d))
        .attr("y2", (d) -> yScaleCurve(d))
        .attr("stroke", "white")
  botAxes.selectAll("empty")
        .data(botyTicks)
        .enter()
        .append("text")
        .text((d) -> d)
        .attr("x", -pad.left*0.1)
        .attr("y", (d) -> yScaleCurve(d))
        .attr("fill", labelcolor)
        .attr("text-anchor", "end")
        .attr("dominant-baseline", "middle")
  xloc = -pad.left*0.65
  yloc = h[1]/2
  botAxes.append("text")
        .attr("x", xloc)
        .attr("y", yloc)
        .text("Phenotype")
        .attr("fill", titlecolor)
        .attr("text-anchor", "middle")
        .attr("transform", "rotate(270,#{xloc},#{yloc})")


  # keep track of "clicked" status
  clicked = []
  for i of orderedInd
    clicked[i] = false

  # the pixels in the upper panel
  imgPixels = image.append("g").attr("id", "imgPixels")
                 .selectAll("rect")
                 .data(phenoList)
                 .enter()
                 .append("rect")
                 .attr("class", "imgPixels")
                 .attr("x", (d) -> xScaleImg(d.col))
                 .attr("y", (d) -> yScaleImg(indexInd[d.row]))
                 .attr("height", pixelsPer)
                 .attr("width", pixelsPer)
                 .attr("fill", (d) -> zScaleImg(d.value))
                 .attr("stroke", (d) -> zScaleImg(d.value))
                 .attr("stroke-width", 0.5)
                 .on("mouseover", (d) -> drawCurve(d.row))
                 .on("click", (d) -> clickCurve(d.row))

  # phenotype curve for an individual
  phecurve = (ind) ->
      d3.svg.line()
        .x((d) -> xScaleCurve(d))
        .y((d,di) -> yScaleCurve(data.curves[ind][di]))

  # function to draw curve for an individual
  drawCurve = (ind) ->
    return 0 if ind == curInd
    curInd = ind

    d3.select("g#phecurve").remove()

    # actually draw the curve
    thecurve = curve.append("g").attr("id", "phecurve")
    thecurve.append("path").attr("id", "phecurve")
          .datum(data.times)
          .attr("d", phecurve(ind))
          .attr("stroke", darkBlue)
          .attr("fill", "none")
          .attr("stroke-width", "2")

    # text to indicate individual
    thecurve.append("text")
          .datum(ind)
          .text("line #{ind*1+1}") # *1 to turn it into a number
          .attr("x", xScaleCurve(7*60)+pad.inner)
          .attr("y", (yScaleCurve(0)+yScaleCurve(-20))/2)
          .attr("text-anchor", "start")
          .attr("fill", darkBlue)
          .attr("dominant-baseline", "middle")

  clickColors = ["blue", "red", "green", "orange", "black"]

  # function to draw curve for an individual
  clickCurve = (ind) ->
    if clicked[ind]
      clicked[ind] = false
      d3.select("g#phecurve_#{ind}").remove()
      d3.select("rect#pherect_#{ind}").remove()
      drawCurve(ind) # put the darkBlue curve there

    else
      d3.select("path#phecurve").remove() # delete the darkBlue curve (but leave text)

      curcolor = clickColors.shift()
      clickColors.push(curcolor)

      clicked[ind] = true
      # actually draw the curve
      thecurve = curve.append("g").attr("id", "phecurve_#{ind}")
      thecurve.append("path")
              .datum(data.times)
              .attr("d", phecurve(ind))
              .attr("stroke", curcolor)
              .attr("fill", "none")
              .attr("stroke-width", 2)

      image.append("rect").attr("id", "pherect_#{ind}")
           .attr("x", 0)
           .attr("width", w)
           .attr("y", yScaleImg(indexInd[ind]))
           .attr("height", pixelsPer)
           .attr("fill", "none")
           .attr("stroke", curcolor)
           .attr("stroke-width", 1)
           .attr("pointer-events", "none")

  randomInd = Math.floor(Math.random()*nInd)
  drawCurve(randomInd)
  curInd = randomInd

  # Add color scale below
  yVals = [0...h[1]]
  for i of yVals
    yVals[i] = minPhe + (maxPhe - minPhe) * i / h[1]
  xPos = w + 10
  curve.append("g").attr("id", "colorscale")
       .selectAll("empty")
       .data(yVals)
       .enter()
       .append("rect")
       .attr("x", xPos)
       .attr("width", pad.right-10)
       .attr("y", (d) -> yScaleCurve(d))
       .attr("height", 1)
       .attr("fill", (d) -> zScaleImg(d))
       .attr("stroke", (d) -> zScaleImg(d))
       .attr("stroke-width", 0.5)


# load json file and call draw function
d3.json("curves.json", draw)
