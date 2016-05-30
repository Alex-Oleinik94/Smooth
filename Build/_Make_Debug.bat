@echo off
echo "======================================="
echo "|Compiling  Debug  Version for Windows|"
echo "======================================="
MKDIR CompiledUnits
MKDIR CompiledUnits\i386-other
make clear_files
@echo off
make inc_version_debug
make debug
@echo off
make clear_files
pause
