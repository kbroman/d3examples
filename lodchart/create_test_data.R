# create test data in JSON format

library(qtl)
data(hyper)
hyper <- calc.genoprob(hyper, step=1)
out.em <- scanone(hyper, chr=1:6)
out.hk <- scanone(hyper, chr=1:6, method="hk")
out <- cbind(out.em, out.hk, labels=c("em", "hk"))

source("scanone2json.R")
cat(scanone2json(out), file="scanone.json")
