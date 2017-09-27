@echo off
CALL _Create_Output_Directoryes
cd ..
DEL AndroidTools\SaGe /F/S/Q
cls
make build_files
@echo off
cd Scripts
CALL _Make_Android_ARM apk
cd ..
make clear_files

if exist "AndroidTools\SaGe\libs\armeabi\libmain.so" ( 
	@echo off
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

	COPY AndroidTools\SaGeKeystore.keystore AndroidTools\SaGe\bin\SaGeKeystore.keystore

	COPY AndroidTools\Android\icon-hdpi.png AndroidTools\SaGe\res\drawable-hdpi\icon.png
	COPY AndroidTools\Android\icon-ldpi.png AndroidTools\SaGe\res\drawable-ldpi\icon.png
	COPY AndroidTools\Android\icon-mdpi.png AndroidTools\SaGe\res\drawable-mdpi\icon.png
	COPY AndroidTools\Android\strings.xml AndroidTools\SaGe\res\values\strings.xml

	COPY AndroidTools\Android\build.xml AndroidTools\SaGe\build.xml
	COPY AndroidTools\Android\build.properties AndroidTools\SaGe\build.properties
	COPY AndroidTools\Android\default.properties AndroidTools\SaGe\default.properties
	COPY AndroidTools\Android\local.properties AndroidTools\SaGe\local.properties

	REM for adding user resourses
	if "%1"=="res" ( 
		ECHO Push!!!!!!!!!!!!!!!
		pause 
		)

	DEL ..\Binaries\SaGe.apk

	CD AndroidTools
	IF "%1"=="" (
		CALL BuildApk.bat debug
		CD ..
		COPY AndroidTools\SaGe\bin\SaGeGameEngine-debug.apk ..\Binaries\SaGe.apk
	) ELSE (
		CALL BuildApk.bat release
		CD ..
		COPY AndroidTools\SaGe\bin\SaGeGameEngine-release.apk ..\Binaries\SaGe.apk
	)

	PAUSE
	DEL AndroidTools\SaGe /F/S/Q
) else (
	@echo off
	echo "==========================="
	echo "| Error while compilation |"
	echo "==========================="
	PAUSE
	DEL AndroidTools\SaGe /F/S/Q
)
