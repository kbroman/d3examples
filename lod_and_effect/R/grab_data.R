# Get LOD curves and effect plot info for 10 wk insulin
# and convert to JSON file for interactive graph

attach("aligned_geno_with_pmap.RData")
attach("lipomics_final_rev2.RData")

phenotype <- "log10 Insulin (ng/ml) 10 wk"

library(lineup)
id <- findCommonID(f2g$pheno$MouseNum, lipomics$MouseNum)
f2g <- f2g[,id$first]
lipomics <- lipomics[id$second,]
f2g <- calc.genoprob(f2g, step=0.5, stepwidth="max", error.prob=0.002, map.function="c-f")
f2g$pheno$insulin <- log10(rowMeans(lipomics[,c(37,41)], na.rm=TRUE))

# genome scan with sex as interactive covariate
sex <- as.numeric(f2g$pheno$Sex)-1
out <- scanone(f2g, phe="insulin", addcovar=sex, intcovar=sex, method="hk")

f2g <- sim.geno(f2g, step=0, error.prob=0.002, map.function="c-f", n.draws=128)
mar <- markernames(f2g)

library(parallel)
ncores <- detectCores()
qtleffects <- mclapply(mar, function(a) effectplot(f2g, phe="insulin", mname1="Sex",
                                                   mname2=a, draw=FALSE), mc.cores=ncores)

for(i in seq(along=qtleffects)) {
  qtleffects[[i]]$Means <- lapply(as.list(as.data.frame(qtleffects[[i]]$Means)), function(a) {names(a) <- c("Female", "Male"); a})
  qtleffects[[i]]$SEs <- lapply(as.list(as.data.frame(qtleffects[[i]]$SEs)), function(a) {names(a) <- c("Female", "Male"); a})
  nam <- names(qtleffects[[i]]$Means)
  nam <- sapply(strsplit(nam, "\\."), function(a) a[2])
  names(qtleffects[[i]]$Means) <- names(qtleffects[[i]]$SEs) <- nam
}

# marker index within lod curves
map <- pull.map(f2g)
outspl <- split(out, out[,1])
mar <- map
for(i in seq(along=map)) {
  mar[[i]] <- match(names(map[[i]]), rownames(outspl[[i]]))-1
  names(mar[[i]]) <- names(map[[i]])
}
markers <- lapply(mar, names)

phevals <- f2g$pheno$insulin
f2gi <- pull.geno(fill.geno(f2g, err=0.002, map.function="c-f"))
g <- pull.geno(f2g)
f2gi[is.na(g) | f2gi != g] <- -f2gi[is.na(g) | f2gi != g]
f2gi <- as.list(as.data.frame(f2gi))
individuals <- as.character(f2g$pheno$MouseNum)

# write data to JSON file
library(RJSONIO)
cat0 <- function(...) cat(..., sep="", file="../insulinlod.json")
cat0a <- function(...) cat(..., sep="", file="../insulinlod.json", append=TRUE)
cat0("{\n")
cat0a("\"phenotype\" : \"", phenotype, "\",\n\n")
cat0a("\"chr\" :\n", toJSON(chrnames(f2g)), ",\n\n")
cat0a("\"lod\" :\n", toJSON(lapply(split(out, out[,1]), function(a) as.list(a[,2:3])), digits=8), ",\n\n")
cat0a("\"markerindex\" :\n", toJSON(mar), ",\n\n")
cat0a("\"markers\" :\n", toJSON(markers), ",\n\n")
cat0a("\"effects\" :\n", toJSON(qtleffects, digits=8), ",\n\n")
cat0a("\"phevals\" :\n", toJSON(phevals, digits=8), ",\n\n")
cat0a("\"sex\" :\n", toJSON(sex), ",\n\n")
cat0a("\"geno\" :\n", toJSON(f2gi), ",\n\n")
cat0a("\"individuals\" :\n", toJSON(individuals), "\n\n")
cat0a("}\n")
