@echo off
MKDIR Sources\Temp
copy .\Sources\Includes\SaGeStandartResourseManagerFiles.inc .\Sources\Temp\SaGeRMFiles.inc
if "%1"=="" ( pause )
