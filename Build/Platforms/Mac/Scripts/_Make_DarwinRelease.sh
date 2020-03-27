#echo off
cd ..
echo "=========================================="
echo "| Compiling release version for Mac OS X |"
echo "=========================================="
MKDIR Output
MKDIR Output/i386-release-desktop
make inc_version_release
make darwin_release
strip ../Binaries/Main
make clear_files
read -p "Press enter to continue..." nothing
