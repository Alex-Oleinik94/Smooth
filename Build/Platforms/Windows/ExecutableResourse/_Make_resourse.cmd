@echo off
set app=Smooth
copy ".\..\..\..\..\Data\Engine\%app%.ico" ".\ProgramIconImage.ico"
windres.exe -i %app%.rc %app%.res
if "%1"=="" ( pause )
