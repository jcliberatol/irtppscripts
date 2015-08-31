mongod --fork --logpath /var/log/mongodb.log
while true
do
Rscript runscenarios.R
sleep 1
done
mongod --shutdown