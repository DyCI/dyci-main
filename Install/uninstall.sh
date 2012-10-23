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

DCI_ROOT_DIR="${USER_HOME}/.dci"
log "DCI_ROOT_DIR='${USER_HOME}/.dci'" 

CLANG_USR_BIN=`xcode-select -print-path`/Toolchains/XcodeDefault.xctoolchain/usr/bin/
CLANG_LOCATION=`xcode-select -print-path`/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
CLANG_BACKUP_LOCATION=$CLANG_LOCATION.backup
CLANG_REAL_LOCATION=$CLANG_LOCATION-real

echo
echo "======== Revertin clang from backup ======="

if [[ ! -f ${CLANG_BACKUP_LOCATION} ]]; then
	echo "== Hm... no clang backup. Was DCI really installed?"
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
	  	log "sudo rm ${CLANG_BACKUP_LOCATION}"
	    sudo rm "${CLANG_BACKUP_LOCATION}"
	    echo "Done."

	    echo -n "== Removing indexes : "
	    log "sudo rm -r ${DCI_ROOT_DIR}"
	    sudo rm -r "${DCI_ROOT_DIR}"
	    echo "Done."

	    echo "== DCI was successfully uninstalled."
	    echo
	fi
fi

