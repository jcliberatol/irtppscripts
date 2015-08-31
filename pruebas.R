setwd("git/irtppscripts/")
source(file = "funcionesDB.R")
## Conectarse a DB
mongo = mongo.create(host = "localhost", db="irtpptest")
mongo.is.connected(mongo)


## Ejemplos

## Cosas que se pueden buscar con query
#"items"
#"individuals"
#"model"
#"s_function"
#"s_count"

## Funciones disponibles
#query_itempars
#query_to_df

query = list("model"="1PL","individuals"=1000,"s_count"=1)
query = list("individuals"=18000)
query=list()
qrm = query_itempars(query)
query = list("individuals"=10000,"s_function"="f_sics")
qrs = query_to_df(query)
qrs

qr = query_itempars(query)
qr[1:10,]
names(qr)
qrm = query_to_df(query)
qr

## Guardar

saveRDS(qrm,"dataframe18000est.RDS")

##Ruta donde quedo guardado
getwd()

qr[]
library(ggplot2)

qplot(data=qr,x=qr$rep,y = qr$t_em,color=qr$func,shape=qr$model)
qplot(data=qrm,x=qrm$rep,y = qrm$t_em,color=qrm$model)
qplot(data=qrs,x=qrs$rep,y = qrs$t_em,color=qrs$model)
