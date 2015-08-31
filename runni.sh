mongod --fork --logpath /var/log/mongodb.log
while true
do
    Rscript runscenarios2.R
    sleep 1
done
mongod --shutdown
