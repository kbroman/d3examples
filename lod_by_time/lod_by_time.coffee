# Interactive lod curves and QTL effect plot for all time points
#
# This is awful code; I just barely know what I'm doing.

# function that does all of the work
draw = (data) ->

  d3.select("p#loading").remove()
  d3.select("div#legend").style("opacity", 1)

  # no. pixels per rectangle in heatmap
  pixelPer = 1.5 # <- I wanted this to be an integer, but I couldn't fit the figure into a talk

  # colors
  darkBlue = "darkslateblue"
  lightGray = d3.rgb(230, 230, 230)
  darkGray = d3.rgb(200, 200, 200)
  pink = "hotpink"
  altpink = "#E9CFEC"
  purple = "#8C4374"
  darkRed = "crimson"
  # bgcolor = "black"
  labelcolor = "black"
  titlecolor = darkBlue
  maincolor = darkBlue

  # rounding functions
  nodig = d3.format(".0f")
  onedig = d3.format(".1f")
  twodig = d3.format(".2f")

  # calculate effects
  eff = []
  for i of data.ave1
    eff[i] = []
    for j of data.ave1[i]
      eff[i][j] = data.ave2[i][j] - data.ave1[i][j]

  # hash: pmarker -> chrindex
  pmarChr = {}
  for chr in data.chr
    for p of data.map[chr]
      pmarChr[p] = chr

  minLodShown = 1

  # to contain the start and end positions
  chrStart = {}
  chrEnd = {}
  chrStartPixel = {}
  chrEndPixel = {}
  for chr in data.chr
    chrStart[chr] = 999
    chrEnd[chr] = -999

  # list version of LOD scores for heatmap
  lodList = []
  for p,pind in data.evenpmar
    i = data.pmarindex[p]
    for j of data.times
      chr = pmarChr[p]
      pos = data.map[chr][p]
      chrStart[chr] = pos if chrStart[chr] > pos
      chrEnd[chr] = pos if chrEnd[chr] < pos
      if data.lod[i][j] > minLodShown
        lodList.push({pmar: p,
        row: j*1, # the *1 is to deal with character strings
        effindex: pind,
        chr: pmarChr[p],
        xpos: pos,
        value: data.lod[i][j]})
  console.log("No. pixels = #{lodList.length}")

  # create X scale for image and LOD curves
  curPixel = 0
  imgXscale = {}
  lodXscale = {}
  for chr in data.chr
    chrStartPixel[chr] = curPixel
    chrEndPixel[chr] = curPixel + (chrEnd[chr] - chrStart[chr])*pixelPer
    curPixel = chrEndPixel[chr]+pixelPer*2
    imgXscale[chr] = d3.scale.linear()
                       .domain([chrStart[chr], chrEnd[chr]])
                       .range([chrStartPixel[chr], chrEndPixel[chr]])
    lodXscale[chr] = d3.scale.linear()
                       .domain([chrStart[chr], chrEnd[chr]])
                       .range([chrStartPixel[chr]+pixelPer/2, chrEndPixel[chr]+pixelPer/2])

  # dimensions
  totalpmar = data.evenpmar.length
  pad = {left:50, top:20, right:10, bottom: 30, inner: 2}
  imgw = pixelPer * (totalpmar + data.chr.length-1)
  imgh = pixelPer * data.times.length
  lodh = 225
  effh = (imgh - pad.top - pad.bottom)/2
  effw = 400
  h = [imgh, lodh, effh, effh]
  w = [imgw, imgw, effw, effw]
  left = [pad.left, pad.left,
          pad.left*2+w[0]+pad.right,
          pad.left*2+w[0]+pad.right]
  top =  [pad.top,
          pad.top*2+h[0]+pad.bottom,
          pad.top,
          pad.top*2 + h[2] + pad.bottom]

  totalh = h[0] + h[1] + (pad.top + pad.bottom)*2
  totalw = (w[0] + w[2]) + (pad.left + pad.right)*2
  console.log("width = #{totalw}, height = #{totalh}")

  # create svg
  svg = d3.select("div#lod_by_time_fig")
          .append("svg")
          .attr("height", totalh)
          .attr("width", totalw)

  # panels
  panels = []
  panelnames = ["imagepanel", "lodpanel", "phepanel", "effpanel"]
  for i in [0...4]
    panels[i] = svg.append("g").attr("id", panelnames[i])
                   .attr("transform", "translate(#{left[i]}, #{top[i]})")

  # rectangles
  for i of panels
    panels[i].append("rect")
             .attr("height", h[i])
             .attr("width", w[i])
             .attr("fill",  lightGray)
             .attr("stroke", "black")
             .attr("stroke-width", 2)

  # maxima and minima
  minEff = 0
  maxEff = 0
  minPhe = data.ave1[0][0]
  maxPhe = data.ave1[0][0]
  for i of data.ave1
    for j of data.ave1[i]
      a1 = data.ave1[i][j]
      a2 = data.ave2[i][j]
      e  = eff[i][j]
      se = data.se[i][j]
      minPhe = a1 if minPhe > a1
      maxPhe = a1 if maxPhe < a1
      minPhe = a2 if minPhe > a2
      maxPhe = a2 if maxPhe < a2
      minEff = e-2*se  if minEff > e - 2*se
      maxEff = e+2*se  if maxEff < e + 2*se
  maxLod = -1
  minLod = 50
  for i of data.lod
    for j of data.lod[i]
      maxLod = data.lod[i][j] if maxLod < data.lod[i][j]
      minLod = data.lod[i][j] if minLod > data.lod[i][j]

  # center effect plot at 0
  maxEff = -minEff if -minEff > maxEff
  minEff = -maxEff if -maxEff < minEff


  # scales
  effYscale = d3.scale.linear()
                .domain([minEff, maxEff])
                .range([effh - pad.inner, pad.inner])
  pheYscale = d3.scale.linear()
                .domain([minPhe, maxPhe])
                .range([effh - pad.inner, pad.inner])

  lodYscale = d3.scale.linear()
                .domain([0, maxLod])
                .range([lodh - pad.inner, pad.inner])

  imgYscale = d3.scale.ordinal()
                .domain(d3.range(data.times.length))
                .rangePoints([imgh-pixelPer, 0], 0)


  imgZscale = d3.scale.linear()
                .domain([0, maxLod])
                .range([0, 1])
                .clamp(true)

  effXscale = d3.scale.linear()
                .domain([d3.min(data.times), d3.max(data.times)])
                .range([pad.inner, w[2]-pad.inner])

  # vertical lines at chromosome boundaries
  boundaries = []
  for chr in data.chr[1..]
    boundaries.push(chrStartPixel[chr])

  for i in [0..1]
    panels[i].append("g").attr("id", "chrBoundaryLines")
             .selectAll("empty")
             .data(boundaries)
             .enter()
             .append("line")
             .attr("y1", 0)
             .attr("y2", h[i])
             .attr("x1", (d) -> d-pixelPer*0.5)
             .attr("x2", (d) -> d-pixelPer*0.5)
             .attr("fill", "none")
             .attr("stroke", "darkGray")
             .attr("stroke-width", 1)

  # x-axis for effect and phenotype panels
  for i in [2..3]
    panels[i].selectAll("empty")
             .data([0..8])
             .enter()
             .append("line")
             .attr("y1", 0)
             .attr("y2", h[i])
             .attr("x1", (d) -> effXscale(d*60))
             .attr("x2", (d) -> effXscale(d*60))
             .attr("fill", "none")
             .attr("stroke", "white")
             .attr("stroke-width", 1)
    panels[i].selectAll("empty")
             .data([0..8])
             .enter()
             .append("text")
             .text((d) -> d)
             .attr("y", h[i] + pad.bottom*0.5)
             .attr("x", (d) -> effXscale(d*60))
             .attr("fill", labelcolor)
             .attr("text-anchor", "middle")
  # "Time (hours)" just at bottom
  panels[3].append("text")
           .text("Time (hours)")
           .attr("x", w[3]/2)
           .attr("y", h[3]+pad.bottom)
           .attr("fill", titlecolor)
           .attr("text-anchor", "middle")


  # chromosome IDs on X axis
  for i in [0..1]
    panels[i].append("g").attr("id", "chrLabels")
             .selectAll("empty")
             .data(data.chr)
             .enter()
             .append("text")
             .attr("y", h[i]+pad.bottom*0.42)
             .attr("x", (d) -> (chrStartPixel[d]+chrEndPixel[d])/2)
             .text((d) -> d)
             .attr("fill", labelcolor)
             .attr("text-anchor", "middle")
  # "Chromosome" just at bottom
  panels[1].append("text")
           .text("Chromosome")
           .attr("fill", titlecolor)
           .attr("text-anchor", "middle")
           .attr("x", w[1]/2)
           .attr("y", h[1]+pad.bottom*0.9)

  # y-axis labels
  panels[0].append("g").attr("id", "imgYaxisLabels")
           .selectAll("empty")
           .data([0..8])
           .enter()
           .append("text")
           .text((d) -> d)
           .attr("x", -pad.left*0.1)
           .attr("y", (d) -> imgYscale(d*30))
           .attr("fill", labelcolor)
           .attr("text-anchor", "end")
           .attr("dominant-baseline", "middle")
  panels[0].append("g").attr("id", "imgYaxisGridlines")
           .selectAll("empty")
           .data([1..7])
           .enter()
           .append("line")
           .attr("y1", (d) -> imgYscale(d*30))
           .attr("y2", (d) -> imgYscale(d*30))
           .attr("x1", 0)
           .attr("x2", w[0])
           .attr("fill", "none")
           .attr("stroke", "white")
           .attr("stroke-width", 1)
  panels[0].append("text")
           .text("Time (hours)")
           .attr("x", -pad.left*0.6)
           .attr("y", h[0]/2)
           .attr("text-anchor", "middle")
           .attr("dominant-baseline", "middle")
           .attr("transform", "rotate(270, #{-pad.left*0.6}, #{h[0]/2})")
           .attr("fill", titlecolor)

  ticks = [null, lodYscale.ticks(5),
          pheYscale.ticks(6), effYscale.ticks(6)]
  scale = [null, lodYscale, pheYscale, effYscale]
  ytitle = [null, "LOD score", "Ave phenotype", "QTL effect (BB - AA)"]
  mult = [null, 0.6, 0.8, 0.7]
  for i in [1..3]
    panels[i].selectAll("empty")
             .data(ticks[i])
             .enter()
             .append("text")
             .text((d) -> nodig(d))
             .attr("x", -pad.left*0.1)
             .attr("y", (d) -> scale[i](d))
             .attr("fill", (d) ->
                return pink if d == 0 and i==3
                labelcolor)
             .attr("text-anchor", "end")
             .attr("dominant-baseline", "middle")
    panels[i].selectAll("empty")
             .data(ticks[i])
             .enter()
             .append("line")
             .attr("y1", (d) -> scale[i](d))
             .attr("y2", (d) -> scale[i](d))
             .attr("x1", 0)
             .attr("x2", w[i])
             .attr("fill", "none")
             .attr("stroke", (d) ->
                return pink if d == 0 and i==3
                "white")
             .attr("stroke-width", 1)
    panels[i].append("text")
             .text(ytitle[i])
             .attr("x", -pad.left*mult[i])
             .attr("y", h[i]/2)
             .attr("text-anchor", "middle")
             .attr("dominant-baseline", "middle")
             .attr("transform", "rotate(270, #{-pad.left*mult[i]}, #{h[i]/2})")
             .attr("fill", titlecolor)


  # Label genotypes in phenotype panel
  panels[2].selectAll("empty")
           .data(["AA","BB"])
           .enter()
           .append("text")
           .text((d) -> d)
           .attr("x", (d,i) -> effXscale((6.5+i)*60))
           .attr("y", pheYscale(-20)/2)
           .attr("fill", (d,g) ->
              return darkBlue if g == 0
              darkRed)
           .attr("text-anchor", "middle")
           .attr("dominant-baseline", "middle")

  # phenotype curve function
  pheCurve = (pmari,g) ->
     d3.svg.line()
       .x((t) -> effXscale(t))
       .y((t,i) ->
         if g==1
           return pheYscale(data.ave1[pmari][i])
         else
           return pheYscale(data.ave2[pmari][i]))

  # plot phenotype curves
  phePlot = (pmari) ->
    for g in [1..2]
      panels[2].append("path").attr("id", "pheCurve#{g}")
               .datum(data.times)
               .attr("d", pheCurve(pmari, g))
               .attr("stroke", ->
                   return darkBlue if g==1
                   darkRed)
               .attr("fill", "none")
               .attr("stroke-width", "2")
    pmar = data.evenpmar[pmari]
    chr = pmarChr[pmar]
    pos = data.map[chr][pmar]
    panels[2].append("text").attr("id", "pheTitle")
             .text("Chr #{chr} @ #{nodig(pos)} cM")
             .attr("x", w[2]/2)
             .attr("y", -pad.top*0.6)
             .attr("text-anchor", "middle")
             .attr("dominant-baseline", "middle")
             .attr("fill", maincolor)

  # effect curve function
  effCurve = (pmari) ->
     d3.svg.line()
       .x((t) -> effXscale(t))
       .y((t,i) -> effYscale(eff[pmari][i]))

  # effect curve function
  seArea = (pmari) ->
    d3.svg.area()
          .x((t) -> effXscale(t))
          .y0((t,i) -> effYscale(eff[pmari][i] - 2*data.se[pmari][i]))
          .y1((t,i) -> effYscale(eff[pmari][i] + 2*data.se[pmari][i]))

  # plot effect curve
  effPlot = (pmari) ->
    panels[3].append("path").attr("id", "effCurve")
             .datum(data.times)
             .attr("d", effCurve(pmari))
             .attr("stroke", darkBlue)
             .attr("fill", "none")
             .attr("stroke-width", "2")

  # plot SE area
  sePlot = (pmari) ->
    panels[3].append("path").attr("id", "seArea")
             .datum(data.times) # every other time, to speed it up
             .attr("d", seArea(pmari))
             .attr("stroke", "none")
             .attr("fill", "lightblue")
             .attr("opacity", 0.4)

  # lod curve function
  lodCurve = (time, chr) ->
    d3.svg.line()
      .x((pmar) -> lodXscale[chr](data.map[chr][pmar]))
      .y((pmar) -> lodYscale(data.lod[data.pmarindex[pmar]][time]))

  # plot LOD curves
  lodPlot = (time) ->
    # convert time into hour:min
    retime = Math.floor(time*2/60) + Math.round(time*2 % 60)/100
    retime = twodig(retime)
    retime = retime.replace(/\./, ":")
    panels[1].append("text").attr("id", "lodTitle")
             .text("time = #{retime}")
             .attr("x", w[1]/2)
             .attr("y", -pad.top*0.6)
             .attr("fill", maincolor)
             .attr("text-anchor", "middle")
             .attr("dominant-baseline", "middle")
    # LOD curves
    for chr in data.chr
      panels[1].append("path").attr("id", "lodCurve#{chr}")
               .datum(data.allpmar[chr])
               .attr("d", lodCurve(time, chr))
               .attr("stroke", darkBlue)
               .attr("fill", "none")
               .attr("stroke-width", "2")

  # image plot
  panels[0].append("g").attr("id", "imagerect")
           .selectAll("empty")
           .data(lodList)
           .enter()
           .append("rect")
           .attr("x", (d) -> imgXscale[d.chr](d.xpos))
           .attr("width", pixelPer)
           .attr("y", (d) -> imgYscale(d.row))
           .attr("height", pixelPer)
           .attr("fill", (d) ->
               return darkBlue if eff[d.effindex][d.row] < 0
               darkRed)
           .attr("stroke",  (d) ->
               return darkBlue if eff[d.effindex][d.row] < 0
               darkRed)
           .attr("stroke-width", 0)
           .attr("opacity", (d) -> imgZscale(d.value))
           .on("mouseover", (d) ->
               effPlot(d.effindex)
               phePlot(d.effindex)
               lodPlot(d.row))
           .on("click", (d) ->
               panels[3].select("path#seArea").remove()
               sePlot(d.effindex))
           .on("mouseout", ->
                 panels[3].select("path#effCurve").remove()
                 panels[3].select("path#seArea").remove()
                 for g in [1..2]
                   panels[2].select("path#pheCurve#{g}").remove()
                 panels[2].select("text#pheTitle").remove()
                 for chr in data.chr
                   panels[1].select("path#lodCurve#{chr}").remove()
                 panels[1].select("text#lodTitle").remove())



# load json file and call draw function
d3.json("all_lod.json", draw)
