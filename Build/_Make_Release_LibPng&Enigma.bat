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
echo "|Сейчас вылетит программа "enigmavbconsole",|"
echo "| но она сделает свою работу нормально      |"
echo "============================================="
"./EnigmaVB/enigmavbconsole.exe" Main.evb
pause
