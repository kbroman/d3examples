# lodchart: reuseable LOD score chart

lodchart = () ->
  width = 800
  height = 500
  margin = {left:60, top:40, right:40, bottom: 40, inner:5}
  axispos = {xtitle:25, ytitle:30, xlabel:5, ylabel:5}
  ylim = null
  nyticks = 5
  yticks = null
  chrGap = 8
  darkrect = d3.rgb(200, 200, 200)
  lightrect = d3.rgb(230, 230, 230)
  linecolor = "darkslateblue"
  linewidth = 2
  pointcolor = "#E9CFEC" # pink
  pointsize = 0 # default = no visible points at markers
  xlab = "Chromosome"
  ylab = "LOD score"
  yscale = d3.scale.linear()
  xscale = null
  lodcurve = null
  lodvarname = "lod"
  markerSelect = null
  chrSelect = null

  ## the main function
  chart = (selection) ->
    selection.each (data) ->
      if !(ylim?)
        ylim = [0, d3.max(data[lodvarname])]

      # Select the svg element, if it exists.
      svg = d3.select(this).selectAll("svg").data([data])

      # Otherwise, create the skeletal chart.
      gEnter = svg.enter().append("svg").append("g")

      # Update the outer dimensions.
      svg.attr("width", width+margin.left+margin.right)
         .attr("height", height+margin.top+margin.bottom);

      # Update the inner dimensions.
      g = svg.select("g")
          .attr("transform", "translate(#{margin.left},#{margin.top})")

      # box
      g.append("rect")
       .attr("x", 0)
       .attr("y", 0)
       .attr("height", height)
       .attr("width", width)
       .attr("fill", darkrect)
       .attr("stroke", "none")

      yscale.domain(ylim)
            .range([height, margin.inner])

      # if yticks not provided, use nyticks to choose pretty ones
      if yticks == null
        yticks = yscale.ticks(nyticks)

      # reorganize lod,pos by chromosomes
      data = reorgData(data, lodvarname)
      
      # add chromosome scales (for x-axis)
      data = chrscales(data, width, chrGap)
      xscale = data.xscale

      # chr rectangles
      chrSelect =
                g.append("g").attr("class", "chrRect")
                 .selectAll("empty")
                 .data(data.chrnames)
                 .enter()
                 .append("rect")
                 .attr("id", (d) -> "chrrect#{d}")
                 .attr("x", (d,i) -> data.chrStart[i]-chrGap/2)
                 .attr("width", (d,i) -> data.chrEnd[i] - data.chrStart[i]+chrGap)
                 .attr("y", 0)
                 .attr("height", height)
                 .attr("fill", (d,i) ->
                    return darkrect if i % 2
                    lightrect)
                 .attr("stroke", "none")

      # x-axis labels
      xaxis = g.append("g").attr("class", "x axis")
      xaxis.selectAll("empty")
           .data(data.chrnames)
           .enter()
           .append("text")
           .text((d) -> d)
           .attr("x", (d,i) -> (data.chrStart[i]+data.chrEnd[i])/2)
           .attr("y", height+axispos.xlabel)
      xaxis.append("text").attr("class", "title")
           .attr("y", height+axispos.xtitle)
           .attr("x", width/2)
           .text(xlab)

      # y-axis
      yaxis = g.append("g").attr("class", "y axis")
      yaxis.selectAll("empty")
           .data(yticks)
           .enter()
           .append("line")
           .attr("y1", (d) -> yscale(d))
           .attr("y2", (d) -> yscale(d))
           .attr("x1", 0)
           .attr("x2", width)
           .attr("fill", "none")
           .attr("stroke", "white")
           .attr("stroke-width", 1)
           .style("pointer-events", "none")
      yaxis.selectAll("empty")
           .data(yticks)
           .enter()
           .append("text")
           .attr("y", (d) -> yscale(d))
           .attr("x", -axispos.ylabel)
           .text((d) -> formatAxis(yticks)(d))
      yaxis.append("text").attr("class", "title")
           .attr("y", height/2)
           .attr("x", -axispos.ytitle)
           .text(ylab)
           .attr("transform", "rotate(270,#{-axispos.ytitle},#{height/2})")

      # lod curves by chr
      lodcurve = (chr) ->
          d3.svg.line()
            .x((d) -> xscale[chr](d))
            .y((d,i) -> yscale(data.lodByChr[chr][i]))

      curves = g.append("g").attr("id", "curves")

      for chr in data.chrnames
        curves.append("path")
              .datum(data.posByChr[chr])
              .attr("d", lodcurve(chr))
              .attr("stroke", linecolor)
              .attr("fill", "none")
              .attr("stroke-width", linewidth)
              .style("pointer-events", "none")

      # points at markers
      if pointsize > 0
        markerpoints = g.append("g").attr("id", "markerpoints_visible")
        markerpoints.selectAll("empty")
                    .data(data.markers)
                    .enter()
                    .append("circle")
                    .attr("cx", (d) -> xscale[d.chr](d.pos))
                    .attr("cy", (d) -> yscale(d.lod))
                    .attr("r", pointsize)
                    .attr("fill", pointcolor)
                    .attr("pointer-events", "hidden")
      # these hidden points are what gets selected...a bit larger
      hiddenpoints = g.append("g").attr("id", "markerpoints_hidden")
      markerSelect =
        hiddenpoints.selectAll("empty")
                  .data(data.markers)
                  .enter()
                  .append("circle")
                  .attr("cx", (d) -> xscale[d.chr](d.pos))
                  .attr("cy", (d) -> yscale(d.lod))
                  .attr("id", (d) -> d.name)
                  .attr("r", d3.max([pointsize*2, 3]))
                  .attr("opacity", 0)
                  .attr("fill", pointcolor)
                  .attr("stroke", "black")
                  .attr("stroke-width", "1")
                  .on "mouseover", (d) ->
                     d3.select(this).attr("opacity", 1)
                     xpos = xscale[d.chr](d.pos)
                     if xpos < width/2
                       xpos += 15
                       anchor = "start"
                     else
                       xpos -= 10
                       anchor = "end"
                     g.append("text")
                      .attr("x", xpos)
                      .attr("y", yscale(d.lod))
                      .text(d.name)
                      .attr("id", "markerbox")
                      .style("pointer-events", "none")
                      .attr("text-anchor", anchor)
                      .attr("dominant-baseline", "middle")
                  .on "mouseout", ->
                     d3.select(this).attr("opacity", 0)
                     g.select("#markerbox").remove()

      # another box around edge
      g.append("rect")
       .attr("x", 0)
       .attr("y", 0)
       .attr("height", height)
       .attr("width", width)
       .attr("fill", "none")
       .attr("stroke", "black")
       .attr("stroke-width", "none")

  ## configuration parameters
  chart.width = (value) ->
    if !arguments.length
      return width
    width = value
    chart

  chart.height = (value) ->
    if !arguments.length
      return height
    height = value
    chart

  chart.margin = (value) ->
    if !arguments.length
      return margin
    margin = value
    chart

  chart.axispos = (value) ->
    if !arguments.length
      return axispos
    axispos = value
    chart

  chart.ylim = (value) ->
    if !arguments.length
      return ylim
    ylim = value
    chart

  chart.nyticks = (value) ->
    if !arguments.length
      return nyticks
    nyticks = value
    chart

  chart.yticks = (value) ->
    if !arguments.length
      return yticks
    yticks = value
    chart

  chart.chrGap = (value) ->
    if !arguments.length
      return chrGap
    chrGap = value
    chart

  chart.darkrect = (value) ->
    if !arguments.length
      return darkrect
    darkrect = value
    chart

  chart.lightrect = (value) ->
    if !arguments.length
      return lightrect
    lightrect = value
    chart

  chart.linecolor = (value) ->
    if !arguments.length
      return linecolor
    linecolor = value
    chart

  chart.linewidth = (value) ->
    if !arguments.length
      return linewidth
    linewidth = value
    chart

  chart.pointcolor = (value) ->
    if !arguments.length
      return pointcolor
    pointcolor = value
    chart

  chart.pointsize = (value) ->
    if !arguments.length
      return pointsize
    pointsize = value
    chart

  chart.xlab = (value) ->
    if !arguments.length
      return xlab
    xlab = value
    chart

  chart.ylab = (value) ->
    if !arguments.length
      return ylab
    ylab = value
    chart

  chart.lodvarname = (value) ->
    if !arguments.length
      return lodvarname
    lodvarname = value
    chart

  chart.yscale = () ->
    return yscale

  chart.xscale = () ->
    return xscale

  chart.lodcurve = () ->
    return lodcurve

  chart.markerSelect = () ->
    return markerSelect

  chart.chrSelect = () ->
    return chrSelect

  # return the chart function
  chart            

