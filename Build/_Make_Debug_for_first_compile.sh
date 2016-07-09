#echo off
echo "======================================="
echo "| Compiling  Debug  Version for Unix  |"
echo "======================================="
mkdir Sources/Temp
mkdir Output
mkdir Output/i386-debug-desktop
make debug
read -p "Press enter to continue..." nothing
