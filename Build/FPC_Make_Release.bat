echo off
echo "======================================="
echo "|Compiling Release Version for Windows|"
echo "======================================="
make release
echo "============================================="
echo "|Сейчас вылетит программа "enigmavbconsole",|"
echo "| но она сделает свою работу нормально      |"
echo "============================================="
make enigma
pause
