@echo off
cd CompiledUnits
del Log.log
cd ..
cd ./../Binaries/
"Main_Release.exe" >> ./../Build/CompiledUnits/Log.log
cd ./../Build/
pause
