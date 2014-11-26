## Comparison of SVG and canvas for plots with _many_ points

Each subdirectory contains a version of a plot with 100,000 points:

- [SVG version](svg) - see it in action
[here](https://www.biostat.wisc.edu/~kbroman/D3/manypoints/svg)
- [canvas version, highlight overlapped points](canvas_all) - see it in action
[here](https://www.biostat.wisc.edu/~kbroman/D3/manypoints/canvas_all)
- [canvas version, highlight closest point](canvas_closest) - see it in action
[here](https://www.biostat.wisc.edu/~kbroman/D3/manypoints/canvas_closest)

SVG is pretty sluggish; canvas is slow to load but more responsive
since I'm not repainting the entire canvas but just individual circles
on mouse over/out.
