@echo off
CALL _Create_Output_Directoryes
cd ..
echo "======================================="
echo "|Compiling  Debug  Version for Android|"
echo "======================================="
if not exist AndroidTools MKDIR AndroidTools
if not exist AndroidTools\SaGe MKDIR AndroidTools\SaGe
if not exist AndroidTools\SaGe\libs MKDIR AndroidTools\SaGe\libs
if not exist AndroidTools\SaGe\libs\armeabi MKDIR AndroidTools\SaGe\libs\armeabi
make inc_version_debug
make android_arm
cd Scripts
@echo off
if "%1"=="" ( pause )
