@echo off
cd ..
if not exist Output MKDIR Output
if not exist Output\AndroidApplication MKDIR Output\AndroidApplication
if not exist Output\AndroidApplication\libs MKDIR Output\AndroidApplication\libs
if not exist Output\AndroidApplication\libs\i386eabi MKDIR Output\AndroidApplication\libs\i386eabi
cd Scripts
CALL _Make_Packages android_i386 false
if "%1"=="" ( pause )
