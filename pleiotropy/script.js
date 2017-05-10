// initial exploration of sliders, for a pleiotropy explorer
var slider_width=800;
var slider_height=80;
var slider_margin=25;

var h = 400;
var w = slider_width - slider_margin;

var svg = d3.select("div#chart").insert("svg").attr("id", "chart")
            .attr("height", h).attr("width", w)

var fig = svg.insert("g").attr("transform", "translate(" + slider_margin + ",0)");
fig.insert("rect").attr("x", 0).attr("y", 0).attr("height", h).attr("width", w).attr("fill", "#ccc");

div1 = d3.select("div#slider1").style("width", slider_width+"px");
div2 = d3.select("div#slider2").style("width", slider_width+"px");

var marker_pos = [0, 14.2, 16.4, 17.5, 18.6, 21.9, 23, 23, 25.1, 28.4, 29.5,
                  30.6, 31.7, 31.7, 32.8, 33.9, 35, 47, 56.8, 74.3];

slider_starts = [Math.random(), Math.random()].map((d) => marker_pos[Math.floor(d*marker_pos.length)])

var slider1= d3.slider().min(d3.min(marker_pos)).max(d3.max(marker_pos))
    .ticks(10).value(slider_starts[0])
    .stepValues(marker_pos)
    .tickFormat((d) => d + " cM")
    .callback((sl) => console.log("slider1: " + sl.value()));

div1.call(slider1);

var slider2= d3.slider().min(d3.min(marker_pos)).max(d3.max(marker_pos))
    .ticks(10).value(slider_starts[1])
    .stepValues(marker_pos)
    .tickFormat((d) => d + " cM")
    .callback((sl) => console.log("slider2: " + sl.value()));
div2.call(slider2);
