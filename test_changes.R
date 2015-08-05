library(IRTpp)
library(numDeriv)

wrapper.loglik<-function(test,traits,z)
{
  items.default=parameter.list(matrix(z,ncol=3))
  loglik(test=test, traits= traits, z=items.default)
}

model="3PL"
model=3
items=20
individuals=1000
seed=1
testArr = simulateTest(items=items,individuals=individuals,reps=1,model=model,seed=seed,threshold=0.05)
ret=NULL
ret$est.irtpp.items = irtpp(dataset=testArr$test[[1]],model=model)
ret$ltt.irtpp = individual.traits(dataset=testArr$test[[1]],model=model,itempars=ret$est.irtpp.items,method="EAP");
ret$map.irtpp = individual.traits(dataset=testArr$test[[1]],model=model,itempars=ret$est.irtpp.items,method="MAP")
ret$loglik.irtpp.map = loglik(ret$map.irtpp$patterns,ret$map.irtpp$trait,parameter.list(ret$est.irtpp.items)) 
ret$loglik.irtpp.eap = loglik(ret$ltt.irtpp$patterns,ret$ltt.irtpp$trait,parameter.list(ret$est.irtpp.items))
items.vector = c(ret$est.irtpp.items)
ret$gradient.irtpp.map = grad(wrapper.loglik, test=ret$map.irtpp$patterns,traits=ret$map.irtpp$trait,x=items.vector)
ret$gradient.irtpp.eap = grad(wrapper.loglik, test=ret$ltt.irtpp$patterns,traits=ret$map.irtpp$trait,x=items.vector)
ret$gradient.irtpp.map = hessian(wrapper.loglik, test=ret$map.irtpp$patterns,traits=ret$map.irtpp$trait,x=items.vector)
ret$gradient.irtpp.eap = hessian(wrapper.loglik, test=ret$ltt.irtpp$patterns,traits=ret$map.irtpp$trait,x=items.vector)
