@echo off
CALL _Create_Output_Directoryes
cd ..
echo "================================="
echo "|Compiling  Packages for Windows|"
echo "================================="
"../Binaries/Main_Console.exe" --build
if %errorlevel% equ 0 (
	copy .\..\Binaries\Main.exe .\..\Binaries\Main_Packages.exe
	)
cd Scripts
if "%1"=="" ( pause )
