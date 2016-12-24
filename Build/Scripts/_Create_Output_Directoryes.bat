@echo off
cd ..
if not exist Output MKDIR Output
if not exist Output\arm-android MKDIR Output\arm-android
if not exist Output\i386-library MKDIR Output\i386-library
if not exist Output\x86_64-library MKDIR Output\x86_64-library
if not exist Output\i386-debug-desktop MKDIR Output\i386-debug-desktop
if not exist Output\i386-release-desktop MKDIR Output\i386-release-desktop
if not exist Output\x86_64-debug-desktop MKDIR Output\x86_64-debug-desktop
if not exist Output\x86_64-release-desktop MKDIR Output\x86_64-release-desktop
if not exist Output\Resources MKDIR Output\Resources
if not exist Output\ResourcesCache MKDIR Output\ResourcesCache
cd Scripts
