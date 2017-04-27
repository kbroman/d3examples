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
var random_jump = function() {
    radius = d3.randomUniform(min_jump, max_jump)()
    console.log(radius)
    angle = d3.randomUniform(0, 2*Math.PI)()
    console.log(angle)

    return {x: radius*Math.cos(angle), y:radius*Math.sin(angle)}
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
    .on("mouseover", (d,i,array) => {
        u = random_jump()
        d3.select(array[i]).transition().attr("r", r*5)
            .attr("cx", (d) => d.x + u.x)
            .attr("cy", (d) => d.y + u.y) })
    .on("mouseout", (d,i,array) =>
        d3.select(array[i]).transition().duration(2000)
            .delay(200).attr("r", r)
            .attr("cx", (d) => d.x)
            .attr("cy", (d) => d.y))
