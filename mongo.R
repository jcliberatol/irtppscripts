#'
#'@param scenarios A data frame with the scenarios , each column must correspond to a parameter of the function, 
#'       Use a column named s.reps to set up the repetitions of each scenario
#'       Obligatory : Use a column named s.function to specify the function to be ran to each scenario. 
#'@return a boolean vector indicating if the transactions were succesfull.




#library(rmongodb)
#mongo = mongo.create(host = "localhost",db="irtpptest") 
#connection=mongo;db="irtpptest";scenario.collection="scenarios";out.collection="out"
source(file="/home/liberato/git/irtppscripts/auxfunc.R")
#connection=mongo;db="irtpptest";scenario.collection="scenarios";out.collection="out"
#library(rmongodbHelper)
library(jsonlite)
