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

CLANG_USR_BIN=`xcode-select -print-path`/Toolchains/XcodeDefault.xctoolchain/usr/bin/
CLANG_LOCATION=`xcode-select -print-path`/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
CLANG_BACKUP_LOCATION=$CLANG_LOCATION.backup
CLANG_REAL_LOCATION=$CLANG_LOCATION-real


echo
echo -n "== Backing up clang : "

if [[ ! -f ${CLANG_BACKUP_LOCATION} ]]; then
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


if [[ -d "${USER_HOME}/Library/Preferences/appCode10" ]]; then
  echo -n "== AppCode found. Installing DYCI as AppCode external tool : "

  if [[ ! -d "${USER_HOME}/Library/Preferences/appCode10/tools" ]]; then
     mkdir -p "${USER_HOME}/Library/Preferences/appCode10/tools"
  fi

  log "sudo cp Support/AppCode/Dynamic Code Injection.xml ${USER_HOME}/Library/Preferences/appCode10/tools/"
  sudo cp Support/AppCode/Dynamic\ Code\ Injection.xml "${USER_HOME}/Library/Preferences/appCode10/tools/"

  DYCITOOL="${USER_HOME}/Library/Preferences/appCode10/tools/Dynamic Code Injection.xml"
  _scriptsDir="${DYCI_ROOT_DIR}/scripts"
  _script=${_scriptsDir}/dyci-recompile.py

 
  ## Escape path for sed using bash find and replace 
  _scriptsDir="${_scriptsDir//\//\\/}"
  _script="${_script//\//\\/}"

 
  # replace __RECOMPILE_SCRIPT_DIRECTORY__ in XML
  sudo sed -e "s/__RECOMPILE_SCRIPT_DIRECTORY__/${_scriptsDir}/" "${DYCITOOL}" > "${DYCITOOL}_TMP" && mv "${DYCITOOL}_TMP" "${DYCITOOL}"
  sudo sed -e "s/__RECOMPILE_SCRIPT__/${_script}/" "${DYCITOOL}"               > "${DYCITOOL}_TMP" && mv "${DYCITOOL}_TMP" "${DYCITOOL}"

  echo "Done."

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





