@echo off
cd ..
cd ../Binaries
Smooth.exe --bt --ic
if %errorlevel% equ 1 (
	del "SmoothConsole.exe"
	copy "Smooth.exe" "SmoothConsole.exe"
	)
cd ../Build
cd Scripts
