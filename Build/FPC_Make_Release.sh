echo off
echo "======================================="
echo "| Compiling Release Version for Unix  |"
echo "======================================="
mkdir CompiledUnits
make release
strip ../Binaries/Main
