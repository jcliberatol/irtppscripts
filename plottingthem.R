
#Now parse the reduce directory to extract the reductions

path = "/home/liberato/irtpptest/dataoutput/";
analysis = analyse.tests(path)
save(analysis,file=paste0(dir,"analysis.RData"))
ll.all = load("logliks.RData")

ll.all <- get(ll.all)
ll.names = names(ll.all[[1]])

ll.all=lapply(ll.all,function(x){matrix(unlist(x),ncol=4)})
length(ll.all)
#ll.all=do.call(what=rbind,ll.all)
for (i in 1:12){
  ll.frame=data.frame(ll.all[[i]])  
  colnames(ll.frame)=ll.names
  p=qplot(x=ll.irtpp.eap,y=ll.mirt.eap,data=ll.frame)
  p+geom_abline(intercept=0,slope=1)
}
ll.all=data.frame(ll.all)
colnames(ll.all)=ll.names
ll.names
p=qplot(x=ll.irtpp.eap,y=ll.mirt.eap,data=ll.all)
p+geom_abline(intercept=0,slope=1)

p=qplot(x=log(ll.irtpp.map),y=log(ll.mirt.map),data=ll.all)
p+geom_abline(intercept=0,slope=1)

require(IRTpp)
require(ggplot2)
setwd("/home/liberato/irtpptest/dataoutput/")
load("analysis.RData")

analysis$est.better
analysis$est.better.count
analysis$mean.dif.irtpp
analysis$mean.dif.mirt

analysis$ll
#make dataframe
df = data.frame(matrix(unlist(analysis$ll),ncol=length(nm)))
colnames(df)<-colnames(analysis$ll)
df[, c(2:9)] <- sapply(df[, c(2:9)],function(x)as.numeric(as.character(x)))
p=qplot(x=ll.irtpp.eap,y=ll.mirt.eap,data=df,color=dataset.models)
p+geom_abline(intercept=0,slope=1)

df = data.frame(matrix(unlist(analysis$times),ncol=length(colnames(analysis$times))))
colnames(df)<-colnames(analysis$times)
df[, c(3:6)] <- sapply(df[, c(3:6)],function(x)as.numeric(as.character(x)))
p=qplot(x=mirt,y=irtpp,data=df,color=dataset.models,size=dataset.items)
p+geom_abline(intercept=0,slope=1)
colnames(df)<-c(colnames(df[,1:5]),"meap","mmap","ieap","imap")



analyse.tests<-function(path){
reduce.all(path)
rpath=paste0(path,"/reduced/")
k=report.from.reduced(rpath)
allliks = k$ll.all
save(allliks,file="logliks.RData")
dataset.names=t(matrix(unlist(lapply(k$dataset,function(x)unlist(strsplit(x,"x")))),nrow=3))
dataset.sizes=as.numeric(dataset.names[,2])
rms = nchar(as.character(dataset.sizes))+3
rps=lapply(dataset.names[,3],function(x)strsplit(x,".RData")[[1]])
dataset.reps=as.numeric(mapply(function(x,y)substr(x,y,13),rps,rms))
lapply(dataset.names[,3],nchar)
dataset.names=dataset.names[,1]
#dataset sizes, reppetittions and names are now available
dataset.items=dataset.sizes
dataset.models=lapply(dataset.names,function(x)substr(x,2,5))
dataset.individuals=dataset.sizes*100
##Compose the tables
tab=NULL
###Pass all the loglikelihoods
tab$ll.all = k$ll.all
### Speedup table

tab$speedup=t(matrix(unlist(lapply(k$speedup,function(x){c(x$estimation,x$eap,x$map)})),nrow=3))
colnames(tab$speedup)<-c("Estimacion","EAP","MAP")
tab$speedup=cbind(dataset.models,dataset.items,dataset.individuals,tab$speedup)

###Times table

tab$times = lapply(k$speedup,function(x){unlist(x$time.means)})
times.names=names(tab$times[[1]])
tab$times=t(matrix(unlist(tab$times),nrow=6))
colnames(tab$times)<-times.names
tab$times=cbind(dataset.models,dataset.items,dataset.individuals,tab$times)

###Loglikelihood tables

tab$ll=t(matrix(unlist(lapply(k$ll.mean,unlist)),nrow=4))
colnames(tab$ll)<-names(unlist(k$ll.mean[[1]]))
tab$ll = cbind(dataset.models,dataset.items,dataset.individuals,tab$ll)
winn=t(matrix(unlist(lapply(lapply(k$ll.max,function(x)x[[1]]),function(x){c(x[1],x[2])})),nrow=2))
winn[is.na(winn)] <- 0
colnames(winn)<-c("w.irtpp","w.mirt")
tab$ll = cbind(tab$ll,winn)

###Difference tables
#Tabla de cual de los paquetes estuvo mas cerca a los poblacionales
tab$est.better = t(matrix(unlist(k$dif.min),nrow=3))
colnames(tab$est.better)<-c("a","b","c")
tab$est.better= cbind(dataset.models,dataset.items,dataset.individuals,tab$est.better)
tab$est.better.count$a=table(unlist(tab$est.better[5:12,4]))
tab$est.better.count$b=table(unlist(tab$est.better[5:12,5]))
tab$est.better.count$c=table(unlist(tab$est.better[9:12,6]))

##Diferencias medias en convergencia

tab$mean.dif.irtpp=t(matrix(unlist(k$mean.dif.irtpp),nrow=3))
colnames(tab$mean.dif.irtpp)<-c("irtpp-a","irtpp-b","irtpp-c");
tab$mean.dif.mirt=t(matrix(unlist(k$mean.dif.mirt),nrow=3))
colnames(tab$mean.dif.mirt)<-c("mirt-a","mirt-b","mirt-c");
tab$mean.dif=cbind(dataset.models,dataset.items,dataset.individuals,tab$mean.dif.mirt,tab$mean.dif.irtpp)

tab
}

