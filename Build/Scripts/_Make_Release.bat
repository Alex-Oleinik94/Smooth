@echo off
CALL _Create_Output_Directoryes
cd ..
echo "======================================="
echo "|Compiling release version for Windows|"
echo "======================================="
make build_files
make inc_version_release
@echo off
make release
@echo off
make clear_files
rm ./../Binaries/SmoothCompressed.exe
copy ".\..\Binaries\Smooth.exe" ".\..\Binaries\SmoothRelease.exe"
"./Platforms/Windows/Utility/upx.exe" -9 -o ./../Binaries/SmoothCompressed.exe ./../Binaries/Smooth.exe
cd Scripts
if "%2"=="" ( CALL _Copy_console_application.bat )
if "%1"=="" ( pause )
