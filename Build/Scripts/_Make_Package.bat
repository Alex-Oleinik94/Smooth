@echo off
CALL _Create_Output_Directoryes
cd ..
set S1="=============================="
set S2="Compiling Packages for Windows"
set S3="=============================="
set p2=
if "%2"=="" (
	set p2=release
) else (
	set p2=%2
)
if "%1"=="" (
	echo Enter package name as param of this file!
) else (
	if exist "../Binaries/Main_Console.exe" (
		echo %S1%
		echo %S2%
		echo %S3%
		"../Binaries/Main_Console.exe" --build --p%1 --%p2%
		if %errorlevel% equ 0 (
			copy .\..\Binaries\Main.exe .\..\Binaries\Main_Packages.exe
			)
	) else (
		echo Compile debug executable first!
	)
)
cd Scripts
if "%2"=="" ( pause )
