@echo off
cd ..
if not exist Output MKDIR Output
if not exist Output\AndroidApk MKDIR Output\AndroidApk
if not exist Output\AndroidApk\libs MKDIR Output\AndroidApk\libs
if not exist Output\AndroidApk\libs\i386eabi MKDIR Output\AndroidApk\libs\i386eabi
cd Scripts
CALL _Make_Packages android_i386 false
if "%1"=="" ( pause )
