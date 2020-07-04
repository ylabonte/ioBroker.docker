#!/bin/bash

# Start temporary container
docker run -d --name iob-temp labonte/iobroker:node12-buster

# Update packages, install ffmpeg, autossh, vim and finally do a little cleanup
docker exec -it iob-temp /bin/bash -c \
    "apt update && apt full-upgrade -y && apt install -y ffmpeg autossh vim && apt clean -y"

# Insert two lines into `/entrypoint.sh` (below line 15, this is between restore
# and startup) that opens a ssh tunnel to my Raspberry Pi FHEM instance telnet
# port. I use autossh for this. There is an additional volume mounted in my 
# `run-qnap-image.sh` that holds the ssh private key and config for host 'fhem'.
docker exec -it iob-temp /bin/sed -i \
    '15i echo \"# Establish ssh tunnel to FHEM instance\"\nsudo -u iobroker -H autossh -M 0 -f -N -L 7072:localhost:7072 fhem 2>&1\n' /entrypoint.sh

# Ensure the resulting image will try to auto-restore a backup on first startup
# as the base image does. There is a conditional auto-restore depending on this
# file inside the `docker-entrypoint.sh`.
docker exec -it iob-temp /bin/bash -c "rm ~/.restore"

# Create the new image
docker container commit iob-temp iobroker:latest

# Remove temporary container
docker container rm -f iob-temp

exit 0
