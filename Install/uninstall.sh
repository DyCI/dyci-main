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

USER_HOME=$(eval echo ~${SUDO_USER})
log "USER_HOME = ${USER_HOME}"

DYCI_ROOT_DIR="${USER_HOME}/.dyci"
log "DYCI_ROOT_DIR='${USER_HOME}/.dyci'" 

CLANG_USR_BIN=`xcode-select -print-path`/Toolchains/XcodeDefault.xctoolchain/usr/bin/
CLANG_LOCATION=`xcode-select -print-path`/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
CLANG_BACKUP_LOCATION=$CLANG_LOCATION.backup
CLANG_REAL_LOCATION=$CLANG_LOCATION-real
CLANG_REAL_LOCATION_PP="$CLANG_LOCATION-real++"


echo
echo "======== Reverting clang from backup ======="

if [[ ! -f ${CLANG_BACKUP_LOCATION} ]]; then
	echo "== Hm... no clang backup. Was DYCI really installed?"
	echo 
else
    echo -n '== Restoring clang from backup : ' 
    log "sudo cp ${CLANG_BACKUP_LOCATION} ${CLANG_LOCATION}"
 	sudo cp "${CLANG_BACKUP_LOCATION}" "${CLANG_LOCATION}"

	if [ $? -gt 0 ]; then
		echo "Failed."
	    echo "== Something went wrong. Cannot restore old clang. Use -v option for motre detailed output"
	    echo
	else
		echo "Done."
	    echo -n "== Removing backup : "
	    log "sudo rm ${CLANG_REAL_LOCATION}"
	  	sudo rm "${CLANG_REAL_LOCATION}"

	    log "sudo rm ${CLANG_REAL_LOCATION_PP}"
	  	sudo rm "${CLANG_REAL_LOCATION_PP}"

	  	log "sudo rm ${CLANG_BACKUP_LOCATION}"
	    sudo rm "${CLANG_BACKUP_LOCATION}"
	    echo "Done."

	    echo -n "== Removing indexes : "
	    log "sudo rm -r ${DYCI_ROOT_DIR}"
	    sudo rm -r "${DYCI_ROOT_DIR}"
	    echo "Done."

	    echo "== DYCI was successfully uninstalled."
	    echo
	fi
fi

echo
echo "======== Removing DYCI Xcode plugin ======="
DYCI_XCODE_PLUGIN_DIR="${USER_HOME}/Library/Application Support/Developer/Shared/Xcode/Plug-ins/SFDYCIPlugin.xcplugin"
if [[ -d  "${DYCI_XCODE_PLUGIN_DIR}" ]]; then
    log "sudo rm -r ${DYCI_XCODE_PLUGIN_DIR}"
    sudo rm -r "${DYCI_XCODE_PLUGIN_DIR}"
else
	echo "== Hm... no DYCI plugin found. Was DYCI really installed?"
	echo 
fi



