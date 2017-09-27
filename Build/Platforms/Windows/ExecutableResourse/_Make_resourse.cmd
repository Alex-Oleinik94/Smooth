@echo off
set app=Sun
windres.exe -i %app%.rc %app%.res
pause
