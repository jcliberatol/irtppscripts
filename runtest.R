
library(IRTpp)
library(mirt)
library(httr)
set_config(use_proxy(url="proxyapp.unal.edu.co", port=8080, username="jcliberatol", password="lov3th3lif3"))
library(devtools)
install_github(repo = "mongosoup/rmongodb")
install.packages(pkgs="rmongodb")
R.home()
#'unitary job, runs a single job, must be saved to a single RData file.
#'
#'
#'
#'
irtpp.test<-function(arglist){
  model=arglist$model;items=arglist$items;individuals=arglist$individuals;seed=arglist$seed;
  itempars=arglist$itempars;
  #obtener el modelo, items e individuos
  #cargar libreriashh
  library(IRTpp)
  model = irtpp.model(model)
  ret=NULL;
  #Simular el test.
  tm = proc.time();
  testArr = simulateTest(items=items,individuals=individuals,reps=1,model=model,seed=seed,threshold=0.05,,itempars=itempars)
  
  tm = proc.time()-tm;
  ret$time.simulation <- tm[3];
  ret$params.poblational <- testArr$itempars;
  ret$seed <- testArr$seed;
  #Estimar Parametros de Items
  tm = proc.time();
  ret$est.irtpp.items = irtpp(dataset=testArr$test[[1]],model=model)
  tm = proc.time()-tm;
  ret$time.irtpp <- tm[3];
  
  #Estimar Parametros de Items (MIRT)
  tm = proc.time();
  modelo=mirt(testArr$test[[1]],1,model)
  ret$est.mirt.items = coef(modelo)
  ret$est.mirt.items = matrix(unlist(ret$est.mirt.items)[1:(items*4)],ncol=4,byrow=T)[,1:3]
  #transform from d to b
  ret$est.mirt.items[,2]<-(-ret$est.mirt.items[,2]/ret$est.mirt.items[,1])
  tm = proc.time()-tm;
  ret$time.mirt <- tm[3];
  
  #Estimar Individuos
  tm = proc.time();
  ret$ltt.irtpp = individual.traits(dataset=testArr$test[[1]],model=model,itempars=ret$est.irtpp.items,method="EAP");
  tm = proc.time()-tm;
  ret$time.irtpp.ltt <- tm[3];
  
  tm = proc.time();
  ret$map.irtpp = individual.traits(dataset=testArr$test[[1]],model=model,itempars=ret$est.irtpp.items,method="MAP")
  tm = proc.time()-tm;
  ret$time.irtpp.map <- tm[3];
  
  #Estimar Individuos (MIRT)
  tm = proc.time();
  ret$ltt.mirt=NULL
  ret$ltt.mirt = list(fscores(modelo));
  ret$ltt.mirt =  lapply(ret$ltt.mirt,function(x){rt=NULL;rt$patterns=x[,1:items];rt$traits=x[,items+1];rt})
  ret$ltt.mirt = ret$ltt.mirt[[1]];
  tm = proc.time()-tm;
  ret$time.mirt.ltt <- tm[3];
  
  tm = proc.time();
  ret$map.mirt=NULL
  ret$map.mirt = list(fscores(modelo,method='MAP'));
  ret$map.mirt =  lapply(ret$map.mirt,function(x){rt=NULL;rt$patterns=x[,1:items];rt$traits=x[,items+1];rt})
  ret$map.mirt = ret$map.mirt[[1]];
  tm = proc.time()-tm;
  ret$time.mirt.map <- tm[3];
  
  #Calcular loglikelihood
  ret$loglik.irtpp.map = loglik(ret$map.irtpp$patterns,ret$map.irtpp$trait,parameter.list(ret$est.irtpp.items)) 
  ret$loglik.mirt.map = loglik(ret$map.mirt$patterns,ret$map.mirt$trait,parameter.list(ret$est.mirt.items))
  
  ret$loglik.irtpp.eap = loglik(ret$ltt.irtpp$patterns,ret$ltt.irtpp$trait,parameter.list(ret$est.irtpp.items)) 
  ret$loglik.mirt.eap = loglik(ret$ltt.mirt$patterns,ret$ltt.mirt$trait,parameter.list(ret$est.mirt.items))
  
  #Weird params
  ms=0;is=0;
  
  ms = ms+sum(ifelse(ret$est.mirt.items[,1]>4,1,0))
  ms = ms+sum(ifelse(abs(ret$est.mirt.items[,2])>4,1,0))
  ms = ms+sum(ifelse(ret$est.mirt.items[,3]>0.5,1,0))
  is = is+sum(ifelse(ret$est.irtpp.items[,1]>4,1,0))
  is = is+sum(ifelse(abs(ret$est.irtpp.items[,2])>4,1,0))
  is = is+sum(ifelse(ret$est.irtpp.items[,3]>0.5,1,0))
  ret$mirt.weird = ms;
  ret$irtpp.weird = is;
  print.sentence("Simulacion terminada en : ",ret$time.simulation);
  print.sentence("Parametros estimados(irtpp) en : ",ret$time.irtpp);
  print.sentence("Parametros estimados(mirt) en : ",ret$time.mirt);
  print.sentence("Individuos estimados(irtpp) en : ",ret$time.irtpp.ltt);
  print.sentence("Individuos estimados(mirt) en : ",ret$time.mirt.ltt);
  print.sentence("Individuos estimados(irtpp-map) en : ",ret$time.irtpp.map);
  print.sentence("Individuos estimados(mirt-map) en : ",ret$time.mirt.map);
  print.sentence("Logliks im mm ie me : ",ret$loglik.irtpp.map,ret$loglik.mirt.map,ret$loglik.irtpp.eap,ret$loglik.mirt.eap)
  print.sentence("Weirds mirt , irtpp : ",ms,is)
  print.sentence("seed : ",seed)
  #devolver lista con todo
  ret
}


