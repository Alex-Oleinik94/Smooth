echo off
echo "======================================="
echo "|Compiling Release Version for Windows|"
echo "======================================="
MKDIR CompiledUnits
MKDIR CompiledUnits\i386-other
make release
echo "============================================="
echo "|����� �뫥�� �ணࠬ�� "enigmavbconsole",|"
echo "| �� ��� ᤥ���� ᢮� ࠡ��� ��ଠ�쭮      |"
echo "============================================="
make enigma
pause
