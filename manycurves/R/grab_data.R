# save the curves matrix as a JSON file
load("curves.RData")
nam <- colnames(curves)
times <- as.numeric(substr(nam, 5, nchar(nam))) # time in minutes (480 min = 8 hrs)

dimnames(curves) <- NULL

library(RJSONIO)

cat0 <- function(file, ...) cat(..., sep="", file=file)
cat0a <- function(file, ...) cat(..., sep="", file=file, append=TRUE)

file <- "../curves.json"
cat0(file, "{\n")
cat0a(file, "\"times\" : \n", toJSON(times), ",\n\n")
cat0a(file, "\"curves\" : \n", toJSON(curves), "\n\n")
cat0a(file, "}\n")

