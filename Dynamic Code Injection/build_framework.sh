#!/bin/sh
xcodebuild -workspace DYCI.xcworkspace -scheme dyci-framework SYMROOT=../build
if [[ -d output ]]; then
   rm -r output
fi
mkdir output
cp -r build/Release-iphonesimulator/dyci.framework output/dyci.framework
