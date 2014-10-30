# the main function that makes all of the plots
plot = (data) ->
    n_states = data.state.length

    # sizes of things
    htop = 530
    hbot = 500
    height = htop + hbot+200

    margin_top = {left:5, top:20, right:25, bottom:40, inner:0}
    fullpanelwidth_top = 180
    panelwidth_top = fullpanelwidth_top - margin_top.left - margin_top.right
    panelheight_top = htop - margin_top.top - margin_top.bottom
    statenamewidth = 101
    width = statenamewidth + fullpanelwidth_top*6

    margin_bot = {left:80, top:20, right:25, bottom:40, inner:5}
    axispos_bot = {xtitle:25, ytitle:50, xlabel:5, ylabel:5}

    fullpanelwidth_bot = width/3
    panelwidth_bot = fullpanelwidth_bot - margin_bot.left - margin_bot.right
    fullpanelheight_bot = hbot/2
    panelheight_bot = fullpanelheight_bot - margin_bot.top - margin_bot.bottom

    # make the svg
    svg = d3.select("div#chart")
            .append("svg")
            .attr("height", height)
            .attr("width", width)

    # info top panels, with dot plots
    top_panel_var = ["total", "not_distracted", "speeding", "alcohol", "ins_premium", "ins_losses"]
    xlim = [[0,25],[0,25],[0,25],[0,25],[0,1500],[0,200]]
    nxticks = [6,6,6,6, 4, 5]
    xlab = ["Crashes per billion miles", "Crashes per billion miles", "Crashes per billion miles",
            "Crashes per billion miles", "Dollars", "Dollars"]
    title = ["Total crashes", "Not distracted crashes", "Speeding crashes", "Alcohol crashes",
            "Ave. Ins. premium", "Ave. Ins. Losses"]

    # make the dot plots
    dotplots = []
    for i of top_panel_var

        this_dotplot = scatterplot().width(panelwidth_top)
                                    .height(panelheight_top)
                                    .margin(margin_top)
                                    .titlepos(10)
                                    .xNA({handle:false})
                                    .yNA({handle:false})
                                    .xlim(xlim[i])
                                    .ylim([0.5, n_states+0.5])
                                    .yticks(d3.range(n_states).map (d) -> d+1)
                                    .xlab(xlab[i])
                                    .ylab("")
                                    .pointsize(3)
                                    .dataByInd(false)
                                    .xvar(top_panel_var[i])
                                    .yvar("rank")
                                    .title(title[i])
        dotplots.push(this_dotplot)

        this_g = svg.append("g")
                    .attr("class", "dotplot")
                    .attr("id", "dotplot#{i}")
                    .attr("transform", "translate(#{statenamewidth+i*fullpanelwidth_top},0)")

        this_g.datum({data:data, indID:data.abbrev})
              .call(this_dotplot)

        # remove the tool tips
        d3.selectAll(".d3-tip").remove()
        points = this_dotplot.pointsSelect().on("mouseover.paneltip", (d) -> d)
                                            .on("mouseout.paneltip", (d) -> d)

        points.on("mouseover", highlight_state)
              .on("mouseout",  lowlight_state)

    # make the horizontal grid lines gray
    d3.selectAll("g.dotplot g.y.axis line").attr("stroke", "#bbb")

    # add state names
    yscale = dotplots[0].yscale()
    state_names = svg.append("g").attr("id", "statenames")
                     .selectAll("empty")
                     .data(data.state)
                     .enter()
                     .append("text")
                     .text((d) -> d)
                     .attr("x", statenamewidth)
                     .attr("y", (d,i) -> yscale(data.rank[i]))
                     .style("font-size", "8pt")
                     .style("dominant-baseline", "middle")
                     .style("text-anchor", "end")
                     .attr("id", (d,i) -> "state#{i}")
                     .on("mouseover", highlight_state)
                     .on("mouseout",  lowlight_state)


    # variables for lower scatterplots
    row = [0, 0, 0, 1, 1, 1]
    col = [0, 1, 2, 0, 1, 2]
    lower_xvar = [0, 0, 0, 0, 0, 4]
    lower_yvar = [1, 2, 3, 4, 5, 5]

    # make the scatterplots
    scatterplots = []
    for i of top_panel_var

        this_scatterplot = scatterplot().width(panelwidth_bot)
                                    .height(panelheight_bot)
                                    .margin(margin_bot)
                                    .axispos(axispos_bot)
                                    .titlepos(10)
                                    .xNA({handle:false})
                                    .yNA({handle:false})
                                    .xlim(xlim[lower_xvar[i]])
                                    .ylim(xlim[lower_yvar[i]])
                                    .nxticks(nxticks[lower_xvar[i]])
                                    .nyticks(nxticks[lower_yvar[i]])
                                    .xlab(title[lower_xvar[i]])
                                    .ylab(title[lower_yvar[i]])
                                    .pointsize(3)
                                    .dataByInd(false)
                                    .xvar(top_panel_var[lower_xvar[i]])
                                    .yvar(top_panel_var[lower_yvar[i]])
        scatterplots.push(this_scatterplot)

        hpos = fullpanelwidth_bot*col[i]
        vpos = htop+row[i]*fullpanelheight_bot+margin_bot.top
        this_g = svg.append("g")
                    .attr("class", "scatterplot")
                    .attr("id", "scatterplot#{i}")
                    .attr("transform", "translate(#{hpos},#{vpos})")

        this_g.datum({data:data, indID:data.abbrev})
              .call(this_scatterplot)

        # remove the tool tips
        d3.selectAll(".d3-tip").remove()
        points = this_scatterplot.pointsSelect().on("mouseover.paneltip", (d) -> d)
                                                .on("mouseout.paneltip", (d) -> d)

        points.on("mouseover", highlight_state)
              .on("mouseout",  lowlight_state)




highlight_state = (d,i) ->
    d3.selectAll("circle.pt#{i}")
      .attr("fill", "Orchid")
      .attr("r", 5)
      .moveToFront()
    d3.select("text#state#{i}")
      .attr("fill", "violetred")

lowlight_state = (d,i) ->
    d3.selectAll("circle.pt#{i}")
      .attr("fill", "slateblue")
      .attr("r", 3)
      .moveToBack()
    d3.select("text#state#{i}")
      .attr("fill", "black")



# load the data and make the plot
d3.json("data.json", plot)
