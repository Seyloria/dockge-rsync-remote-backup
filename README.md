# dockge rsync remote backup

##### A small backup script written in bash to automatically backup your dockge files & container volumes.  It uses tar to compress the files into a single archive while preserving file ownership and permission rights. It then copies the file via rsync to your remote host backup location.


## Installation

Just download the dockge_backup.sh and make it executable 

```sh
curl -O  https://raw.githubusercontent.com/Seyloria/dockge-rsync-remote-backup/main/hide.me-sw.sh
chmod +x dockge_backup.sh
```


## Dependencies & Prerequisites
**SSH**, **tar** and **rsync** should be setup for your machine and the remote host where you'd like to store the backup. Use ssh key pairs if you wanna use it via a cronjob. You might want to use a privileged user or even root to run the script, as some files inside your docker volumes might not be readable otherwise(tar/rsync won't be able to backup all your files in that case)


## Usage

##### Edit the variables at the top of the script to suit your particular use case.

```sh
# Variables - Replace these with your matching values
# The dockge container must be named strictly 'dockge'!(declared with 'container_name: dockge' in the dockge related compose.yaml)
DATE_NOW=$(date +'%Y-%m-%d') # just the current date for tar backup naming
DOCKGE_DIR="/home/user/dockge" # dockge directory on your system
DOCKGE_APPS_DIR="/home/user/dockge/stacks" # dockge stacks directory | where the docker containers are located
BACKUP_DIR="/home/user/dockge_backup_tmp" # temporary directory for the backup tar file. Usually a folder in your home dir. DON'T create in advance!
SSH_PORT="22" # define your used ssh port
REMOTE_HOST_USER="root" # ssh user
REMOTE_HOST_ADR="11.22.33.44" # ssh backup server location address
REMOTE_HOST_DIR="/mnt/user/backup/servername/dockge/" # remote server backup path
```
If you need your backup and want to restore your files from an archive, make sure you preserve the ownership and permissions of the files after you've extracted them. You can do this by running tar as root, or by setting the **--same-owner** and **--preserve-permissions** flags when extracting.


## Suggestions
Use crontab to set up a cronjob with an interval of your choice to run the script periodically. Then run an additional script on the remote host that deletes, say, all archives older than 1 month.
##### The script might look as follows:
```sh
#!/bin/bash
find /mnt/user/backup/servername/dockge -type f -name "dockge_backup_*.tar.gz" -mtime +30 -delete
```
