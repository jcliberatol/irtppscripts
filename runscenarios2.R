
library(rmongodb)
library(jsonlite)
library(devtools)
library(IRTpp)
library(mirt)



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

model="1PL"

f_sics<-function(model,items,individuals,s_count){
  test = list(model=model,items=items,individuals=individuals)
  if(!exists("mongo")){
    mongo = mongo.create(host="localhost",db="irtpptest")
    mongo=mongo.reconnect(mongo=mongo)
  }
  if(!mongo.is.connected(mongo)){
    stop("turn on mongodb please")
  }

  #testfile = paste0("/home/irtpp/datasets/","t",model,"x",individuals,"x",items,"r",s_count,".csv")
  
  testfile = paste0("/home/irtpp/datasets/","test",model,"x",individuals,"x",items,"x",s_count,".rds")
  testfile
  if(file.exists(testfile)){
    #write.table(x=test$test,append=F,file=testfile)
    model = irtpp.model(model)
    ret=NULL;
    
    ##Call IRTpp with test file
    tm = proc.time();
    test = readRDS(testfile)
    
    
    if(is.list(test$test)){
      test$test=test$test[[1]]
    }
    
    ret$est_items = irtpp(test$test,model=model)
    ret$est_iterations = ret$est_items$iterations;
    ret$est_convergence = ret$est_items$convergence;
    ret$est_items = ret$est_items$zita;
    ret$est_items = matrix(ret$est_items,ncol=3)
    tm = proc.time()-tm;
    ret$time_em <- tm[3];
    
    #Estimar Individuos
    tm = proc.time();
    
    ret$eap = individual.traits(dataset=test$test,model=model,itempars=ret$est_items,method="EAP");
    tm = proc.time()-tm;
    ret$time_eap <- tm[3];
    
    tm = proc.time();
    ret$map = ret$eap = individual.traits(dataset=test$test,model=model,itempars=ret$est_items,method="MAP");
    tm = proc.time()-tm;
    ret$time_map <- tm[3];
    
    #Calcular loglikelihood
    ret$loglik_map = loglik(ret$map$patterns,ret$map$trait,parameter.list(ret$est_items)) 
    ret$loglik_eap = loglik(ret$eap$patterns,ret$eap$trait,parameter.list(ret$est_items)) 
    #  
    print.sentence("Parametros estimados(irtpp) en : ",ret$time_em);
    print.sentence("Individuos estimados(irtpp) en : ",ret$time_eap);
    print.sentence("Individuos estimados(irtpp-map) en : ",ret$time_map);
    print.sentence("Logliks im ie : ",ret$loglik_map,ret$loglik_eap)
    ret$est_items = parameter.list(ret$est_items);
    ret$map=ret$map$trait;
    ret$eap=ret$eap$trait;
    ret
  }else{
    print.sentence("file not found, sorry")
    stop("IRTpp could not find the file provided.")
    list(1,2,3)
  }
}

