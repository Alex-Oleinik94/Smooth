@echo off
CALL _Create_Output_Directoryes
cd ..
copy .\Sources\Includes\SaGeStandartFileRegistrationResources.inc .\Output\Resources\SaGeFileRegistrationResources.inc
cd Scripts
if "%1"=="" ( pause )
