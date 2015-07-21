install.packages("ggplot2")


###First the reduce step and what we gotta get.
dir = "/home/mirt/irtpptest/dataoutput/";
subdir ="d2PLx100x1000050/"
path=paste0(dir,subdir)
files=list.files(path = path);
dset.n=length(files);

##Create the log arrays
##times

time.irtpp = NULL
time.mirt = NULL
time.irtpp.eap = NULL;
time.mirt.eap = NULL;
time.irtpp.map =NULL;
time.mirt.map = NULL;

##Estimations

est.irtpp = NULL;
est.mirt = NULL;


file=paste0(path,files[[1]])
obj=load(file =file ,verbose = T)
obj<-get(obj)
##The parsed content of a file.
names(obj)
### Tiempos lista.
obj$time.irtpp
obj$time.mirt
obj$time.irtpp.ltt
obj$time.mirt.ltt
## Estimaciones lista de matrices.
obj$est.irtpp.items

obj$est.mirt.items

## Loglik Lista.
## irtppeap mirteap irtppmap mirtmap

obj$loglik.irtpp
obj$loglik.mirt




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