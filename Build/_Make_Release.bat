@echo off
echo "======================================="
echo "|Compiling Release Version for Windows|"
echo "======================================="
MKDIR Output
MKDIR Output\i386-release-desktop
make build_files
make inc_version_release
@echo off
make release
@echo off
make clear_files
rm ./../Binaries/Main_Compressed.exe
"./Utility/upx.exe" -9 -o ./../Binaries/Main_Compressed.exe ./../Binaries/Main.exe
pause
