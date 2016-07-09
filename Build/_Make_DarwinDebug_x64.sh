#echo off
echo "=========================================="
echo "| Compiling  Debug  Version for Mac OSX  |"
echo "=========================================="
mkdir Output
mkdir Output/x86_64-debug-desktop
make inc_version_debug
make darwin_debug_x64
make clear_files
read -p "Press enter to continue..." nothing
