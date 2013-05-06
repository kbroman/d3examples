# simulate matrix of data for manyboxplots2 visualization
# p arrays with n measurements in each
# pmix are mixture of two normals; rest are from a single normal

simData <-
function(p=500, n=20000, pmix=0.2, overallmean=20, meanSD=5)
{  
  means <- rnorm(p, overallmean, meanSD)
  mix <- sample(c(TRUE,FALSE), p, repl=TRUE, prob=c(pmix, 1-pmix))
  meanmix <- rnorm(sum(mix), 0, meanSD)
  x <- matrix(rnorm(p*n), ncol=p, nrow=n)
  x <- t(t(x) + means)

  whmix <- which(mix)
  for(i in seq(along=whmix)) {
    wh <- sample(1:n, rbinom(1, n, 0.5))
    x[wh,whmix[i]] <- x[wh,whmix[i]] + meanmix[i]
  }

  x
}
