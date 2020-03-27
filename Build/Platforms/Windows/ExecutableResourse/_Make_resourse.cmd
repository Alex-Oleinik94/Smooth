@echo off
set app=Smooth
windres.exe -i %app%.rc %app%.res
if "%1"=="" ( pause )
