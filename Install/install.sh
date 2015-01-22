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

USER_HOME=$(eval echo ~${SUDO_USER})
log "USER_HOME = ${USER_HOME}"

DYCI_ROOT_DIR="${USER_HOME}/.dyci"
log "DYCI_ROOT_DIR='${USER_HOME}/.dyci'" 

echo -n "== Preparing dyci-recompile directories: "
if [[ ! -d "${DYCI_ROOT_DIR}/scripts" ]]; then

  mkdir -p "${DYCI_ROOT_DIR}/scripts"

  # not sure about this really
  chmod 777 "${DYCI_ROOT_DIR}"
  chmod 777 "${DYCI_ROOT_DIR}/scripts"
  echo "Done."
else
  echo "Skipped. (Already prepared)."  
fi

#Copying scripts
echo -n "== Copying scripts : "

cp Scripts/dyci-recompile.py "${DYCI_ROOT_DIR}/scripts/"
cp Scripts/clangParams.py "${DYCI_ROOT_DIR}/scripts/"
cp Scripts/xcactivity-parser.py "${DYCI_ROOT_DIR}/scripts/"

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
