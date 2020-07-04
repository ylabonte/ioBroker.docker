#!/bin/sh

IOBROKER_BACKUP_DIR=/opt/iobroker/backups
MOST_RECENT_BACKUP=0

printf "# Checking permissions for '%s' with user iobroker: " ${IOBROKER_BACKUP_DIR}
if [ $(sudo -u iobroker test -w "${IOBROKER_BACKUP_DIR}") ]; then
  printf "OK\n"
else
  if [ $(sudo -u iobroker test -r "${IOBROKER_BACKUP_DIR}") ] \
  && [ $(sudo -u iobroker test -x "${IOBROKER_BACKUP_DIR}") ]; then
    printf "PARTIALLY OK\n"
    printf "** WARNING: User iobroker cannot write to the backup directory (%s).\n" ${IOBROKER_BACKUP_DIR}
  else
    printf "FAILED\n"
  fi

  printf "# Trying to fix permissions for user iobroker: "
  FIX_PERMISSIONS=$(chown -R iobroker. "${IOBROKER_BACKUP_DIR}" && chmod -R u+rwX "${IOBROKER_BACKUP_DIR}")
  if [ $? -eq 0 ]; then
    printf "OK\n"
    printf "** INFO: Owner of '%s' has been set to iobroker.\n" ${IOBROKER_BACKUP_DIR}
  else
    printf "FAILED\n" 
    printf "** ERROR: User iobroker cannot access the backup directory (%s).\n" ${IOBROKER_BACKUP_DIR}
    
    exit 1
  fi
fi


printf "# Checking for existing files in ${IOBROKER_BACKUP_DIR}: "
EXISTING_BACKUPS_NUM=$(ls -l ${IOBROKER_BACKUP_DIR} | tail -n1 | awk '{print $2}')
if [ ${EXISTING_BACKUPS_NUM} -gt "0" ]; then
  printf "Got ${EXISTING_BACKUPS_NUM} backups\n"

  printf "# Identifying most recent backup: "
  MOST_RECENT_BACKUP=$(ls -t ${IOBROKER_BACKUP_DIR}/ | head -n 1)
  printf "Found '${MOST_RECENT_BACKUP}'\n"
  
  IOBROKER_BACKUP_FILE="${IOBROKER_BACKUP_DIR}/${MOST_RECENT_BACKUP}"
  printf "# Restoring backup:\n"
  iobroker restore "${IOBROKER_BACKUP_FILE}"
  
  printf "# Trigger upload for all adapters:\n"
  iobroker upload all

else
  printf "# Directory is empty\nStarting from scratch...\n"
fi

exit 0
