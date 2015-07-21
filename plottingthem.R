
install.packages("ggplot2")


###First the reduce step and what we gotta get.
dir = "/home/liberato/irtpptest/dataoutput/";
subdir ="d3PLx10x1000200/"
path=paste0(dir,subdir)
files=list.files(path = path);
files

dset.n=length(files);



##Create the arrays
##times
time.irtpp = NULL;
time.mirt = NULL;
time.irtpp.eap = NULL;
time.mirt.eap = NULL;
time.irtpp.map =NULL;
time.mirt.map = NULL;

##Estimations are matrices lol !

est.irtpp = NULL;
est.mirt = NULL;

##Loglikelihood

ll.irtpp.eap =NULL;
ll.irtpp.map =NULL;
ll.mirt.eap =NULL;
ll.mirt.map =NULL;

for (i in 1:dset.n){
  file = paste0(path,files[[i]]) 
  obj=load(file =file ,verbose = T)
  obj<-get(obj)
  time.irtpp[[i]]<-obj$time.irtpp;
  time.mirt[[i]]<-obj$time.mirt;
  time.irtpp.eap[[i]]<-obj$time.irtpp.ltt;
  time.mirt.eap[[i]]<-obj$time.mirt.ltt;
  
  est.irtpp[[i]]<-obj$est.irtpp.items;
  est.mirt[[i]]<-obj$est.mirt.items;
  
  ll.irtpp.eap[[i]]<-obj$loglik.irtpp;
  ll.mirt.eap[[i]]<-obj$loglik.mirt;
  print.sentence("Irtpp ll : ",obj$loglik.irtpp,obj$seed)
  
  ret=NULL;
  obj=NULL;
}
ll.irtpp.eap
ll.mirt.eap
time.mirt


## EAP LL
## MAP (Run after) LL
## MAP mirt LL.
##  ####### call to mirt with method = "MAP"
#Estimar Individuos
tm = proc.time();
ret$ltt.irtpp = individual.traits(dataset=testArr$test[[1]],model=model,itempars=ret$est.irtpp.items,method="EAP");
tm = proc.time()-tm;
ret$time.irtpp.ltt <- tm[3];


#Estimar Individuos (MIRT)
tm = proc.time();
ret$ltt.mirt=NULL
ret$ltt.mirt = list(fscores(modelo));
ret$ltt.mirt =  lapply(ret$ltt.mirt,function(x){rt=NULL;rt$patterns=x[,1:items];rt$traits=x[,items+1];rt})
ret$ltt.mirt = ret$ltt.mirt[[1]];
tm = proc.time()-tm;
ret$time.mirt.ltt <- tm[3];