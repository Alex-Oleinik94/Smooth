@echo off
CALL _Create_Output_Directoryes
cd ..
echo "======================================="
echo "|Compiling  Debug  Version for Android|"
echo "======================================="
if not exist AndroidTools MKDIR AndroidTools
if not exist AndroidTools\SaGe MKDIR AndroidTools\SaGe
if not exist AndroidTools\SaGe\libs MKDIR AndroidTools\SaGe\libs
if not exist AndroidTools\SaGe\libs\i386eabi MKDIR AndroidTools\SaGe\libs\i386eabi
make inc_version_debug
make android_i386
cd Scripts
@echo off
if "%1"=="" ( pause )
