library(lineup)
load("~/Projects/Attie/GoldStandard/FinalData/aligned_geno_with_pmap.RData")
load("~/Projects/Attie/GoldStandard/FinalData/islet_mlratio_final.RData")
id <- findCommonID(f2g$pheno$MouseNum, rownames(islet.mlratio))
f2g <- calc.genoprob(f2g[,id$first], step=0.5, stepwidth="max",
                     err=0.002, map.function="c-f")
islet.mlratio <- islet.mlratio[id$second,]
markers <- c("rs3024135", "rs8262456", "rs13479085", "rs13479086")
markerpos <- f2g$geno[["6"]]$map[markers]
markerpos.Mbp <- pmap[["6"]][markers]

load("~/Projects/Attie/GoldStandard/AnnotAmit/annot.amit_rev.RData")
haspos <- annot$a_gene_id[!is.na(annot$pos.Mb)]
load("~/Projects/Attie/GoldStandard/Scanone_expr/maxlod/islet/maxlod.islet.RData")
lod <- maxlod.islet$maxlod[6,]
pos <- maxlod.islet$maxlod.pos[[6]]
m <- !is.na(match(names(lod), haspos))
lod <- lod[m]
pos <- pos[m]
chr <- annot$chr[match(names(lod), annot$a_gene_id)]
probes <- names(pos[pos >= markerpos[2] & pos <= markerpos[3] & lod > 100 & chr != 6])
pc <- cmdscale(dist(islet.mlratio[,probes]))
qtlg <- 4-as.numeric(cut(pc[,1], c(-Inf, -1, 1, Inf)))
names(qtlg) <- as.character(f2g$pheno$MouseNum)

probes <- sample(names(pos[pos >= markerpos[2] & pos <= markerpos[3] & lod > 25 & chr != 6]), 100)
x <- islet.mlratio[,probes]
group <- qtlg
colnames(x) <- paste0("gene", 1:ncol(x))
rownames(x) <- names(group) <- paste0("ind", 1:nrow(x))
save(x, group, file="example_data.RData")
