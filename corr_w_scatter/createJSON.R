# Convert data to JSON format for corr_w_scatter vis
#   - image of correlation matrix linked to scatterplots

convert4corrwscatter <-
function(dat, group, reorder=TRUE)
{
  ind <- rownames(dat)
  variables <- colnames(dat)

  if(nrow(dat) != length(group))
    stop("nrow(dat) != length(group)")
  if(!is.null(names(group)) && !all(names(group) == ind))
    stop("names(group) != rownames(dat)")

  if(reorder) {
    ord <- hclust(dist(t(dat)), method="ward")$order
    variables <- variables[ord]
    dat <- dat[,ord]
  }

  # correlation matrix
  corr <- cor(dat, use="pairwise.complete.obs")

  # get rid of names
  dimnames(corr) <- dimnames(dat) <- NULL
  names(group) <- NULL

  # data structure for JSON
  require(rjson)
  require(df2json)

  output <- list("ind" = toJSON(ind),
                 "var" = toJSON(variables),
                 "corr" = matrix2json(corr),
                 "dat" =  matrix2json(t(dat)), # columns as rows
                 "group" = toJSON(group))
  paste0("{", paste0("\"", names(output), "\" :", output, collapse=","), "}")
}

# simulated data:
#source("simData.R")
#z <- simData(n.groups=4)
#y <- convert4corrwscatter(z$x, z$group)

# real data:
load("example_data.RData")
y <- convert4corrwscatter(x, group)

cat(y, file="data.json")
