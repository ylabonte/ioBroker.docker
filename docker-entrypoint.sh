#!/bin/sh

echo "Try to find an applicable backup to restore"
iobroker-restore.sh
echo "Start ioBroker"
iobroker start
echo "Watching ioBroker logs"
iobroker logs --watch
