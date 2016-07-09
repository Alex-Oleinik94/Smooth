@echo off
echo "======================================="
echo "|Compiling  Debug  Version for Windows|"
echo "======================================="
MKDIR Output
MKDIR Output\i386-library
make clear_files
@echo off
make inc_version_debug
make lib
@echo off
make clear_files
pause
