@echo off
echo "======================================="
echo "|Compiling  Debug  Version for Windows|"
echo "======================================="
MKDIR Output
MKDIR Output\x86_64-debug-desktop
make clear_files
@echo off
make inc_version_debug
make debug_x64
@echo off
make clear_files
pause
