echo off
SET PATH=C:\Android\android-sdk\tools;C:\Android\android-sdk\build-tools\19.0.1;C:\Android\android-sdk\platform-tools\;C:\Progra~1\Java\jdk1.7.0_25\bin
SET APP_NAME=SaGe
SET ANDROID_HOME=C:\Android\android-sdk
SET APK_SDK_PLATFORM=C:\Android\android-sdk\platforms\android-14
SET APK_PROJECT_PATH=Ñ:\android\androidlcl\android
keytool -genkey -v -keystore SaGeDebugKey.keystore -alias SaGeDebugKey -keyalg RSA -validity 10000
pause
