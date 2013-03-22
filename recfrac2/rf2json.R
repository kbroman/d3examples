######################################################################
# rf2json.R
#
# pull recombination fractions from a cross object and write to
# a JSON file, for later plotting using D3
######################################################################

rf2json <-
function(cross, chr, file = "rf.json")
{
  if(!missing(chr)) cross <- cross[chr,]

  if(!("rf" %in% names(cross))) {
    warning("First running est.rf().")
    cross <- est.rf(cross)
  }

  rf <- cross$rf

  # marker and numeric indices
  mnames <- markernames(cross)
  index <- 1:length(mnames)-1

  # turn into JSON-type string
  mnames <- paste("\"marker\":\"", mnames, "\",", sep="")
  index <- paste("\"index\":", index, sep="")
  markers <- paste("[", paste(paste("{", mnames, index, "}", sep=""), collapse=",\n    "), "]")

  # chromosome names, lo and high indices
  chrnames <- names(cross$geno)
  n.mar <- nmar(cross)
  lo <- cumsum(c(1,nmar(cross)))[1:nchr(cross)]-1
  hi <- cumsum(c(0,nmar(cross)))[-1]-1

  # turn into JSON-type string
  chrnames <- paste("\"chr\":\"", chrnames, "\",", sep="")
  n.mar <- paste("\"nmar\":", n.mar, ",", sep="")
  lo <- paste("\"lo\":", lo, ",", sep="")
  hi <- paste("\"hi\":", hi, sep="")
  chr <- paste("[", paste(paste("{", chrnames, n.mar, lo, hi, "}", sep=""), collapse=",\n    "), "]")

  # turn rec fracs into JSON-type string
  value <- as.character(rf)
  value[is.na(value) | value == "NaN"] <- "null"
  value <- paste("\"value\":", value, sep="")
  rowindex <- paste("\"row\":", row(rf)-1, ",", sep="")
  colindex <- paste("\"col\":", col(rf)-1, ",", sep="")
  rf <- paste("[", paste(paste("{", rowindex, colindex, value, "}", sep=""), collapse=",\n    "), "]")

  cat("{\"markers\":", markers, ",\n",
      "\"chr\":", chr, ",\n",
      "\"rf\":", rf, "}\n", file=file, sep="")
}
