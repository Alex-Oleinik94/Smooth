@echo off
CALL _Create_Output_Directoryes
cd ..
set S1="=============================="
set S2="Compiling Packages for Windows"
set S3="=============================="
if exist "../Binaries/Main_Console.exe" (
	echo %S1%
	echo %S2%
	echo %S3%
	"../Binaries/Main_Console.exe" --build -packages %1
	if %errorlevel% equ 0 (
		copy .\..\Binaries\Main.exe .\..\Binaries\Main_Packages.exe
		)
) else (
	echo Compile debug executable first!
)
cd Scripts
if "%2"=="" ( pause )
