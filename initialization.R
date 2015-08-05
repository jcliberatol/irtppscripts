library(IRTpp)

## Small scenarios
#models = c("1PL","2PL","3PL")
#items = c(20, 50, 100)
#individuals = c(1000,10000,100000)
models = c("1PL","2PL","3PL")
items = c(20,50)
individuals = c(1000,10000)
s_reps = 10
s_function = c("f_mirt","f_sics")

scn = do.call(rbind,lapply(models,function(model)cbind(items,model)))
scn = do.call(rbind,lapply(individuals,function(individuals)cbind(scn,individuals)))
scn = do.call(rbind,lapply(s_function,function(s_function)cbind(scn,s_function,s_reps)))

scn = data.frame(scn)
scn$items = as.numeric(as.character(scn$items))
scn$model = as.character(scn$model)
scn$s_reps = as.numeric(as.character(scn$s_reps))
scn$s_function = as.character(scn$s_function)
scn$individuals = as.numeric(as.character(scn$individuals))

scenarios = scn
# Create the itempars files and test files for both irtpp and mirt.

for(i in 1:nrow(scenarios))
{
	itempars = simulateItemParameters(item=scenarios$items[i],model=scenarios$model[i])
  savefile = paste0("/home/irtpp/itempars/","itempars",scenarios$model[i],"x",scenarios$individuals[i],"x",
                    scenarios$items[i],".RData");
  save(itempars,file=savefile);
  print.sentence("Using file : ",savefile)
  test = simulateTest(model=scenarios$model[i],
	                    individuals=scenarios$individuals[i],
	                    items=scenarios$items[i],
	                    directory="/home/irtpp/datasets/",
	                    reps=scenarios$s_reps[i],
	                    itempars=itempars,
                      filename=paste0("t",scenarios$model[i],"x",scenarios$individuals[i],"x",
                                      scenarios$items[i],"r")
                      )
}

scenarios
library(rmongodb)
mongo = mongo.create(host = "localhost",db="irtpptest")
mongo.is.connected(mongo)
##Load the mongo file
source(file="/home//liberato/git/irtppscripts/mongo.R")
scenario.insert(connection=mongo,scenarios,db="irtpptest")
