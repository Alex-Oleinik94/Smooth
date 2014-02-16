@echo off
SET PATH=C:\Android\android-sdk\tools;C:\Android\android-sdk\platform-tools\;C:\Progra~1\Java\jdk1.7.0_25\bin;C:\Android\android-sdk\build-tools\19.0.1
SET APP_NAME=SaGe
SET ANDROID_HOME=C:\Android\android-sdk
SET APK_SDK_PLATFORM=C:\Android\android-sdk\platforms\android-14
SET APK_PROJECT_PATH=C:\Programming\SaGe\Build\CompiledUnits\arm-android\android
del bin\%APP_NAME%.ap_
del bin\%APP_NAME%.apk
del raw\lib\armeabi\*.so
copy libs\armeabi\*.so raw\lib\armeabi\
call aapt p -v -f -M AndroidManifest.xml -F bin\%APP_NAME%.ap_ -I %APK_SDK_PLATFORM%\android.jar -S res -m -J gen raw
call javac -verbose -encoding UTF8 -classpath %APK_SDK_PLATFORM%\android.jar -d bin\classes src\com\pascal\lcltest\LCLActivity.java
call dx --dex --verbose --output=%APK_PROJECT_PATH%\bin\classes.dex %APK_PROJECT_PATH%\bin\classes
@echo off
del %APK_PROJECT_PATH%\bin\%APP_NAME%-unsigned.apk
call apkbuilder %APK_PROJECT_PATH%\bin\%APP_NAME%-unsigned.apk -v -u -z %APK_PROJECT_PATH%\bin\%APP_NAME%.ap_ -f %APK_PROJECT_PATH%\bin\classes.dex
@echo off
keytool -genkey -v -keystore bin\SaGeDebugKey.keystore -alias SaGeDebugKey -keyalg RSA -validity 10000 -dname "Sanches" -storepass 12345678 -keypass 12345678
del bin\%APP_NAME%-unaligned.apk
jarsigner -verbose -keystore bin\SaGeDebugKey.keystore -keypass 12345678 -storepass 12345678 -signedjar bin\%APP_NAME%-unaligned.apk bin\%APP_NAME%-unsigned.apk SaGeDebugKey
zipalign -v 4 bin\%APP_NAME%-unaligned.apk bin\%APP_NAME%.apk
