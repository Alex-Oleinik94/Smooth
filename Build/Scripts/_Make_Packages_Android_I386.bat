@echo off
cd ..
if not exist AndroidTools MKDIR AndroidTools
if not exist AndroidTools\SaGe MKDIR AndroidTools\SaGe
if not exist AndroidTools\SaGe\libs MKDIR AndroidTools\SaGe\libs
if not exist AndroidTools\SaGe\libs\i386eabi MKDIR AndroidTools\SaGe\libs\i386eabi
cd Scripts
CALL _Make_Packages android_i386 false
if "%1"=="" ( pause )
