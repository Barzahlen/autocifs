#!/bin/bash

# AutoCIFS v1.0 Tests

# (c) 2012-2016 by Martin Seener (martin.seener@barzahlen.de)
# Licensed under the MIT License

testAutoCIFSDefaultParameters() {
  # Load AutoCIFS defaults for testing
  . etc/default/autocifs

  echo -e "\033[35mExecuting 9 Assert-Tests...\033[0m"

  echo -e "-> \033[34mChecking default SCRIPTPATH...\033[0m"
  assertTrue 'Check default SCRIPTPATH' "[ '${SCRIPTPATH}' == '/usr/local/bin/autocifs.sh' ]"

  echo -e "-> \033[34mCheck valid LOGLEVEL values...\033[0m"
  assertTrue 'Check valid LOGLEVEL values' "[ $LOGLEVEL -ge 0 -a $LOGLEVEL -le 2 ]"

  echo -e "-> \033[34mCheck that FILESERVER is not empty...\033[0m"
  assertTrue 'Check that FILESERVER is not empty' "[[ -n $FILESERVER ]]"

  echo -e "-> \033[34mCheck valid CIFSVERSCHECK value...\033[0m"
  assertTrue 'Check valid CFVERSCHECK value' "[ $CIFSVERSCHECK == 'SMB2' ]"

  echo -e "-> \033[34mCheck valid CIFSVERSMOUNT value...\033[0m"
  assertTrue 'Check valid CFVERSMOUNT value' "[ $CIFSVERSMOUNT == '2.1' ]"

  echo -e "-> \033[34mCheck that INTERVAL is a valid number...\033[0m"
  assertTrue 'Check that INTERVAL is a valid number' "[[ ${INTERVAL} =~ ^[0-9]+$ ]]"

  echo -e "-> \033[34mCheck that MOUNTS is not empty...\033[0m"
  assertTrue 'Check that MOUNTS is not empty' "[ ${#MOUNTS[@]} -ne 0 ]"

  echo -e "-> \033[34mCheck the default MOUNTSDELIMITER...\033[0m"
  assertTrue 'Check the default MOUNTSDELIMITER' "[ '${MOUNTSDELIMITER}' == '|' ]"

  echo -e "-> \033[34mCheck that ACIFSDEP is not empty...\033[0m"
  assertTrue 'Check that ACIFSDEP is not empty' "[ ${#ACIFSDEP[@]} -ne 0 ]"
}

. shunit2-2.1.6/src/shunit2
