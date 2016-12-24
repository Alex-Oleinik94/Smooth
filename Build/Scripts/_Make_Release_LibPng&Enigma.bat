@echo off
CALL _Create_Output_Directoryes
cd ..
echo "======================================="
echo "|Compiling Release Version for Windows|"
echo "======================================="
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
