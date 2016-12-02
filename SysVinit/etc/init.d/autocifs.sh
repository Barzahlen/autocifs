#!/usr/bin/env bash
### BEGIN INIT INFO
# Provides:          autocifs
# Required-Start:    $network $named $remote_fs
# Required-Stop:     $network $named $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start / Stop / Restart AutoCIFS
# Description:       starts, stops or restarts the autocifs script which handles the cifs mounts
### END INIT INFO
# Author: Martin Seener <martin.seener@barzahlen.de>

# Load configuration
if [ -f "/etc/default/autocifs" ]; then
  . /etc/default/autocifs
else
  echo "Cannot find configuration file. Exiting."
  exit 3
fi

# Actions
case "$1" in
  start)
    # Check for a .pid file, otherwise run that sh..cript
    echo -n "Starting AutoCIFS: "
    if [ -f "/var/run/autocifs.pid" ]; then
      # .pid exists. Now we check if the process is dead
      /bin/ps aux | grep "`cat /var/run/autocifs.pid`" | grep -v grep > /dev/null 2>&1
      if [ $? -eq 0 ]; then
        # Process is running… Aborting.
        echo "AutoCIFS is still running. Aborting."
        exit 0
      else
        # Process is dead… Aborting.
        echo "/var/run/autocifs.pid exists. Process not running. Aborting."
        exit 1
      fi
    else
      # No .pid - we`re starting AutoCIFS.
      /bin/bash $SCRIPTPATH &
      echo "done."
      exit 0
    fi
    ;;
  stop)
    # Stopping AutoCIFS if its running
    echo -n "Stopping AutoCIFS: "
    if [ -f "/var/run/autocifs.pid" ]; then
      # .pid is in place. checking if process is there
      /bin/ps aux | grep "`cat /var/run/autocifs.pid`" | grep -v grep > /dev/null 2>&1
      if [ $? -eq 0 ]; then
        # Process is there too. Let us stop it
        kill -9 `cat /var/run/autocifs.pid`
        rm -f /var/run/autocifs.pid
        echo "done."
        exit 0
      else
        # No Process found
        echo "Nothing to stop. Please delete old /var/run/autocifs.pid."
        exit 1
      fi
    else
      # No .pid found. Nothing to stop
      echo "Nothing to stop."
      exit 3
    fi
    ;;
  restart)
    # Restarting AutoCIFS
    echo -n "Restarting AutoCIFS: ..."
    if [ -f "/var/run/autoCIFS.pid" ]; then
      # .pid is in place. checking if process is there
      /bin/ps aux | grep "`cat /var/run/autocifs.pid`" | grep -v grep > /dev/null 2>&1
      if [ $? -eq 0 ]; then
        # Process is there too. Let us stop it
        kill -9 `cat /var/run/autocifs.pid`
        rm -f /var/run/autocifs.pid
        echo -n "stopped ..."
        /bin/bash $SCRIPTPATH &
        echo "started."
        exit 0
      else
        # No Process found
        echo "Nothing to restart. Please delete old /var/run/autocifs.pid."
        exit 1
      fi
    else
      # No .pid found. Starting AutoCIFS
      echo -n "Nothing to stop. Starting AutoCIFS: "
      /bin/bash $SCRIPTPATH &
      echo "started."
      exit 0
    fi
    ;;
  status)
    # Getting the status of AutoCIFS
    echo -n "AutoCIFS is "
    if [ -f "/var/run/autocifs.pid" ]; then
      # .pid is in place. checking if process is there
      /bin/ps aux | grep "`cat /var/run/autocifs.pid`" | grep -v grep > /dev/null 2>&1
      if [ $? -eq 0 ]; then
        echo "running. PID File in place."
        exit 0
      else
        echo "not running. PID File in place."
        exit 1
      fi
    else
      echo "not running."
      exit 3
    fi
    ;;
esac
# Close Script
exit 0
