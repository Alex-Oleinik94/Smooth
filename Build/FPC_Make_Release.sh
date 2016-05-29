#echo off
echo "======================================="
echo "| Compiling Release Version for Unix  |"
echo "======================================="
MKDIR CompiledUnits
MKDIR CompiledUnits/i386-other
make inc_version_release
make build_files
make release
strip ../Binaries/Main
read -p "Press enter to continue..." nothing
