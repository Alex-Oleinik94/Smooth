@echo off
echo "======================================="
echo "|Compiling Release Version for Windows|"
echo "======================================="
MKDIR CompiledUnits
MKDIR CompiledUnits\i386-other
CALL SG_MAKE_FILES.bat
make release
CALL SG_MAKE_FILES_CLEAR.bat
REM echo "============================================="
REM echo "|Сейчас вылетит программа "enigmavbconsole",|"
REM echo "| но она сделает свою работу нормально      |"
REM echo "============================================="
REM make enigma
pause
