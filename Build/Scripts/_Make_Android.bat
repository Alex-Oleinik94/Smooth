@echo off
CALL _Create_Output_Directoryes
cd ..
echo "======================================="
echo "|Compiling  Debug  Version for Android|"
echo "======================================="
MKDIR AndroidTools
MKDIR AndroidTools\SaGe
MKDIR AndroidTools\SaGe\libs
MKDIR AndroidTools\SaGe\libs\armeabi
make inc_version_debug
make android
@echo off
if "%1"=="" ( pause )
