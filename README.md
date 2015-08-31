# irtppscripts
Examples and scripts that use irtpp


### Como correr los tests de irtpp

#### Inicializando los tests :
Modifique las lineas 148 a 152 de `initialization2.R`
```
models = c("1PL","2PL","3PL")
items = c(100,200)
individuals = c(10000,20000)
s_reps = 101
s_function = c("f_sics","f_mirt")
```

Aqui se especifica las pruebas que se quieran correr , en items e individuos, el vector de items debe ser igual de largo al vector de individuos.

Luego se debe correr el script para inicializar las pruebas, en una linea de comandos , estando en la carpeta irtppscripts escriba : 

```
Rscript initialization2.R
```

Cuando se finalize la inicializacion, ya se pueden correr las pruebas de la siguiente manera.

```
./runtest.sh //SICS y MIRT
./runtestsics.sh // Solo SICS
./runtestmirt.sh // Solo MIRT
```

Las pruebas reportan un mensaje que dice "I'm Done" cuando terminan, entonces se pueden exportar los resultados utilizando el script Pruebas.R

### Exportando con Pruebas.R

Este script consta de 2 funciones para exportar las pruebas , estos son `query_to_df` y `query_itempars`
cada una de estas funciones toma una lista llamada query para especificar los filtros con los que se busca en la base de datos.

Uso de Pruebas.R
```
###Primero se debe ir al directorio y cargar el archivo de las funciones
setwd("git/irtppscripts/")
source(file = "funcionesDB.R")
## Luego Conectarse a DB
mongo = mongo.create(host = "localhost", db="irtpptest")
mongo.is.connected(mongo)
## Especificar una query
query=list()
##Exportar 
qrm = query_itempars(query)
qrs = query_to_df(query)
##Guardar los dataframes
saveRDS(qrm,"dataframeest.RDS")
saveRDS(qrs,"dataframetiempos.RDS")
```

