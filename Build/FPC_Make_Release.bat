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
REM echo "|����� �뫥�� �ணࠬ�� "enigmavbconsole",|"
REM echo "| �� ��� ᤥ���� ᢮� ࠡ��� ��ଠ�쭮      |"
REM echo "============================================="
REM make enigma
pause
