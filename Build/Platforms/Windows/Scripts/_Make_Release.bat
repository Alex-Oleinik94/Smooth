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
copy ".\..\Binaries\Main.exe" ".\..\Binaries\Main_Release.exe"
"./Platforms/Windows/Utility/upx.exe" -9 -o ./../Binaries/Main_Compressed.exe ./../Binaries/Main.exe
cd Scripts
if "%2"=="" ( CALL _Check_Console )
if "%1"=="" ( pause )
