@echo off
cd ..
cd Output
del Log.log
cd ..
cd ./../Binaries/
"SmoothRelease.exe" >> ./../Build/Output/Log.log
cd ./../Build/
pause
