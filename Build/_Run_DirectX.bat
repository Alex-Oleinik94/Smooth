@echo off
cd CompiledUnits
del Log.log
cd ..
cd ./../Binaries/
"Main.exe" -gui -d3dx %1 %2 %3 %4 %5 %6 %7 %8 >> ./../Build/CompiledUnits/Log.log
cd ./../Build/
pause
