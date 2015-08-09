##############################################DETALLES

#poligono de frecuencias


###200 iteraciones


#
unopl=runif(16)
dospl=runif(16)
trespl=runif(16)
#


x=c(1:16)
l=c("k*20","k*50","k*100","k*200","10k*20","10k*50","10k*100","10k*200","100k*20","100k*50","100k*100","100k*200","250k*20","250k*50","250k*100","250k*200")
plot(x,unopl,type="o",col="red",lwd=0.7,cex=0.5, 
     lab=c(16,16,16),xlab="",ylab="Proporciones",las=3,main="Poligono de Frecuencias",axes=F)
lines(dospl,type="o",col="black",lwd=0.7,cex=0.5)
lines(trespl,type="o",col="blue",lwd=0.7,cex=0.5)
legend("topright",legend=c("Modelo 1pl","Modelo 2pl","Modelo 3pl"),col=c("red","black","blue"),pch=15)
axis(side=1,at=c(1:16),las=3, lab=l)
axis(side=2, las=1,at=seq(0,1,by=0.1))
abline(h=0.75,col="green",lwd=0.7)

###50 iteraciones


#
unopl=runif(16)
dospl=runif(16)
trespl=runif(16)
#


x=c(1:16)
l=c("k*500","k*k","k*2k","k*5k","10k*500","10k*k","10k*2k","10k*5k","100k*500","100k*k","100k*2k","100k*5k","250k*500","250k*k","250k*2k","250k*5k")
plot(x,unopl,type="o",col="red",lwd=0.7,cex=0.5, 
     lab=c(16,16,16),xlab="",ylab="Proporciones",las=3,main="Poligono de Frecuencias",axes=F)
lines(dospl,type="o",col="black",lwd=0.7,cex=0.5)
lines(trespl,type="o",col="blue",lwd=0.7,cex=0.5)
legend("topright",legend=c("Modelo 1pl","Modelo 2pl","Modelo 3pl"),col=c("red","black","blue"),pch=15)
axis(side=1,at=c(1:16),las=3, lab=l)
axis(side=2, las=1,at=seq(0,1,by=0.1))
abline(h=0.75,col="green",lwd=0.7)


#heatmap

rm(list=ls())

#200 iteraciones

#
datos=matrix(c(runif(16*3)),ncol=16,byrow=T)
dimnames(datos)=list(c("1pl","2pl","3pl"),c("k*20","k*50","k*100","k*200","10k*20","10k*50","10k*100","10k*200","100k*20","100k*50","100k*100","100k*200","250k*20","250k*50","250k*100","250k*200")
)
datos
#

if (!require("gplots")) {
  install.packages("gplots", dependencies = TRUE)
  library(gplots)
}
if (!require("RColorBrewer")) {
  install.packages("RColorBrewer", dependencies = TRUE)
  library(RColorBrewer)
}

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

heatmap.2(datos,
          #cellnote = datos,  # same data set for cell labels
          main = "porcentajes", # heat map title
          #notecol="black",      # change font color of cell labels to
          density.info="none",  # turns off density plot inside color 
          trace="none",         # turns off trace lines inside the heat
          margins =c(12,9),     # widens margins around plot
          col=my_palette,       # use on color palette defined earlier 
          #breaks=col_breaks,    # enable color transition at specified 
          dendrogram="none")     # only draw a row dendrogram 

#50 iteraciones

#
datos=matrix(c(runif(16*3)),ncol=16,byrow=T)
dimnames(datos)=list(c("1pl","2pl","3pl"),c("k*500","k*k","k*2k","k*5k","10k*500","10k*k","10k*2k","10k*5k","100k*500","100k*k","100k*2k","100k*5k","250k*500","250k*k","250k*2k","250k*5k")
                     
)
datos
#

if (!require("gplots")) {
  install.packages("gplots", dependencies = TRUE)
  library(gplots)
}
if (!require("RColorBrewer")) {
  install.packages("RColorBrewer", dependencies = TRUE)
  library(RColorBrewer)
}

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

heatmap.2(datos,
          #cellnote = datos,  # same data set for cell labels
          main = "porcentajes", # heat map title
          #notecol="black",      # change font color of cell labels to
          density.info="none",  # turns off density plot inside color 
          trace="none",         # turns off trace lines inside the heat
          margins =c(12,9),     # widens margins around plot
          col=my_palette,       # use on color palette defined earlier 
          #breaks=col_breaks,    # enable color transition at specified 
          dendrogram="none")     # only draw a row dendrogram 
