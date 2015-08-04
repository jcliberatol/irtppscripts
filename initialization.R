
items = c(20, 50, 100)
individuals = 1000
s_reps = 200
s_function = rep(c("f_mirt","f_sics"),3)

scenarios = cbind.data.frame(items,individuals,s_reps,s_function)





scenarios
library(rmongodb)
mongo = mongo.create(host = "localhost",db="irtpptest")
mongo.is.connected(mongo)
##Load the mongo file
source(file="/home//liberato/git/irtppscripts/mongo.R")
scenario.insert(connection=mongo,scenarios,db="irtpptest")
