@echo off
CALL _Create_Output_Directoryes
cd ..
copy .\Sources\Includes\SaGeStandartFileRegistrationResources.inc .\Output\Resources\SaGeFileRegistrationResources.inc
copy .\Sources\Includes\SaGeStandartFileForRegistrationExtensions.inc .\Output\Resources\SaGeFileForRegistrationExtensions.inc
cd Scripts
if "%1"=="" ( pause )
