#'
#'@param scenarios A data frame with the scenarios , each column must correspond to a parameter of the function, 
#'       Use a column named s.reps to set up the repetitions of each scenario
#'       Obligatory : Use a column named s.function to specify the function to be ran to each scenario. 
#'@return a boolean vector indicating if the transactions were succesfull.
scenario.insert <- function(scenarios,connection=mongo,db="test",collection="scenarios"){
  s_status = "notrun"
  scenarios=cbind.data.frame(scenarios,s_status)
  scenarios$s_function = as.character(scenarios$s_function)
  scenarios$s_status = as.character(scenarios$s_status)
  s_count = 0
  scenarios = cbind.data.frame(scenarios,s_count)
  
  scenarios.list=lapply(split(scenarios,seq_along(scenarios[,1])),as.list)

  ret=lapply(scenarios.list,function(x){
    k = mongo.bson.from.list(x)
    mongo.insert(connection,
                 paste0(db,".",collection),k)
  })
  ret
}



scenarios.run<- function(connection=mongo,db="test",scenario.collection="scenarios",out.collection="out"){
  ###Search for not ran scenarios
  repeat{
  evaluate = T;
  scenario_c = paste0(db,".",scenario.collection)
  out_c = paste0(db,".",out.collection)
  query=mongo.bson.from.list(list("s_status"="notrun"))
  element=mongo.findOne(connection,scenario_c,query);
  if(is.null(element)){
    print("I'm done")
    break
  }
  element = mongo.bson.to.list(element)  
  
  func = element$s_function
  argnames=names(formals(func))  
  arglist=lapply(argnames,function(x)element[[x]])  
  fun.eval = get(func)
  
  elem_id = as.character(element["_id"][[1]])
  #Select id of this element for later queries
  
  criteria=list('_id'=mongo.oid.from.string(elem_id))
  if(element$s_count>= element$s_reps){
    #Mark flag as run
    newobj = '{ "$set" : { "s_status" : "finished"}}'
    mongo.update(connection,ns=scenario_c,criteria=criteria,objNew=newobj)
    evaluate=F
  }
  
  ## Evaluate if not evaluated
  if (evaluate){
  evalout=do.call(fun.eval,arglist)
  evalout$s_rep = element$s_count 
  #Increase the count
  newobj = '{ "$inc" : { "s_count" : 1}}'
  
  mongo.update(connection,ns=scenario_c,criteria=criteria,objNew=newobj)
  #Save in db
  mongo.insert(connection,out_c,evalout)}
  }
}