# 538 data
if(!file.exists("bad-drivers.csv"))
    system("wget https://raw.githubusercontent.com/fivethirtyeight/data/master/bad-drivers/bad-drivers.csv")
crashes <- read.csv("bad-drivers.csv")

rownames(crashes) <- crashes[,1]
crashes[,3:6] <- crashes[,3:6]*crashes[,2]/100
colnames(crashes)[-1] <- c("total", "speeding", "alcohol", "not_distracted", "no_previous", "ins_premium", "ins_losses")
