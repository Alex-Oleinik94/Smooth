@echo off
CALL _Create_Output_Directoryes
cd ..
echo "======================================="
echo "|Compiling  Debug  Version for Android|"
echo "======================================="
echo "======================================="
if not exist Output MKDIR Output
if not exist Output\AndroidApk MKDIR Output\AndroidApk
if not exist Output\AndroidApk\libs MKDIR Output\AndroidApk\libs
if not exist Output\AndroidApk\libs\armeabi MKDIR Output\AndroidApk\SaGe\libs\armeabi
make inc_version_debug
make android_arm
cd Scripts
@echo off
if "%1"=="" ( pause )
