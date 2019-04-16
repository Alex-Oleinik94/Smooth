@echo off
cd ..
if not exist Output MKDIR Output
if not exist Output\AndroidApplication MKDIR Output\AndroidApplication
if not exist Output\AndroidApplication\libs MKDIR Output\AndroidApplication\libs
if not exist Output\AndroidApplication\libs\armeabi MKDIR Output\AndroidApplication\libs\armeabi
cd Scripts
CALL _Make_Extensions android_arm false
if "%1"=="" ( pause )
