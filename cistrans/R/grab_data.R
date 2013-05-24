# grab data for interactive cistrans plot
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

# subset: just probes with LOD >= minlod
ml.islet <-
  list(lod = maxlod.islet$maxlod[,haspeak],
       pos = maxlod.islet$maxlod[,haspeak])
for(i in 1:20)
  ml.islet$pos[i,] <- maxlod.islet$maxlod.pos[[i]][haspeak]

# data frame with peaks >= minlod and where they occurred
wh <- which(ml.islet$lod >= minlod)
peaks <- data.frame(a_gene_id=colnames(ml.islet$lod)[col(ml.islet$lod)[wh]],
                    lod = ml.islet$lod[wh],
                    chr = c(1:19,"X")[row(ml.islet$lod)[wh]],
                    pos = ml.islet$pos[wh],
                    stringsAsFactors=FALSE)

attach("aligned_geno_with_pmap.RData")
gmap <- pull.map(f2g)

# determine corresponding physical location
peaks$pos_Mbp <- interpPositions(peaks[,c("chr", "pos")], gmap, pmap)$newpos
names(peaks)[4] <- "pos_cM"

# annotation information just for probes with LOD >= 5
annot <- annot[!is.na(match(annot$a_gene_id, haspeak)),]
annot <- annot[,c("a_gene_id", "chr", "pos.Mb", "pos.cM", "officialgenesymbol")]
names(annot)[3:5] <- c("pos_Mbp", "pos_cM", "gene")

# ensembl URL for a gene; same for MGI
# http://www.ensembl.org/Mus_musculus/Search/Details?db=core;end=1;idx=Gene;species=Mus_musculus;q=Zswim7
# http://www.informatics.jax.org/searchtool/Search.do?query=Zswim7

# load phenotype data and scanone results
# create one JSON file for each probe with a peak
attach("islet_mlratio_final.RData")

# line up phenotypes and genotypes
library(lineup)
id <- findCommonID(f2g$pheno$MouseNum, rownames(islet.mlratio))
f2g <- f2g[,id$first]
islet.mlratio <- islet.mlratio[id$second,]

tmp <- data.frame(start_cM = sapply(gmap, min),
                  end_cM = sapply(gmap, max),
                  start_Mbp = sapply(pmap, min),
                  end_Mbp = sapply(pmap, max))
chr <- vector("list", nrow(tmp))
for(i in seq(along=chr))
    chr[[i]] <- as.list(tmp[i,])
names(chr) <- names(gmap)

# simple scan to grab pseudo marker locations
f2g <- calc.genoprob(f2g, step=0.5, stepwidth="max", err=0.002, map="c-f")
pmark <- scanone(f2g, phe=1:nind(f2g), method="hk")[,1:2]

pmarknames <- split(rownames(pmark), pmark[,1])

class(pmark) <- "data.frame"
tmp <- interpPositions(pmark, gmap, pmap)
names(tmp) <- c("chr", "pos_cM", "pos_Mbp")
pmark <- vector("list", nrow(tmp))
names(pmark) <- rownames(tmp)
for(i in seq(along=pmark))
    pmark[[i]] <- as.list(tmp[i,])


tmp <- peaks
names(tmp)[1] <- "probe"
peaks <- vector("list", nrow(tmp))
for(i in seq(along=peaks))
    peaks[[i]] <- as.list(tmp[i,])

rownames(annot) <- annot[,1]
annot <- annot[,-1]
annot$chr <- as.character(annot$chr)
annot$gene <- as.character(annot$gene)
probes <- vector("list", nrow(annot))
for(i in seq(along=probes))
    probes[[i]] <- as.list(annot[i,])
names(probes) <- rownames(annot)

sex <- as.numeric(f2g$pheno$Sex)-1
f2gi <- pull.geno(fill.geno(f2g, err=0.002, map.function="c-f"))
g <- pull.geno(f2g)
f2gi[is.na(g) | f2gi != g] <- -f2gi[is.na(g) | f2gi != g]
f2gi <- as.list(as.data.frame(f2gi))
individuals <- as.character(f2g$pheno$MouseNum)


library(RJSONIO)
cat0 <- function(file, ...) cat(..., sep="", file=file)
cat0a <- function(file, ...) cat(..., sep="", file=file, append=TRUE)

file <- "../data/islet_eqtl.json"
cat0(file, "{\n")
cat0a(file, "\"markers\" : \n", toJSON(markernames(f2g)), ",\n\n")
cat0a(file, "\"chrnames\" : \n", toJSON(names(chr)), ",\n\n")
cat0a(file, "\"chr\" : \n", toJSON(chr), ",\n\n")
cat0a(file, "\"pmarknames\" : \n", toJSON(pmarknames), ",\n\n")
cat0a(file, "\"pmark\" : \n", toJSON(pmark), ",\n\n")
cat0a(file, "\"probes\" : \n", toJSON(probes), ",\n\n")
cat0a(file, "\"peaks\" : \n", toJSON(peaks), ",\n\n")
cat0a(file, "\"sex\" :\n", toJSON(sex), ",\n\n")
cat0a(file, "\"geno\" :\n", toJSON(f2gi), ",\n\n")
cat0a(file, "\"individuals\" :\n", toJSON(individuals), "\n\n")
cat0a(file, "}\n")

for(i in 1:4) detach(2)
