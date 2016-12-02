#!/usr/bin/env bash

# AutoCIFS v1.0

# (c) 2012-2016 by Martin Seener (martin.seener@barzahlen.de)
# Licensed under the MIT License

# Load the configuration file
if [ -f "/etc/default/autocifs" ]; then
  . /etc/default/autocifs
else
  if [ $LOGLEVEL -ge 1 ]; then logger -t autocifs "Cannot find configuration file. Exiting."; fi
  exit 3
fi

# Check the dependencies
check_dependencies() {
  param_array=$1[@]
  work_array=("${!param_array}")

  for CMD in ${work_array[@]}
  do
    type -p $CMD >/dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo -e "\e[01;31mSorry, but > $CMD < cannot be found on this machine! Dependencies are not completly met.\e[00m"
      logger -t autocifs "Sorry, but > $CMD < cannot be found on this machine! Dependencies are not completly met."
      exit 1
    fi
  done
}

check_dependencies ACIFSDEP

# Write PID to a PIDFILE for later process kill
# The init script handles the kill process and if there`s already a process running
echo $$ > /var/run/autocifs.pid

declare -a MNTPATH
while true; do
  # First check if Fileserver is serving CIFS and has some shares
  /usr/bin/smbclient -L //"${FILESERVER}" -U "${USERNAME}%${PASSWORD}" -m "${CIFSVERSCHECK}" -g 2>/dev/null | grep "Disk|" >/dev/null
  if [ $? -ne 0 ]; then
    # First check failed, therefore doing it twice after a second
    if [ $LOGLEVEL -ge 1 ]; then logger -t autocifs "Fileserver[${FILESERVER}] seems to be down - Rechecking in a second"; fi
    sleep 1
    /usr/bin/smbclient -L //"${FILESERVER}" -U "${USERNAME}%${PASSWORD}" -m "${CIFSVERSCHECK}" -g 2>/dev/null | grep "Disk|" >/dev/null
    if [ $? -eq 0 ]; then
      # Second check was succssful, checking if all CIFS Shares are mounted
      if [ $LOGLEVEL -ge 1 ]; then logger -t autocifs "Fileserver[${FILESERVER}] is up"; fi
      for MOUNT in ${MOUNTS[@]}; do
        # Split the share if it has a different remote and local mountpoint
        # Both will be the same if the mountpoints are so too
        MNTPATH=( $(echo ${MOUNT//$MOUNTSDELIMITER/ }) )
        RMNTPATH=${MNTPATH[0]}
        LMNTPATH=${MNTPATH[${#MNTPATH[@]}-1]}
        # Let's check if its already mounted
        mount | grep -E "^//${FILESERVER}/${RMNTPATH} on .*$" &>/dev/null
        if [ $? -ne 0 ]; then
          # The actual CIFS Share is not mounted, so it will be done now
          if [ $LOGLEVEL -eq 2 ]; then logger -t autocufs "CIFS-Share[${MOUNT}] not mounted - attempting to mount it from: //${FILESERVER}/${MOUNT}"; fi
          mount -t cifs //"${FILESERVER}/${RMNTPATH}" ${LMNTPATH} -o "user=${USERNAME},password=${PASSWORD},vers=${CIFSVERSMOUNT}"
        fi
      done
    else
      # The Fileserver was not reachable two times, unmounting shares which are still mounted
      if [ $LOGLEVEL -ge 1 ]; then logger -t autocifs "Fileserver(${FILESERVER}) is down."; fi
      for MOUNT in ${MOUNTS[@]}; do
        # Split the share if it has a different remote and local mountpoint
        # Both will be the same if the mountpoints are so too
        MNTPATH=( $(echo ${MOUNT//$MOUNTSDELIMITER/ }) )
        RMNTPATH=${MNTPATH[0]}
        LMNTPATH=${MNTPATH[${#MNTPATH[@]}-1]}
        # Let's check if its already mounted
        mount | grep -E "^//${FILESERVER}/${RMNTPATH} on .*$" &>/dev/null
        if [ $? -eq 0 ]; then
          if [ $LOGLEVEL -ge 1 ]; then logger -t autocifs "Cannot reach ${FILESERVER}, therefore unmounting CIFS-Share[${LMNTPATH}]"; fi
          umount -f ${LMNTPATH}
        fi
      done
    fi
  else
    # First check succeeded, so just checking if all CIFS-Shares are mounted
    if [ $LOGLEVEL -eq 2 ]; then logger -t autocifs "Fileserver[${FILESERVER}] is up"; fi
    for MOUNT in ${MOUNTS[@]}; do
      # Split the share if it has a different remote and local mountpoint
      # Both will be the same if the mountpoints are so too
      MNTPATH=( $(echo ${MOUNT//$MOUNTSDELIMITER/ }) )
      RMNTPATH=${MNTPATH[0]}
      LMNTPATH=${MNTPATH[${#MNTPATH[@]}-1]}
      # Let's check if its already mounted
      mount | grep -E "^//${FILESERVER}/${RMNTPATH} on .*$" &>/dev/null
      if [ $? -ne 0 ]; then
        # The actual CIFS Share is not mounted, so it will be done now
        if [ $LOGLEVEL -eq 2 ]; then logger -t autocifs "CIFS-Share[${MOUNT}] not mounted - attempting to mount it from: //${FILESERVER}/${MOUNT}"; fi
        mount -t cifs //"${FILESERVER}/${RMNTPATH}" ${LMNTPATH} -o "user=${USERNAME},password=${PASSWORD},vers=${CIFSVERSMOUNT}"
      fi
    done
  fi
  # Gone through the check iteration - sleeping now for a while
  sleep $INTERVAL
done