mirt.test<-function(arglist){
  model=arglist$model;items=arglist$items;individuals=arglist$individuals;seed=arglist$seed;
  itempars=arglist$itempars;
  #obtener el modelo, items e individuos
  #cargar libreriashh
  library(IRTpp)
  library(mirt)
  model = irtpp.model(model)
  ret=NULL;
  #Simular el test.
  tm = proc.time();
  testArr = simulateTest(items=items,individuals=individuals,reps=1,model=model,seed=seed,threshold=0.05,,itempars=itempars)
  
  tm = proc.time()-tm;
  ret$time.simulation <- tm[3];
  ret$params.poblational <- testArr$itempars;
  ret$seed <- testArr$seed;
  #Estimar Parametros de Items
  tm = proc.time();
  ret$est.irtpp.items = irtpp(dataset=testArr$test[[1]],model=model)
  tm = proc.time()-tm;
  ret$time.irtpp <- tm[3];
  
  #Estimar Parametros de Items (MIRT)
  tm = proc.time();
  modelo=mirt(testArr$test[[1]],1,model)
  ret$est.mirt.items = coef(modelo)
  ret$est.mirt.items = matrix(unlist(ret$est.mirt.items)[1:(items*4)],ncol=4,byrow=T)[,1:3]
  #transform from d to b
  ret$est.mirt.items[,2]<-(-ret$est.mirt.items[,2]/ret$est.mirt.items[,1])
  tm = proc.time()-tm;
  ret$time.mirt <- tm[3];
  
  #Estimar Individuos
  tm = proc.time();
  ret$ltt.irtpp = individual.traits(dataset=testArr$test[[1]],model=model,itempars=ret$est.irtpp.items,method="EAP");
  tm = proc.time()-tm;
  ret$time.irtpp.ltt <- tm[3];
  
  tm = proc.time();
  ret$map.irtpp = individual.traits(dataset=testArr$test[[1]],model=model,itempars=ret$est.irtpp.items,method="MAP")
  tm = proc.time()-tm;
  ret$time.irtpp.map <- tm[3];
  
  #Estimar Individuos (MIRT)
  tm = proc.time();
  ret$ltt.mirt=NULL
  ret$ltt.mirt = list(fscores(modelo));
  ret$ltt.mirt =  lapply(ret$ltt.mirt,function(x){rt=NULL;rt$patterns=x[,1:items];rt$traits=x[,items+1];rt})
  ret$ltt.mirt = ret$ltt.mirt[[1]];
  tm = proc.time()-tm;
  ret$time.mirt.ltt <- tm[3];
  
  tm = proc.time();
  ret$map.mirt=NULL
  ret$map.mirt = list(fscores(modelo,method='MAP'));
  ret$map.mirt =  lapply(ret$map.mirt,function(x){rt=NULL;rt$patterns=x[,1:items];rt$traits=x[,items+1];rt})
  ret$map.mirt = ret$map.mirt[[1]];
  tm = proc.time()-tm;
  ret$time.mirt.map <- tm[3];
  
  #Calcular loglikelihood
  ret$loglik.irtpp.map = loglik(ret$map.irtpp$patterns,ret$map.irtpp$trait,parameter.list(ret$est.irtpp.items)) 
  ret$loglik.mirt.map = loglik(ret$map.mirt$patterns,ret$map.mirt$trait,parameter.list(ret$est.mirt.items))
  
  ret$loglik.irtpp.eap = loglik(ret$ltt.irtpp$patterns,ret$ltt.irtpp$trait,parameter.list(ret$est.irtpp.items)) 
  ret$loglik.mirt.eap = loglik(ret$ltt.mirt$patterns,ret$ltt.mirt$trait,parameter.list(ret$est.mirt.items))
  
  #Weird params
  ms=0;is=0;
  
  ms = ms+sum(ifelse(ret$est.mirt.items[,1]>4,1,0))
  ms = ms+sum(ifelse(abs(ret$est.mirt.items[,2])>4,1,0))
  ms = ms+sum(ifelse(ret$est.mirt.items[,3]>0.5,1,0))
  is = is+sum(ifelse(ret$est.irtpp.items[,1]>4,1,0))
  is = is+sum(ifelse(abs(ret$est.irtpp.items[,2])>4,1,0))
  is = is+sum(ifelse(ret$est.irtpp.items[,3]>0.5,1,0))
  ret$mirt.weird = ms;
  ret$irtpp.weird = is;
  print.sentence("Simulacion terminada en : ",ret$time.simulation);
  print.sentence("Parametros estimados(irtpp) en : ",ret$time.irtpp);
  print.sentence("Parametros estimados(mirt) en : ",ret$time.mirt);
  print.sentence("Individuos estimados(irtpp) en : ",ret$time.irtpp.ltt);
  print.sentence("Individuos estimados(mirt) en : ",ret$time.mirt.ltt);
  print.sentence("Individuos estimados(irtpp-map) en : ",ret$time.irtpp.map);
  print.sentence("Individuos estimados(mirt-map) en : ",ret$time.mirt.map);
  print.sentence("Logliks im mm ie me : ",ret$loglik.irtpp.map,ret$loglik.mirt.map,ret$loglik.irtpp.eap,ret$loglik.mirt.eap)
  print.sentence("Weirds mirt , irtpp : ",ms,is)
  print.sentence("seed : ",seed)
  #devolver lista con todo
  ret
}