report.from.reduced<-function(path){
  files=list.files(path)
  all=NULL;
  dset.n = length(files)
  #i=1
  for(i in 1:dset.n){
    ret=NULL;
    file = paste0(path,"/",files[[i]])
    print(file)
    
    print(files)
    
    obj = load(file = file)
    obj <- get(obj)
    if(is.null(obj$speedup)){
      break;
    }
    all$speedup[[i]] = obj$speedup
    all$ll.all[[i]] = obj$ll.all
    all$ll.max[[i]] = list(obj$ll.max)
    all$ll.mean[[i]] = obj$ll.mean
    all$dif.min[[i]] = obj$dif.min
    all$mean.dif.irtpp[[i]] = obj$mean.dif.irtpp
    all$mean.dif.mirt[[i]] = obj$mean.dif.mirt
    all$dataset[[i]] = files[[i]]
    obj = NULL;
    gc();
  }
  all
}


###First the reduce step and what we gotta get.
#path = "/home/liberato/irtpptest/dataoutput/";
#reduce.all(path)


reduce.all<-function(path,verbose=T){
  ##Create a directory if it doesnt exists to output the reduce files
  out.dir = paste0(path,"/","reduced")
  if(!dir.exists(out.dir)){
    dir.create(out.dir)
  }
  ##Directories to reduce
  dirs=list.dirs(path)
  dirnames = list.dirs(path,full.names=F)
  dirs.n = length(dirs)
  #i=2
  for (i in 1:dirs.n){
    ret=NULL;
    print.sentence("Reducing directory : ",dirs[[i]])
    ret = reduce.dir(dirs[[i]],verbose)
    ##Save if proper
    if(is.character(ret)){
      print("Skipping directory")
      next;
    }
    if(!is.null(ret$speedup)){
      rfilename = paste0(out.dir,"/",dirnames[[i]],".RData") 
      save(ret,file=rfilename);
    }
    #Not proper
    else{if(verbose){print(paste0("Directory : ",dirs[[i]]," is not a proper directory"))}}
    ret=NULL;
  }
  
}
reduce.dir<-function(path,verbose=T){
  path=paste0(path,"/")
  ## List the files
  files=list.files(path = path);
  dset.n=length(files);
  ##Create the arrays
  ##times
  time.irtpp = NULL;
  time.mirt = NULL;
  time.irtpp.eap = NULL;
  time.mirt.eap = NULL;
  time.irtpp.map =NULL;
  time.mirt.map = NULL;
  ##Estimations are matrices
  est.irtpp = NULL;
  est.mirt = NULL;
  ##Loglikelihood
  ll.irtpp.eap =NULL;
  ll.irtpp.map =NULL;
  ll.mirt.eap =NULL;
  ll.mirt.map =NULL;
  
  
  est.poblational = NULL;
  ##Extraction
  #One for the while
  i=1
  while(i<=dset.n){
    file = paste0(path,files[[i]])
    if(dir.exists(file)){
      if(verbose){
        print(paste0("ERROR : Is a directory : ",file));
        }
      break;
    }
    if(!file.exists(file)){
      if(verbose){print(paste0("Non existant file : ",file));
      }
      break;
    }
    else{
      if(verbose){
        print(paste0("Loading : ",file," ..."))
      }
    }
    
    
    obj=load(file = file)
    obj<-get(obj)
    #names(obj)
    #times
    if(is.null(obj$time.irtpp)){
      if(verbose){
        print(paste0("Skipping file ",file," Because it is not a test file"))
      }  
      break;
    }
    time.irtpp[[i]]<-obj$time.irtpp;
    time.mirt[[i]]<-obj$time.mirt; 
    
    #print.sentence(obj$time.mirt," : ",obj$time.irtpp)
    time.irtpp.eap[[i]]<-obj$time.irtpp.ltt;
    time.mirt.eap[[i]]<-obj$time.mirt.ltt;
    time.irtpp.map[[i]]<-obj$time.irtpp.map;
    time.mirt.map[[i]]<-obj$time.mirt.map;
    #estimation
    est.irtpp[[i]]<-obj$est.irtpp.items;
    est.mirt[[i]]<-obj$est.mirt.items;
    #logliks
    ll.irtpp.eap[[i]]<-obj$loglik.irtpp.eap;
    ll.mirt.eap[[i]]<-obj$loglik.mirt.map;
    ll.irtpp.map[[i]]<-obj$loglik.irtpp.map;
    ll.mirt.map[[i]]<-obj$loglik.mirt.map;
    est.poblational<-obj$params.poblational;
    ret=NULL;
    obj=NULL;
    i=i+1;
  }
  
  ret = NULL;
  ##times speedup media
  if(!is.null(time.mirt)){
  
  speedup.deviations = c(sd(time.mirt),sd(time.irtpp),sd(time.mirt.eap),sd(time.mirt.map),sd(time.irtpp.eap),sd(time.irtpp.map))
  names(speedup.deviations)<-c("mirt","irtpp","m-eap","m-map","i-eap","i-map");
  time.means = list(time.mirt,time.irtpp,time.mirt.eap,time.mirt.map,time.irtpp.eap,time.irtpp.map)
  time.means = lapply(time.means,mean)
  names(time.means)<-c("mirt","irtpp","m-eap","m-map","i-eap","i-map");
  speedup.zita = time.mirt/time.irtpp
  speedup.eap = time.mirt.eap/time.irtpp.eap
  speedup.map = time.mirt.map/time.irtpp.map
  speedup = list(speedup.zita,speedup.eap,speedup.map)
  speedup = lapply(speedup,mean)
  speedup = as.list(speedup)
  names(speedup) <- c("estimation","eap","map")
  speedup$time.deviations = speedup.deviations
  speedup$time.means = time.means
  ret$speedup=speedup;
  
  
  
  #Log likelihoods
  ll.table=NULL;
  ll.table$ll.irtpp.eap=ll.irtpp.eap
  ll.table$ll.mirt.eap=ll.mirt.eap
  ll.table$ll.irtpp.map=ll.irtpp.map
  ll.table$ll.mirt.map=ll.mirt.map
  ret$ll.all = ll.table
  ll.summary=lapply(ll.table,summary)
  ##Mean and median
  ll.mean=lapply(ll.summary,function(x)x[[3]])
  #codes 1 ie 2 me 3 im 4 mm
  ll.matrix=matrix(unlist(ll.table),ncol=4)
  ll.max=NULL
  for(i in 1:dim(ll.matrix)[1]){
    ll.max[[i]]=which.min(ll.matrix[i,])
  }
  ll.max=lapply(ll.max,function(x){
    if(x==1)ret="irtpp.eap";
    if(x==2)ret="mirt.eap";
    if(x==3)ret="irtpp.map";
    if(x==4)ret="mirt.map";
    ret})
  ll.max = table(unlist(ll.max))
  reps.n = dim(ll.matrix)[1]
  ll.max=ll.max/reps.n
  
  
  ret$ll.max = ll.max
  ret$ll.mean = ll.mean
  
  library(IRTpp)
  
  est.poblational = parameter.matrix(est.poblational)
  
  ## Estimation parameters (mean of dif)
  
  mean.est.irtpp = Reduce("+",est.irtpp)/reps.n
  mean.est.mirt = Reduce("+",est.mirt)/reps.n
  mean.dif.irtpp = colSums(abs(mean.est.irtpp-est.poblational))/reps.n
  mean.dif.mirt = colSums(abs(mean.est.mirt-est.poblational))/reps.n
  
  dif.min = ifelse(mean.dif.irtpp-mean.dif.mirt>0,"mirt","irtpp")
  names(dif.min)<-c("a","b","c")
  
  ret$dif.min=dif.min
  ret$mean.dif.irtpp=mean.dif.irtpp
  ret$mean.dif.mirt=mean.dif.mirt
  
  ##Cleaning
  speedup.zita=NULL;speedup.map=NULL;speedup.eap=NULL;speedup=NULL;
  ll.table=NULL;ll.summary=NULL;ll.matrix=NULL;ll.max=NULL;ll.mean=NULL;
  est.poblational = NULL; mean.dif.irtpp=NULL; mean.dif.mirt=NULL; mean.est.irtpp=NULL; mean.est.mirt==NULL;
  gc(verbose=verbose)
  ret
  }
  else{
    if(verbose){
      print("ERROR : Path does not contain a proper folder");
    }
  }
}



