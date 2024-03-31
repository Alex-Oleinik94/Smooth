@echo off
cd ..
cd Output
del Log.log
cd ..
cd ./../Binaries/
"Smooth.exe"  %1 %2 %3 %4 %5 %6 %7 %8 >>  ./../Build/Output/Log.log
cd ./../Build/
pause
