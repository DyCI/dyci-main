#!/bin/bash

set -u
set -e

# Assume this script was called normally and hasn't been added to the path or symlinked
SCRIPT_DIR=$(dirname "$0")
if [[ $SCRIPT_DIR != /* ]]; then
    if [[ $SCRIPT_DIR == "." ]]; then
        SCRIPT_DIR=$PWD
    else
        SCRIPT_DIR=$PWD/$SCRIPT_DIR
    fi
fi

#resolving
DEVELOPER_PATH=`xcode-select -print-path`
LOCAL_DEVELOPER_PATH="$HOME/Library/Developer"

SPECIFICATIONS_DIR="Developer/Library/Xcode/Specifications"
SPECIFICATIONS_FILE="iOSDynamicFramework.xcspec"
IOS_SPECIFICATIONS_PATH="Platforms/iPhoneOS.platform/$SPECIFICATIONS_DIR"
SIM_SPECIFICATIONS_PATH="Platforms/iPhoneSimulator.platform/$SPECIFICATIONS_DIR"


# Get the install path

IOS_SPECIFICATIONS_DST_PATH="$DEVELOPER_PATH/$IOS_SPECIFICATIONS_PATH"
SIM_SPECIFICATIONS_DST_PATH="$DEVELOPER_PATH/$SIM_SPECIFICATIONS_PATH"


# Remove spec files
echo
echo "[ Removing custom specification files ]"
echo
echo sudo rm -f "$IOS_SPECIFICATIONS_DST_PATH/$SPECIFICATIONS_FILE"
sudo rm -f "$IOS_SPECIFICATIONS_DST_PATH/$SPECIFICATIONS_FILE"
echo sudo rm -f "$SIM_SPECIFICATIONS_DST_PATH/$SPECIFICATIONS_FILE"
sudo rm -f "$SIM_SPECIFICATIONS_DST_PATH/$SPECIFICATIONS_FILE"

echo
echo "[ Uninstall complete. Please restart Xcode. ]"
echo
