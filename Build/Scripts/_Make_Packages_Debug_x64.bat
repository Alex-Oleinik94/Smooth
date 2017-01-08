@echo off
CALL _Make_Packages_x64 debug false
if "%1"=="" ( pause )
