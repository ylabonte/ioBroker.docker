#!/bin/sh

# Only try to automatically restore from backup at first start
if [ ! -f ~/.restore ];then
    echo "# Starting restore script"
    iobroker-restore.sh \
    && echo "# (remove ~/.restore to re-run on next startup)" \
    && printf "# Restored from '%s' at %s\n" ${IOBROKER_BACKUP_FILE} $(date) >> ~/.restore \
    || printf "# Restore failed (%s)\n" $(date) >> ~/.restore
else
    printf "# Restore skipped (%s)\n" $(date) >> ~/.restore
    echo "# Skipping restore script"
fi

echo "# Starting ioBroker"
iobroker start

echo "# Start watching the ioBroker logs"
iobroker logs --watch
