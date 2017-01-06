#echo off
cd ..
echo "======================================="
echo "| Compiling  Debug  Version for Unix  |"
echo "======================================="
mkdir Output
mkdir Output/i386-debug-desktop
make inc_version_debug
make debug
make clear_files
read -p "Press enter to continue..." nothing
