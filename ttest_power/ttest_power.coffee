# code to create interactive graph demonstrating power in a two-sample t-test

# function that grabs slider value
getSliderValue = (sliderID) ->
    slider = document.getElementById(sliderID)

    if sliderID=="alpha"
        digits=Math.floor(-slider.value)+2
        return(Math.round(10**slider.value * 10**digits)/10**digits)
    else
        return(slider.value)

# function that prints slider value next to slider
printSliderValue = (sliderID) ->
    val = getSliderValue(sliderID)

    textboxID = "#{sliderID}value"
    textbox = document.getElementById(textboxID)
    textbox.value = val

# stuff for form
param =
    n:
        text: "sample size per group, <em>n</em>"
        min: 2
        max: 1000
        step: 1
        value: 100
    delta:
        text: "effect, &Delta;"
        min: 0
        max: 10
        step: 0.1
        value: 1
    sigma:
        text: "population SD, &sigma;"
        min: 0.1
        max: 10
        step: 0.1
        value: 1
    alpha:
        text: "significance level, &alpha;"
        min: -4
        max: -0.3
        step: 0.01
        value: Math.log10(0.05)

# fill out the form
for par of param
    p = d3.select("form#sliders").append("p")
    p.append("input")
     .attr("id", par)
     .attr("type", "range")
     .attr("min", param[par].min)
     .attr("max", param[par].max)
     .attr("value", param[par].value)
     .attr("step", param[par].step)
    p.append("a")
      .html(param[par].text + " = ")
    p.append("output")
      .attr("id", "#{par}value")
      .attr("for", par)

    printSliderValue(par)

# when any slider changes...
d3.select("form#sliders")
  .on("input", () ->
                   for par in ["n", "alpha", "delta", "sigma"]
                       printSliderValue(par)
                   update_plots() )

# create svg
bgcolor = "#ccc"
colors = ["slateblue", "violetred"]
npts = 500
figwidth = 500
figheight= 250

margin = {left:50,right:10, bottom:50, top:30, inner: 5}
figtotw = figwidth + margin.left + margin.right
figtoth = figheight + margin.top + margin.bottom
height = figtoth*3
width=   figtotw
svg = d3.select("div#chart")
        .append("svg")
        .attr("width", width)
        .attr("height", height)

figs = [null, null, null]
titles = ["Population distribution",
    "Distribution of sample mean",
    "Distribution of test statistic"]
short = ["pop", "samp", "stat"]
xscale = [null, null, null]
yscale = [null, null, null]
xrange = [[0,1], [0,1], [-4,8]]
yrange = [[0,1], [0,1], [0, dnorm(0, 0, 1)]]

draw_plot = (index) ->
    figs[index] = svg.append("g")
                 .attr("id", short[index])
                 .attr("transform", "translate(0,#{figtoth*index})")
                 .append("svg")
                 .attr("width", figtotw)
                 .attr("height", figtoth)

    figs[index].append("rect")
               .attr("x", margin.left)
               .attr("y", margin.top)
               .attr("height", figheight)
               .attr("width", figwidth)
               .attr("fill", bgcolor)
               .attr("stroke", "black")
               .attr("stroke-width", 2)
    figs[index].append("text")
               .text(titles[index])
               .attr("x", margin.left + figwidth/2)
               .attr("y", margin.top/2)
               .attr("dominant-baseline", "middle")
               .attr("text-anchor", "middle")

    if index==0 or index==1 # population distribution
        xrange[index] = [100-param.sigma.max*3, 100+param.delta.max+param.sigma.max*3]
        yrange[index] = [0, dnorm(0, 0, param.sigma.min)]

    xscale[index] = d3.scale.linear().clamp(true)
                            .range([margin.left, margin.left+figwidth])
                            .domain(xrange[index])
    yscale[index] = d3.scale.linear().clamp(true)
                            .range([margin.top+figheight, margin.top+margin.inner])
                            .domain(yrange[index])


for i in [0..2]
    draw_plot(i)


curve = (index) ->
    d3.svg.line()
      .x((d) -> xscale[index](d.x))
      .y((d) -> yscale[index](d.y))

update_plots = () ->
    svg.selectAll("path").remove()

    sigma = +getSliderValue("sigma")
    delta = +getSliderValue("delta")
    n = +getSliderValue("n")
    sem = sigma/Math.sqrt(n)
    df = 2*n-2

    scale4x = d3.scale.linear().domain([0,1]).range([100-sigma*6, 100+delta+sigma*6])
    x = d3.range(npts).map (i) -> scale4x(i/npts)

    yscale[0].domain([0, dnorm(0, 0, sigma)])
    yscale[1].domain([0, dnorm(0, 0, sem)])

    # curves for population distributions
    mu = [100, 100+delta]
    for i of mu
        data = []
        for j of x
            data.push({x:x[j], y:dnorm(x[j], mu[i], sigma)})

        figs[0].append("path")
               .datum(data)
               .attr("d", curve(0))
               .attr("fill", "none")
               .attr("stroke", colors[i])
               .attr("stroke-width", 2)

    scale4x = d3.scale.linear().domain([0,1]).range([100-sem*6, 100+delta+sem*6])
    x = d3.range(npts).map (i) -> scale4x(i/npts)

    # curves for sampling distributions
    for i of mu
        data = []
        for j of x
            data.push({x:x[j], y:dnorm(x[j], mu[i], sem)})

        figs[1].append("path")
               .datum(data)
               .attr("d", curve(1))
               .attr("fill", "none")
               .attr("stroke", colors[i])
               .attr("stroke-width", 2)

    scale4x = d3.scale.linear().domain([0,1]).range([-4, 8])
    x = d3.range(npts).map (i) -> scale4x(i/npts)

    data = []
    for j of x
        data.push({x:x[j], y:dt(x[j], df)})

    figs[2].append("path")
           .datum(data)
           .attr("d", curve(2))
           .attr("fill", "none")
           .attr("stroke", "black")
           .attr("stroke-width", 2)

update_plots()

# test statistic, null and alternative
