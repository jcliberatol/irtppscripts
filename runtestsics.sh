mongod --fork --logpath /var/log/mongodb.log
while true
do
Rscript runscenariossics.R
sleep 1
done
mongod --shutdown