f_mirt<-function(model,items,individuals,s_count){
  test = list(model=model,items=items,individuals=individuals)
  if(!exists("mongo")){
    mongo = mongo.create(host="localhost",db="irtpptest")}
  where = list(mongo=mongo,collection="irtpptest.test")
  #test = test_from_mongo(test,where)
  
  testfile = paste0("/home/irtpp/datasets/","test",model,"x",individuals,"x",items,"x",s_count,".rds")
  
  if(file.exists(testfile)){
    tm = proc.time();
    test = readRDS(testfile)
    
    
    if(is.list(test$test)){
      test$test=test$test[[1]]
    }
  }
  test = test$test
  model = irtpp.model(model)
  ret=NULL;
  ##Bring the file with itempars
  if(model == "1PL"){model = "Rasch"}
  
  tm = proc.time();
  modelo=mirt(test,1,model)
  ret$est_items = coef(modelo)
  ret$est_items = matrix(unlist(ret$est_items)[1:(items*4)],ncol=4,byrow=T)[,1:3]
  #transform from d to b
  ret$est_items[,2]<-(-ret$est_items[,2]/ret$est_items[,1])
  tm = proc.time()-tm;
  ret$time_em <- tm[3];
  
  
  #Estimar Individuos (MIRT)
  tm = proc.time();
  ret$eap=NULL
  ret$eap = list(fscores(modelo));
  ret$eap =  lapply(ret$eap,function(x){rt=NULL;rt$patterns=x[,1:items];rt$traits=x[,items+1];rt})
  ret$eap = ret$eap[[1]];
  tm = proc.time()-tm;
  ret$time_eap <- tm[3];
  
  tm = proc.time();
  ret$map=NULL
  ##ret$map = list(fscores(modelo,method='MAP'));
  ##ret$map =  lapply(ret$map,function(x){rt=NULL;rt$patterns=x[,1:items];rt$traits=x[,items+1];rt})
  ##ret$map = ret$map[[1]];
  tm = proc.time()-tm;
  ret$time_map <- tm[3];
  
  #Calcular loglikelihood
  ##ret$loglik_map = loglik(ret$map$patterns,ret$map$trait,parameter.list(ret$est_items)) 
  ret$loglik_eap = loglik(ret$eap$patterns,ret$eap$trait,parameter.list(ret$est_items)) 
  #  
  print.sentence("Parametros estimados(mirt) en : ",ret$time_em);
  print.sentence("Individuos estimados(mirt) en : ",ret$time_eap);
  print.sentence("Individuos estimados(mirt-map) en : ",ret$time_map);
  print.sentence("Logliks  ie : ",ret$loglik_eap)
  ret$eap=ret$eap$trait
  ##ret$map=ret$map$trait
  ret
}



scenarios.run<- function(connection=mongo,db="test",scenario.collection="scenarios",out.collection="out"){
  ###Search for not ran scenarios
  repeat{
    
    evaluate = T;
    
    ##Repetition to search for :
    c_rep = mongo.findOne(connection,ns="irtpptest.global",query=list("name"="rep"))
    c_rep = mongo.bson.to.list(c_rep)
    print.sentence("Repetition : ",c_rep$value)
    scenario_c = paste0(db,".",scenario.collection)
    out_c = paste0(db,".",out.collection)
    query1 = paste0('{"s_status" : "notrun",  "s_count" : ',c_rep$value,' , "s_function" : "f_mirt"}')
    element = mongo.findOne(connection,scenario_c,query1)
    if (is.null(element)){
      c_rep$value=c_rep$value+1;
      mongo.update(connection,"irtpptest.global",list("name"="rep"),c_rep)
    }
    element = mongo.findOne(connection,scenario_c,query1)
    if (is.null(element)){
      query1 = paste0('{"s_status" : "notrun" }')
      element = mongo.findOne(connection,scenario_c,query1)
      if(is.null(element)){
        print("I'm done")
        break
      }
    }
    element = mongo.bson.to.list(element)
    
    if(element$s_count<c_rep$value){
      c_rep$value = element$s_count
      mongo.update(connection,"irtpptest.global",list("name"="rep"),c_rep)
    }
    
    
    func = element$s_function
    argnames=names(formals(func))  
    arglist=lapply(argnames,function(x)element[[x]])  
    fun.eval = get(func)
    do.call(print.sentence,list(argnames))
    do.call(print.sentence,list(arglist))
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
      #evalout = mongo.bson.from.list(evalout);
      #print(evalout)
      
      mongo.update(connection,ns=scenario_c,criteria=criteria,objNew=newobj)
      #Save in db
      evalout[names(element)] = element
      evalout["_id"] = NULL
      
      err = mongo.insert(connection,out_c,mongo.bson.from.JSON(toJSON(evalout)))
      print.sentence("success ?  : ",err);
    }
  }
}


mongo = mongo.create(host = "localhost",db="irtpptest")
mongo.is.connected(mongo)

y=scenarios.run(connection=mongo,db="irtpptest",scenario.collection="scenarios",out.collection="out")


