#echo off
./_Create_Output_Directoryes.sh
./_Restore_Registration_Files.sh
cd ./..
echo "======================================="
echo "| Compiling release version for Unix  |"
echo "======================================="
make build_files
make inc_version_release
make release_x64
strip ../Binaries/Main
make clear_files
cd ./Scripts
read -p "Press enter to continue..." nothing
