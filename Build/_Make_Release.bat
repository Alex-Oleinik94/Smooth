@echo off
echo "======================================="
echo "|Compiling Release Version for Windows|"
echo "======================================="
MKDIR CompiledUnits
MKDIR CompiledUnits\i386-other
make build_files
make inc_version_release
@echo off
make release
@echo off
make clear_files
pause
