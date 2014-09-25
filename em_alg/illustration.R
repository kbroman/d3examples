# static illustration (in R) to give me a sense of what I'm doing

library(qtl)
library(broman)

data(hyper)
hyper <- drop.markers(hyper, markernames(hyper, chr=1)[c(4,5,7,8,14,15,16,17,18,19,20)])
hyper <- calc.genoprob(hyper, step=1, err=0.002)
y <- hyper$pheno[,1]
out <- scanone(hyper)

pmar <- find.pseudomarker(hyper, 1, 78.7, "prob")
pmar <- strsplit(pmar, "\\.")[[1]][2]
p <- hyper$geno[[1]]$prob[,pmar,]
p0 <- p[,2]

par(ask=TRUE)
grayplot(p0, y,
         xlab="Pr(AB | data)", ylab="Phenotype", las=1,
         pch=21, bg="violetred",
         xlim=c(-0.1, 1.1))

mstep <-
function(p, y)
{
    mu <- c(AA=sum((1-p)*y)/sum(1-p), AB=sum(p*y)/sum(p))
    sig <- sqrt(sum((1-p)*(y-mu[1])^2 + p*(y-mu[2])^2)/length(y))
    c(mu, sig)
}

theta0 <- mstep(p0, y)
segments(0:1-0.05, theta0[1:2], 0:1+0.05, theta0[1:2],
         lwd=4, col="slateblue")

loglik <-
function(p, y, theta)
{
    ll0 <- sum(log10(dnorm(y, mean(y), sqrt(sum((y-mean(y))^2)/length(y)))))

    q1 <- (1-p)*dnorm(y, theta[1], theta[3])
    q2 <- p*dnorm(y, theta[2], theta[3])

    sum(log10(q1+q2))-ll0
}

title(main=paste0("iter ", 1, "; LOD = ", myround(loglik(p0, y, theta0), 2)))

estep <-
function(p, y, theta)
{
    q1 <- (1-p)*dnorm(y, theta[1], theta[3])
    q2 <- p*dnorm(y, theta[2], theta[3])
    q2/(q1+q2)
}

p1 <- estep(p0, y, theta0)
grayplot(p1, y,
         xlab="Pr(AB | data)", ylab="Phenotype", las=1,
         pch=21, bg="violetred",
         xlim=c(-0.1, 1.1))

theta1 <- mstep(p1, y)
segments(0:1-0.05, theta1[1:2], 0:1+0.05, theta1[1:2],
         lwd=4, col="slateblue")
title(main=paste0("iter ", 2, "; LOD = ", myround(loglik(p0, y, theta1), 2)))

###

p2 <- estep(p0, y, theta1)
grayplot(p2, y,
         xlab="Pr(AB | data)", ylab="Phenotype", las=1,
         pch=21, bg="violetred",
         xlim=c(-0.1, 1.1))

theta2 <- mstep(p2, y)
segments(0:1-0.05, theta2[1:2], 0:1+0.05, theta2[1:2],
         lwd=4, col="slateblue")
title(main=paste0("iter ", 3, "; LOD = ", myround(loglik(p0, y, theta2), 2)))

###

theta <- theta2

i <- 4
while(1) {
    p3 <- estep(p0, y, theta)
    grayplot(p3, y,
             xlab="Pr(AB | data)", ylab="Phenotype", las=1,
             pch=21, bg="violetred",
             xlim=c(-0.1, 1.1))

    theta <- mstep(p3, y)
    segments(0:1-0.05, theta[1:2], 0:1+0.05, theta2[1:2],
             lwd=4, col="slateblue")
    title(main=paste0("iter ", i, "; LOD = ", myround(loglik(p0, y, theta), 2)))
    i <- i + 1
}
