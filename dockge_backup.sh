#!/usr/bin/env bash

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

#------------ Script starts here ------------

# Show running containers
tput bold; tput setaf 0; tput setab 5; echo -e "\nThe following docker containers are currently running"; tput sgr0
# Short version of docker ps
docker ps --format '{{.Names}}'


# Stop dockge container
tput bold; tput setaf 0; tput setab 5; echo -e "\nStopping dockge"; tput sgr0
cd "$DOCKGE_DIR" && docker compose stop

# Takes all running docker containers and puts them into an array
declare -a dockerContainers
mapfile -t dockerContainers < <(docker ps --format "{{.Names}}")

tput bold; tput setaf 0; tput setab 5; echo -e "\n\nStopping docker containers"; tput sgr0
for container in "${dockerContainers[@]}"; do
	if [ $container != "dockge" ]; then
		echo "Stopping $container"
		cd "$DOCKGE_APPS_DIR/$container"
		docker compose stop
		sleep 0.5
	else
		:
	fi
done

sleep 2 #Short sleep to be sure all containers are stopped

tput bold; tput setaf 0; tput setab 3; echo -e "\n\nChecking if all docker containers are correctly stopped"; tput sgr0
DOCKER_ACTIVE=$(docker ps --format '{{.Names}}')
if [ -z "$DOCKER_ACTIVE" ]; then
	tput bold; tput setaf 2; tput setab 0; echo -e "All containers stopped...proceeding with backup\n"; tput sgr0
	tput bold; tput setaf 0; tput setab 3; echo -e "Starting tar compression and rsync copy"; tput sgr0
	# tar complete dockge dir and copy them with rsync to remote host
	mkdir $BACKUP_DIR && tar czPf $BACKUP_DIR/dockge_backup_$DATE_NOW.tar.gz $DOCKGE_DIR && sleep 2 && \
	rsync --progress --numeric-ids -azbhe "ssh -p $SSH_PORT" $BACKUP_DIR/dockge_backup_*.tar.gz "$REMOTE_HOST_USER"@"$REMOTE_HOST_ADR":"$REMOTE_HOST_DIR" && \
	rm -rf $BACKUP_DIR && tput bold; tput setaf 0; tput setab 6; echo -e "tar compression and rsync copy done..."; tput sgr0
else
	tput bold; tput setaf 1; tput setab 0; echo -e "The following docker containers are still running:"; tput sgr0
	echo -e "$DOCKER_ACTIVE\n"
	tput bold; tput setaf 1; tput setab 0; echo -e "Aborting backup and starting docker containers again\n"; tput sgr0
fi

# Start dockge again
tput bold; tput setaf 0; tput setab 6; echo -e "\n\nStarting dockge again"; tput sgr0
cd "$DOCKGE_DIR" && docker compose start

# Start the Docker applications
tput bold; tput setaf 0; tput setab 6; echo -e "\nStarting docker containers again"; tput sgr0
for container in "${dockerContainers[@]}"; do
	if [ $container != "dockge" ]; then
		echo "Stopping $container"
		cd "$DOCKGE_APPS_DIR/$container"
		docker compose start
		sleep 0.5
	else
		:
	fi
done

#for dockerApp in "${dockerApps[@]}"
#do
#  echo "Starting up $dockerApp:"
#  cd "$DOCKGE_APPS_DIR/$dockerApp"
#  docker compose start
#  sleep 1
#done

tput bold; tput setaf 0; tput setab 6; echo -e "\n\nDocker containers are started and running again"; tput sgr0
docker ps
tput bold; tput setaf 0; tput setab 6; echo -e "\nScript done...bye..."; tput sgr0
