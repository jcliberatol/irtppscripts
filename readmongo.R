
## Connect to mongodb to extract the data
library(rmongodb)
library(jsonlite)
mongo = mongo.create(host = "localhost", db="irtpptest")
mongo.is.connected(mongo)
mongo
## Names of exported things
df.names = c("t_em","t_eap","t_map","ll_eap","ll_map","items","inds","func","model","rep")
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
       record$s_count
       );
  names(df) = df.names
  df
}

## Query to df function , makes a query and converts it to a data frame.
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

## To plot proportions over scenarios
propplot<-function(unopl,dospl,trespl,scenarios){
  sc.n = length(unopl)
  x=1:sc.n
  l= scenarios
  plot(x,unopl,type="o",col="red",lwd=0.7,cex=0.5, 
       lab=c(sc.n,sc.n,sc.n),xlab="",ylab="Proporciones",las=3,main="Poligono de Frecuencias-200 iteraciones",axes=F)
  lines(dospl,type="o",col="black",lwd=0.7,cex=0.5)
  lines(trespl,type="o",col="blue",lwd=0.7,cex=0.5)
  legend("topright",legend=c("Modelo 1pl","Modelo 2pl","Modelo 3pl"),col=c("red","black","blue"),pch=15)
  axis(side=1,at=c(1:(sc.n*3)),las=3, lab=l)
  axis(side=2, las=1,at=seq(0,1,by=0.1))
  abline(h=0.75,col="green",lwd=0.7)
}

##Heatmap plot
heatmap200=function(h){
  #data <- read.csv("../datasets/heatmaps_in_r.csv", comment.char="#")
  #rnames <- data[,1]                            # assign labels in column 1 to #"rnames"
  #mat_data <- data.matrix(data[,2:ncol(data)])  # transform column 2-5 into a #matrix
  #rownames(mat_data) <- rnames                  # assign row names 
  my_palette <- colorRampPalette(c("red", "yellow", "green"))(n = 299)
  
  col_breaks = c(seq(-1,0,length=100),  # for red
                 seq(0,0.8,length=100),              # for yellow
                 seq(0.8,1,length=100))              # for green
  
  
  #png("Desktop/SICS/informe 1/heatmap.png" ,   
  # width = 5*300,        # 5 x 300 pixels
  # height = 5*300,
  # res = 300,            # 300 pixels per inch
  # pointsize = 8)        # smaller font size
  
  heatmap.2(h,
            cellnote = h,  # same data set for cell labels
            main = "porcentajes-200 iteraciones", # heat map title
            notecol="black",      # change font color of cell labels to
            density.info="none",  # turns off density plot inside color 
            trace="none",         # turns off trace lines inside the heat
            margins =c(12,9),     # widens margins around plot
            col=my_palette,       # use on color palette defined earlier 
            #breaks=col_breaks,    # enable color transition at specified 
            dendrogram="none",key.title=NA)     # only draw a row dendrogram 
}

### Make the proportion plots
## Query the database for mirt and sics
df.m = query_to_df(list("s_function"="f_mirt"))
df.s = query_to_df(list("s_function"="f_sics"))

# Order by
df.m=df.m[order(df.m["inds"],df.m["items"],df.m["model"]),]
df.s=df.s[order(df.s["inds"],df.s["items"],df.s["model"]),]

# Get the scenarios
df.sc = df.m[order(df.m["inds"],df.m["items"],df.m["model"]),]
df.sc=df.sc[df.sc$rep==1,]
df.sc=df.sc[c("items","inds","model")]
## Get the differences
dif = df.s-df.m
dim(df.s)
dim(df.m)

cases = nrow(df.sc)
step = max(df.m$rep)

## Initialize the proportion list
props = list()

