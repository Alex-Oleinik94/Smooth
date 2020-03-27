@echo off
CALL _Create_Output_Directoryes
cd ..
echo "======================================="
echo "|Compiling  debug  version for Windows|"
echo "======================================="
make clear_files
@echo off
make inc_version_debug
make debug
@echo off
make clear_files
cd Scripts
if "%2"=="" ( CALL _Check_Console )
if "%1"=="" ( pause )
