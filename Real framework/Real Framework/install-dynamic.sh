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

DEVELOPER_PATH=`xcode-select -print-path`
LOCAL_DEVELOPER_PATH="$HOME/Library/Developer"

TEMPLATES_DIR="Templates/Framework & Library"
SPECIFICATIONS_DIR="Developer/Library/Xcode/Specifications"
SPECIFICATIONS_FILE="UFW-iOSDynamicFramework.xcspec"
IOS_SPECIFICATIONS_PATH="Platforms/iPhoneOS.platform/$SPECIFICATIONS_DIR"
SIM_SPECIFICATIONS_PATH="Platforms/iPhoneSimulator.platform/$SPECIFICATIONS_DIR"

TEMPLATES_SRC_PATH="$SCRIPT_DIR/$TEMPLATES_DIR"
TEMPLATES_DST_PATH="$LOCAL_DEVELOPER_PATH/Xcode/$TEMPLATES_DIR"


# Get the install path
GLOBAL_DEVELOPER_PATH="$DEVELOPER_PATH"


IOS_SPECIFICATIONS_DST_PATH="$GLOBAL_DEVELOPER_PATH/$IOS_SPECIFICATIONS_PATH"
SIM_SPECIFICATIONS_DST_PATH="$GLOBAL_DEVELOPER_PATH/$SIM_SPECIFICATIONS_PATH"

if [[ -f "$IOS_SPECIFICATIONS_DST_PATH/$SPECIFICATIONS_FILE" && -f "$SIM_SPECIFICATIONS_DST_PATH/$SPECIFICATIONS_FILE" ]]; then
echo "  Skipping installation - Items was already installed"
echo 
echo " * $IOS_SPECIFICATIONS_DST_PATH/$SPECIFICATIONS_FILE"
echo " * $SIM_SPECIFICATIONS_DST_PATH/$SPECIFICATIONS_FILE"
exit 0
fi

# Last chance to back out
echo "iOS Real Static Framework Installer"
echo "==================================="
echo
echo "This will install the iOS static framework templates and support files on your computer."
echo "Note: Real static frameworks require two xcspec files to be added to Xcode."
echo
echo "*** THIS SCRIPT WILL ADD THE FOLLOWING FILES TO XCODE ***"
echo
echo " * $IOS_SPECIFICATIONS_PATH/$SPECIFICATIONS_FILE"
echo " * $SIM_SPECIFICATIONS_PATH/$SPECIFICATIONS_FILE"
echo
echo "The templates will be installed in $TEMPLATES_DST_PATH"
echo

read -p "continue [y/N]: " answer
echo
if [ "$answer" != "Y" ] && [ "$answer" != "y" ]; then
    echo
    echo "[ Cancelled ]"
    echo
    exit 1
fi


echo
echo "[ Installing xcspec file ]"
echo
echo sudo cp "$SCRIPT_DIR/$SPECIFICATIONS_FILE" "$IOS_SPECIFICATIONS_DST_PATH/"
sudo cp "$SCRIPT_DIR/$SPECIFICATIONS_FILE" "$IOS_SPECIFICATIONS_DST_PATH/"
echo sudo cp "$SCRIPT_DIR/$SPECIFICATIONS_FILE" "$SIM_SPECIFICATIONS_DST_PATH/"
sudo cp "$SCRIPT_DIR/$SPECIFICATIONS_FILE" "$SIM_SPECIFICATIONS_DST_PATH/"


# Install templates
echo
echo "[ Installing templates ]"
echo
echo mkdir -p "$TEMPLATES_DST_PATH"
mkdir -p "$TEMPLATES_DST_PATH"
cd "$TEMPLATES_SRC_PATH"
for template in *; do
	installpath="$TEMPLATES_DST_PATH/$template"
    echo rm -rf "$installpath"
    rm -rf "$installpath"
    echo cp -R "$template" "$installpath"
    cp -R "$template" "$installpath"
done

# Remove old version of unit test framework
rm -rf "$TEMPLATES_DST_PATH/Static iOS Framework Test.xctemplate"


echo
echo
echo "[ Installation complete. Please restart Xcode. ]"
echo
