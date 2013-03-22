# write logs likelihood to json file

# load data
#   nll = nicola's log likelihoods
#   kll = karl's log likelihoods
#     [each a list with components being matrices with log likelihood values]
#   m = vector of values for parameter m
#   p = vector of values for parameter p
load("all_loglik.RData")

# save the curves matrix as a JSON file
library(RJSONIO)

file <- "../loglik.json"
cat0 <- function(file, ...) cat(..., sep="", file=file)
cat0a <- function(file, ...) cat(..., sep="", file=file, append=TRUE)

cat0(file, "{\n")
cat0a(file, "\"m\" : \n", toJSON(m), ",\n\n")
cat0a(file, "\"p\" : \n", toJSON(p), ",\n\n")
cat0a(file, "\"nll\" : \n", toJSON(nll), ",\n\n")
cat0a(file, "\"kll\" : \n", toJSON(kll), "\n\n")
cat0a(file, "}\n")


