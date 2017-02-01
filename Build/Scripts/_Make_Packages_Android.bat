@echo off
cd ..
MKDIR AndroidTools
MKDIR AndroidTools\SaGe
MKDIR AndroidTools\SaGe\libs
MKDIR AndroidTools\SaGe\libs\armeabi
cd Scripts
CALL _Make_Packages android false
if "%1"=="" ( pause )
