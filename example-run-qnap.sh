#!/bin/bash

# This is an example on how to run this ioBroker image with a static IP on 
# your Qnap NAS with Container Station and a bridged network interface using 
# the docker cli. Of course, you can also use the Container Station GUI...
# but if you are building your own image, you are probably already using and
# maybe preferring the docker cli. ;)

# You can build your own image and replace the url, if you want.
IOBROKER_IMAGE="labonte/iobroker:latest"
# First choose a name for the container.
IOBROKER_CONTAINER="iobroker"
# Then pick the right network interface. (eg. use `docker network ls` to display them)
IOBROKER_NET="qnet-static-bond0-434d21"
# Now set the static IP address.
IOBROKER_IP="10.11.11.100"
# Chose a hostname.
IOBROKER_HOSTNAME="iobroker.qnap.int"
# Define where to find your backup volume.
IOBROKER_BACKUP_VOLUME="/share/Container/container-station-data/application/iobroker-backups"
# Finally define where to find your letsencrypt volume.
LETSENCRYPT_VOLUME="/share/Container/container-station-data/application/letsencrypt"

# Let's run this container...
docker run -d --name ${IOBROKER_CONTAINER} \
  --restart unless-stopped \
  --memory=4096M \
  --cpus=1 \
  --hostname ${IOBROKER_HOSTNAME} \
  --net ${IOBROKER_NET} \
  --ip ${IOBROKER_IP} \
  -v ${IOBROKER_BACKUP_VOLUME}:/opt/iobroker/backups \
  -v ${LETSENCRYPT_VOLUME}:/etc/letsencrypt \
  ${IOBROKER_IMAGE}
