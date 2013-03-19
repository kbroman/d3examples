# Grab LOD curves for all time points 
# plus phenotype and genotype data
# and convert to JSON file for interactive graph

# load R/qtl package
library(qtl)

# load phenotype and genotype data
load("spal.RData")

# load scanone results, each time point considered individually
load("out.RData")

# times (in minutes)
times <- as.numeric(substr(phenames(spal), 2, nchar(phenames(spal))))

# genetic map at which LOD scores were calculated
map <- lapply(spal$geno, function(a) attr(a$prob, "map"))
for(i in seq(along=map)) {
  nam <- names(map[[i]])
  g <- grep("^loc[0-9]*$", nam)
  nam[g] <- paste0("c", i, ".", nam[g])
  names(map[[i]]) <- nam
}

# pseudomarker indices, for even spacing (every cM)
tmp <- split(cbind(as.data.frame(out[,1:2]), (1:nrow(out))-1), out[,1])
evenpmarindex <- lapply(tmp, function(a) a[match(seq(0, max(a[,2]), by=1), a[,2]),ncol(a),drop=FALSE])
evenpmarindex <- lapply(evenpmarindex, function(a) { b <- unlist(a); names(b) <- rownames(a); b})
evenpmar <- unlist(lapply(evenpmarindex, names))
names(evenpmar) <- NULL
evenpmarindex <- unlist(evenpmarindex)
names(evenpmarindex) <- evenpmar

# all pseudomarkers
allpmar <- lapply(map, names)
pmarindex <- (1:length(unlist(allpmar)))-1
names(pmarindex) <- unlist(allpmar)

# imputed genotypes at evenly spaced pseudomarkers
gi <- pull.draws(sim.geno(spal, err=0.002, map.function="kosambi", n.draws=1, step=1))[,unlist(evenpmarindex)+1,1]

# lod scores
lod <- as.matrix(out[-(1:2)])
dimnames(lod) <- NULL

# phenotypes
pheno <- as.matrix(spal$pheno)

# phenotype averages for the two genotype groups, position by position
ave1 <- ave2 <- matrix(nrow=ncol(gi), ncol=ncol(pheno))
for(i in 1:ncol(gi)) {
  ave1[i,] <- colMeans(pheno[gi[,i]==1,])
  ave2[i,] <- colMeans(pheno[gi[,i]==2,])
}

# SE of difference
se <- ave1
for(i in 1:ncol(gi))
  se[i,] <- sqrt(apply(pheno[gi[,i]==1,], 2, function(a) var(a)/length(a)) +
                 apply(pheno[gi[,i]==2,], 2, function(a) var(a)/length(a)))

# write data to JSON file
library(RJSONIO)
cat0 <- function(...) cat(..., sep="", file="../Data/all_lod.json")
cat0a <- function(...) cat(..., sep="", file="../Data/all_lod.json", append=TRUE)
cat0("{\n")
cat0a("\"chr\" :\n", toJSON(chrnames(spal)), ",\n\n")
cat0a("\"map\" :\n", toJSON(map, digits=10), ",\n\n")
cat0a("\"allpmar\" :\n", toJSON(allpmar), ",\n\n")
cat0a("\"evenpmar\" :\n", toJSON(evenpmar), ",\n\n")
cat0a("\"pmarindex\" :\n", toJSON(pmarindex), ",\n\n")
cat0a("\"times\" :\n", toJSON(times), ",\n\n")
cat0a("\"lod\" :\n", toJSON(lod), ",\n\n")
cat0a("\"ave1\" :\n", toJSON(ave1), ",\n\n")
cat0a("\"ave2\" :\n", toJSON(ave2), ",\n\n")
cat0a("\"se\" :\n", toJSON(se), "\n\n")
cat0a("}\n")
