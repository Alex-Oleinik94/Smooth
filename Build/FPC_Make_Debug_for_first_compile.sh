#echo off
echo "======================================="
echo "| Compiling  Debug  Version for Unix  |"
echo "======================================="
mkdir CompiledUnits
mkdir CompiledUnits/i386-other
make debug
read -p "Press enter to continue..." nothing
