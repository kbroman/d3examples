# create JSON file with car crash data
# (from http://fivethirtyeight.com/datalab/which-state-has-the-worst-drivers/)

# read data (read off figs by hand, with a ruler)
source("data.R")

# convert to json format
library(jsonlite)

crashes$state <- rownames(crashes)
rownames(crashes) <- 1:nrow(crashes)
crashes$rank <- rank(crashes$total, ties.method="first")
cat(toJSON(crashes, dataframe="columns"), file="data.json")
