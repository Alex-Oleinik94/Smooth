@echo off
CALL _Create_Output_Directoryes
cd ..
set S1="================================"
set S2="Compiling extensions for Windows"
if "%1" equ "" (
	set TARGET=debug
) else (
	set TARGET=%1
	)
if exist "../Binaries/SmoothConsole.exe" (
	echo %S1%
	echo %S2%
	echo %S1%
	"../Binaries/SmoothConsole.exe" --bt --build --x86_64 --extensions --%TARGET%
	if %errorlevel% equ 0 (
		copy .\..\Binaries\Smooth.exe .\..\Binaries\SmoothExtensions.exe
		)
) else (
	echo Compile debug executable first!
)
cd Scripts
if "%2"=="" ( pause )
