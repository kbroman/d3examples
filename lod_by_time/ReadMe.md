Single-QTL scans for phenotype over time
----------------------------------------------------------------------

See it in action [here](http://www.biostat.wisc.edu/~kbroman/d3/lod_by_time).

Here we consider a phenotype measured over time, and perform QTL
analysis with each time point individually, to seek genetic loci that
affect the response.  The data concern a set of 162 recombinant inbred
lines.

The top-left plot is a &ldquo;heat map&rdquo; of the LOD scores
for each time point at each genomic position.  LOD scores are also
colored to indicate the sign of the QTL effect, with red indicating
that BB lines have larger phenotype values and blue indicating that AA lines
have larger phenotype values.  We consider only those (position, time)
pairs with LOD > 1.

When you hover over a point in the top-left plot, the LOD curves for the
corresponding time are shown below, and the phenotype averages and
estimated QTL effect (across time) for the corresponding genomic
position are shown to the right.

Click on a point to show pointwise confidence bands on the QTL
effect (&pm; 2 SE).  (We require a mouse click, as otherwise the graph
was painfully slow to refresh.)
