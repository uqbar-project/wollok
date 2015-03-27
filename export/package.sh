#!/bin/bash
set -e

echo "Erasing previous files"

rm -f output.log
rm -f *.tar.gz
rm -f *.zip

touch output.log

echo "Generating Linux X86"
cd linux.gtk.x86
tar -czf "../linux.gtk.x86.tar.gz" "wollok" >> output.log
cd ..

echo "Generating Linux X86_64"
cd linux.gtk.x86_64
tar -czf "../linux.gtk.x86_64.tar.gz" "wollok" >> output.log
cd ..

echo "Generating MacOS X86"
cd macosx.cocoa.x86
zip -9 -r ../macosx.cocoa.x86.zip wollok >> output.log
cd ..

echo "Generating MacOS X86_64"
cd macosx.cocoa.x86_64
zip -9 -r ../macosx.cocoa.x86_64.zip wollok >> output.log
cd ..

echo "Generating Win32 X86"
cd win32.win32.x86
zip -9 -r ../win32.win32.x86.zip wollok >> output.log
cd ..

echo "Generating Win32 X86_64"
cd win32.win32.x86_64
zip -9 -r ../win32.win32.x86_64.zip wollok >> output.log
cd ..
