
mychart = lodChart().pointsize(0)

d3.json "scanone.json", (data) ->
  d3.select("div#chart")
    .datum(data)
    .call(mychart)
#  xscale = mychart.xscale()
#  console.log xscale[2](30)
#  lodcurve = mychart.lodcurve()
#  console.log lodcurve