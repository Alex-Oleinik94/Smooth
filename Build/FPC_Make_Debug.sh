echo off
echo "======================================="
echo "| Compiling  Debug  Version for Unix  |"
echo "======================================="
mkdir CompiledUnits
mkdir CompiledUnits/i386-other
make inc_version_debug
make debug
make clear_files
