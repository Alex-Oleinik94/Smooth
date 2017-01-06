@echo off
CALL _Create_Output_Directoryes
cd ..
echo "======================================="
echo "|Compiling  Debug  Version for Windows|"
echo "======================================="
make clear_files
@echo off
make inc_version_debug
make lib
@echo off
make clear_files
pause
