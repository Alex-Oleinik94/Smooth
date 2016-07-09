@echo off
echo "======================================="
echo "|Compiling Release Version for Windows|"
echo "======================================="
MKDIR Output
MKDIR Output\x86_64-release-desktop
make build_files
make inc_version_release
@echo off
make release_x64
@echo off
make clear_files
pause
