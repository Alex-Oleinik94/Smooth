@echo off
CALL _Create_Output_Directoryes
cd ..
DEL Output\AndroidApplication /F/S/Q
cls
make build_files
@echo off
cd Scripts
IF "%1"=="" (
	CALL _Make_Android_ARM apk
) ELSE (
	CALL _Make_Extensions android_arm false
)
cd ..
make clear_files

if exist "Output\AndroidApplication\libs\armeabi\libmain.so" set LIB="existed"
rem if exist "Output\AndroidApplication\libs\i386eabi\libmain.so" set LIB="existed"

if "%LIB%"==""existed"" (
	echo "================"
	echo "| Building APK |"
	echo "================"
	CD Output\AndroidApplication
	if not exist bin MKDIR bin
	if not exist res MKDIR res
	if not exist src MKDIR src
	if not exist res\drawable-hdpi MKDIR res\drawable-hdpi
	if not exist res\drawable-ldpi MKDIR res\drawable-ldpi
	if not exist res\drawable-mdpi MKDIR res\drawable-mdpi
	if not exist res\values MKDIR res\values
	CD ..\..

	COPY Platforms\Android\SmoothKeystore.keystore Output\AndroidApplication\bin\SmoothKeystore.keystore
	
	COPY Platforms\Android\Application\AndroidManifest.xml Output\AndroidApplication\AndroidManifest.xml

	COPY Platforms\Android\Application\icon-hdpi.png Output\AndroidApplication\res\drawable-hdpi\icon.png
	COPY Platforms\Android\Application\icon-ldpi.png Output\AndroidApplication\res\drawable-ldpi\icon.png
	COPY Platforms\Android\Application\icon-mdpi.png Output\AndroidApplication\res\drawable-mdpi\icon.png
	COPY Platforms\Android\Application\strings.xml Output\AndroidApplication\res\values\strings.xml

	COPY Platforms\Android\Application\build.xml Output\AndroidApplication\build.xml
	COPY Platforms\Android\Application\build.properties Output\AndroidApplication\build.properties
	COPY Platforms\Android\Application\default.properties Output\AndroidApplication\default.properties
	COPY Platforms\Android\Application\local.properties Output\AndroidApplication\local.properties

	REM for adding user resourses
	if "%1"=="res" (
		ECHO Push!!!!!!!!!!!!!!!
		pause 
		)

	if exist ..\Binaries\Smooth.apk ( 
		DEL ..\Binaries\Smooth.apk 
	)
	
	CD Output
	SET PATH=C:\Programming\jdk\bin;C:\Programming\android-sdk\tools;C:\Programming\apache-ant\bin;C:\Programming\jdk\lib
	cd AndroidApplication
	IF "%1"=="release" (
		ant release
		rem TO DO
		del bin\Smooth-release-unaligned.apk
		jarsigner -verbose -keystore bin\SmoothKeystore.keystore -keypass 12345678 -storepass 12345678 -signedjar bin\Smooth-release-unaligned.apk bin\Smooth-release-unsigned.apk SmoothKeystore
		zipalign -v 4 bin\Smooth-release-unaligned.apk bin\Smooth-release.apk
		CD ..\..
		COPY Output\AndroidApplication\bin\Smooth-release.apk ..\Binaries\Smooth-release.apk
	) else (
		ant debug
		CD ..\..
		COPY Output\AndroidApplication\bin\Smooth-debug.apk ..\Binaries\Smooth-debug.apk
	)
	
	rem DEL Output\AndroidApplication /F/S/Q
	cd Scripts
) else (
	@echo off
	echo "==========================="
	echo "| Error while compilation |"
	echo "==========================="
	rem DEL Output\AndroidApplication /F/S/Q
	cd Scripts
)
PAUSE
