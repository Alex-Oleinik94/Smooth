@echo off
CALL _Create_Output_Directoryes
CALL _Restore_Registration_Files.bat false
cd ..\Platforms\Windows\ExecutableResourse
call _Make_resourse.cmd WithoutPause
cd ..\..\..\Scripts
cd ..
echo "======================================="
echo "|Compiling  debug  version for Windows|"
echo "======================================="
make debug_x64
cd Scripts
if "%2"=="" ( CALL _Check_Console )
if "%1"=="" ( pause )
