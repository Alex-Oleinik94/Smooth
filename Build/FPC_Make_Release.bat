@echo off
echo "======================================="
echo "|Compiling Release Version for Windows|"
echo "======================================="
MKDIR CompiledUnits
MKDIR CompiledUnits\i386-other
make inc_version_release
make build_files
@echo off
make release
@echo off
make clear_files
@echo off
REM echo "============================================="
REM echo "|Сейчас вылетит программа "enigmavbconsole",|"
REM echo "| но она сделает свою работу нормально      |"
REM echo "============================================="
REM make enigma
pause
