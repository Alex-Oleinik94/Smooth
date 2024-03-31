@echo off
CALL _Create_Output_Directoryes
cd ..
echo "======================================="
echo "|Compiling  debug  version for Android|"
echo "======================================="
if not exist Output MKDIR Output
if not exist Output\AndroidApplication MKDIR Output\AndroidApplication
if not exist Output\AndroidApplication\libs MKDIR Output\AndroidApplication\libs
if not exist Output\AndroidApplication\libs\armeabi MKDIR Output\AndroidApplication\libs\armeabi
make inc_version_debug
make android_arm
cd Scripts
@echo off
if "%1"=="" ( pause )
