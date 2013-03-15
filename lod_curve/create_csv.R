# R script to create a sample CSV file with LOD curve info
library(qtl)
data(hyper)
hyper <- calc.genoprob(hyper, step=1, err=0.002)
out <- scanone(hyper)
out <- cbind(marker=rownames(out), as.data.frame(out))
write.csv(out, file="lod.csv", row.names=FALSE, quote=FALSE)
