@echo off
CALL _Create_Output_Directoryes
cd ..
echo "======================================="
echo "|Compiling release version for Windows|"
echo "======================================="
make build_files
make inc_version_release
@echo off
make release_x64
@echo off
make clear_files
cd Scripts
if "%2"=="" ( CALL _Check_Console )
if "%1"=="" ( pause )
