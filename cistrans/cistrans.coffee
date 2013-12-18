# cistrans.coffee
#
# Interactive cis-trans eQTL plot
#
# In top figure, x-axis corresponds to marker location, y-axis is
# genomic position of probes on a gene expression microarray Each
# plotted point is an inferred eQTL with LOD > 10; opacity corresponds
# to LOD score, though all LOD > 25 are made fully opaque.
#
# Hover over a point to see probe ID and LOD score; also highlighted
# are any other eQTL for that probe.  Click on the point to see LOD
# curves below.
#
# If a clicked probe is in known gene, title in lower plot is a link
# to the Mouse Genome Informatics (MGI) site at the Jackson Lab.
#
# Hover over markers in LOD curve plot to view marker names; click on
# a marker to see the phenotype-vs-genotype plot to right.  In
# geno-vs-pheno plot, hover over average to view value, and hover over
# points to view individual IDs.
#
# This is awful code; I just barely know what I'm doing.

# function that does all of the work
draw = (data) ->

  d3.select("p#loading").remove()
  d3.select("div#legend").style("opacity", 1)
  d3.select("div#geneinput").style("opacity", 1)

  # dimensions of panels
  w = [500, 300]
  h = [w[0], 200]
  pad = {left:60, top:40, right:40, bottom: 40, inner: 10}
  w = [w[0], w[0] + w[1] + pad.left + pad.right, w[1]]
  h = [h[0], h[1], h[0]]

  left = [pad.left, pad.left,
          pad.left + w[0] + pad.right + pad.left]
  top =  [pad.top,
          pad.top + h[0] + pad.bottom + pad.top,
          pad.top]
  right = []
  bottom = []
  for i of left
    right[i] = left[i] + w[i]
    bottom[i] = top[i] + h[i]

  totalw = right[2] + pad.right
  totalh = bottom[1] + pad.bottom

  # Size of rectangles in top-left panel
  peakRad = 2
  bigRad = 5

  # gap between chromosomes in lower plot
  chrGap = 8

  # transition speeds
  slowtime = 1000
  fasttime = 250

  # height of marker ticks in lower panel
  tickHeight = (bottom[1] - top[1])*0.02

  # jitter amounts for PXG plot
  jitterAmount = (right[2] - left[2])/50
  jitter = []
  for i of data.individuals
    jitter[i] = (2.0*Math.random()-1.0) * jitterAmount

  nodig = d3.format(".0f")
  onedig = d3.format(".1f")
  twodig = d3.format(".2f")

  # colors definitions
  lightGray = d3.rgb(230, 230, 230)
  darkGray = d3.rgb(200, 200, 200)
  darkblue = "darkslateblue"
  darkgreen = "darkslateblue" # "darkgreen" # <- I didn't like having separate colors for each chr in cis/trans plot
  pink = "hotpink"
  altpink = "#E9CFEC"
  purple = "#8C4374"
  darkred = "crimson"
  # bgcolor = "black"
  labelcolor = "black"   # "white"
  titlecolor = "blue"    # "Wheat"
  maincolor = "darkblue" # "Wheat"

  # probes for each gene
  probesByGene = {}
  origGeneName = {}
  for probe of data.probes
    gene = data.probes[probe].gene
    if gene != "" and gene != null
      origGeneName[gene.toLowerCase()] = gene
      if probesByGene?[gene]
        probesByGene[gene].push(probe)
      else
        probesByGene[gene] = [probe]

  allgenes = (gene for gene of probesByGene)

  # calculate X and Y scales, using cM positions
  totalChrLength = 0;
  for c in data.chrnames
    data.chr[c].length_cM = data.chr[c].end_cM - data.chr[c].start_cM
    totalChrLength += data.chr[c].length_cM

  chrXScale = {}
  chrYScale = {}
  curXPixel = left[0]+peakRad
  curYPixel = bottom[0]-peakRad
  for c in data.chrnames
    data.chr[c].length_pixel = Math.round((w[0]-peakRad*2) * data.chr[c].length_cM / totalChrLength)
    data.chr[c].start_Xpixel = curXPixel
    data.chr[c].end_Xpixel = curXPixel + data.chr[c].length_pixel - 1
    data.chr[c].start_Ypixel = curYPixel
    data.chr[c].end_Ypixel = curYPixel - (data.chr[c].length_pixel - 1)

    chrXScale[c] = d3.scale.linear()
                  .domain([data.chr[c].start_cM, data.chr[c].end_cM])
                  .range([data.chr[c].start_Xpixel, data.chr[c].end_Xpixel])
                  .clamp(true)
    chrYScale[c] = d3.scale.linear()
                  .domain([data.chr[c].start_cM, data.chr[c].end_cM])
                  .range([data.chr[c].start_Ypixel, data.chr[c].end_Ypixel])
                  .clamp(true)

    curXPixel += data.chr[c].length_pixel
    curYPixel -= data.chr[c].length_pixel

  # slight adjustments
  top[0] = data.chr["X"].end_Ypixel-peakRad
  h[0] = bottom[0] - top[0]
  data.chr["1"].start_Xpixel = left[0]
  data.chr["1"].start_Ypixel = bottom[0]
  data.chr["X"].end_Xpixel = right[0]
  data.chr["X"].end_Ypixel = top[0]

  # chr scales in lower figure
  chrLowXScale = {}
  cur = Math.round(pad.left + chrGap/2)
  for c in data.chrnames
    data.chr[c].start_lowerXpixel = cur
    data.chr[c].end_lowerXpixel = cur + Math.round((w[1]-chrGap*(data.chrnames.length))/totalChrLength*data.chr[c].length_cM)
    chrLowXScale[c] = d3.scale.linear()
                        .domain([data.chr[c].start_cM, data.chr[c].end_cM])
                        .range([data.chr[c].start_lowerXpixel, data.chr[c].end_lowerXpixel])
    cur = data.chr[c].end_lowerXpixel + chrGap

  # X scales for PXG plot
  # autosome in intercross: 6 cases
  pxgXscaleA = d3.scale.ordinal()
                 .domain(d3.range(6))
                 .rangePoints([left[2], right[2]], 1)
  # X chromosome in intercross (both sexes, one direction): 4 cases
  pxgXscaleX = d3.scale.ordinal()
                 .domain(d3.range(4))
                 .rangePoints([left[2], right[2]], 1)

  # swap genotypes in females on X chromsome
  for m in data.markers
    continue unless data.pmark[m].chr == "X"
    for g,i in data.geno[m]
      if data.sex[i] == 0
        newg = 0
        switch g
          when -1 then newg = -2
          when -2 then newg = -1
          when +1 then newg = +2
          when +2 then newg = +1
        data.geno[m][i] = newg

  # create SVG
  svg = d3.select("div#cistrans").append("svg")
          .attr("width", totalw)
          .attr("height", totalh)

  # gray backgrounds
  for j of left
    svg.append("rect")
       .attr("x", left[j])
       .attr("y", top[j])
       .attr("height", h[j])
       .attr("width", w[j])
       .attr("class", "innerBox")

  # add dark gray rectangles to define chromosome boundaries as checkerboard
  checkerboard = svg.append("g").attr("id", "checkerboard")
  for ci,i in data.chrnames
    for cj,j in data.chrnames
      if((i + j) % 2 == 0)
        checkerboard.append("rect")
           .attr("x", data.chr[ci].start_Xpixel)
           .attr("width", data.chr[ci].end_Xpixel - data.chr[ci].start_Xpixel)
           .attr("y", data.chr[cj].end_Ypixel)
           .attr("height", data.chr[cj].start_Ypixel - data.chr[cj].end_Ypixel)
           .attr("stroke", "none")
           .attr("fill", darkGray)
           .style("pointer-events", "none")

  # same in lower panel
  checkerboard2 = svg.append("g").attr("id", "checkerboard2")
  for ci,i in data.chrnames
      if(i % 2 == 0)
        checkerboard2.append("rect")
           .attr("x", data.chr[ci].start_lowerXpixel - chrGap/2)
           .attr("width", data.chr[ci].end_lowerXpixel - data.chr[ci].start_lowerXpixel + chrGap)
           .attr("y", top[1])
           .attr("height", h[1])
           .attr("stroke", "none")
           .attr("fill", darkGray)
           .style("pointer-events", "none")

  # chromosome labels
  axislabels = svg.append("g").attr("id", "axislabels").style("pointer-events", "none")
  axislabels.append("g").attr("id", "topleftX").selectAll("empty")
     .data(data.chrnames)
     .enter()
     .append("text")
     .text((d) -> d)
     .attr("x", (d) -> (data.chr[d].start_Xpixel + data.chr[d].end_Xpixel)/2)
     .attr("y", bottom[0] + pad.bottom*0.3)
     .attr("fill", labelcolor)
  axislabels.append("g").attr("id", "topleftY")
     .selectAll("empty")
     .data(data.chrnames)
     .enter()
     .append("text")
     .text((d) -> d)
     .attr("x", left[0] - pad.left*0.15)
     .attr("y", (d) -> (data.chr[d].start_Ypixel + data.chr[d].end_Ypixel)/2)
     .style("text-anchor", "end")
     .attr("fill", labelcolor)
  axislabels.append("g").attr("id", "bottomX").selectAll("empty")
     .data(data.chrnames)
     .enter()
     .append("text")
     .text((d) -> d)
     .attr("x", (d) -> (data.chr[d].start_lowerXpixel + data.chr[d].end_lowerXpixel)/2)
     .attr("y", bottom[1] + pad.bottom*0.3)
     .attr("fill", labelcolor)
  axislabels.append("text")
     .text("Marker position (cM)")
     .attr("x", (left[0] + right[0])/2)
     .attr("y", bottom[0] + pad.bottom*0.75)
     .attr("fill", titlecolor)
     .attr("text-anchor", "middle")
  axislabels.append("text")
     .text("Position (cM)")
     .attr("x", (left[1] + right[1])/2)
     .attr("y", bottom[1] + pad.bottom*0.75)
     .attr("fill", titlecolor)
     .attr("text-anchor", "middle")
  xloc = left[0] - pad.left*0.65
  yloc = (top[0] + bottom[0])/2
  axislabels.append("text")
     .text("Probe position (cM)")
     .attr("x", xloc)
     .attr("y", yloc)
     .attr("transform", "rotate(270,#{xloc},#{yloc})")
     .style("text-anchor", "middle")
     .attr("fill", titlecolor)
  xloc = left[1] - pad.left*0.65
  yloc = (top[1] + bottom[1])/2
  axislabels.append("text")
     .text("LOD score")
     .attr("x", xloc)
     .attr("y", yloc)
     .attr("transform", "rotate(270,#{xloc},#{yloc})")
     .style("text-anchor", "middle")
     .attr("fill", titlecolor)

  # overall maximum lod score
  maxlod = d3.max(data.peaks, (d) -> d.lod)

  # sort peaks to have increasing LOD score
  data.peaks = data.peaks.sort (a,b) ->
    return if a.lod < b.lod then -1 else +1

  # LOD score controls opacity
  Zscale = d3.scale.linear()
             .domain([0, 25])
             .range([0, 1])

  # tool tips using https://github.com/Caged/d3-tip
  #   [slightly modified in https://github.com/kbroman/d3-tip]
  eqtltip = d3.svg.tip()
                 .orient("right")
                 .padding(3)
                 .text((z) -> "#{z.probe} (LOD = #{onedig(z.lod)})")
                 .attr("class", "d3-tip")
                 .attr("id", "eqtltip")
  martip = d3.svg.tip()
             .orient("right")
             .padding(3)
             .text((z) -> z)
             .attr("class", "d3-tip")
             .attr("id", "martip")
  indtip = d3.svg.tip()
             .orient("right")
             .padding(3)
             .text((d,i) -> data.individuals[i])
             .attr("class", "d3-tip")
             .attr("id", "indtip")
  efftip = d3.svg.tip()
             .orient("right")
             .padding(3)
             .text((d) -> twodig(d))
             .attr("class", "d3-tip")
             .attr("id", "efftip")

  # create indices to lod scores, split by chromosome
  cur = 0
  for c in data.chrnames
    for p in data.pmarknames[c]
      data.pmark[p].index = cur
      cur++

  # function for drawing lod curve for probe
  draw_probe = (probe_data) ->
    # delete all related stuff
    svg.selectAll(".probe_data").remove()
    d3.select("text#pxgtitle").text("")
    svg.selectAll(".plotPXG").remove()

    # find marker with maximum LOD score
    maxlod = -1
    maxlod_marker = null
    for m in data.markers
      lod = probe_data.lod[data.pmark[m].index]
      if maxlod < lod
        maxlod = lod
        maxlod_marker = m

    # y-axis scale
    lodcurve_yScale = d3.scale.linear()
                        .domain([0, maxlod*1.05])
                        .range([bottom[1], top[1]])

    # y-axis
    yaxis = svg.append("g").attr("class", "probe_data").attr("id", "loweryaxis")
    ticks = lodcurve_yScale.ticks(6)
    yaxis.selectAll("empty")
         .data(ticks)
         .enter()
         .append("line")
         .attr("y1", (d) -> lodcurve_yScale(d))
         .attr("y2", (d) -> lodcurve_yScale(d))
         .attr("x1", left[1])
         .attr("x2", right[1])
         .attr("stroke", "white")
         .attr("stroke-width", "1")
    yaxis.selectAll("empty")
         .data(ticks)
         .enter()
         .append("text")
         .text((d) ->
            return if maxlod > 10 then nodig(d) else onedig(d))
         .attr("y", (d) -> lodcurve_yScale(d))
         .attr("x", left[1] - pad.left*0.1)
         .style("text-anchor", "end")
         .attr("fill", labelcolor)
    yaxis.append("line")
         .attr("y1", lodcurve_yScale(5))
         .attr("y2", lodcurve_yScale(5))
         .attr("x1", left[1])
         .attr("x2", right[1])
         .attr("stroke", purple)
         .attr("stroke-width", "1")
         .attr("stroke-dasharray", "2,2")

    # lod curves by chr
    lodcurve = (c) ->
        d3.svg.line()
          .x((p) -> chrLowXScale[c](data.pmark[p].pos_cM))
          .y((p) -> lodcurve_yScale(probe_data.lod[data.pmark[p].index]))
    curves = svg.append("g").attr("id", "curves").attr("class", "probe_data")
    for c in data.chrnames
      curves.append("path")
            .datum(data.pmarknames[c])
            .attr("d", lodcurve(c))
            .attr("class", "thickline")
            .attr("stroke", darkblue)
            .style("pointer-events", "none")
            .attr("fill", "none")

    # title
    titletext = probe_data.probe
    probeaxes = svg.append("g").attr("id", "probe_data_axes").attr("class", "probe_data")
    gene = data.probes[probe_data.probe].gene
    ensembl = "http://www.ensembl.org/Mus_musculus/Search/Details?db=core;end=1;idx=Gene;species=Mus_musculus;q=#{gene}"
    mgi = "http://www.informatics.jax.org/searchtool/Search.do?query=#{gene}"
    if gene isnt null
      titletext += " (#{gene})"
      xlink = probeaxes.append("a").attr("xlink:href", mgi)
      xlink.append("text")
         .text(titletext)
         .attr("x", (left[1]+right[1])/2)
         .attr("y", top[1] - pad.top/2)
         .attr("fill", maincolor)
         .style("font-size", "18px")
    else
      probeaxes.append("text")
         .text(titletext)
         .attr("x", (left[1]+right[1])/2)
         .attr("y", top[1] - pad.top/2)
         .attr("fill", maincolor)
         .style("font-size", "18px")

    # black border
    svg.append("rect").attr("class", "probe_data")
       .attr("x", left[1])
       .attr("y", top[1])
       .attr("height", h[1])
       .attr("width", w[1])
       .attr("class", "outerBox")

    # point at probe
    svg.append("circle")
       .attr("class", "probe_data")
       .attr("id", "probe_circle")
       .attr("cx", chrLowXScale[data.probes[probe_data.probe].chr](data.probes[probe_data.probe].pos_cM))
       .attr("cy", top[1])
       .attr("r", bigRad)
       .attr("fill", pink)
       .attr("stroke", darkblue)
       .attr("stroke-width", 1)
       .attr("opacity", 1)

    svg.append("text")
       .attr("id", "pxgtitle")
       .attr("x", (left[2]+right[2])/2)
       .attr("y", pad.top/2)
       .text("")
       .attr("fill", maincolor)

    # keep track of clicked marker
    markerClick = {}
    for m in data.markers
      markerClick[m] = 0
    lastMarker = ""

    # dots at markers on LOD curves
    svg.append("g").attr("id", "markerCircle").attr("class", "probe_data")
       .selectAll("empty")
       .data(data.markers)
       .enter()
       .append("circle")
       .attr("class", "probe_data")
       .attr("id", (td) -> "marker_#{td}")
       .attr("cx", (td) -> chrLowXScale[data.pmark[td].chr](data.pmark[td].pos_cM))
       .attr("cy", (td) -> lodcurve_yScale(probe_data.lod[data.pmark[td].index]))
       .attr("r", bigRad)
       .attr("fill", purple)
       .attr("stroke", "none")
       .attr("stroke-width", "2")
       .attr("opacity", 0)
       .on("mouseover", (td) ->
              d3.select(this).attr("opacity", 1) unless markerClick[td]
              martip.call(this,td))
       .on "mouseout", (td) ->
              d3.select(this).attr("opacity", markerClick[td])
              d3.selectAll("#martip").remove()
       .on "click", (td) ->
              pos = data.pmark[td].pos_cM
              chr = data.pmark[td].chr
              title = "#{td} (chr #{chr}, #{onedig(pos)} cM)"
              d3.select("text#pxgtitle").text(title)
              if lastMarker is ""
                  plotPXG td
              else
                  markerClick[lastMarker] = 0
                  d3.select("circle#marker_#{lastMarker}").attr("opacity", 0).attr("fill",purple).attr("stroke","none")
                  revPXG td
              lastMarker = td
              markerClick[td] = 1
              d3.select(this).attr("opacity", 1).attr("fill",altpink).attr("stroke",purple)

    draw_pxgXaxis = (means, genotypes, chr, sexcenter, male) ->
      pxgXaxis.selectAll("line.PXGvert")
              .data(means)
              .enter()
              .append("line")
              .attr("class", "PXGvert")
              .attr("y1", top[2])
              .attr("y2", bottom[2])
              .attr("x1", (d,i) -> return if(chr is "X") then pxgXscaleX(i) else pxgXscaleA(i))
              .attr("x2", (d,i) -> return if(chr is "X") then pxgXscaleX(i) else pxgXscaleA(i))
              .attr("stroke", darkGray)
              .attr("fill", "none")
              .attr("stroke-width", "1")
      pxgXaxis.selectAll("line.PXGvert")
              .data(means)
              .transition().duration(fasttime)
              .attr("x1", (d,i) -> return if(chr is "X") then pxgXscaleX(i) else pxgXscaleA(i))
              .attr("x2", (d,i) -> return if(chr is "X") then pxgXscaleX(i) else pxgXscaleA(i))
      pxgXaxis.selectAll("line.PXGvert")
              .data(means)
              .exit().remove()
      pxgXaxis.selectAll("text.PXGgeno")
              .data(genotypes)
              .enter()
              .append("text")
              .attr("class", "PXGgeno")
              .text((d) -> d)
              .attr("y", bottom[2] + pad.bottom*0.25)
              .attr("x",  (d,i) -> return if(chr is "X") then pxgXscaleX(i) else pxgXscaleA(i))
              .attr("fill", labelcolor)
      pxgXaxis.selectAll("text.PXGgeno")
              .data(genotypes)
              .transition().duration(fasttime)
              .text((d) -> d)
              .attr("x",  (d,i) -> return if(chr is "X") then pxgXscaleX(i) else pxgXscaleA(i))
      pxgXaxis.selectAll("text.PXGgeno")
              .data(genotypes)
              .exit().remove()
      pxgXaxis.selectAll("text.PXGsex")
              .data(["Female", "Male"])
              .enter()
              .append("text")
              .attr("class", "PXGsex")
              .attr("id", "sextext")
              .text((d) -> d)
              .attr("y", bottom[j] + pad.bottom*0.75)
              .attr("x", (d, i) -> sexcenter[i])
              .attr("fill", labelcolor)
      pxgXaxis.selectAll("text.PXGsex")
              .data(["Female", "Male"])
              .transition().duration(fasttime)
              .attr("x", (d, i) -> sexcenter[i])
      pxgXaxis.selectAll("text.PXGsex")
              .data(["Female", "Male"])
              .exit().remove()

      # add line segments
      meanmarks.selectAll("line.PXGmeans")
         .data(means)
         .enter()
         .append("line")
         .attr("class", "PXGmeans")
         .attr("x1", (d,i) ->
            return if chr is "X" then pxgXscaleX(i)-jitterAmount*3 else pxgXscaleA(i)-jitterAmount*3)
         .attr("x2", (d,i) ->
            return if chr is "X" then pxgXscaleX(i)+jitterAmount*3 else pxgXscaleA(i)+jitterAmount*3)
         .attr("y1", (d) -> pxgYscale(d))
         .attr("y2", (d) -> pxgYscale(d))
         .attr("stroke", (d,i) -> return if male[i] then darkblue else darkred)
         .attr("stroke-width", 4)
         .on("mouseover", efftip)
         .on("mouseout", -> d3.selectAll("#efftip").remove())
      meanmarks.selectAll("line.PXGmeans")
         .data(means)
         .transition().duration(slowtime)
         .attr("x1", (d,i) ->
            return if chr is "X" then pxgXscaleX(i)-jitterAmount*3 else pxgXscaleA(i)-jitterAmount*3)
         .attr("x2", (d,i) ->
            return if chr is "X" then pxgXscaleX(i)+jitterAmount*3 else pxgXscaleA(i)+jitterAmount*3)
         .attr("y1", (d) -> pxgYscale(d))
         .attr("y2", (d) -> pxgYscale(d))
         .attr("stroke", (d,i) -> return if male[i] then darkblue else darkred)
      meanmarks.selectAll("line.PXGmeans")
         .data(means).exit().remove()

    pxgYscale = null
    pxgXaxis = svg.append("g").attr("class", "probe_data").attr("id", "pxg_xaxis")
    pxgYaxis = svg.append("g").attr("class", "probe_data").attr("class", "plotPXG").attr("id", "pxg_yaxis")
    meanmarks = svg.append("g").attr("id", "pxgmeans").attr("class", "probe_data")

    plotPXG = (marker) ->
      pxgYscale = d3.scale.linear()
                     .domain([d3.min(probe_data.pheno),
                              d3.max(probe_data.pheno)])
                     .range([bottom[2]-pad.inner, top[2]+pad.inner])
      pxgticks = pxgYscale.ticks(8)
      pxgYaxis.selectAll("empty")
         .data(pxgticks)
         .enter()
         .append("line")
         .attr("y1", (d) -> pxgYscale(d))
         .attr("y2", (d) -> pxgYscale(d))
         .attr("x1", left[2])
         .attr("x2", right[2])
         .attr("stroke", "white")
         .attr("stroke-width", "1")
      pxgYaxis.selectAll("empty")
         .data(pxgticks)
         .enter()
         .append("text")
         .text((d) -> twodig(d))
         .attr("y", (d) -> pxgYscale(d))
         .attr("x", left[2] - pad.left*0.1)
         .style("text-anchor", "end")
         .attr("fill", labelcolor)

      # calculate group averages
      chr = data.pmark[marker].chr
      if(chr is "X")
        means = [0,0,0,0]
        n = [0,0,0,0]
        male = [0,0,1,1]
        genotypes = ["BR", "RR", "BY", "RY"]
        sexcenter = [(pxgXscaleX(0) + pxgXscaleX(1))/2,
                     (pxgXscaleX(2) + pxgXscaleX(3))/2]
      else
        means = [0,0,0,0,0,0]
        n = [0,0,0,0,0,0]
        male = [0,0,0,1,1,1]
        genotypes = ["BB", "BR", "RR", "BB", "BR", "RR"]
        sexcenter = [pxgXscaleA(1), pxgXscaleA(4)]
      for i of data.individuals
         g = Math.abs(data.geno[marker][i])
         sx = data.sex[i]
         if(data.pmark[marker].chr is "X")
           x = sx*2+g-1
         else
           x = sx*3+g-1
         means[x] += probe_data.pheno[i]
         n[x]++
      for i of means
        means[i] /= n[i]

      draw_pxgXaxis(means, genotypes, chr, sexcenter, male)

      svg.append("g").attr("id", "plotPXG").attr("class", "probe_data").attr("id","PXGpoints").selectAll("empty")
          .data(probe_data.pheno)
          .enter()
          .append("circle")
          .attr("class", "plotPXG")
          .attr("cx", (d,i) ->
              g = Math.abs(data.geno[marker][i])
              sx = data.sex[i]
              if(data.pmark[marker].chr is "X")
                return pxgXscaleX(sx*2+g-1)+jitter[i]
              pxgXscaleA(sx*3+g-1)+jitter[i])
          .attr("cy", (d) -> pxgYscale(d))
          .attr("r", peakRad)
          .attr("fill", (d,i) ->
              g = data.geno[marker][i]
              return pink if g < 0
              darkGray)
          .attr("stroke", (d,i) ->
               g = data.geno[marker][i]
               return purple if g < 0
               "black")
          .attr("stroke-width", (d,i) ->
               g = data.geno[marker][i]
               return "2" if g < 0
               "1")
          .on "mouseover", (d,i) ->
               d3.select(this).attr("r", bigRad)
               indtip.call(this, d, i)
          .on "mouseout", ->
               d3.selectAll("#indtip").remove()
               d3.select(this).attr("r", peakRad)



    revPXG = (marker) ->
      # calculate group averages
      chr = data.pmark[marker].chr
      if(chr is "X")
        means = [0,0,0,0]
        n = [0,0,0,0]
        male = [0,0,1,1]
        genotypes = ["BR", "RR", "BY", "RY"]
        sexcenter = [(pxgXscaleX(0) + pxgXscaleX(1))/2,
                     (pxgXscaleX(2) + pxgXscaleX(3))/2]
      else
        means = [0,0,0,0,0,0]
        n = [0,0,0,0,0,0]
        male = [0,0,0,1,1,1]
        genotypes = ["BB", "BR", "RR", "BB", "BR", "RR"]
        sexcenter = [pxgXscaleA(1), pxgXscaleA(4)]
      for i of data.individuals
         g = Math.abs(data.geno[marker][i])
         sx = data.sex[i]
         if(data.pmark[marker].chr is "X")
           x = sx*2+g-1
         else
           x = sx*3+g-1
         means[x] += probe_data.pheno[i]
         n[x]++
      for i of means
        means[i] /= n[i]

      draw_pxgXaxis(means, genotypes, chr, sexcenter, male)

      svg.selectAll("circle.plotPXG")
         .transition().duration(slowtime)
         .attr("cx", (d,i) ->
              g = Math.abs(data.geno[marker][i])
              sx = data.sex[i]
              if(data.pmark[marker].chr is "X")
                return pxgXscaleX(sx*2+g-1)+jitter[i]
              pxgXscaleA(sx*3+g-1)+jitter[i])
         .attr("fill", (d,i) ->
              g = data.geno[marker][i]
              return pink if g < 0
              darkGray)
         .attr("stroke", (d,i) ->
               g = data.geno[marker][i]
               return purple if g < 0
               "black")
         .attr("stroke-width", (d,i) ->
               g = data.geno[marker][i]
               return "2" if g < 0
               "1")

    # initially select the marker with maximum LOD
    lastMarker = maxlod_marker
    markerClick[lastMarker] = 1
    d3.select("circle#marker_#{lastMarker}").attr("opacity", 1).attr("fill",altpink).attr("stroke",purple)
    pos = data.pmark[lastMarker].pos_cM
    chr = data.pmark[lastMarker].chr
    title = "#{lastMarker} (chr #{chr}, #{onedig(pos)} cM)"
    d3.select("text#pxgtitle").text(title)
    plotPXG(lastMarker)

  chrindex = {}
  for c,i in data.chrnames
    chrindex[c] = i

  # circles at eQTL peaks
  peaks = svg.append("g").attr("id", "peaks")
             .selectAll("empty")
             .data(data.peaks)
             .enter()
             .append("circle")
             .attr("class", (d) -> "probe_#{d.probe}")
             .attr("cx", (d) -> chrXScale[d.chr](d.pos_cM))
             .attr("cy", (d) -> chrYScale[data.probes[d.probe].chr](data.probes[d.probe].pos_cM))
             .attr("r", peakRad)
             .attr("stroke", "none")
             .attr("fill", (d) -> return if(chrindex[d.chr] % 2 is 0) then darkblue else darkgreen)
             .attr("opacity", (d) -> Zscale(d.lod))
             .on "mouseover", (d) ->
                 d3.selectAll("circle.probe_#{d.probe}")
                                .attr("r", bigRad)
                                .attr("fill", pink)
                                .attr("stroke", darkblue)
                                .attr("stroke-width", 1)
                                .attr("opacity", 1)
                 eqtltip.call(this,d)
             .on "mouseout", (d) ->
                 d3.selectAll("circle.probe_#{d.probe}")
                                .attr("r", peakRad)
                                .attr("fill", (d) -> return if(chrindex[d.chr] % 2 is 0) then darkblue else darkgreen)
                                .attr("stroke", "none")
                                .attr("opacity", (d) -> Zscale(d.lod))
                 d3.selectAll("#eqtltip").remove()
             .on "click", (d) ->
                 d3.json("data/probe_data/probe#{d.probe}.json", draw_probe)

  # initial set of LOD curves at the bottom
  d3.json("data/probe_data/probe517761.json", draw_probe)

  # grab selected gene from the search box
  selectedGene = ""
  $("#geneinput").submit () ->
    newSelection = document.getElementById("genesymbol").value
    if newSelection == "random" or newSelection == "\"random\""
      newSelection = allgenes[Math.floor(Math.random()*allgenes.length)]
    if newSelection != "" and newSelection != selectedGene
      selectedGene = newSelection
      if origGeneName?[selectedGene.toLowerCase()]
        selectedGene = origGeneName[selectedGene.toLowerCase()]
        selectedProbes = probesByGene[selectedGene]
        if(selectedProbes.length > 1)
          selectedProbe = selectedProbes[Math.floor(Math.random()*selectedProbes.length)]
        else
          selectedProbe = selectedProbes[0]
        d3.json("data/probe_data/probe#{selectedProbe}.json", draw_probe)
        mgi = "http://www.informatics.jax.org/searchtool/Search.do?query=#{selectedGene}"
        d3.select("a#currentgenesymbol")
          .html("Gene: #{selectedGene} &rarr; Probe: #{selectedProbe}")
          .attr("href", mgi)
      else
        d3.select("a#currentgenesymbol")
          .text("Gene \"#{selectedGene}\" not found")
          .attr("href", null)
    return false

  # black borders
  for j of left
    svg.append("rect")
       .attr("x", left[j])
       .attr("y", top[j])
       .attr("height", h[j])
       .attr("width", w[j])
       .attr("class", "outerBox")

# grayed-out "Gene symbol" within text input box
$('input#genesymbol').each(() ->
  console.log($(this).val())
  $(this)
    .data('default', $(this).val())
    .addClass('inactive')
    .focus(() ->
      $(this).removeClass('inactive')
      $(this).val('') if($(this).val() is $(this).data('default') or $(this).val() is '')
    )
    .blur(() ->
      if($(this).val() is '')
        $(this).addClass('inactive').val($(this).data('default'))
    )
  )

# load json file and call draw function
d3.json("data/islet_eqtl.json", draw)
