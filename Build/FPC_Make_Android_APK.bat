@echo off
DEL AndroidTools\SaGe /F/S/Q
CALL FPC_Make_Android cmd
echo "================"
echo "| Building APK |"
echo "================"
CD AndroidTools\SaGe
MKDIR bin
MKDIR res
MKDIR src
MKDIR res\drawable-hdpi
MKDIR res\drawable-ldpi
MKDIR res\drawable-mdpi
MKDIR res\values
CD ..\..

COPY AndroidTools\Android\AndroidManifest.xml AndroidTools\SaGe\AndroidManifest.xml

COPY AndroidTools\SaGeDebugKey.keystore AndroidTools\SaGe\bin\SaGeDebugKey.keystore

COPY AndroidTools\Android\icon-hdpi.png AndroidTools\SaGe\res\drawable-hdpi\icon.png
COPY AndroidTools\Android\icon-ldpi.png AndroidTools\SaGe\res\drawable-ldpi\icon.png
COPY AndroidTools\Android\icon-mdpi.png AndroidTools\SaGe\res\drawable-mdpi\icon.png
COPY AndroidTools\Android\strings.xml AndroidTools\SaGe\res\values\strings.xml

COPY AndroidTools\Android\build.xml AndroidTools\SaGe\build.xml
COPY AndroidTools\Android\build.properties AndroidTools\SaGe\build.properties
COPY AndroidTools\Android\default.properties AndroidTools\SaGe\default.properties
COPY AndroidTools\Android\local.properties AndroidTools\SaGe\local.properties

CD AndroidTools
CALL BuildApk.bat
CD ..

DEL ..\Binaries\SaGe.apk
COPY AndroidTools\SaGe\bin\SaGe-release.apk ..\Binaries\SaGe.apk
PAUSE
DEL AndroidTools\SaGe /F/S/Q
