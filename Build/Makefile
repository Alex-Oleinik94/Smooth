PP=fpc
PP271=..\FPC\2.7.1\bin\i386-win32\fpc
BASEARGS= -FuSrcUnits\Includes -FuSrcUnits/Inet -FuSrcUnits/Inet/sys -FuSrcUnits -FiSrcUnits/Includes -Sm 
RENDERARGS= -FuSrcUnits/DirectX -FuSrcUnits/OpenGL 
ANDROIDARGS= -FuSrcUnits/Android -FlAndroidTools\Libs\toolchains -FlAndroidTools\Libs\platforms
OUTPUTUNIXORWIN= -FUCompiledUnits\i386-win32,win64,unix -FE./../Binaries
OUTPUTANDROID= -FUCompiledUnits\arm-android -oCompiledUnits\arm-android\android\libs\armeabi\liblclapp.so
OUTPUTLIBRARY= -FUCompiledUnits\i386-win32,win64,unix -FE./../Binaries 
DODEBUG= -gl
DORELEASE= -XX -O3 -CX -dRELEASE
DOANDROID= -Sc -Sg -Si -Sh -Tandroid -Parm -dANDROID -Xd -CpARMV6 -Mobjfpc

enigma:
	./EnigmaVB/enigmavbconsole.exe Main.evb
release:
	MKDIR -p CompiledUnits
	MKDIR -p CompiledUnits\i386-win32,win64,unix
	$(PP) $(DORELEASE) $(BASEARGS) $(RENDERARGS) $(OUTPUTUNIXORWIN) $(OPT) Main
debug:
	MKDIR -p CompiledUnits
	MKDIR -p CompiledUnits\i386-win32,win64,unix
	$(PP) $(DODEBUG) $(BASEARGS) $(RENDERARGS) $(OUTPUTUNIXORWIN) $(OPT) Main
android:
	MKDIR -p CompiledUnits
	MKDIR -p CompiledUnits\arm-android
	MKDIR -p CompiledUnits\arm-android\android
	MKDIR -p CompiledUnits\arm-android\android\libs
	MKDIR -p CompiledUnits\arm-android\android\libs\armeabi
	$(PP271) $(DOANDROID) $(BASEARGS) $(ANDROIDARGS) $(OUTPUTANDROID) $(OPT) Main
lib:
	MKDIR -p CompiledUnits
	MKDIR -p CompiledUnits\i386-win32,win64,unix
	$(PP) $(DORELEASE) $(BASEARGS) $(RENDERARGS) $(OUTPUTLIBRARY) $(OPT) SaGeLib
clear:
	MKDIR -p CompiledUnits
	MKDIR -p CompiledUnits\i386-win32,win64,unix
	MKDIR -p CompiledUnits\arm-android
	rm -f CompiledUnits/arm-android/*.ppu
	rm -f CompiledUnits/arm-android/*.o
	rm -f CompiledUnits/i386-win32,win64,unix/*
	rm -f *.o
	rm -f *.ppu
	rm -f *.or
	rm -f ppas.bat
	rm -f *.a
	rm -f fpc-res.res
	rm -f SrcUnits/*.o
	rm -f SrcUnits/*.ppu
	rm -f Main.res
