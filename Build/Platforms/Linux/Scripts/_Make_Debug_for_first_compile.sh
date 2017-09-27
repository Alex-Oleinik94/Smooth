#echo off
./_Create_Output_Directoryes.sh
./_Restore_Registration_Files.sh
cd ./..
echo "======================================="
echo "| Compiling  Debug  Version for Unix  |"
echo "======================================="
make debug
cd ./Scripts
./_Check_Console.sh
read -p "Press enter to continue..." nothing
