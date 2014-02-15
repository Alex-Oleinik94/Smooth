echo off
echo "======================================="
echo "|Compiling  Debug  Version for Android|"
echo "======================================="
make android
CD CompiledUnits\arm-android\android
MKDIR bin
MKDIR bin\classes
MKDIR gen
MKDIR gen\com
MKDIR gen\com\pascal
MKDIR gen\com\pascal\lcltest
MKDIR raw
MKDIR raw\lib
MKDIR raw\lib\armeabi
CD ..\..\..
COPY AndroidTools\AndroidManifest.xml CompiledUnits\arm-android\android\AndroidManifest.xml
COPY AndroidTools\SaGeDebugKey.keystore CompiledUnits\arm-android\android\bin\SaGeDebugKey.keystore
CD CompiledUnits\arm-android\android
CALL ..\..\..\AndroidTools\BuildDebugApk
pause
