@echo off
echo "======================================="
echo "|Compiling  Debug  Version for Windows|"
echo "======================================="
MKDIR Sources\Temp
MKDIR Output
MKDIR Output\x86_64-debug-desktop
CALL _Restore_RMFile.bat false
make debug_x64
pause
