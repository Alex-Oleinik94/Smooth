@echo off
CALL _Create_Output_Directoryes
cd ..
set S1="=============================="
set S2="Compiling Packages for Windows"
if "%1" equ "" (
	set TARGET=debug
) else (
	set TARGET=%1
	)
if exist "../Binaries/Main_Console.exe" (
	echo %S1%
	echo %S2%
	echo %S1%
	"../Binaries/Main_Console.exe" --build --x86_64 --packages --%TARGET%
	if %errorlevel% equ 0 (
		copy .\..\Binaries\Main.exe .\..\Binaries\Main_Packages.exe
		)
) else (
	echo Compile debug executable first!
)
cd Scripts
if "%2"=="" ( pause )
