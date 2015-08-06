library(IRTpp) 

tm = proc.time()
test = simulateTest(model = "3PL", items = 1000, individuals = 100000, reps = 1, directory = "/home/mirt/dataoutput/")
tm = tm - proc.time()

simulateTest
