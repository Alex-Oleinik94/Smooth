@echo off
CALL _Create_Output_Directoryes
cd ..
echo "======================================="
echo "|Compiling Release Version for Windows|"
echo "======================================="
make build_files
make inc_version_release
@echo off
make release
@echo off
make clear_files
rm ./../Binaries/Main_Compressed.exe
"./Utility/upx.exe" -9 -o ./../Binaries/Main_Compressed.exe ./../Binaries/Main.exe
pause
