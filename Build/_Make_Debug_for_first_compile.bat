@echo off
echo "======================================="
echo "|Compiling  Debug  Version for Windows|"
echo "======================================="
MKDIR Sources\Temp
MKDIR Output
MKDIR Output\i386-debug-desktop
CALL _Restore_RMFile.bat false
make debug
pause
