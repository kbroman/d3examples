height = 300
width = 250
gap = 10

// overall svg
svg = d3.select("body")
    .append("svg")
    .attr("id", "mainsvg")
    .attr("height", height)
    .attr("width", width*2 + gap)

// first svg
svg1 = d3.select("svg#mainsvg")
    .append("svg")
    .attr("id", "svg1")
    .attr("height", height)
    .attr("width", width)
svg2 = d3.select("svg#mainsvg")
    .append("g") // group to move svg sideways
      .attr("transform", "translate(" + (width+gap) + ")")
      .append("svg")
      .attr("id", "svg2")
      .attr("height", height)
      .attr("width", width)

// add a box around each SVG
svg1.append("rect")
    .attr("height", height)
    .attr("width", width)
    .attr("stroke", "black")
    .attr("fill", "#ccc")
    .attr("stroke-width", 2)
svg2.append("rect")
    .attr("height", height)
    .attr("width", width)
    .attr("stroke", "black")
    .attr("fill", "#ccc")
    .attr("stroke-width", 2)

// simulate some data
n_pts = 20
index = d3.range(n_pts)
data = index.map(function(i) {
    x = Math.random()*(width-10)+5;
    y = x*0.3 + Math.random()*height/2;
    z = x*0.4 + Math.random()*height/2;
    return {x:x, y:y, z:z};
})


// plot y vs x in first plot
svg1.selectAll("empty")
    .data(data)
    .enter()
    .append("circle")
    .attr("cx", function(d) { return d.x; })
    .attr("cy", function(d) { return height-d.y+10; })
    .attr("class", function(d,i) { return "pt" + i; })
    .attr("r", 5)
    .attr("stroke", "black")
    .attr("fill", "slateblue")
    .on("mouseover", function(d, i) {
        console.log(i)
        d3.selectAll("circle.pt" + i)
          .attr("fill", "Orchid")
          .attr("r", 10)
    })
    .on("mouseout", function(d, i) {
        d3.selectAll("circle.pt" + i)
          .attr("fill", "slateblue")
          .attr("r", 5)
    })

// plot z vs x in 2nd plot
svg2.selectAll("empty")
    .data(data)
    .enter()
    .append("circle")
    .attr("cx", function(d) { return d.x; })
    .attr("cy", function(d) { return height-d.z+10; })
    .attr("class", function(d,i) { return "pt" + i; })
    .attr("r", 5)
    .attr("stroke", "black")
    .attr("fill", "slateblue")
    .on("mouseover", function(d, i) {
        console.log(i)
        d3.selectAll("circle.pt" + i)
          .attr("fill", "Orchid")
          .attr("r", 10)
    })
    .on("mouseout", function(d, i) {
        d3.selectAll("circle.pt" + i)
          .attr("fill", "slateblue")
          .attr("r", 5)
    })
