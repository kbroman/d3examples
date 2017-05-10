# exploring a d3-slider

# slider size
slider_width=800
slider_height=80
slider_margin=25

# svg size
h = 100+slider_height
w = slider_width

# figure size
figw = w - slider_margin*2
figh = h-slider_height

# insert svg
svg = d3.select("div#chart").insert("svg").attr("id", "chart")
        .attr("height", h).attr("width", w)

# insert figure
fig = svg.insert("g").attr("transform", "translate(" + slider_margin + ",0)")
fig.insert("rect").attr("x", 0).attr("y", 0).attr("height", figh).attr("width", figw).attr("fill", "#ddd")

# stop positions (at marker locations)
marker_pos = [0, 14.2, 16.4, 17.5, 18.6, 21.9, 23, 23, 25.1, 28.4, 29.5,
             30.6, 31.7, 31.7, 32.8, 33.9, 35, 47, 56.8, 74.3]

# xscale
xscale = d3.scaleLinear().range([0,figw]).domain([d3.min(marker_pos), d3.max(marker_pos)])

# add vertical lines to figure
fig.selectAll("empty")
   .data(marker_pos)
   .enter()
   .insert("line")
   .attr("stroke", "black")
   .attr("stroke-width", 2)
   .attr("x1", (d) => xscale(d))
   .attr("x2", (d) => xscale(d))
   .attr("y1", 0)
   .attr("y2", figh)

# central horizontal lines
vpos = [figh/3, 2*figh/3]
fig.selectAll("empty")
    .data(vpos)
    .enter()
    .insert("line")
    .attr("x1", 0)
    .attr("x2", figw)
    .attr("y1", (d) -> d)
    .attr("y2", (d) -> d)
    .attr("stroke", (d,i) ->
        return "slateblue" if i==0
        "orchid")
    .attr("stroke-width", 2)

# a circle in the figure, whose position will be controlled by the slider

circles = [0,1].map( (i) ->
                    fig.insert("circle")
                       .attr("id", "circle")
                       .attr("cx", Math.random()*figw)
                       .attr("cy", vpos[i])
                       .attr("r", 10)
                       .attr("fill",
                           if i==0
                               "slateblue"
                           else
                               "orchid"))

# g to contain the slider
slider_g = svg.insert("g").attr("transform", "translate(0," + figh + ")")

# slider callbacks
slider_callback1 = (sl) ->
    circles[0].attr("cx", xscale(sl.value()[0]))
slider_callback2 = (sl) ->
    circles[1].attr("cx", xscale(sl.value()[1]))

# insert slider
my_slider = double_slider()
my_slider(slider_g, slider_callback1, slider_callback2, [d3.min(marker_pos), d3.max(marker_pos)], marker_pos)
