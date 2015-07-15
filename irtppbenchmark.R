#Load the irtpp library

library(IRTpp)
#Simulate 100 tests of 10 items and 1000 individuals
x = simulateTest(model="2PL",items=10,individuals=1000,reps=100,threshold=0.05,seed=1)
#Calibrate these tests
ip=lapply(x$test,function(t)irtpp(t,2))
#Mean of the estimations
mn=Reduce("+",ip)/100
par(mfrow=c(1,3))
flat = lapply(ip,c)
pa = unlist(lapply(flat,function(x)x[1:10]))
pb = unlist(lapply(flat,function(x)x[11:20]))
pc = unlist(lapply(flat,function(x)x[21:30]))
hist(pa,breaks=30);rug(pa);
hist(pb,breaks=30);rug(pb);
hist(pc,breaks=30);rug(pc);
#Poblational parameters
matrix(c(unlist(x$itempars)),ncol=3)
#Estimation mean
mn
lapply(ip,function(x){sum(x[,3])})
ip[[98]]
est = irtpp(x$test[[100]],2)

ip[[100]]
est
