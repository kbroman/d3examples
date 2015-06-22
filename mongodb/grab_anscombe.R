# grab anscombe's quartet (from wikipedia page) and create JSON file

# read web page
url <- "https://en.wikipedia.org/wiki/Anscombe's_quartet"
library(curl)
con <- curl(url)
the_text <- readLines(con)
close(con)

# grab table
the_table <- XML::readHTMLTable(the_text)[[2]][-1,]

# turn into list of columns, as numbers
the_table <- lapply(the_table, function(a) as.numeric(as.character(a)))
n <- length(the_table[[1]])

# convert to list of data sets
anscombe <- vector("list", 4)
names(anscombe) <- list("I", "II", "III", "IV")
for(i in 1:4) {
    anscombe[[i]] <- vector("list", n)
    for(j in 1:n) { # unbox to insure x and y are scalars
        anscombe[[i]][[j]] <- list(x=jsonlite::unbox(the_table[[i*2-1]][j]),
                                   y=jsonlite::unbox(the_table[[i*2]][j]))
    }
}

# write to file
cat(jsonlite::toJSON(anscombe), file="anscombe_quartet.json")
