@echo off
CALL _Create_Output_Directoryes
cd ..
rm -f Output/i386-android/SaGe*.o
rm -f Output/i386-android/SaGe*.ppu
rm -f Output/arm-android/SaGe*.o
rm -f Output/arm-android/SaGe*.ppu
rm -f Output/i386-library/SaGe*.ppu
rm -f Output/i386-library/SaGe*.o
rm -f Output/x86_64-library/SaGe*.ppu
rm -f Output/x86_64-library/SaGe*.o
rm -f Output/i386-debug-desktop/SaGe*.ppu
rm -f Output/i386-debug-desktop/SaGe*.o
rm -f Output/i386-release-desktop/SaGe*.ppu
rm -f Output/i386-release-desktop/SaGe*.o
rm -f Output/x86_64-debug-desktop/SaGe*.ppu
rm -f Output/x86_64-debug-desktop/SaGe*.o
rm -f Output/x86_64-release-desktop/SaGe*.ppu
rm -f Output/x86_64-release-desktop/SaGe*.o
cd Scripts
pause
