#echo off
cd ..
echo "==========================================="
echo "| Compiling  debug  version for Mac OS X  |"
echo "==========================================="
mkdir Sources/Temp
mkdir Output
mkdir Output/i386-debug-desktop
make darwin_debug
read -p "Press enter to continue..." nothing
