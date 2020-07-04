#!/bin/bash

# This is an example on how to run this ioBroker image with a static IP over
# a bridged network interface in your local network on your Qnap NAS with 
# Container Station.
#
# To have this said: You can also do that using the Container Station GUI!
# I just added this to the repo, because I preferred to use the docker cli
# and it took me a moment to gather all relevant console parameters...

## Image
# You might want to build your own image and replace the url below.
IOBROKER_IMAGE="labonte/iobroker:latest"

## Container name
IOBROKER_CONTAINER="iobroker"

## Network interface
# Then pick the right network interface.
# (eg. use `docker network ls` to display them)
IOBROKER_NET="qnet-static-bond0-434d21"

## Static ip address
IOBROKER_IP="10.11.11.100"

## Hostname
IOBROKER_HOSTNAME="iobroker.qnap.int"

## Backup volume
# Assuming you want to use a bind mount on your Qnap NAS, specify the full
# path to your ioBroker backup directory. Otherwise you can just leave a
# name for a named volume, that will then be created on container launch.
IOBROKER_BACKUP_VOLUME="/share/Container/container-station-data/application/iobroker-backups"

## Letsencrypt volume
# Finally define where to find your letsencrypt volume. If you will not use
# letsencrypt with this container, you might completely remove the volume
# (from the Dockerfile, when building your own image), but at least remove
# the line `-v ${LETSENCRYPT_VOLUME}:/etc/letsencrypt \` below.
LETSENCRYPT_VOLUME="/share/Container/container-station-data/application/letsencrypt"

## Run container
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
