echo off
echo "======================================="
echo "| Compiling Release Version for Unix  |"
echo "======================================="
make release
strip ../Binaries/Main
