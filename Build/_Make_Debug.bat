@echo off
echo "======================================="
echo "|Compiling  Debug  Version for Windows|"
echo "======================================="
MKDIR Output
MKDIR Output\i386-debug-desktop
make clear_files
@echo off
make inc_version_debug
make debug
@echo off
make clear_files
pause
