#echo off
./_Create_Output_Directoryes.sh
./_Restore_Registration_Files.sh
cd ./..
echo "======================================="
echo "| Compiling  debug  version for Unix  |"
echo "======================================="
make inc_version_debug
make debug_x64
make clear_files
cd ./Scripts
./_Check_Console.sh
read -p "Press enter to continue..." nothing
