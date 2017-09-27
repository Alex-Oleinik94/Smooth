@echo off
CALL _Create_Output_Directoryes
CALL _Restore_Registration_Files.bat false
cd ..
echo "======================================="
echo "|Compiling  Debug  Version for Windows|"
echo "======================================="
make debug_x64
cd Scripts
if "%2"=="" ( CALL _Check_Console )
if "%1"=="" ( pause )
