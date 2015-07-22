###First the reduce step and what we gotta get.
dir = "/home/liberato/irtpptest/dataoutput/";
reduce.all(dir)


reduce.all<-function(path,verbose=T){
  ##Create a directory if it doesnt exists to output the reduce files
  out.dir = paste0(path,"/","reduced")
  out.dir
  if(!dir.exists(out.dir)){
    dir.create(out.dir)
  }
  ##Directories to reduce
  dirs=list.dirs(path)
  dirnames = list.dirs(path,full.names=F)
  dirs.n = length(dirs)
  for (i in 1:dirs.n){
    ret=NULL;
    ret = reduce.dir(dirs[[2]],verbose)
    ##Save if proper
    if(!is.null(ret$speedup)){
      rfilename = paste0(path,dirnames[[i]],".RData") 
      save(ret,file=rfilename);
    }
    #Not proper
    else{if(verbose){print(paste0("Directory : ",dirs[[i]]," is not a proper directory"))}}
    ret=NULL;
  }
  
}


reduce.dir(path)

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
  
  speedup.zita = time.mirt/time.irtpp
  speedup.eap = time.mirt.eap/time.irtpp.eap
  speedup.map = time.mirt.map/time.irtpp.map
  speedup = list(speedup.zita,speedup.eap,speedup.map)
  speedup = lapply(speedup,mean)
  speedup = as.list(speedup)
  names(speedup) <- c("estimation","eap","map")
  ret$speedup=speedup;
  
  
  
  #Log likelihoods
  ll.table=NULL;
  ll.table$ll.irtpp.eap=ll.irtpp.eap
  ll.table$ll.mirt.eap=ll.mirt.eap
  ll.table$ll.irtpp.map=ll.irtpp.map
  ll.table$ll.mirt.map=ll.mirt.map
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



