library(IRTpp)
library(mirt)
#model="2PL"; items=50;individuals=1000;s_count=5;
#f_sics(model="2PL", items=50,individuals=1000,s_count=5)

f_sics<-function(model,items,individuals,s_count){
  testfile = paste0("/home/irtpp/datasets/","t",model,"x",individuals,"x",items,"r",s_count,".csv")
  model = irtpp.model(model)
  ret=NULL;
  ##Bring the file with itempars
  savefile = paste0("/home/irtpp/itempars/","itempars",model,"x",individuals,"x",
                    items,".RData");
  if(file.exists(testfile)){
  nm=load(savefile)
  itempars = get(nm)
  
  ##Call IRTpp with test file
  tm = proc.time();
  ret$est_items = irtpp(filename=testfile,model=model)
  ret$est_iterations = ret$est_items$iterations;
  ret$est_convergence = ret$est_items$convergence;
  ret$est_items = ret$est_items$zita;
  ret$est_items = matrix(ret$est_items,ncol=3)
  tm = proc.time()-tm;
  ret$time_em <- tm[3];
  
  #Estimar Individuos
  tm = proc.time();
  ret$eap = individual.traits(filename=testfile,model=model,itempars=ret$est_items,method="EAP");
  tm = proc.time()-tm;
  ret$time_eap <- tm[3];
  
  tm = proc.time();
  ret$map = individual.traits(filename=testfile,model=model,itempars=ret$est_items,method="MAP")
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
  ret$map=NULL;
  ret$eap=NULL;
  ret
  }
  else{
  print.sentence("file not found, sorry")
  list(1,2,3)
  }
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
  ret$map = list(fscores(modelo,method='MAP'));
  ret$map =  lapply(ret$map,function(x){rt=NULL;rt$patterns=x[,1:items];rt$traits=x[,items+1];rt})
  ret$map = ret$map[[1]];
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
  ret$map=NULL;
  ret$eap=NULL;
  ret
}
