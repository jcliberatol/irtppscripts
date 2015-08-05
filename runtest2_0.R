library(IRTpp)
library(mirt)
#library(numDeriv)


#IRTpp section

f_sics<-function(model, items, individuals, seed, itempars, test)
{
  model = irtpp.model(model)
  ret=NULL;

  ret$params.poblational <- itempars;
  ret$seed <- seed;
  #Estimar Parametros de Items
  tm = proc.time();
  ret$est.irtpp.items = irtpp(dataset=test,model=model)
  tm = proc.time()-tm;
  ret$time.irtpp <- tm[3];
  
  #Estimar Individuos
  tm = proc.time();
  ret$ltt.irtpp = individual.traits(dataset=test,model=model,itempars=ret$est.irtpp.items,method="EAP");
  tm = proc.time()-tm;
  ret$time.irtpp.ltt <- tm[3];
  
  tm = proc.time();
  ret$map.irtpp = individual.traits(dataset=test,model=model,itempars=ret$est.irtpp.items,method="MAP")
  tm = proc.time()-tm;
  ret$time.irtpp.map <- tm[3];
  
  #Calcular loglikelihood
  ret$loglik.irtpp.map = loglik(ret$map.irtpp$patterns,ret$map.irtpp$trait,parameter.list(ret$est.irtpp.items)) 
  ret$loglik.irtpp.eap = loglik(ret$ltt.irtpp$patterns,ret$ltt.irtpp$trait,parameter.list(ret$est.irtpp.items)) 
#  ret$gradient.irtpp.map = grad(loglik, ret$map.irtpp$patterns,ret$map.irtpp$trait,parameter.list(ret$est.irtpp.items)) 
#  ret$hessian.irtpp.map = hessian(loglik, ret$map.irtpp$patterns,ret$map.irtpp$trait,parameter.list(ret$est.irtpp.items))
#  ret$gradient.irtpp.map = grad(wrapper.loglik, test=ret$map.irtpp$patterns,traits=ret$map.irtpp$trait,x=items.vector)
#  ret$gradient.irtpp.eap = grad(wrapper.loglik, test=ret$ltt.irtpp$patterns,traits=ret$map.irtpp$trait,x=items.vector)
#  ret$hessian.irtpp.map = hessian(wrapper.loglik, test=ret$map.irtpp$patterns,traits=ret$map.irtpp$trait,x=items.vector)
#  ret$hessian.irtpp.eap = hessian(wrapper.loglik, test=ret$ltt.irtpp$patterns,traits=ret$map.irtpp$trait,x=items.vector)

  print.sentence("Parametros estimados(irtpp) en : ",ret$time.irtpp);
  print.sentence("Individuos estimados(irtpp) en : ",ret$time.irtpp.ltt);
  print.sentence("Individuos estimados(irtpp-map) en : ",ret$time.irtpp.map);
  print.sentence("Logliks im ie : ",ret$loglik.irtpp.map,ret$loglik.irtpp.eap)
  print.sentence("seed : ",seed)
  #devolver lista con todo
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