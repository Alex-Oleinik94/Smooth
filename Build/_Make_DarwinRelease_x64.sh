#echo off
echo "=========================================="
echo "| Compiling Release Version for Mac OSX  |"
echo "=========================================="
MKDIR CompiledUnits
MKDIR CompiledUnits/i386-other
make inc_version_release
make darwin_release_x64
strip ../Binaries/Main
make clear_files
read -p "Press enter to continue..." nothing