run.test.unit<-function(arglist){
  model=arglist$model;items=arglist$items;individuals=arglist$individuals;seed=arglist$seed;
  itempars=arglist$itempars;
  #obtener el modelo, items e individuos
  #cargar libreriashh
  library(IRTpp)
  library(mirt)
  model = irtpp.model(model)
  ret=NULL;
  #Simular el test.
  tm = proc.time();
  testArr = simulateTest(items=items,individuals=individuals,reps=1,model=model,seed=seed,threshold=0.05,,itempars=itempars)

  tm = proc.time()-tm;
  ret$time.simulation <- tm[3];
  ret$params.poblational <- testArr$itempars;
  ret$seed <- testArr$seed;
  #Estimar Parametros de Items
  tm = proc.time();
  ret$est.irtpp.items = irtpp(dataset=testArr$test[[1]],model=model)
  tm = proc.time()-tm;
  ret$time.irtpp <- tm[3];
  
  #Estimar Parametros de Items (MIRT)
  tm = proc.time();
  modelo=mirt(testArr$test[[1]],1,model)
  ret$est.mirt.items = coef(modelo)
  ret$est.mirt.items = matrix(unlist(ret$est.mirt.items)[1:(items*4)],ncol=4,byrow=T)[,1:3]
  #transform from d to b
  ret$est.mirt.items[,2]<-(-ret$est.mirt.items[,2]/ret$est.mirt.items[,1])
  tm = proc.time()-tm;
  ret$time.mirt <- tm[3];
  
  #Estimar Individuos
  tm = proc.time();
  ret$ltt.irtpp = individual.traits(dataset=testArr$test[[1]],model=model,itempars=ret$est.irtpp.items,method="EAP");
  tm = proc.time()-tm;
  ret$time.irtpp.ltt <- tm[3];
  
  tm = proc.time();
  ret$map.irtpp = individual.traits(dataset=testArr$test[[1]],model=model,itempars=ret$est.irtpp.items,method="MAP")
  tm = proc.time()-tm;
  ret$time.irtpp.map <- tm[3];
  
  #Estimar Individuos (MIRT)
  tm = proc.time();
  ret$ltt.mirt=NULL
  ret$ltt.mirt = list(fscores(modelo));
  ret$ltt.mirt =  lapply(ret$ltt.mirt,function(x){rt=NULL;rt$patterns=x[,1:items];rt$traits=x[,items+1];rt})
  ret$ltt.mirt = ret$ltt.mirt[[1]];
  tm = proc.time()-tm;
  ret$time.mirt.ltt <- tm[3];
  
  tm = proc.time();
  ret$map.mirt=NULL
  ret$map.mirt = list(fscores(modelo,method='MAP'));
  ret$map.mirt =  lapply(ret$map.mirt,function(x){rt=NULL;rt$patterns=x[,1:items];rt$traits=x[,items+1];rt})
  ret$map.mirt = ret$map.mirt[[1]];
  tm = proc.time()-tm;
  ret$time.mirt.map <- tm[3];
  
  #Calcular loglikelihood
  ret$loglik.irtpp.map = loglik(ret$map.irtpp$patterns,ret$map.irtpp$trait,parameter.list(ret$est.irtpp.items)) 
  ret$loglik.mirt.map = loglik(ret$map.mirt$patterns,ret$map.mirt$trait,parameter.list(ret$est.mirt.items))

  ret$loglik.irtpp.eap = loglik(ret$ltt.irtpp$patterns,ret$ltt.irtpp$trait,parameter.list(ret$est.irtpp.items)) 
  ret$loglik.mirt.eap = loglik(ret$ltt.mirt$patterns,ret$ltt.mirt$trait,parameter.list(ret$est.mirt.items))
  
  #Weird params
  ms=0;is=0;

  ms = ms+sum(ifelse(ret$est.mirt.items[,1]>4,1,0))
  ms = ms+sum(ifelse(abs(ret$est.mirt.items[,2])>4,1,0))
  ms = ms+sum(ifelse(ret$est.mirt.items[,3]>0.5,1,0))
  is = is+sum(ifelse(ret$est.irtpp.items[,1]>4,1,0))
  is = is+sum(ifelse(abs(ret$est.irtpp.items[,2])>4,1,0))
  is = is+sum(ifelse(ret$est.irtpp.items[,3]>0.5,1,0))
  ret$mirt.weird = ms;
  ret$irtpp.weird = is;
  print.sentence("Simulacion terminada en : ",ret$time.simulation);
  print.sentence("Parametros estimados(irtpp) en : ",ret$time.irtpp);
  print.sentence("Parametros estimados(mirt) en : ",ret$time.mirt);
  print.sentence("Individuos estimados(irtpp) en : ",ret$time.irtpp.ltt);
  print.sentence("Individuos estimados(mirt) en : ",ret$time.mirt.ltt);
  print.sentence("Individuos estimados(irtpp-map) en : ",ret$time.irtpp.map);
  print.sentence("Individuos estimados(mirt-map) en : ",ret$time.mirt.map);
  print.sentence("Logliks im mm ie me : ",ret$loglik.irtpp.map,ret$loglik.mirt.map,ret$loglik.irtpp.eap,ret$loglik.mirt.eap)
  print.sentence("Weirds mirt , irtpp : ",ms,is)
  print.sentence("seed : ",seed)
  #devolver lista con todo
  ret
}

