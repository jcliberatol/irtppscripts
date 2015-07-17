install.packages("/home/liberato/git/IRTpp_1.0.tar.gz", repos=NULL, type = "source")
library(IRTpp)
cuads = read.table("/home//liberato/git//IRTpp/inst/SICSRepository//SICS//Cuads.csv",sep=",",header=T);
data = as.matrix(read.table("/home//liberato/Downloads/Test_10_1_1000(1).csv",sep=" ",header=T))
cuads = as.matrix(cuads);
irtppinterface(as.matrix(data),2,cuads)
