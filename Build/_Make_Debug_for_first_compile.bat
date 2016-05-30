@echo off
echo "======================================="
echo "|Compiling  Debug  Version for Windows|"
echo "======================================="
MKDIR CompiledUnits
MKDIR CompiledUnits\i386-other
CALL _Restore_RMFile.bat false
make debug
pause
