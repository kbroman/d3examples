Interactive cis-trans eQTL plot
----------------------------------------------------------------------

See it in action [here](http://www.biostat.wisc.edu/~kbroman/D3/cistrans).

In top figure, x-axis corresponds to marker location, y-axis is
genomic position of probes on a gene expression microarray Each
plotted point is an inferred eQTL with LOD > 10; opacity corresponds
to LOD score, though all LOD > 25 are made fully opaque.

Hover over a point to see probe ID and LOD score; also highlighted
are any other eQTL for that probe.  Click on the point to see LOD
curves below.

If a clicked probe is in known gene, title in lower plot is a link
to the Mouse Genome Informatics (MGI) site at the Jackson Lab.

Hover over markers in LOD curve plot to view marker names; click on
a marker to see the phenotype-vs-genotype plot to right.  In
geno-vs-pheno plot, hover over average to view value, and hover over
points to view individual IDs.

