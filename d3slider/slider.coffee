# d3-based slider

slider = (chartOpts) ->
    chartOpts = {} unless chartOpts? # make sure it's defined

    # chartOpts start
    width = chartOpts?.width ? 800                                          # total width of svg for slider
    height = chartOpts?.height ? 80                                         # total height of svg for slider
    margin = chartOpts?.margin ? 25                                         # margin on left and right of slider
    rectheight = chartOpts?.rectheight ? 10                                 # height of slider scale
    rectcolor = chartOpts?.rectcolor ? "#ccc"                               # color of slider scale
    buttonsize = chartOpts?.buttonsize ? rectheight*2                       # size of button
    buttoncolor = chartOpts?.buttoncolor ? "#eee"                           # color of button
    buttonstroke = chartOpts?.buttonstroke ? "black"                        # color of button border
    buttonround = chartOpts?.buttonround ? buttonsize*0.2                   # how much to round the button corners
    buttondotfill = chartOpts?.buttondotfill ? "slateblue"                  # color of dot on button
    buttondotsize = chartOpts?.buttondotsize ? buttonsize/4                 # radius of dot on button
    tickheight = chartOpts?.tickheight ? 10                                 # height of ticks
    tickgap = chartOpts?.tickgap ? tickheight/2                             # gap below ticks
    textsize = chartOpts?.textsize ? 14                                     # font size for axis labels
    nticks = chartOpts?.nticks ? 5                                          # number of ticks
    ticks = chartOpts?.ticks ? null                                         # vector of ticks
    # chartOpts end
    # accessors start
    value = 0 # current value of slider
    # accessors end
    slider_svg = null

    chart = (selection, callback, range, stops) ->

        range = [margin, width-margin*2] unless range?
        value = (range[1]-range[0])*Math.random() + range[0]

        slider_svg = selection.insert("svg")
                              .attr("height", height)
                              .attr("width", width)

        xscale = d3.scaleLinear()
                   .range([margin, width-margin])
                   .domain(range)
                   .clamp(true)
        clamp_pixels = (pixels, interval) ->
            return interval[0] if pixels < interval[0]
            return interval[1] if pixels > interval[1]
            pixels

        # insert bar
        slider_svg.insert("rect")
                  .attr("x", margin)
                  .attr("y", height/2 - rectheight/2)
                  .attr("rx", rectheight*0.3)
                  .attr("ry", rectheight*0.3)
                  .attr("width", width-margin*2)
                  .attr("height", rectheight)
                  .attr("fill", rectcolor)

        # add scale
        ticks = xscale.ticks(nticks) unless ticks?
        slider_svg.selectAll("empty")
                  .data(ticks)
                  .enter()
                  .insert("line")
                  .attr("x1", (d) -> xscale(d))
                  .attr("x2", (d) -> xscale(d))
                  .attr("y1", height/2 + rectheight/2 + tickgap)
                  .attr("y2", height/2 + rectheight/2 + tickgap + tickheight)
                  .attr("stroke", "black")
                  .attr("shape-rendering", "crispEdges")
        slider_svg.selectAll("empty")
                  .data(ticks)
                  .enter()
                  .insert("text")
                  .attr("x", (d) -> xscale(d))
                  .attr("y", height/2 + rectheight/2 + tickgap*2+tickheight)
                  .text((d) -> d)
                  .style("font-size", textsize)
                  .style("dominant-baseline", "hanging")
                  .style("text-anchor", "middle")
                  .style("pointer-events", "none")


        # add button
        button = slider_svg.insert("g").attr("id", "button")
                           .attr("transform", "translate(" + xscale(value) + ",0)")
        button.insert("rect")
              .attr("x", -buttonsize/2)
              .attr("y", height/2 - buttonsize/2)
              .attr("height", buttonsize)
              .attr("width", buttonsize)
              .attr("rx", buttonround)
              .attr("ry", buttonround)
              .attr("stroke", buttonstroke)
              .attr("stroke-width", 2)
              .attr("fill", buttoncolor)

        button.insert("circle")
              .attr("cx", 0)
              .attr("cy", height/2)
              .attr("r", buttondotsize)
              .attr("fill", buttondotfill)

        dragged = (d) ->
            pixel_value = d3.event.x - margin
            clamped_pixels = clamp_pixels(pixel_value, [0, width-margin*2])
            value = xscale.invert(clamped_pixels+margin)
            callback(chart) if callback?
            d3.select(this).attr("transform", "translate(" + xscale(value) + ",0)")

        button.call(d3.drag().on("drag", dragged))

        # run the callback at the beginning
        callback(chart) if callback?

    # functions to grab stuff
    chart.value = (arg) ->
        value = arg if arg?
        value

    # function to remove the slider
    chart.remove = () ->
        slider_svg.remove()

    # return the chart function
    chart
