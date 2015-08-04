source(file="/home//liberato/git/irtppscripts/mongo.R")
source(file="/home//liberato/git/irtppscripts/auxfunc.R")
library(rmongodb)
mongo = mongo.create(host = "localhost",db="irtpptest")
mongo.is.connected(mongo)

scenarios.run(connection=mongo,db="irtpptest",scenario.collection="scenarios",out.collection="out")