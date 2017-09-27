@echo off
CALL _Create_Output_Directoryes
cd ..
echo "======================================="
echo "|Compiling  Debug  Version for Android|"
echo "======================================="
if not exist Output MKDIR Output
if not exist Output\AndroidApk MKDIR Output\AndroidApk
if not exist Output\AndroidApk\libs MKDIR Output\AndroidApk\libs
if not exist Output\AndroidApk\libs\i386eabi MKDIR Output\AndroidApk\libs\i386eabi
make inc_version_debug
make android_i386
cd Scripts
@echo off
if "%1"=="" ( pause )
