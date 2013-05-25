# illustration of use of the lodchart function

h = 300
w = 600
margin = {left:60, top:40, right:40, bottom: 40, inner:5}
halfh = (h+margin.top+margin.bottom)
totalh = halfh*2
totalw = (w+margin.left+margin.right)

# simplest use
d3.json "scanone.json", (data) ->
  mychart = lodchart().lodvarname("lod.em")
                      .height(h)
                      .width(w)
                      .margin(margin)

  d3.select("div#topchart")
    .datum(data)
    .call(mychart)

  # grab chromosome rectangles; color pink on hover
  chrrect = mychart.chrSelect()
  chrrect.on "mouseover", ->
              d3.select(this).attr("fill", "#E9CFEC")
         .on "mouseout", (d,i) ->
              d3.select(this).attr("fill", ->
                    return d3.rgb(200,200,200) if i % 2
                    d3.rgb(230,230,230))

  # animate points at markers on click
  mychart.markerSelect()
            .on "click", (d) ->
                  r = d3.select(this).attr("r")
                  d3.select(this)
                    .transition().duration(500).attr("r", r*3)
                    .transition().duration(500).attr("r", r)

# two LOD charts within one SVG
d3.json "scanone.json", (data) ->
  mychart_em = lodchart().lodvarname("lod.em")
                         .height(h)
                         .width(w)
                         .margin(margin)
                         .ylab("LOD score (by EM)")
                         .pointsize(1)
                         .nyticks(9)
  mychart_hk = lodchart().lodvarname("lod.hk")
                         .height(h)
                         .width(w)
                         .margin(margin)
                         .ylab("LOD score (by H-K)")
                         .linecolor("Crimson")
                         .yticks([0, 1, 2, 4, 6, 8])

  svg = d3.select("div#bottomchart")
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
