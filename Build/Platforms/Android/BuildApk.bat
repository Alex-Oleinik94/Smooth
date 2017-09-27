@echo off
SET PATH=C:\Programming\jdk\bin
SET PATH=C:\Programming\android-sdk\tools
SET APP_NAME=SaGeGameEngine-release

CD SaGe 

IF "%1"=="debug" (
	CALL ..\BuildWithAnt.bat debug
)

IF "%1"=="release" (
	CALL ..\BuildWithAnt.bat release
	
	del bin\%APP_NAME%-unaligned.apk
	jarsigner -verbose -keystore bin\SaGeKeystore.keystore -keypass 12345678 -storepass 12345678 -signedjar bin\%APP_NAME%-unaligned.apk bin\%APP_NAME%-unsigned.apk SaGeKeystore
	C:\Programming\android-sdk\tools\zipalign -v 4 bin\%APP_NAME%-unaligned.apk bin\%APP_NAME%.apk
)

CD ..