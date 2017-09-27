@echo off
SET PATH=C:\Android\android-sdk\tools;C:\Android\android-sdk\build-tools\19.0.1;C:\Android\android-sdk\platform-tools\;C:\Progra~1\Java\jdk1.7.0_25\bin
keytool -genkey -v -keystore SaGeKeystore.keystore -alias SaGeKeystore -keyalg RSA -validity 10000
pause
