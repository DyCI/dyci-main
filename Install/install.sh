#!/bin/bash

# ============= Logging support ======================
_V=0
_SKIP_CLANG_PROXY=0

while getopts "vs" OPTION
do
  case $OPTION in
    v) _V=1
       ;;
    s) _SKIP_CLANG_PROXY=1
       ;; 
  esac
done


function log () {
    if [[ $_V -eq 1 ]]; then
        echo
        echo "$@"
    fi
}

# ============= Logging support ends ======================

# determining from which directory script is executed
DIR="$( cd -P "$( dirname "$0" )" && pwd )"
# going to that directory
cd "${DIR}"
cd ..

CLANG_LOCATION=`xcrun -find clang`
CLANG_USR_BIN=`dirname "${CLANG_LOCATION}"`
CLANG_BACKUP_LOCATION=$CLANG_LOCATION.backup
CLANG_REAL_LOCATION=$CLANG_LOCATION-real
CLANG_REAL_LOCATION_PP="$CLANG_LOCATION-real++"

echo
if [[ $_SKIP_CLANG_PROXY -eq 0 ]]; then
  echo -n "== Backing up clang : "
  if [[ ! -f ${CLANG_BACKUP_LOCATION} ]]; then
    # Checking, if it isn't our script laying in clang
    echo grep -Fq "== CLANG_PROXY ==" "$CLANG_LOCATION"
    if grep -Fq "== CLANG_PROXY ==" "$CLANG_LOCATION"  
      then
      # code if found
      # This is bad....
     echo "Original clang compiler was already proxied via dyci and no backup can be found."
     echo "This can be because of Xcode update without dyci uninstallation."
     echo "In case, if you see this, clang is little broken now, and you need to update it manually."
     echo "By running next command in your terminal : "
     echo "echo ""${CLANG_LOCATION}"" ""${CLANG_BACKUP_LOCATION}"" | xargs -n 1 cp /usr/bin/clang"
     exit 1
    fi
  # We should backup clang ONLY if it is an binary file only
    log " cp ${CLANG_LOCATION} ${CLANG_BACKUP_LOCATION}"
    cp "${CLANG_LOCATION}" "${CLANG_BACKUP_LOCATION}"
    log "echo Backup is at : ${CLANG_BACKUP_LOCATION}"
    echo "Done."
  else
    echo "Skipped."
    echo "   Seems dyci-clang has already been installed"
    log "Backup is at : ${CLANG_BACKUP_LOCATION}"
  fi

  echo -n "== Faking up clang : "

  log "cp ${CLANG_BACKUP_LOCATION} ${CLANG_REAL_LOCATION}"
  cp "${CLANG_BACKUP_LOCATION}" "${CLANG_REAL_LOCATION}"

  log " cp ${CLANG_BACKUP_LOCATION} ${CLANG_REAL_LOCATION_PP}"
  cp "${CLANG_BACKUP_LOCATION}" "${CLANG_REAL_LOCATION_PP}"
fi

#DYCI-CLANG RIGHTS
chmod +x Scripts/dyci-clang.py
chmod +x Scripts/dyci-recompile.py

log "cp Scripts/dyci-clang.py ${CLANG_LOCATION}"
log "cp Scripts/clangParams.py ${CLANG_USR_BIN}"

cp Scripts/dyci-clang.py "${CLANG_LOCATION}"
cp Scripts/clangParams.py "${CLANG_USR_BIN}"

echo "Done."

USER_HOME=$(eval echo ~${SUDO_USER})
log "USER_HOME = ${USER_HOME}"

DYCI_ROOT_DIR="${USER_HOME}/.dyci"
log "DYCI_ROOT_DIR='${USER_HOME}/.dyci'" 

echo -n "== Preparing dyci-recompile directories: "
log "if [[ ! -d ${DYCI_ROOT_DIR}/index ]]; then"
if [[ ! -d "${DYCI_ROOT_DIR}/index" ]]; then

  mkdir -p "${DYCI_ROOT_DIR}/index"
  mkdir -p "${DYCI_ROOT_DIR}/scripts"

  # not sure about this really
  chmod 777 "${DYCI_ROOT_DIR}"
  chmod 777 "${DYCI_ROOT_DIR}/index"
  chmod 777 "${DYCI_ROOT_DIR}/scripts"
  echo "Done."
else
  echo "Skipped. (Already prepared)."  
fi

#Copying scripts
echo -n "== Copying scripts : "

cp Scripts/dyci-recompile.py "${DYCI_ROOT_DIR}/scripts/"
cp Scripts/clangParams.py "${DYCI_ROOT_DIR}/scripts/"

echo "Done."


for i in $(seq 2 9)
  do 
	for j in $(seq 0 9)
		do
		    if [[ -d "${USER_HOME}/Library/Preferences/appCode${i}${j}" ]]; then
		      echo -n "== AppCode ${i}.${j} found. Installing DYCI as AppCode plugin : "

		      PLUGINS_DIRECTORY="${USER_HOME}/Library/Application Support/appCode${i}${j}"
		      PLUGIN_NAME="Dyci.jar"
		      if [[ ! -d "${PLUGINS_DIRECTORY}" ]]; then
		         mkdir -p "${PLUGINS_DIRECTORY}"
		      fi

		      log "cp Support/AppCode/Dyci/${PLUGIN_NAME} ${PLUGINS_DIRECTORY}"
		      cp "Support/AppCode/Dyci/${PLUGIN_NAME}" "${PLUGINS_DIRECTORY}"/

		      echo "Done."

		      echo "   Restart Appcode. Plugin should be loaded automaticaly. If not, you may need to install it manually"

		    fi
		done
done

echo -n "== Installing Xcode DYCI plugin : "
if [[ ! -d "${USER_HOME}/Library/Application Support/Developer/Shared/Xcode/Plug-ins" ]]; then
    mkdir -p "${USER_HOME}/Library/Application Support/Developer/Shared/Xcode/Plug-ins"
fi

cp -R Support/Xcode/Binary/*.* "${USER_HOME}/Library/Application Support/Developer/Shared/Xcode/Plug-ins/"
echo Done. 
echo "  Now you can use DYCI from the Xcode :P"


echo
echo "DYCI was successfully installed!"
echo "Use (^X) hot key in your IDE to perform code injections. Have fun."
echo
