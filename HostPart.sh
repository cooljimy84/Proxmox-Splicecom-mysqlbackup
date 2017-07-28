#!/bin/bash
# Setup time
ACTIVECONTAINERS=ActiveContainers.list
LOCATION=`pwd`

# List active containers to
lxc-ls --active -1 > $ACTIVECONTAINERS

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
	echo "Pull the Backup.sql.gz file and change its name to the container name"
	pct pull $name /root/BackupScript/Backup.sql.gz $name-`date +"%d%m%Y"`.sql.gz
	echo "Attach to the container to and remove script and backup file"
	lxc-attach -n $name -- rm -f /root/BackupScript/ContainerPart.sh
	lxc-attach -n $name -- rm -f /root/BackupScript/Backup.sql.gz
	echo "Next"
done

# Cleanup our active containers.list
rm -f $ACTIVECONTAINERS
