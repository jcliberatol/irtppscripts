library(IRTpp)
##Functions
scenario.insert <- function(scenarios,connection=mongo,db="test",collection="scenarios"){
  s_status = "notrun"
  scenarios=cbind.data.frame(scenarios,s_status)
  scenarios$s_function = as.character(scenarios$s_function)
  scenarios$s_status = as.character(scenarios$s_status)
  scenarios$s_rand = runif(nrow(scenarios))
  s_count = 1
  scenarios = cbind.data.frame(scenarios,s_count)
  
  scenarios.list=lapply(split(scenarios,seq_along(scenarios[,1])),as.list)
  
  ret=lapply(scenarios.list,function(x){
    k = mongo.bson.from.list(x)
    mongo.insert(connection,
                 paste0(db,".",collection),k)
  })
  ret
}

library(rmongodb)
if(!exists("mongo")){
  mongo = mongo.create(host = "localhost",db="irtpptest") 
}
if(!mongo.is.connected(mongo)){
  mongo = mongo.create(host = "localhost",db="irtpptest")  
}

test_from_mongo<-function(test,where)
{
  test$test = NULL
  test$latentTraits = NULL
  t_query = mongo.bson.from.list(test)
  mongo = where$mongo
  col = where$collection
  query.result = mongo.findOne(mongo=mongo,ns=col,query=t_query)
  query.result = mongo.bson.to.list(query.result)
  query.result$test = matrix(unlist(query.result$test), ncol=test$items)
  query.result$latentTraits = unlist(query.result$latentTraits)
  query.result
}

#' ToMongo function, a wrapper for mongo insert, returns error false or true
toMongo<-function(what,where){
  if(!is.list(what)){what=list(what)}
  what=mongo.bson.from.list(what)
  mongo = where$mongo
  col = where$collection
  err=mongo.insert(mongo=mongo,ns=col,b=what)
  err
}



# Create the itempars files and test files for both irtpp and mirt.

initialize<-function(scn){

criteria=list("name"="rep")
objNew=list("name"="rep","value"=1)
mongo.update(mongo,ns="irtpptest.global",criteria,objNew,mongo.update.upsert)

for(i in 1:nrow(scn))
{
  
  savefile = paste0("/home/irtpp/itempars/","itempars",scn$model[i],"x",scn$individuals[i],"x",
                    scn$items[i],".RData");
  if(!file.exists(savefile)){
    itempars = simulateItemParameters(item=scn$items[i],model=scn$model[i])
    save(itempars,file=savefile);
    print.sentence("Creating file : ",savefile)
  }
  else {
    pars = load(savefile)
    itempars = get(pars)
    print.sentence("Using existing file : ",savefile)
  }
  
  savefile2 = paste0("/home/irtpp/itempars/","traits",scn$model[i],"x",scn$individuals[i],"x",
                    scn$items[i],".RData");
  if(!file.exists(savefile2)){
    th=rnorm(scn$individuals[i],0,1)
    th=(th-mean(th))/sd(th)
    save(th,file=savefile2);
    print.sentence("Creating file : ",savefile2)
  }
  else {
    pars = load(savefile2)
    th = get(pars)
    print.sentence("Using existing file : ",savefile2)
  }
  
 
    for (j in 1:scn$s_reps[[i]]){
      savefile = paste0("/home/irtpp/datasets/","test",scn$model[i],"x",scn$individuals[i],"x",
                        scn$items[i],"x",j,".rds");
      if(!file.exists(savefile)){
      test = simulateTest(model=scn$model[i],
                          individuals=scn$individuals[i],
                          items=scn$items[i],
                          itempars=itempars,
                          seed = j,
                          threshold=0.02,
                          latentTraits=th)
      test$t_rep = j; 
      tm = proc.time()
      saveRDS(test,file=savefile)
      tm = proc.time() - tm
      print.sentence("Created file : ",savefile," in :", tm[3], "s")
    }
  
    else{
      print.sentence("File : ",savefile," already exists")
    }
  }
  
  q = mongo.bson.from.list(scn[i,])
  qr = mongo.findOne(mongo=mongo,ns="irtpptest.scenarios",q)
  if(is.null(qr)){
    r = scenario.insert(connection=mongo,scn[i,],db="irtpptest")
    r=unlist(r)[[1]]
    if(r){
      print.sentence("Sucessfully inserted scenario into DB")
      print.data.frame(scn[i,])
    }else {
      stop("No mongoDB connection, please open a server")
    }
  }else{
    print.sentence("Scenario already existant in database")
    print.data.frame(scn[i,])
  }
  
}

}

##############Test Scenario 1 times (many scenarios , few reps)
models = c("1PL","2PL","3PL")
items = c(10,20,50,100)
individuals = c(1000,5000,10000)
s_reps = 5
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

scn = scn[order(scn$individuals,scn$items),]

initialize(scn)



