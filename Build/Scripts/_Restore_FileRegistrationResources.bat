@echo off
cd ..
if not exist Sources\Temp MKDIR Sources\Temp
copy .\Sources\Includes\SaGeStandartFileRegistrationResources.inc .\Sources\Temp\SaGeFileRegistrationResources.inc
cd Scripts
if "%1"=="" ( pause )
