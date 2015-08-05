library(IRTpp)
library(mirt)
#library(numDeriv)

items=20;model="1PL";individuals=1000;s_count=1;

##Bring the test file
library(IRTpp)
library(mirt)
f_sics<-function(model,items,individuals,s_count){
  testfile = paste0("/home/irtpp/datasets/","t",model,"x",individuals,"x",items,"r",s_count,".csv")
  model = irtpp.model(model)
  ret=NULL;
  ##Bring the file with itempars
  savefile = paste0("/home/irtpp/itempars/","itempars",model,"x",individuals,"x",
                    items,".RData");
  nm=load(savefile)
  itempars = get(nm)

##Call IRTpp with test file
tm = proc.time();
ret$est.items = irtpp(filename=testfile,model=model)
ret$est.iterations = ret$est.items$iterations;
ret$est.convergence = ret$est.items$convergence;
ret$est.items = ret$est.items$zita;
ret$est.items = matrix(ret$est.items,ncol=3)
tm = proc.time()-tm;
ret$time.em <- tm[3];

#Estimar Individuos
tm = proc.time();
ret$eap = individual.traits(filename=testfile,model=model,itempars=ret$est.items,method="EAP");
tm = proc.time()-tm;
ret$time.eap <- tm[3];

tm = proc.time();
ret$map = individual.traits(filename=testfile,model=model,itempars=ret$est.items,method="MAP")
tm = proc.time()-tm;
ret$time.map <- tm[3];

#Calcular loglikelihood
ret$loglik.map = loglik(ret$map$patterns,ret$map$trait,parameter.list(ret$est.items)) 
ret$loglik.eap = loglik(ret$eap$patterns,ret$eap$trait,parameter.list(ret$est.items)) 
#  
print.sentence("Parametros estimados(irtpp) en : ",ret$time.irtpp);
print.sentence("Individuos estimados(irtpp) en : ",ret$time.eap);
print.sentence("Individuos estimados(irtpp-map) en : ",ret$time.map);
print.sentence("Logliks im ie : ",ret$loglik.map,ret$loglik.eap)

ret

}

f_mirt<-function(model,items,individuals,s_count){
  testfile = paste0("/home/irtpp/datasets/","t",model,"x",individuals,"x",items,"r",s_count,".csv")
  model = irtpp.model(model)
  ret=NULL;
  ##Bring the file with itempars
  savefile = paste0("/home/irtpp/itempars/","itempars",model,"x",individuals,"x",
                    items,".RData");
  if(model == "1PL"){model = "Rasch"}
  nm=load(savefile)
  itempars = get(nm)
  
  
  tm = proc.time();
  test = read.table(testfile,header=F,sep=",")
  modelo=mirt(test,1,model)
  ret$est.items = coef(modelo)
  ret$est.items = matrix(unlist(ret$est.items)[1:(items*4)],ncol=4,byrow=T)[,1:3]
  #transform from d to b
  ret$est.items[,2]<-(-ret$est.items[,2]/ret$est.items[,1])
  tm = proc.time()-tm;
  ret$time.em <- tm[3];
  
  
  #Estimar Individuos (MIRT)
  tm = proc.time();
  ret$eap=NULL
  ret$eap = list(fscores(modelo));
  ret$eap =  lapply(ret$eap,function(x){rt=NULL;rt$patterns=x[,1:items];rt$traits=x[,items+1];rt})
  ret$eap = ret$eap[[1]];
  tm = proc.time()-tm;
  ret$time.eap <- tm[3];
  
  tm = proc.time();
  ret$map=NULL
  ret$map = list(fscores(modelo,method='MAP'));
  ret$map =  lapply(ret$map,function(x){rt=NULL;rt$patterns=x[,1:items];rt$traits=x[,items+1];rt})
  ret$map = ret$map[[1]];
  tm = proc.time()-tm;
  ret$time.map <- tm[3];
  
  #Calcular loglikelihood
  ret$loglik.map = loglik(ret$map$patterns,ret$map$trait,parameter.list(ret$est.items)) 
  ret$loglik.eap = loglik(ret$eap$patterns,ret$eap$trait,parameter.list(ret$est.items)) 
  #  
  print.sentence("Parametros estimados(irtpp) en : ",ret$time.irtpp);
  print.sentence("Individuos estimados(irtpp) en : ",ret$time.eap);
  print.sentence("Individuos estimados(irtpp-map) en : ",ret$time.map);
  print.sentence("Logliks im ie : ",ret$loglik.map,ret$loglik.eap)
  
  ret
}

#MIRT section

f_mirt<-function(model, items, individuals, seed, itempars, testArr)
{
  model = irtpp.model(model)
  ret=NULL;

  ret$params.poblational <- itempars;
  ret$seed <- seed;
  #Estimar Parametros de Items (MIRT)
  tm = proc.time();
  modelo=mirt(test,1,model)
  ret$est.mirt.items = coef(modelo)
  ret$est.mirt.items = matrix(unlist(ret$est.mirt.items)[1:(items*4)],ncol=4,byrow=T)[,1:3]
  #transform from d to b
  ret$est.mirt.items[,2]<-(-ret$est.mirt.items[,2]/ret$est.mirt.items[,1])
  tm = proc.time()-tm;
  ret$time.mirt <- tm[3];
  
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
  ret$loglik.mirt.map = loglik(ret$map.mirt$patterns,ret$map.mirt$trait,parameter.list(ret$est.mirt.items))
  ret$loglik.mirt.eap = loglik(ret$ltt.mirt$patterns,ret$ltt.mirt$trait,parameter.list(ret$est.mirt.items))
#  ret$gradient.irtpp.map = grad(wrapper.loglik, test=ret$map.irtpp$patterns,traits=ret$map.irtpp$trait,x=items.vector)
#  ret$gradient.irtpp.eap = grad(wrapper.loglik, test=ret$ltt.irtpp$patterns,traits=ret$map.irtpp$trait,x=items.vector)
#  ret$hessian.mirt.map = hessian(wrapper.loglik, test=ret$map.irtpp$patterns,traits=ret$map.irtpp$trait,x=items.vector)
#  ret$hessian.mirt.eap = hessian(wrapper.loglik, test=ret$ltt.irtpp$patterns,traits=ret$map.irtpp$trait,x=items.vector)
  
  print.sentence("Parametros estimados(mirt) en : ",ret$time.mirt);
  print.sentence("Individuos estimados(mirt) en : ",ret$time.mirt.ltt);
  print.sentence("Individuos estimados(mirt-map) en : ",ret$time.mirt.map);
  print.sentence("Logliks mm me : ",ret$loglik.mirt.map,ret$loglik.mirt.eap)
  print.sentence("seed : ",seed)
  #devolver lista con todo
  ret
}