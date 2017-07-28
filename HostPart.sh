#!/bin/bash
# Setup time
ACTIVECONTAINERS=ActiveContainers.list
LOCATION=`pwd`
LOGFILE=`pwd`/Hostlog.log
EMAILFROM=me@me.com
EMAILTO=me@me.com

# List active containers to
lxc-ls --active -1 > $ACTIVECONTAINERS

# Redirect output to log file
exec > >(tee -i $LOGFILE)

# Erm
for line in $(cat $ACTIVECONTAINERS)
do
        name="$line"
        echo "#########################################################"
        echo "Container number $name"
        echo "Lets create the directory for the script"
        lxc-attach -n $name -- mkdir /root/BackupScript/
        echo "Lets push the files we need to the container"
        pct push $name $LOCATION/ContainerPart.sh /root/BackupScript/ContainerPart.sh
        echo "chmod +x so we can run the bloodly thing"
        lxc-attach -n $name -- chmod +x /root/BackupScript/ContainerPart.sh
        echo "Attach to the container to run the script we just pushed"
        lxc-attach -n $name -- /root/BackupScript/./ContainerPart.sh
     		if [[ $? -eq 1 ]]; then
		echo "!!! mysql command failed within the container $name !!!"
		echo "Container $name failed the backup" >> $LOCATION/failed.log
		continue
	fi
	echo "Pull the Backup.sql.gz file and change its name to the container name"
	pct pull $name /root/BackupScript/Backup.sql.gz $name-`date +"%d%m%Y"`.sql.gz
	echo "Attach to the container to and remove script and backup file"
	lxc-attach -n $name -- rm -f /root/BackupScript/ContainerPart.sh
	lxc-attach -n $name -- rm -f /root/BackupScript/Backup.sql.gz
	echo "Backup completed"
done

# Cleanup our active containers.list
rm -f $ACTIVECONTAINERS

# Search for errors in the log file and if found send error email
if grep -q failed "$LOGFILE";
	then 
	cat $LOCATION/failed.log | mail -s "`hostname` backup failures" -r "$EMAILFROM" $MAILTO
	exit
fi
# Send log file to Email address any way if errors were not found
echo "Everything seems fine." | mail -s "`hostname` backup seems fine" -r "$EMAILFROM" $EMAILTO