## Calculate the proportions
for (i in 0:(cases-1)){
  i1 = i*step+1
  i2 = (i+1)*step
  df = dif[i1:i2,]
  t_em=ifelse(df$t_em>0,"mirt","sics")
  t_eap=ifelse(df$t_eap>0,"mirt","sics")
  t_map=ifelse(df$t_map>0,"mirt","sics")
  ll_eap=ifelse(df$ll_eap>0,"mirt","sics")
  ll_map=ifelse(df$ll_eap>0,"mirt","sics")
  t_em=table(t_em)
  props[[i+1]]=list()
  props[[i+1]]$t_em = t_em/sum(t_em)
  if("sics"%in%names(props[[i+1]]$t_em)){
    props[[i+1]]$t_em = props[[i+1]]$t_em[["sics"]]
  }
  else {
    props[[i+1]]$t_em = 0
  }
  
  t_eap=table(t_eap)
  props[[i+1]]$t_eap = t_eap/sum(t_eap)
  if("sics"%in%names(props[[i+1]]$t_eap)){
    props[[i+1]]$t_eap = props[[i+1]]$t_eap[["sics"]]
  }
  else {
    props[[i+1]]$t_eap = 0
  }
  
  t_map=table(t_map)
  props[[i+1]]$t_map = t_map/sum(t_map)
  if("sics"%in%names(props[[i+1]]$t_map)){
    props[[i+1]]$t_map = props[[i+1]]$t_map[["sics"]]
  }
  else {
    props[[i+1]]$t_map = 0
  }
  
  ll_eap=table(ll_eap)
  props[[i+1]]$ll_eap = ll_eap/sum(ll_eap)
  if("sics"%in%names(props[[i+1]]$ll_eap)){
    props[[i+1]]$ll_eap = props[[i+1]]$ll_eap[["sics"]]
  }
  else {
    props[[i+1]]$ll_eap = 0
  }
  
  ll_map=table(ll_map)
  props[[i+1]]$ll_map = ll_map/sum(ll_map)
  if("sics"%in%names(props[[i+1]]$ll_map)){
    props[[i+1]]$ll_map = props[[i+1]]$ll_map[["sics"]]
  }
  else {
    props[[i+1]]$ll_map = 0
  }

}

## Form the data frame and add scenarios
props = do.call(rbind.data.frame,lapply(props,cbind.data.frame))
scenarios = mapply(function(x,y)paste0(x,"x",y),df.sc$items,df.sc$inds)
props = cbind.data.frame(df.sc,props,scenarios)

##Plots
t_em_1pl=props[props$model=="1PL",]$t_em
t_em_2pl=props[props$model=="2PL",]$t_em
t_em_3pl=props[props$model=="3PL",]$t_em

t_eap_1pl=props[props$model=="1PL",]$t_eap
t_eap_2pl=props[props$model=="2PL",]$t_eap
t_eap_3pl=props[props$model=="3PL",]$t_eap

t_map_1pl=props[props$model=="1PL",]$t_map
t_map_2pl=props[props$model=="2PL",]$t_map
t_map_3pl=props[props$model=="3PL",]$t_map

ll_eap_1pl=props[props$model=="1PL",]$ll_eap
ll_eap_2pl=props[props$model=="2PL",]$ll_eap
ll_eap_3pl=props[props$model=="3PL",]$ll_eap

ll_map_1pl=props[props$model=="1PL",]$ll_map
ll_map_2pl=props[props$model=="2PL",]$ll_map
ll_map_3pl=props[props$model=="3PL",]$ll_map

propplot(t_em_1pl,t_em_2pl,t_em_3pl,scenarios)
propplot(t_eap_1pl,t_eap_2pl,t_eap_3pl,scenarios)
propplot(t_map_1pl,t_map_2pl,t_map_3pl,scenarios)
propplot(ll_eap_1pl,ll_eap_2pl,ll_eap_3pl,scenarios)
propplot(ll_map_1pl,ll_map_2pl,ll_map_3pl,scenarios)

props_t_em = matrix(props$t_em,ncol=sc.n)
dimnames(props_t_em) = list(props$model[1:3],names(table(props$scenarios)))

props_t_eap = matrix(props$t_eap,ncol=sc.n)
dimnames(props_t_eap) = list(props$model[1:3],names(table(props$scenarios)))

props_t_map = matrix(props$t_map,ncol=sc.n)
dimnames(props_t_map) = list(props$model[1:3],names(table(props$scenarios)))

props_ll_eap = matrix(props$ll_eap,ncol=sc.n)
dimnames(props_ll_eap) = list(props$model[1:3],names(table(props$scenarios)))

props_ll_map = matrix(props$ll_map,ncol=sc.n)
dimnames(props_ll_map) = list(props$model[1:3],names(table(props$scenarios)))


heatmap200(props_t_em)
heatmap200(props_t_eap)
heatmap200(props_t_map)
heatmap200(props_ll_eap)
heatmap200(props_ll_map)


####Diferencias

dif
df.m[1:10,]
df.s[1:10,]

##all queries

df.all = query_to_df(list("model"="2PL","items"=20))
names(df.all)

qplot(data=df.all,y=ll_eap,color=func,x=inds)





library(IRTpp)
ti = 1:1000
for (i in 1:1000){
t = simulateTest()
tm=proc.time()
e=irtpp(dataset=t$test,model="2PL")
ti[[i]]=(proc.time()-tm)[3]
print(ti[[i]])
}
ti

plot(1:1000,ti)
summary(ti)
var(ti)


