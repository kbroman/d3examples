# Convert data for large matrix to JSON format for manyboxplots vis
#   - quantiles for boxplot-like figure
#   - counts for histograms

convert4manyboxplots2 <-
function(dat, qu = c(0.001, 0.01, 0.1, 0.25), orderByMedian=TRUE,
         breaks=251)
{
  if(is.null(colnames(dat)))
    colnames(dat) <- paste0(1:ncol(dat))

  if(orderByMedian)
    dat <- dat[,order(apply(dat, 2, median, na.rm=TRUE))]

  # check quantiles
  if(any(qu <= 0)) {
    warning("qu should all be > 0")
    qu <- qu[qu > 0]
  }

  if(any(qu >= 0.5)) {
    warning("qu should all by < 0.5")
    qu <- qu[qu < 0.5]
  }

  qu <- c(qu, 0.5, rev(1-qu))
  quant <- apply(dat, 2, quantile, qu, na.rm=TRUE)

  # counts for histograms
  if(length(breaks) == 1)
    breaks <- seq(floor(min(dat)), ceiling(max(dat)), length=breaks)

  counts <- apply(dat, 2, function(a) hist(a, breaks=breaks, plot=FALSE)$counts)

  ind <- colnames(dat)

  dimnames(quant) <- dimnames(counts) <- NULL

  # data structure for JSON
  require(rjson)
  require(df2json)
  output <- list("ind" = toJSON(ind),
                 "qu" = toJSON(qu),
                 "breaks" = toJSON(breaks),
                 "quant" = matrix2json(quant),
                 "counts" = matrix2json(t(counts)))
  paste0("{", paste0("\"", names(output), "\" :", output, collapse=","), "}")
}
