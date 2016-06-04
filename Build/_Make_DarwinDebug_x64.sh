#echo off
echo "=========================================="
echo "| Compiling  Debug  Version for Mac OSX  |"
echo "=========================================="
mkdir CompiledUnits
mkdir CompiledUnits/i386-other
make inc_version_debug
make darwin_debug_x64
make clear_files
read -p "Press enter to continue..." nothing
