#!/bin/bash
# This script will refresh the data in the gvm-var-lib repo
# It will include a new db dump and the contents of /data/var-lib
# This should run from a cron with a long enough sleep to make sure
# the gvmd has updated the DB before creating the archive and pushing
# to github. It's probably not going to be useful to anyone but me
# but the output will benefit all. 
# Temp working directory ... needs enough space to pull the entire feed and then compress it. ~2G
TWD="/var/lib/openvas"
STIME="2m" # time between resync and archiving.
# Force a pull of the latest image.
docker pull immauss/openvas:latest
echo "Starting container for an update"
docker run -d --rm --name updater immauss/openvas
date
echo "Sleeping for $STIME to make sure the feeds are updated in the db"
sleep $STIME

cd $TWD
echo "First copy the feeds from the container"
docker cp updater:/data/var-lib .
echo "Now dump the db from postgres"
docker exec -i updater su -c "/usr/lib/postgresql/12/bin/pg_dumpall" postgres > ./base.sql 

echo "Stopping update container"
docker stop updater


echo "Compress and archive the data"
tar cJf var-lib.tar.xz var-lib
xz -1 base.sql
scp *.xz push@www.immauss.com:/var/www/html/openvas/

git clone git+ssh://git@github.com/immauss/openvas.git
cd openvas

date > update.ts
git commit update.ts -m "Data update for $Date"
echo "And pushing to github"
git push 
echo "Cleaning up"
cd ..
rm -rf openvas var-lib *.xz
echo "All done"


