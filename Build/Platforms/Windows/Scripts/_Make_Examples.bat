@echo off
CALL _Create_Output_Directoryes
cd ..
echo "========================================"
echo "|Compiling Examples Version for Windows|"
echo "========================================"
make clear_files
@echo off
make examples
@echo off
make clear_files
cd Scripts
if "%1"=="" ( pause )
