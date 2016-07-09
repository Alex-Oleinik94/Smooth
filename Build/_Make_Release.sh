#echo off
echo "======================================="
echo "| Compiling Release Version for Unix  |"
echo "======================================="
MKDIR Output
MKDIR Output/i386-release-desktop
make build_files
make inc_version_release
make release
strip ../Binaries/Main
make clear_files
read -p "Press enter to continue..." nothing
