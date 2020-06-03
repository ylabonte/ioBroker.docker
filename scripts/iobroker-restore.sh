#!/bin/sh

IOBROKER_DIR=/opt/iobroker

printf "Checking for backup: "

chown -R iobroker. ${IOBROKER_DIR}
MOST_RECENT_BACKUP=`ls -t ${IOBROKER_DIR}/backups/ | head -n 1`

if [ -n "${MOST_RECENT_BACKUP}" ]; then
  printf "Found '${MOST_RECENT_BACKUP}'\n"
  printf "Restoring backup: "
  iobroker restore ${IOBROKER_DIR}/backups/${MOST_RECENT_BACKUP} && printf "OK\n" || printf "ERROR\n"
  printf "Uploading Adapters: "
  iobroker upload all && printf "OK\n" || printf "ERROR\n"
else
  printf "No backup found. \nStarting from scratch...\n"
fi

exit 0
