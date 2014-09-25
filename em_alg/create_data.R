library(qtl)

# load hyper data; drop some markers from chromosome 1
data(hyper)
hyper <- drop.markers(hyper, markernames(hyper, chr=1)[c(4,5,7,8,14,15,16,17,18,19,20)])
hyper <- calc.genoprob(hyper, step=1, err=0.002)
y <- hyper$pheno[,1]

# genotype probabilities at a pseudomarker not far from peak
pmar <- find.pseudomarker(hyper, 1, 78.7, "prob")
pmar <- strsplit(pmar, "\\.")[[1]][2]
p <- hyper$geno[[1]]$prob[,pmar,]
p0 <- p[,2]

# functions to do EM alg and calculate LOD score
do_mstep <-
function(p, y)
{
    mu <- c(AA=sum((1-p)*y)/sum(1-p), AB=sum(p*y)/sum(p))
    sig <- sqrt(sum((1-p)*(y-mu[1])^2 + p*(y-mu[2])^2)/length(y))
    c(mu, sig)
}

calc_lod <-
function(p, y, theta)
{
    ll0 <- sum(log10(dnorm(y, mean(y), sqrt(sum((y-mean(y))^2)/length(y)))))

    q1 <- (1-p)*dnorm(y, theta[1], theta[3])
    q2 <- p*dnorm(y, theta[2], theta[3])

    sum(log10(q1+q2))-ll0
}

do_estep <-
function(p, y, theta)
{
    q1 <- (1-p)*dnorm(y, theta[1], theta[3])
    q2 <- p*dnorm(y, theta[2], theta[3])
    q2/(q1+q2)
}

# do 100 iterations of EM and save all of the results
n_iter <- 100
theta <- matrix(ncol=3, nrow=n_iter)
p <- matrix(ncol=length(p0), nrow=n_iter)
lod <- rep(NA, ncol=n_iter)

p[1,] <- p0
for(i in 1:n_iter) {
    theta[i,] <- do_mstep(p[i,], y)
    lod[i] <- calc_lod(p0, y, theta[i,])
    if(i < n_iter)
        p[i+1,] <- do_estep(p0, y, theta[i,])
}

# save as json file
library(jsonlite)
cat(toJSON( list(y=y, p=p, theta=theta, lod=lod) ), file="data.json")
