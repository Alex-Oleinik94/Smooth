@echo off
cd ..
cd Output
del Log.log
cd ..
cd ./../Binaries/
"Main_Release.exe" >> ./../Build/Output/Log.log
cd ./../Build/
pause
