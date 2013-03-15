# grab the lod curves for each probe
# also grab the mlratios for each probe
#
# write a JSON file for each probe...though there's a lot of them!
rm(list=ls())
minlod = 10

# annotation information
attach("annot.amit_rev.RData")
annot <- annot[!is.na(annot$chr) & !is.na(match(annot$chr, c(1:19, "X"))),]

# maximum LOD for each probe on each chromosome and where it occurred
attach("maxlod.islet.RData")
# probes with LOD >= minlod
haspeak <- colnames(maxlod.islet$maxlod)[apply(maxlod.islet$maxlod, 2, max, na.rm=TRUE) >= minlod]
haspeak <- haspeak[!is.na(match(haspeak, annot$a_gene_id))]

# load phenotype data and scanone results
# create one JSON file for each probe with a peak
load("islet_mlratio_final.RData")
islet.mlratio <- islet.mlratio[,haspeak]

load("scanone.islet.RData")
scan.islet <- scan.islet[,haspeak]

# line up phenotypes and genotypes
attach("aligned_geno_with_pmap.RData")
library(lineup)
id <- findCommonID(f2g$pheno$MouseNum, rownames(islet.mlratio))
f2g <- f2g[,id$first]
islet.mlratio <- islet.mlratio[id$second,]

library(RJSONIO)
cat0 <- function(file, ...) cat(..., sep="", file=file)
cat0a <- function(file, ...) cat(..., sep="", file=file, append=TRUE)

# function to write lod curve and mlratios to file
f <-
function(i) {
  probe <- colnames(islet.mlratio)[i]
  file <- paste0("../data/probe_data/probe", probe, ".json")
  cat0(file, "{\n")
  cat0a(file, "\"probe\" : \"", probe, "\",\n\n")
  cat0a(file, "\"pheno\" : \n")
  cat0a(file, toJSON(as.numeric(islet.mlratio[,i]), digits=6), ",\n\n")
  cat0a(file, "\"lod\" : \n")
  cat0a(file, toJSON(round(as.numeric(scan.islet[,probe]), 5), digits=8), "\n\n")
  cat0a(file, "}\n")
}

# write LOD curves and phenotypes to files
library(parallel)
junk <- mclapply(1:ncol(islet.mlratio), f, mc.cores=32)

