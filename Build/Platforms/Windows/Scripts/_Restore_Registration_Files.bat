@echo off
CALL _Create_Output_Directoryes
cd ..
copy .\Sources\Includes\SmoothStandartFileRegistrationResources.inc .\Output\Resources\SmoothFileRegistrationResources.inc
copy .\Sources\Includes\SmoothStandartFileForRegistrationExtensions.inc .\Output\Resources\SmoothFileForRegistrationExtensions.inc
cd Scripts
if "%1"=="" ( pause )