#'Many job , fills a folder with repetitions of the same call upon files, name is
#'provided by argument filename, and each repetition is appended at the end with r<number>
#'A args list is passed to the function
#'
#'
run.many.jobs<-function(filename,directory,reps,arglist,unitfun,redo=F){
  for (i in 1:reps) {
    rfilename = paste0(directory,"/",filename,"r",i,".RData");
    #Si existe el archivo
    calculate=T
    if(file.exists(rfilename))
    {
      print(paste(rfilename,"Found"));
      calculate=F;
      if(redo){
        rm=file.remove(rfilename);
        if(rm){
          print(" File removed and listed for recalculation ");
          calculate=T;
        }
        else{
          print("Unable to remove file, recalculation will not be done")
        }
      }
      else{print("Skipping calculation")}
    }
    if(calculate) {
      #reporiducble seed
      arglist$seed=i;
      ret = unitfun(arglist);
      save(ret,file=rfilename);
      ret=NULL;
      gc()
      print(paste(rfilename," Saved"));
    }
  }
}



run.test.scheduler<-function(masterdir,masterarglist,reps,unitfun,redo=F,seed=1,namingfun){
  #ensure that reps and masterarglist are same size.
  if(!length(masterarglist)==length(reps)){
    stop("hammertime")
  }
  idx=1;
  for (lst in  masterarglist){
    #determine folder name
    
    fname = namingfun(lst)
    fname=paste0("d",fname,reps[[idx]])
    #do.call(paste,c(lst,list(sep="x")))
    finame=paste0("f",fname,reps[[idx]])
    
    path=paste0(masterdir,"/",fname);1
    
    #create folder
    print.sentence(path," is the path")
    dir.create(path = path)
    #fill with repetitions
    run.many.jobs(finame,path,reps[[idx]],lst,unitfun,redo)
    idx=idx+1;
  }  
}



unit.namingfun<-function(lst){
  lst=list(lst$model,lst$items,lst$individuals)
  fname=do.call(paste,args=c(lst,sep="x"))
}


models = c("3PL","2PL");
items =     c(10,  20,  50,  100,  200,  500);
individuals=c(1000,2000,5000,10000,20000,50000);
reps =      c(200, 200, 100, 50,   10,   10);
mstrlst = NULL
size=length(models)*length(items)
mstrlst = as.list(1:size)
rps = as.list(1:size)
seq=1;
#generate the item parameter poblationally made
itempars=lapply(items,function(x){simulateTest(model="3PL",items = x,individuals=1,seed=1)})
itempars=lapply(itempars,function(x)x$itempars);

for (i in models){
  for (j in 1:length(items)){
    mstrlst[[seq]]<-list(model=i,items=items[[j]],individuals=individuals[[j]],seed=1,itempars=itempars[[j]])
    rps[[seq]]<-reps[[j]]
    seq=seq+1;
  }
}

run.test.scheduler(masterdir="/home/liberato/irtpptest/dataoutput/",
                   masterarglist=mstrlst,reps=rps,unitfun=run.test.unit,namingfun=unit.namingfun
)
