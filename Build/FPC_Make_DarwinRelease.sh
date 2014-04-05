echo off
echo "=========================================="
echo "| Compiling Release Version for Mac OSX  |"
echo "=========================================="
MKDIR CompiledUnits
MKDIR CompiledUnits/i386-other
make darwin_release
strip ../Binaries/Main
