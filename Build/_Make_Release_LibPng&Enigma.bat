@echo off
echo "======================================="
echo "|Compiling Release Version for Windows|"
echo "======================================="
MKDIR CompiledUnits
MKDIR CompiledUnits\i386-other
make build_files
make inc_version_release
@echo off
make release_libpng
@echo off
make clear_files
@echo off
"./Utility/enigmavbconsole.exe" "./Utility/Main.evb"
REM "./Utility/upx.exe" -9 -o ./../Binaries/Main_Release_2.exe ./../Binaries/Main_Release.exe
pause
