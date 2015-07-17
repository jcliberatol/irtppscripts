
#'run many test
#'
#'@param mlist is the model list to run all the test in size m
#'@param itlist is the item list to be ran for each model ,size i
#'@param indlist is the individual list to be ran with each item list element ,size i
#'@param seed is the seed to reproduce results.
#'@reps is the reps matrix of size i * id
#'
##Parameter lists


gc()
run.test<-function(model,items,individuals,seed,reps){
  #Cargar paquetes
  library(IRTpp)
  library(mirt)
    = irtpp.model(model)
  ret=NULL;
  #Simular el test
  tm = proc.time();
  testArr = simulateTest(items=items,individuals=individuals,reps=reps,model=model,seed=seed,threshold=0.05)
  ret$poblational.items = testArr$itempars;
  tm = proc.time()-tm;
  ret$time.simulation <- tm[3];

  #Estimar Parametros de Items
  tm = proc.time();
  ret$est.irtpp.items = irtpp(dataset=testArr$test,model=model)
  tm = proc.time()-tm;
  ret$time.irtpp <- tm[3];

  #Estimar Parametros de Items (MIRT)
  tm = proc.time();
  modelo=lapply(testArr$test,function(x)mirt(x,1,model))
  ret$est.mirt.items = lapply(modelo,coef)
  ret$est.mirt.items  = lapply(ret$est.mirt.items ,function(x)matrix(unlist(x)[1:(items*4)],ncol=4,byrow=T)[,1:3])
  ret$est.mirt.items[[1]]
  tm = proc.time()-tm;
  ret$time.mirt <- tm[3];

  #Estimar Individuos
  tm = proc.time();
  ret$ltt.irtpp = mapply(function(x,y){individual.traits(dataset=x,model=model,itempars=y)},testArr$test,ret$est.irtpp.items,SIMPLIFY=F)
  tm = proc.time()-tm;
  ret$time.irtpp.ltt <- tm[3];

  #Estimar Individuos (MIRT)
  tm = proc.time();
  ret$ltt.mirt=NULL
  ret$ltt.mirt = lapply(modelo,fscores)
  ret$ltt.mirt = lapply(ret$ltt.mirt,function(x){rt=NULL;rt$patterns=x[,1:items];rt$traits=x[,items+1];rt})
  tm = proc.time()-tm;
  ret$time.mirt.ltt <- tm[3];

  #Calcular loglikelihood
  ret$loglik.irtpp = mapply(function(x,y){loglik(x$patterns,x$trait,parameter.list(y))},ret$ltt.irtpp,ret$est.irtpp.items)
  ret$loglik.mirt = mapply(function(x,y){loglik(x$patterns,x$trait,parameter.list(y))},ret$ltt.mirt,ret$est.mirt.items)

  options(digits=4)
  print.sentence("Simulacion terminada en : ",ret$time.simulation);
  print.sentence("Parametros estimados(irtpp) en : ",ret$time.irtpp);
  print.sentence("Parametros estimados(mirt) en : ",ret$time.mirt);
  print.sentence("Individuos estimados(irtpp) en : ",ret$time.irtpp.ltt);
  print.sentence("Individuos estimados(mirt) en : ",ret$time.mirt.ltt);
  options(digits=10)
  #Retornar todo
  ret
}

mlist=c(     1,   2)
itlist= c(10  ,  20,  10,  20,  50,  100,   50,  100,  200,  500,  200,   500,  750, 750)
indlist=c(1000,2000,2000,4000,5000,10000,10000,20000,20000,40000,50000,100000,75000,100000)
repslist =  c(200 ,200 ,200 ,200 ,100 ,100  ,50   ,50   ,50   ,50   ,30   ,10    ,1    ,1)
lapply(mlist,function(cmod){
mapply(function(it,idv,reps){
  filename=paste0(cmod,"PL",it,"x",idv,"r",reps,".RData")
  print(paste("Working on :",filename));
  gc()
  tr=run.test(model=cmod,items=it,individuals=idv,seed=1,reps=reps);
  save(filename,file=filename);
  tr=NULL;
  gc()
}
,itlist,indlist,repslist)})
