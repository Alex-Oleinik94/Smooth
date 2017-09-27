@echo off
cd ..
if not exist Output MKDIR Output
if not exist Output\AndroidApk MKDIR Output\AndroidApk
if not exist Output\AndroidApk\libs MKDIR Output\AndroidApk\libs
if not exist Output\AndroidApk\libs\armeabi MKDIR Output\AndroidApk\SaGe\libs\armeabi
cd Scripts
CALL _Make_Packages android_arm false
if "%1"=="" ( pause )
