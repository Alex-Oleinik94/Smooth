#echo off
echo "=========================================="
echo "| Compiling  Debug  Version for Mac OSX  |"
echo "=========================================="
mkdir Output
mkdir Output/i386-debug-desktop
make inc_version_debug
make darwin_debug
make clear_files
read -p "Press enter to continue..." nothing
