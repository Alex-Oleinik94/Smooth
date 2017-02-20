@echo off
cd ..
if not exist AndroidTools MKDIR AndroidTools
if not exist AndroidTools\SaGe MKDIR AndroidTools\SaGe
if not exist AndroidTools\SaGe\libs MKDIR AndroidTools\SaGe\libs
if not exist AndroidTools\SaGe\libs\armeabi MKDIR AndroidTools\SaGe\libs\armeabi
cd Scripts
CALL _Make_Packages android_arm false
if "%1"=="" ( pause )
