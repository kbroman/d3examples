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

# central horizontal line
fig.insert("line")
   .attr("x1", 0)
   .attr("x2", figw)
   .attr("y1", figh/2)
   .attr("y2", figh/2)
   .attr("stroke", "slateblue")
   .attr("stroke-width", 2)

# a circle in the figure, whose position will be controlled by the slider
circle = fig.insert("circle")
            .attr("id", "circle")
            .attr("cx", Math.random()*figw)
            .attr("cy", figh/2)
            .attr("r", 10)
            .attr("fill", "slateblue")

# g to contain the slider
slider_g = svg.insert("g").attr("transform", "translate(0," + figh + ")")

# slider callback
slider_callback = (sl) ->
    circle.attr("cx", xscale(sl.value()))

# insert slider
my_slider = slider()
my_slider(slider_g, slider_callback, [d3.min(marker_pos), d3.max(marker_pos)], marker_pos)
