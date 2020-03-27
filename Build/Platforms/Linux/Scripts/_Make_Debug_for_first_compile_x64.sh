#echo off
./_Create_Output_Directoryes.sh
./_Restore_Registration_Files.sh
cd ./..
echo "======================================="
echo "| Compiling  debug  version for Unix  |"
echo "======================================="
make debug_x64
cd ./Scripts
./_Check_Console.sh
read -p "Press enter to continue..." nothing
