@echo off
echo "======================================="
echo "|Compiling Release Version for Windows|"
echo "======================================="
MKDIR CompiledUnits
MKDIR CompiledUnits\i386-other
make build_files
make inc_version_release
@echo off
make release_libpng
@echo off
make clear_files
@echo off
echo "============================================="
echo "|����� �뫥�� �ணࠬ�� "enigmavbconsole",|"
echo "| �� ��� ᤥ���� ᢮� ࠡ��� ��ଠ�쭮      |"
echo "============================================="
"./EnigmaVB/enigmavbconsole.exe" Main.evb
pause
