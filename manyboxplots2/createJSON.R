set.seed(5831936)
source("simData.R")
source("convert4manyboxplots2.R")

x <- simData()
y <- convert4manyboxplots2(x)
cat(y, file="data.json")
