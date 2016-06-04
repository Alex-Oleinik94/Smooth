#echo off
echo "==========================================="
echo "| Compiling  Debug  Version for Mac OS X  |"
echo "==========================================="
mkdir CompiledUnits
mkdir CompiledUnits/i386-other
make darwin_debug
read -p "Press enter to continue..." nothing
