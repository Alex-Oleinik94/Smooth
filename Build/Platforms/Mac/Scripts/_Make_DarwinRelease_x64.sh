#echo off
cd ..
echo "=========================================="
echo "| Compiling release version for Mac OS X |"
echo "=========================================="
MKDIR Output
MKDIR Output/x86_64-release-desktop
make inc_version_release
make darwin_release_x64
strip ../Binaries/Main
make clear_files
read -p "Press enter to continue..." nothing
