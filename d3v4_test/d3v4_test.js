// playing around to try to understand d3 version 4

var height = 800;
var width  = 800;
var r = 5;
var margin = r;

var svg = d3.select("div#chart")
    .insert("svg")
    .attr("height", height)
    .attr("width", width);

// simulate a bunch of random points
var n=2000;
var data = d3.range(n)
    .map((d) => ({x:Math.random()*(width-2*margin)+margin,
                  y:Math.random()*(height-2*margin)+margin}));

var min_jump = 20
var max_jump = 200
var u = function() {
    ru = d3.randomUniform(min_jump, max_jump)

    if(Math.random() < 0.5) {
        return ru()
    } else {
        return -1*ru()
    }
}

// circles jump away on mouseover, then slowly come back
svg.selectAll("empty")
    .data(data)
    .enter()
    .insert("circle")
    .attr("cx", (d) => d.x)
    .attr("cy", (d) => d.y)
    .attr("r", r)
    .attr("fill", (d) => d3.rgb(Math.random()*255,
                                Math.random()*255,
                                Math.random()*255))
    .on("mouseover", (d,i,array) =>
        d3.select(array[i]).transition().attr("r", r*5)
        .attr("cx", (d) => d.x + u())
        .attr("cy", (d) => d.y + u()))
    .on("mouseout", (d,i,array) =>
        d3.select(array[i]).transition().duration(2000)
        .delay(200).attr("r", r)
        .attr("cx", (d) => d.x)
        .attr("cy", (d) => d.y))
