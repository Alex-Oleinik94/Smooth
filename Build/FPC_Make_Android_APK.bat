echo off
echo "================"
echo "| Building APK |"
echo "================"
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
MKDIR res
MKDIR res\drawable-hdpi
MKDIR res\drawable-ldpi
MKDIR res\drawable-mdpi
MKDIR res\values
MKDIR src
MKDIR src\com
MKDIR src\com\pascal
MKDIR src\com\pascal\lcltest
CD ..\..\..
COPY AndroidTools\AndroidManifest.xml CompiledUnits\arm-android\android\AndroidManifest.xml
COPY AndroidTools\LCLActivity.java CompiledUnits\arm-android\android\src\com\pascal\lcltest\LCLActivity.java
COPY AndroidTools\SaGeDebugKey.keystore CompiledUnits\arm-android\android\bin\SaGeDebugKey.keystore
COPY AndroidTools\icon-hdpi.png CompiledUnits\arm-android\android\res\drawable-hdpi\icon.png
COPY AndroidTools\icon-ldpi.png CompiledUnits\arm-android\android\res\drawable-ldpi\icon.png
COPY AndroidTools\icon-mdpi.png CompiledUnits\arm-android\android\res\drawable-mdpi\icon.png
COPY AndroidTools\strings.xml CompiledUnits\arm-android\android\res\values\strings.xml
CD CompiledUnits\arm-android\android
CALL ..\..\..\AndroidTools\BuildDebugApk
CD ..\..\..
COPY CompiledUnits\arm-android\android\bin\SaGe.apk ..\Binaries\SaGe.apk
pause
