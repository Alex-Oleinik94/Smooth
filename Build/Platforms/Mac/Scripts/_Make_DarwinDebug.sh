#echo off
cd ..
echo "=========================================="
echo "| Compiling  debug  version for Mac OS X |"
echo "=========================================="
mkdir Output
mkdir Output/i386-debug-desktop
make inc_version_debug
make darwin_debug
make clear_files
read -p "Press enter to continue..." nothing
