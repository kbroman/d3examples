# function to convert scanone output to json format

scanone2json <-
function(output)
{
  require(rjson)

  # marker names: replace pseudomarkers with blanks
  mnames <- rownames(output)
  pmarkers <- grep("^c.+\\.loc-*[0-9]+", mnames)
  mnames[pmarkers] <- ""

  # chromosome names
  chrnames <- as.character(unique(output[,1]))

  toJSON(c(list(chrnames = chrnames), as.list(output), list(markernames = mnames)))
}
