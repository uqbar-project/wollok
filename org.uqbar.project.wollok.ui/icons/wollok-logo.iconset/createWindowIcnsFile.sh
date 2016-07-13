#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
   echo "Running on Mac..."
   iconutil -c icns .
else
   echo "Running on linux..."
   png2icns ../wollok-logo.icns icon_*.png
fi
