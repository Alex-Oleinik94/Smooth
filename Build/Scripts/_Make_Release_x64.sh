#echo off
cd ..
echo "======================================="
echo "| Compiling Release Version for Unix  |"
echo "======================================="
MKDIR Output
MKDIR Output/x86_64-release-desktop
make build_files
make inc_version_release
make release_x64
strip ../Binaries/Main
make clear_files
read -p "Press enter to continue..." nothing
