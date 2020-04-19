@echo off
CALL _Create_Output_Directoryes
cd ..
rm -f Output/i386-android/Smooth*.o
rm -f Output/i386-android/Smooth*.ppu
rm -f Output/arm-android/Smooth*.o
rm -f Output/arm-android/Smooth*.ppu
rm -f Output/i386-library/Smooth*.ppu
rm -f Output/i386-library/Smooth*.o
rm -f Output/x86_64-library/Smooth*.ppu
rm -f Output/x86_64-library/Smooth*.o
rm -f Output/i386-debug-desktop/Smooth*.ppu
rm -f Output/i386-debug-desktop/Smooth*.o
rm -f Output/i386-release-desktop/Smooth*.ppu
rm -f Output/i386-release-desktop/Smooth*.o
rm -f Output/x86_64-debug-desktop/Smooth*.ppu
rm -f Output/x86_64-debug-desktop/Smooth*.o
rm -f Output/x86_64-release-desktop/Smooth*.ppu
rm -f Output/x86_64-release-desktop/Smooth*.o
cd Scripts
pause
