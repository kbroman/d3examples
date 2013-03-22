# Convert data for hypo expression arrays to JSON file with
#   - quantiles for boxplot-like figure
#   - counts for histograms

load("F2.mlratio.hypo.RData")
# hypo.mlratio is dimension 40572 (transcripts) x 494 (mice)

# calculate quantiles
qu <- c(0.01, 0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95, 0.99)
quant <- apply(hypo.mlratio, 2, quantile, qu, na.rm=TRUE)
ord <- rev(order(quant[5,])) # ordered array indices, by array medians

## the many boxplots figure
#plot(quant[5,ord], type="l", lwd=2, ylim=c(-1, 1))
#for(i in 1:4) {
#  lines(quant[i,ord], col=c("blue", "green", "red", "orange")[i])
#  lines(quant[10-i,ord], col=c("blue", "green", "red", "orange")[i])
#}

## a portion of the boxplots
#boxplot(hypo.mlratio[,ord[seq(1, length(ord), by=5)]], outline=FALSE, las=2)

# counts for histograms
br <- seq(-2, 2, len=401)
counts <- apply(hypo.mlratio, 2, function(a) hist(a, breaks=br, plot=FALSE)$counts)

mice <- colnames(hypo.mlratio)
mice.ordered <- mice[ord]

# write data to JSON file
library(RJSONIO)
cat0 <- function(...) cat(..., sep="", file="../hypo.json")
cat0a <- function(...) cat(..., sep="", file="../hypo.json", append=TRUE)
cat0("{\"ind\" : \n", toJSON(mice.ordered), ",\n\n")
cat0a("\"qu\" :\n", toJSON(qu), ",\n\n")
cat0a("\"br\" :\n", toJSON(br), ",\n\n")
cat0a("\"quant\" :\n", toJSON(quant), ",\n\n")
cat0a("\"counts\" :\n", toJSON(as.list(as.data.frame(counts))), "\n")
cat0a("}\n")
