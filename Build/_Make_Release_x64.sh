#echo off
echo "======================================="
echo "| Compiling Release Version for Unix  |"
echo "======================================="
MKDIR CompiledUnits
MKDIR CompiledUnits/i386-other
make build_files
make inc_version_release
make release_x64
strip ../Binaries/Main
make clear_files
read -p "Press enter to continue..." nothing
