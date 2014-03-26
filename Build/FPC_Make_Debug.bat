@echo off
echo "======================================="
echo "|Compiling  Debug  Version for Windows|"
echo "======================================="
MKDIR CompiledUnits
MKDIR CompiledUnits\i386-other
make clear_files
@echo off
make debug
pause
