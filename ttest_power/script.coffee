# code to create

# function that prints slider value next to slider
printSliderValue = (sliderID) ->
    textboxID = "#{sliderID}value"

    textbox = document.getElementById(textboxID)
    slider = document.getElementById(sliderID)

    if sliderID=="alpha"
        digits=Math.floor(-slider.value)+2
        textbox.value = Math.round(10**slider.value * 10**digits)/10**digits
    else
        textbox.value = slider.value

# stuff for form
param =
    n:
        text: "sample size, <em>n</em>"
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
  .on("change", () ->
                   for par in ["n", "alpha", "delta", "sigma"]
                       printSliderValue(par))
