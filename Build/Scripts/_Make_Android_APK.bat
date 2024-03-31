@echo off
CALL _Create_Output_Directoryes
cd ..
DEL Output\AndroidApplication /F/S/Q
cls
make build_files
@echo off
cd Scripts
CALL _Make_Android_ARM apk
cd ..
make clear_files

set LIB=""
if exist "Output\AndroidApplication\libs\armeabi\libmain.so" set LIB="1"
if exist "Output\AndroidApplication\libs\i386eabi\libmain.so" set LIB="1"

if "%LIB%"==""1"" (
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
	SET APP_NAME=SmoothGameEngine-release
	SET TARGETVER=""
	IF "%1"=="" (
		set TARGETVER="debug"
	) else (
		set TARGETVER="release"
	)
	cd AndroidApplication
	
	ant %TARGETVER%
	
	if "%TARGETVER%"==""release"" (
		del bin\%APP_NAME%-unaligned.apk
		jarsigner -verbose -keystore bin\SmoothKeystore.keystore -keypass 12345678 -storepass 12345678 -signedjar bin\%APP_NAME%-unaligned.apk bin\%APP_NAME%-unsigned.apk SmoothKeystore
		C:\Programming\android-sdk\tools\zipalign -v 4 bin\%APP_NAME%-unaligned.apk bin\%APP_NAME%.apk
	)
	
	CD ..\..
	if "%TARGETVER%"==""debug"" (
		COPY Output\AndroidApplication\bin\SmoothGameEngine-debug.apk ..\Binaries\Smooth.apk
	) else (
		COPY Output\AndroidApplication\bin\SmoothGameEngine-release.apk ..\Binaries\Smooth.apk
	)
	DEL Output\AndroidApplication /F/S/Q
) else (
	@echo off
	echo "==========================="
	echo "| Error while compilation |"
	echo "==========================="
	DEL Output\AndroidApplication /F/S/Q
)
PAUSE
