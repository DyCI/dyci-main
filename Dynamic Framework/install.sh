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

if [[ -f "$IOS_SPECIFICATIONS_DST_PATH/$SPECIFICATIONS_FILE" && -f "$SIM_SPECIFICATIONS_DST_PATH/$SPECIFICATIONS_FILE" ]]; then
    echo "  Skipping installation - Items was already installed"
    echo 
    echo " * $IOS_SPECIFICATIONS_DST_PATH/$SPECIFICATIONS_FILE"
    echo " * $SIM_SPECIFICATIONS_DST_PATH/$SPECIFICATIONS_FILE"
    exit 0
fi

echo
echo "[ Installing xcspec file ]"
echo
echo sudo cp "$SCRIPT_DIR/$SPECIFICATIONS_FILE" "$IOS_SPECIFICATIONS_DST_PATH/"
sudo cp "$SCRIPT_DIR/$SPECIFICATIONS_FILE" "$IOS_SPECIFICATIONS_DST_PATH/"
echo sudo cp "$SCRIPT_DIR/$SPECIFICATIONS_FILE" "$SIM_SPECIFICATIONS_DST_PATH/"
sudo cp "$SCRIPT_DIR/$SPECIFICATIONS_FILE" "$SIM_SPECIFICATIONS_DST_PATH/"

echo
echo "[ Installation complete. Please restart Xcode. ]"
echo
