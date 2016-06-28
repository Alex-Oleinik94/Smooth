@echo off
echo "====================================="
echo "|Compiling Debug Version for Windows|"
echo "====================================="
MKDIR CompiledUnits
MKDIR CompiledUnits\i386-other
@echo off
make clear_files
@echo off
make inc_version_debug
@echo off
make debug_libpng
@echo off
make clear_files
pause
