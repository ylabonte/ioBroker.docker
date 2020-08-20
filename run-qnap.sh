#!/bin/bash

# These are the explicit values I use to run ioBroker on my Qnap NAS.
# The only new to the well commented, more general example (example-run-qnap.sh)
# is the ssh volume, where I have my ssh private key and config file, to open
# an ssh tunnel to my Raspberry Pi FHEM instance.
# See the prepare-qnap.sh to see how I apply my personalized changes to my
# public image...

IOBROKER_IMAGE="iobroker:latest"
IOBROKER_CONTAINER="iobroker"
IOBROKER_NET="qnet-static-bond0-434d21"
IOBROKER_IP="10.11.11.100"
IOBROKER_HOSTNAME="iobroker.yannic.labonte.cloud"
IOBROKER_BACKUP_VOLUME="iob-backups"
IOBROKER_SSH_VOLUME="iob-ssh"
LETSENCRYPT_VOLUME="letsencrypt"

docker run -d --name ${IOBROKER_CONTAINER} \
  --restart unless-stopped \
  --memory=4096M \
  --cpus=2 \
  --hostname ${IOBROKER_HOSTNAME} \
  --net ${IOBROKER_NET} \
  --ip ${IOBROKER_IP} \
  -v ${IOBROKER_BACKUP_VOLUME}:/opt/iobroker/backups \
  -v ${LETSENCRYPT_VOLUME}:/etc/letsencrypt \
  -v ${IOBROKER_SSH_VOLUME}:/home/iobroker/.ssh \
  ${IOBROKER_IMAGE}
