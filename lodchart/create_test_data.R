# create test data in JSON format

library(qtl)
data(hyper)
hyper <- calc.genoprob(hyper, step=1)
out <- scanone(hyper, chr=1:6)

source("scanone2json.R")
cat(scanone2json(out), file="scanone.json")
