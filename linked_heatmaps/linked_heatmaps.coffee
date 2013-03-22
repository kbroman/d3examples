# linked_heatmaps.coffee
#
# For each chromosome, there is a pair of heatmaps depicting two
# different log likelihood calculations that ideally should be the
# same.
#
# Hover over a point to see plots of the cross-sections.

# function that does all of the work
draw = (data) ->

  d3.select("p#loading").remove()
  d3.select("div#legend").style("opacity", 1)

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

  # min and max loglik by chromosome
  minLL = []
  maxLL = []
  nmaxloc = []
  kmaxloc = []
  for i in [0...data.nll.length]
    minLL[i] = data.nll[i][0][0]
    maxLL[i] = data.nll[i][0][0]
    nmaxhere = data.nll[i][0][0]
    kmaxhere = data.kll[i][0][0]
    nmaxloc[i] = {row:0, col:0}
    kmaxloc[i] = {row:0, col:0}
    for j of data.nll[i]
      for k of data.nll[i][j]
        minLL[i] = data.nll[i][j][k] if minLL[i] > data.nll[i][j][k]
        maxLL[i] = data.nll[i][j][k] if maxLL[i] < data.nll[i][j][k]
        if nmaxhere < data.nll[i][j][k]
          nmaxhere = data.nll[i][j][k]
          nmaxloc[i] = {row:k, col:j}
        minLL[i] = data.kll[i][j][k] if minLL[i] > data.kll[i][j][k]
        maxLL[i] = data.kll[i][j][k] if maxLL[i] < data.kll[i][j][k]
        if kmaxhere < data.kll[i][j][k]
          kmaxhere = data.kll[i][j][k]
          kmaxloc[i] = {row:k, col:j}

  # list version of data
  llList = []
  for i in [0...data.nll.length]
    llList[i] = []
    for j of data.nll[i]
      for k of data.nll[i][j]
        llList[i].push({col:j, row:k, nll:data.nll[i][j][k], kll:data.kll[i][j][k], chr:i})

  # dimensions
  w = 300 # width of heat maps
  pad = {left:60, top:40, right:25, bottom: 35, inner: 0}
  h = w # height of heat maps
  h2 = (h - pad.top - pad.bottom)/2 # height of line plot

  # total size of SVG
  totalh = w + pad.top + pad.bottom
  totalw = 3*(w + pad.left+pad.right)
  console.log("totalw = #{totalw}; totalh = #{totalh}")

  # widths and heights of panels
  iw = [w, w, w, w]
  ih = [h, h, h2, h2]

  # loop over chromosomes
  svg = []
  panels = []
  xScaleImg = []
  yScaleImg = []
  zScaleImg = []
  for i in [0...data.nll.length]
    d3.select("div#heatmap_fig")
      .append("hr")
      .style("border", 0)
      .style("width", "100%")
      .style("color", "black")
      .style("background-color", "black")
      .style("height", "2px")
    d3.select("div#heatmap_fig")
      .append("h3")
      .text("Chromosome #{i+1}")

    svg[i] = d3.select("div#heatmap_fig")
               .append("svg")
              .attr("height", totalh)
              .attr("width", totalw)

    # groups for the panels, translated to have origin = (0,0)
    panels[i] = []
    panels[i][0] = svg[i].append("g").attr("id", "n_image_#{i}")
                     .attr("transform", "translate(#{pad.left},#{pad.top})")
    panels[i][1] = svg[i].append("g").attr("id", "k_image_#{i}")
                     .attr("transform", "translate(#{pad.left*2+pad.right+w},#{pad.top})")
    panels[i][2] = svg[i].append("g").attr("id", "p_line_#{i}")
                     .attr("transform", "translate(#{pad.left*3+pad.right*2+w*2},#{pad.top})")
    panels[i][3] = svg[i].append("g").attr("id", "m_line_#{i}")
                     .attr("transform", "translate(#{pad.left*3+pad.right*2+w*2},#{pad.top*2+pad.bottom+h2})")
                  
    # background rectangle for each panel
    for j in [0...4]
      panels[i][j].append("rect")
              .attr("height", ih[j])
              .attr("width", iw[j])
              .attr("fill", "white")
              .attr("stroke", "black")
              .attr("stroke-width", 1)

    # scales
    nm = data.nll[i].length
    np = data.nll[i][0].length
    xScaleImg[i] = d3.scale.ordinal()
                  .domain(data.m[0...nm])
                  .rangeBands([0, w])
    yScaleImg[i] = d3.scale.ordinal()
                  .domain(data.p[0...np])
                  .rangeBands([h, 0])
    zScaleImg[i] = d3.scale.linear()
                  .domain([-20, maxLL[i]])
                  .range([darkBlue, "white"])
                  .clamp(true)

    # title text
    for j in [0..1]
      panels[i][j].append("text").attr("id", "loglik#{i}#{j}")
               .text("")
               .attr("x", w/2)
               .attr("y", -pad.top*0.25)
               .attr("text-anchor", "middle")
               .attr("dominant-baseline", "middle")
               .attr("fill", labelcolor)
      panels[i][j].append("text")
               .text(["Nicola", "Karl"][j])
               .attr("x", w/2)
               .attr("y", -pad.top*0.75)
               .attr("text-anchor", "middle")
               .attr("dominant-baseline", "middle")
               .attr("fill", maincolor)

    # left image panel
    panels[i][0].append("g").attr("id", "n_imgrect_#{i}")
             .selectAll("empty")
             .data(llList[i])
             .enter()
             .append("rect")
             .attr("x", (d) -> xScaleImg[i](data.m[d.col]))
             .attr("y", (d) -> yScaleImg[i](data.p[d.row]))
             .attr("width", xScaleImg[i].rangeBand())
             .attr("height", yScaleImg[i].rangeBand())
             .attr("fill", (d) -> zScaleImg[i](d.nll))
             .on("mouseover", (d) ->
                       title0 = "loglik = #{onedig(d.nll)}"
                       title1 = "loglik = #{onedig(d.kll)}"
                       d3.select("text#loglik#{d.chr}0").text(title0)
                       d3.select("text#loglik#{d.chr}1").text(title1)
                       panels[d.chr][0].append("rect").attr("id","mouseover0")
                                .attr("x", xScaleImg[d.chr](data.m[d.col]))
                                .attr("y", yScaleImg[d.chr](data.p[d.row]))
                                .attr("width", xScaleImg[d.chr].rangeBand())
                                .attr("height", yScaleImg[d.chr].rangeBand())
                                .style("pointer-events", "none")
                                .attr("fill", "none")
                                .attr("stroke", "green")
                                .attr("stroke-width", 2)
                       panels[d.chr][1].append("rect").attr("id","mouseover1")
                                .attr("x", xScaleImg[d.chr](data.m[d.col]))
                                .attr("y", yScaleImg[d.chr](data.p[d.row]))
                                .attr("width", xScaleImg[d.chr].rangeBand())
                                .attr("height", yScaleImg[d.chr].rangeBand())
                                .style("pointer-events", "none")
                                .attr("fill", "none")
                                .attr("stroke", "green")
                                .attr("stroke-width", 2))
             .on("mouseout", (d) ->
                       d3.select("text#loglik#{d.chr}0").text("")
                       d3.select("text#loglik#{d.chr}1").text("")
                       d3.select("rect#mouseover0").remove()
                       d3.select("rect#mouseover1").remove())
                      

    # right image panel
    panels[i][1].append("g").attr("id", "n_imgrect_#{i}")
             .selectAll("empty")
             .data(llList[i])
             .enter()
             .append("rect")
             .attr("x", (d) -> xScaleImg[i](data.m[d.col]))
             .attr("y", (d) -> yScaleImg[i](data.p[d.row]))
             .attr("width", xScaleImg[i].rangeBand())
             .attr("height", yScaleImg[i].rangeBand())
             .attr("fill", (d) -> zScaleImg[i](d.kll))
             .on("mouseover", (d) ->
                       title0 = "loglik = #{onedig(d.nll)}"
                       title1 = "loglik = #{onedig(d.kll)}"
                       d3.select("text#loglik#{d.chr}0").text(title0)
                       d3.select("text#loglik#{d.chr}1").text(title1)
                       panels[d.chr][0].append("rect").attr("id","mouseover0")
                                .attr("x", xScaleImg[d.chr](data.m[d.col]))
                                .attr("y", yScaleImg[d.chr](data.p[d.row]))
                                .attr("width", xScaleImg[d.chr].rangeBand())
                                .attr("height", yScaleImg[d.chr].rangeBand())
                                .style("pointer-events", "none")
                                .attr("fill", "none")
                                .attr("stroke", "green")
                                .attr("stroke-width", 2)
                       panels[d.chr][1].append("rect").attr("id","mouseover1")
                                .attr("x", xScaleImg[d.chr](data.m[d.col]))
                                .attr("y", yScaleImg[d.chr](data.p[d.row]))
                                .attr("width", xScaleImg[d.chr].rangeBand())
                                .attr("height", yScaleImg[d.chr].rangeBand())
                                .style("pointer-events", "none")
                                .attr("fill", "none")
                                .attr("stroke", "green")
                                .attr("stroke-width", 2))
                       
             .on("mouseout", (d) ->
                       d3.select("text#loglik#{d.chr}0").text("")
                       d3.select("text#loglik#{d.chr}1").text("")
                       d3.select("rect#mouseover0").remove()
                       d3.select("rect#mouseover1").remove())

    # rectangles at max
    panels[i][0].append("rect")
             .attr("x", xScaleImg[i](data.m[nmaxloc[i].col]))
             .attr("y", yScaleImg[i](data.p[nmaxloc[i].row]))
             .attr("width", xScaleImg[i].rangeBand())
             .attr("height", yScaleImg[i].rangeBand())
             .attr("fill", "none")
             .attr("stroke", darkRed)
             .attr("stroke-width", 2)
    panels[i][1].append("rect")
             .attr("x", xScaleImg[i](data.m[kmaxloc[i].col]))
             .attr("y", yScaleImg[i](data.p[kmaxloc[i].row]))
             .attr("width", xScaleImg[i].rangeBand())
             .attr("height", yScaleImg[i].rangeBand())
             .attr("fill", "none")
             .attr("stroke", darkRed)
             .attr("stroke-width", 2)
    
    # axis labels
    lab = []
    for j in [0..1]
      lab[j] = panels[i][j].append("g")
      lab[j].append("text")
            .text("m")
            .attr("x", w/2)
            .attr("y", h+pad.bottom*0.7)
            .attr("fill", titlecolor)
            .attr("text-anchor", "middle")
            .attr("dominant-baseline", "middle")
      lab[j].append("text")
            .text("p")
            .attr("x", -pad.left*0.7)
            .attr("y", h/2)
            .attr("fill", titlecolor)
            .attr("text-anchor", "middle")
            .attr("dominant-baseline", "middle")
      lab[j].selectAll("empty")
            .data([0, 5, 10])
            .enter()
            .append("text")
            .text((d) -> d)
            .attr("x", (d) -> xScaleImg[i](d)+xScaleImg[i].rangeBand()/2)
            .attr("y", h+pad.bottom*0.3)
            .attr("fill", labelcolor)
            .attr("text-anchor", "middle")
            .attr("dominant-baseline", "middle")
      lab[j].selectAll("empty")
            .data([0, 0.03, 0.06, 0.09])
            .enter()
            .append("text")
            .text((d) -> twodig(d))
            .attr("x", -pad.left*0.05)
            .attr("y", (d) -> yScaleImg[i](d)+yScaleImg[i].rangeBand()/2)
            .attr("fill", labelcolor)
            .attr("text-anchor", "end")
            .attr("dominant-baseline", "middle")



            

# load json file and call draw function
d3.json("loglik.json", draw)
