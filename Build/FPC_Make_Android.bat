echo off
echo "======================================="
echo "|Compiling  Debug  Version for Android|"
echo "======================================="
MKDIR CompiledUnits
MKDIR CompiledUnits\arm-android
MKDIR CompiledUnits\arm-android\android
MKDIR CompiledUnits\arm-android\android\libs
MKDIR CompiledUnits\arm-android\android\libs\armeabi
make android
pause
