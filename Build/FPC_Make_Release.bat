@echo off
echo "======================================="
echo "|Compiling Release Version for Windows|"
echo "======================================="
MKDIR CompiledUnits
MKDIR CompiledUnits\i386-other
make build_files
make inc_version_release
@echo off
make release
@echo off
make clear_files
@echo off
REM echo "============================================="
REM echo "|����� �뫥�� �ணࠬ�� "enigmavbconsole",|"
REM echo "| �� ��� ᤥ���� ᢮� ࠡ��� ��ଠ�쭮      |"
REM echo "============================================="
REM make enigma
pause
