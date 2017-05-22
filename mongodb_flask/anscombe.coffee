# plot Anscombe's quartet, with mongoDB on the back end

height = 500      # height of right panel
width  = 800      # width of right panel
left_width = 80   # width of left bit, with the buttons
gap = 10          # gap to left of buttons
button_size = 20  # width of buttons
rad = 3           # radius of circles in main plot
color = "#6A5ACD" # slateblue
hilit = "#C71585" # violetred
margin = {left:60, top:40, right:40, bottom:40, inner:5}

# four big points that, when clicked, generate the scatterplot
svg = d3.select("div#chart")
        .append("svg")
        .attr("height", height)
        .attr("width", width + left_width)

# the four sets, and where the buttons will go
sets = ["I", "II", "III", "IV"]
y = (margin.top + i*button_size*1.5 for i of sets)

# add the four buttons
svg.selectAll("empty")
   .data(sets)
   .enter()
   .append("rect")
   .attr("x", gap)
   .attr("y", (d,i) -> y[i])
   .attr("height", button_size)
   .attr("width", button_size)
   .attr("fill", color)
   .on("mouseover", (d) -> d3.select(this).attr("fill", hilit))
   .on("mouseout", (d) -> d3.select(this).attr("fill", color))
   .on("click", (d) -> make_plot(d)) # <- click a button and make the plot

# add text next to the buttons
svg.selectAll("empty")
   .data(sets)
   .enter()
   .append("text")
   .text((d) -> d)
   .attr("x", gap + button_size*2)
   .attr("y", (d,i) -> y[i] + button_size/2.0)
   .style("dominant-baseline", "middle")
   .style("text-anchor", "middle")
   .style("font-size", "20px")

# function to create the scatterplot
# (see http://kbroman.org/d3panels)
myscatter = d3panels.scatterplot({
    margin:margin
    xlim:[3,20]
    ylim:[2.1,13.74]
    xlab:"X"
    ylab:"Y"
    height: height,
    width: width,
    pointsize:rad,
    pointcolor:color})

# function that actually makes the plot of one of the 4 sets
#   - the URL passed to d3.json causes the request to the database, and data as JSON back
#   - we remove previous plot and any d3-tip objects
#   - then make the scatterplot
make_plot = (set) ->
    d3.json "http://localhost:8080/anscombe/#{set}", (data) ->
        data4plot = {x:(d.x for d in data.data),y:(d.y for d in data.data)}

        d3.select("svg#scatterplot").remove()
        d3.select(".d3-tip").remove()

        myscatter_svg = svg.append("svg")
               .attr("height", height)
               .attr("width", width + left_width)
               .attr("id", "scatterplot")
               .append("g").attr("transform", "translate(#{left_width},0)")
        myscatter(myscatter_svg, data4plot)
