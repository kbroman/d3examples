### Reusable LOD score chart

Here, I'm trying to create a reusable chart for plotting LOD curves
across a genome.  I'm following
[Mike Bostock](http://bost.ocks.org/mike)'s
[Towards Reuseable Charts](http://bost.ocks.org/mike/chart/).

- lodChart makes the basic chart (frame and axes and such)

  - width
  - height
  - pad = {bottom, left, top, right} padding around figure
  - axispos = {xlabel, xtitle, ylabel, ytitle}: positions of axis
    title and labels
  - darkrect and lightrect: colors for alternating chromosomes
  - ylim: y-axis limits
  - nyticks = no. ticks on y-axis
  - yticks = vector of actual y-axis ticks
  - chrGap = gap (in pixels) between chromosomes
  - pointcolor color of points at markers
  - pointsize size of points at markers (in pixels)
  - linecolor color of LOD curves
  - linewidth width of LOD curves