# function to determine rounding of axis labels
formatAxis = (d) ->
  d = d[1] - d[0]
  ndig = Math.floor( Math.log(d % 10) / Math.log(10) )
  ndig = 0 if ndig > 0
  ndig = Math.abs(ndig)
  d3.format(".#{ndig}f")

# reorganize lod/pos in data by chromosome
reorgData = (data, lodvarname) ->
  data.posByChr = {}
  data.lodByChr = {}
  for chr,i in data.chrnames
    data.posByChr[chr] = []
    data.lodByChr[chr] = []
    for pos,j in data.pos
      data.posByChr[chr].push(pos) if data.chr[j] == chr
      data.lodByChr[chr].push(data[lodvarname][j]) if data.chr[j] == chr
  data.markers = []
  for marker,i in data.markernames
    if marker != ""
      data.markers.push({name:marker, chr:data.chr[i], pos:data.pos[i], lod:data[lodvarname][i]}) 
  data

# calculate chromosome start/end + scales
chrscales = (data, width, chrGap) ->
  # start and end of chromosome positions
  chrStart = []
  chrEnd = []
  chrLength = []
  totalChrLength = 0
  for chr in data.chrnames
    rng = d3.extent(data.posByChr[chr])
    chrStart.push(rng[0])
    chrEnd.push(rng[1])
    L = rng[1] - rng[0]
    chrLength.push(L)
    totalChrLength += L

  # break up x axis into chromosomes by length, with gaps
  data.chrStart = []
  data.chrEnd = []
  cur = Math.round(chrGap/2)
  data.xscale = {}
  for chr,i in data.chrnames
    data.chrStart.push(cur)
    w = Math.round((width-chrGap*data.chrnames.length)/totalChrLength*chrLength[i])
    data.chrEnd.push(cur + w)
    cur = data.chrEnd[i] + chrGap
    # x-axis scales, by chromosome
    data.xscale[chr] = d3.scale.linear()
                         .domain([chrStart[i], chrEnd[i]])
                         .range([data.chrStart[i], data.chrEnd[i]])

  # return data with new stuff added
  data
