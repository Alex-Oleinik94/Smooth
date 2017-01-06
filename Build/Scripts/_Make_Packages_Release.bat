@echo off
CALL _Make_Packages release false
if "%1"=="" ( pause )
