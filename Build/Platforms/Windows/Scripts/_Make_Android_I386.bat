@echo off
CALL _Create_Output_Directoryes
cd ..
echo "======================================="
echo "|Compiling  debug  version for Android|"
echo "======================================="
if not exist Output MKDIR Output
if not exist Output\AndroidApplication MKDIR Output\AndroidApplication
if not exist Output\AndroidApplication\libs MKDIR Output\AndroidApplication\libs
if not exist Output\AndroidApplication\libs\i386eabi MKDIR Output\AndroidApplication\libs\i386eabi
make inc_version_debug
make android_i386
cd Scripts
@echo off
if "%1"=="" ( pause )
