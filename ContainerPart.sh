#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games

#Lets setup our objects so we can change things here, rather than in the scipt
DB=TC_splicecom
DUMP_FILE=/root/BackupScript/Backup.sql.gz
SENDTO=Send@to.address
SENDFROM=Send@from.address
THIS_SCRIPT=/root/BackupScript/ContainerPart.sh
DB_USERNAME=root
DB_PASSWORD=root

# Lock the database and sleep in the background task
mysql -u$DB_USERNAME -p$DB_PASSWORD $DB -e "FLUSH TABLES WITH READ LOCK; DO SLEEP(3600);" &
sleep 3

# Export and compress the database while it is still locked
mysqldump --hex-blob --skip-comments -u$DB_USERNAME -p$DB_PASSWORD $DB | gzip > $DUMP_FILE

# When finished, kill the previous background task to unlock
kill $! 2>/dev/null
wait $! 2>/dev/null
