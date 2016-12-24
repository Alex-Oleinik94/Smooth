@echo off
CALL _Create_Output_Directoryes
CALL _Restore_FileRegistrationResources.bat false
cd ..
echo "======================================="
echo "|Compiling  Debug  Version for Windows|"
echo "======================================="
make debug_x64
pause
