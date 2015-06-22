# plot Anscombe's quartet, with mongoDB on the back end

height = 500
width  = 800
left_width = 80
gap = 10
bigrad = 20
rad = 3
color = "slateblue"
hilit = "violetred"
margin = {left:60, top:40, right:40, bottom:40, inner:5}

# four big points that, when clicked, generate the scatterplot
svg = d3.select("div#chart")
        .append("svg")
        .attr("height", height)
        .attr("width", width + left_width)


sets = ["I", "II", "III", "IV"]
y = (height/8 + height/4*i for i of sets)

svg.selectAll("empty")
   .data(sets)
   .enter()
   .append("circle")
   .attr("cx", left_width-bigrad-gap)
   .attr("cy", (d,i) -> y[i])
   .attr("r", bigrad)
   .attr("fill", color)
   .on("mouseover", (d) -> d3.select(this).attr("fill", hilit))
   .on("mouseout", (d) -> d3.select(this).attr("fill", color))
   .on("click", (d) -> make_plot(d))

svg.selectAll("empty")
   .data(sets)
   .enter()
   .append("text")
   .text((d) -> d)
   .attr("x", gap)
   .attr("y", (d,i) -> y[i])
   .style("dominant-baseline", "middle")
   .style("text-anchor", "middle")
   .style("font-size", "20px")

myscatter = scatterplot().xvar("x")
                         .yvar("y")
                         .xlab("X")
                         .ylab("Y")
                         .xlim([3,20])
                         .ylim([2.1,13.74])
                         .margin(margin)
                         .height(height - margin.top - margin.bottom)
                         .width(width - margin.left - margin.right-gap)
                         .pointsize(rad)
                         .pointcolor(color)

make_plot = (set) ->
    d3.json("http://localhost:8080/anscombe/#{set}", (data) ->
        d3.select("svg#scatterplot").remove()
        d3.select(".d3-tip").remove()

        myscatter_svg = svg.append("svg")
               .attr("height", height)
               .attr("width", width + left_width)
               .attr("id", "scatterplot")
               .append("g").attr("transform", "translate(#{left_width},0)")
               .datum(data)
               .call(myscatter)

        )
