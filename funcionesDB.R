library(rmongodb)
library(jsonlite)
library(IRTpp)
library(mirt)


df.names = c("t_em","t_eap","t_map","ll_eap","ll_map","items","inds","func","model","rep","date")
f1 <- function(record){
  df = list(record$time_em,
            record$time_eap,
            record$time_map,
            record$loglik_eap,
            record$loglik_map,
            record$items,
            record$individuals,
            record$s_function,
            record$model,
            record$s_count,
            record$date
  );
  names(df) = df.names
  df
}

df.names2 = c("items","inds","func","model","rep","date")
f22 <- function(record){
  df = list(record$items,
            record$individuals,
            record$s_function,
            record$model,
            record$s_count,
            record$date
  );
  names(df) = NULL
  names(df) = df.names2
   df = unlist(df)
  df2 = parameter.matrix(record$est_items)
  df2 = unlist(df2)
  items = nrow(df2)
  item = 1:items
  df2 = data.frame(df2);
  names(df2) = c("a","b","c");
  df2=cbind.data.frame(df2,item)
  df=rep(df,items)
  df = unlist(df)
  df = matrix(df,ncol = 6,byrow = T)
  df = data.frame(df);
  names(df) = df.names2;
  df = cbind.data.frame(df,df2)
  df
}

query_itempars = function(query){
  if(is.list(query)){
    query=mongo.bson.from.list(query)}
  else{
    stop("wrong query")
  }
  k = mongo.find.all(mongo,"irtpptest.out",query=query)
  rk=lapply(k,f22)
  rk = do.call(rbind.data.frame,rk)
  ##Diferenciar sics y mirt
  fl = split.data.frame(rk,rk$func)
  ##Partir dataframe
  fsics = NULL; fmirt = NULL;
  if(fl[[1]]$func[[1]] == "f_sics"){fsics = fl[[1]]; fmirt = fl[[2]]} else {fsics = fl[[2]]; fmirt = fl[[1]]}
  ##Trabajar con mirt que es el que esta volteado
  f2 = fmirt
  ##Factor de filtro
  col = mapply(function(itm,ind,fun,mod,rep){
    paste(itm,ind,ind,fun,mod,rep,sep="x")
  },f2$items,f2$inds,f2$func,f2$model,f2$rep)
  ##Añadir el factor al dataframe
  f2 = cbind.data.frame(f2,col)
  ##Partir el df
  f2l = split.data.frame(f2,col)
  ##Reordenar los datos desordenados
  f2l = lapply(f2l,function(k){
    y=as.matrix(k[,7:9])
    k[,7:9]<-matrix(c(unlist(y)),ncol=3,byrow=T)
    k
  })
  ##Rearmar el dataframe
  f2 = do.call(rbind.data.frame,f2l)
  ##Quitar columna de fiiltro
  f2 = f2[,1:10]
  ##Pegar el df de sics
  f2 = rbind.data.frame(f2,fsics)
  f2
}

query_to_df=function(query){
  if(is.list(query)){
    query=mongo.bson.from.list(query)}
  if(is.character(query)){
    
  }
  k = mongo.find.all(mongo,"irtpptest.out",query=query)
  rk=lapply(k,f1)
  df = lapply(rk,cbind.data.frame)
  df = do.call(rbind.data.frame,df)
  df
}