@echo off
echo "======================================="
echo "|Compiling  Debug  Version for Android|"
echo "======================================="
MKDIR CompiledUnits
MKDIR AndroidTools
MKDIR AndroidTools\SaGe
MKDIR AndroidTools\SaGe\libs
MKDIR AndroidTools\SaGe\libs\armeabi
make android
SET ZEROSTRING=
if "%1"=="" ( pause )
