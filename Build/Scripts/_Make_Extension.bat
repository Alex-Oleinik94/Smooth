@echo off
CALL _Create_Output_Directoryes
cd ..
set S1="==============================="
set S2="Compiling extension for Windows"
set e2=
if "%2"=="" (
	set e2=release
) else (
	set e2=%2
)
if "%1"=="" (
	echo Enter extension name as param of this file!
) else (
	if exist "../Binaries/SmoothConsole.exe" (
		echo %S1%
		echo %S2%
		echo %S1%
		"../Binaries/SmoothConsole.exe" --bt --build --e%1 --%e2%
		if %errorlevel% equ 0 (
			copy .\..\Binaries\Smooth.exe .\..\Binaries\SmoothExtensions.exe
			)
	) else (
		echo Compile debug executable first!
	)
)
cd Scripts
if "%2"=="" ( pause )
