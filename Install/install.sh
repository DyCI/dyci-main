#!/bin/bash

# ============= Logging support ======================
_V=0

while getopts "v" OPTION
do
  case $OPTION in
    v) _V=1
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
   echo "echo ""${CLANG_LOCATION}"" ""${CLANG_BACKUP_LOCATION}"" | xargs -n 1 sudo cp /usr/bin/clang"
   exit 1
  fi
# We should backup clang ONLY if it is an binary file only
  log "sudo cp ${CLANG_LOCATION} ${CLANG_BACKUP_LOCATION}"
  sudo cp "${CLANG_LOCATION}" "${CLANG_BACKUP_LOCATION}"
  log "echo Backup is at : ${CLANG_BACKUP_LOCATION}"
  echo "Done."
else
  echo "Skipped."
  echo "   Seems dyci-clang has already been installed"
  log "Backup is at : ${CLANG_BACKUP_LOCATION}"
fi

echo -n "== Faking up clang : "

log "sudo cp ${CLANG_BACKUP_LOCATION} ${CLANG_REAL_LOCATION}"
sudo cp "${CLANG_BACKUP_LOCATION}" "${CLANG_REAL_LOCATION}"

log "sudo cp ${CLANG_BACKUP_LOCATION} ${CLANG_REAL_LOCATION_PP}"
sudo cp "${CLANG_BACKUP_LOCATION}" "${CLANG_REAL_LOCATION_PP}"

#DYCI-CLANG RIGHTS
sudo chmod +x Scripts/dyci-clang.py
sudo chmod +x Scripts/dyci-recompile.py

log "sudo cp Scripts/dyci-clang.py ${CLANG_LOCATION}"
log "sudo cp Scripts/clangParams.py ${CLANG_USR_BIN}"

sudo cp Scripts/dyci-clang.py "${CLANG_LOCATION}"
sudo cp Scripts/clangParams.py "${CLANG_USR_BIN}"

echo "Done."

USER_HOME=$(eval echo ~${SUDO_USER})
log "USER_HOME = ${USER_HOME}"

DYCI_ROOT_DIR="${USER_HOME}/.dyci"
log "DYCI_ROOT_DIR='${USER_HOME}/.dyci'" 

echo -n "== Preparing dyci-recompile directories: "
log "if [[ ! -d ${DYCI_ROOT_DIR}/index ]]; then"
if [[ ! -d "${DYCI_ROOT_DIR}/index" ]]; then

  sudo mkdir -p "${DYCI_ROOT_DIR}/index"
  sudo mkdir -p "${DYCI_ROOT_DIR}/scripts"

  # not sure about this really
  sudo chmod 777 "${DYCI_ROOT_DIR}"
  sudo chmod 777 "${DYCI_ROOT_DIR}/index"
  sudo chmod 777 "${DYCI_ROOT_DIR}/scripts"
  echo "Done."
else
  echo "Skipped. (Already prepared)."  
fi

#Copying scripts
echo -n "== Copying scripts : "

sudo cp Scripts/dyci-recompile.py "${DYCI_ROOT_DIR}/scripts/"
sudo cp Scripts/clangParams.py "${DYCI_ROOT_DIR}/scripts/"

echo "Done."

if [[ -d "${USER_HOME}/Library/Preferences/appCode20" ]]; then
  echo -n "== AppCode found. Installing DYCI as AppCode plugin : "

  PLUGINS_DIRECTORY="${USER_HOME}/Library/Application Support/appCode20"    
  PLUGIN_NAME="Dyci Plugin.jar"
  if [[ ! -d "${PLUGINS_DIRECTORY}" ]]; then
     mkdir -p "${PLUGINS_DIRECTORY}"
  fi

  log "cp Support/AppCode/${PLUGIN_NAME} ${PLUGINS_DIRECTORY}"
  cp "Support/AppCode/${PLUGIN_NAME}" "${PLUGINS_DIRECTORY}"/

  echo "Done."

  echo "   Restart Appcode. Plugin should be loaded automaticaly. If not, you may need to install it manually"

fi

echo -n "== Installing Xcode DYCI plugin : "
if [[ ! -d "${USER_HOME}/Library/Application Support/Developer/Shared/Xcode/Plug-ins" ]]; then
    mkdir -p "${USER_HOME}/Library/Application Support/Developer/Shared/Xcode/Plug-ins"
fi

cp -R Support/Xcode/Binary/*.* "${USER_HOME}/Library/Application Support/Developer/Shared/Xcode/Plug-ins/"
echo Done. 
echo "  Now you can use DYCI from the Xcode :P (^X)"


echo
echo "DYCI was successfully installed!"
echo