
h = 450
w = 1000
margin = {left:60, top:40, right:40, bottom: 40, inner:5}
halfh = (h+margin.top+margin.bottom)
totalh = halfh*2
totalw = (w+margin.left+margin.right)

mychart_em = lodChart().lodvarname("lod.em").height(h).width(w).margin(margin)
mychart_hk = lodChart().lodvarname("lod.hk").height(h).width(w).margin(margin)

d3.json "scanone.json", (data) ->
  svg = d3.select("div#chart")
          .append("svg")
          .attr("height", totalh)
          .attr("width", totalw)

  chart1 = svg.append("g").attr("id", "chart1")

  chart2 = svg.append("g").attr("id", "chart2")
              .attr("transform", "translate(0, #{halfh})")

  chart1.datum(data)
    .call(mychart_em)

  chart2.datum(data)
    .call(mychart_hk)
