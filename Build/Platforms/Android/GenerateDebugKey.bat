@echo off
SET PATH=C:\Programming\android-sdk\tools;C:\Programming\android-sdk\build-tools\19.0.1;C:\Programming\android-sdk\platform-tools\;C:\Programming\jdk\bin
keytool -genkey -v -keystore SmoothKeystore.keystore -alias SmoothKeystore -keyalg RSA -validity 10000
pause
