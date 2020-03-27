#echo off
cd ..
echo "==========================================="
echo "| Compiling  debug  version for Mac OS X  |"
echo "==========================================="
mkdir Output
mkdir Output/x86_64-debug-desktop
make inc_version_debug
make darwin_debug_x64
make clear_files
read -p "Press enter to continue..." nothing
