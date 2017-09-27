@echo off
cd ..
cd ../Binaries
Main.exe -ic
if %errorlevel% equ 1 (
	del "Main_Console.exe"
	copy "Main.exe" "Main_Console.exe"
	)
cd ../Build
cd Scripts
