cd CompiledUnits
del Log.log
cd ..
cd ./../Binaries/
"Main.exe" -gui -d3dx >> ./../Build/CompiledUnits/Log.log
cd ./../Build/
pause
