library(IRTpp)

models = c(3, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1)
items = c(20, 50, 100)
individuals = 1000
s_reps = 200
s_function = rep(c("f_mirt","f_sics"),3)

itempars = simulateItemParameters(item=, model=)
test = simulateTest(model=, individuals=, items=, directory="/home/mirt/Downloads/datasets/", reps=)


scenarios = cbind.data.frame(items,individuals,s_reps,s_function)

for(i in 1:nrow(scenarios))
{
	itempars = simulateItemParameters(item=scenarios$items[i],
	                                  model=scenarios$models[i],
	                                  seed = 1)

	test = simulateTest(model=scenarios$models[i],
	                    individuals=scenarios$individuals[i],
	                    items=scenarios$items[i],
	                    directory="/home/mirt/Downloads/datasets/",
	                    reps=scenarios$s_reps,
	                    itempars=itempars)
}

scenarios
library(rmongodb)
mongo = mongo.create(host = "localhost",db="irtpptest")
mongo.is.connected(mongo)
##Load the mongo file
source(file="/home//liberato/git/irtppscripts/mongo.R")
scenario.insert(connection=mongo,scenarios,db="irtpptest")
