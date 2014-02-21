PP=fpc
PP271=../FPC/2.7.1/bin/i386-win32/fpc
BASEARGS= -FuSrcUnits/Includes -FuSrcUnits/Inet -FuSrcUnits/Inet/sys -FuSrcUnits -FiSrcUnits/Includes -Sm 
RENDERARGS= -FuSrcUnits/DirectX -FuSrcUnits/OpenGL 
ANDROIDARGS= -FuSrcUnits/Android -FlAndroidTools/Libs/Others -FlAndroidTools/Libs/platforms 
OUTPUTUNIXORWIN= -FUCompiledUnits/i386-other -FE./../Binaries
OUTPUTANDROID= -FUCompiledUnits/arm-android -oAndroidTools/SaGe/libs/armeabi/libmain.so
OUTPUTLIBRARY= -FUCompiledUnits/i386-other -FE./../Binaries
DODEBUG= -gl
DORELEASE= -XX -O3 -CX -dRELEASE
DOANDROID= -Sc -Sg -Si -Sh -Tandroid -Parm -dANDROID -Xd -CpARMV6 -Mobjfpc

enigma:
	./EnigmaVB/enigmavbconsole.exe Main.evb
release:
	$(PP) $(DORELEASE) $(BASEARGS) $(RENDERARGS) $(OUTPUTUNIXORWIN) $(OPT) Main
debug:
	$(PP) $(DODEBUG) $(BASEARGS) $(RENDERARGS) $(OUTPUTUNIXORWIN) $(OPT) Main
android:
	$(PP271) $(DOANDROID) $(BASEARGS) $(ANDROIDARGS) $(OUTPUTANDROID) $(OPT) Main
lib:
	$(PP) $(DORELEASE) $(BASEARGS) $(RENDERARGS) $(OUTPUTLIBRARY) $(OPT) SaGeLib
clear:
	rm -f CompiledUnits/arm-android/*
	rm -f CompiledUnits/i386-other/*
	rm -f *.o
	rm -f *.ppu
	rm -f *.or
	rm -f ppas.bat
	rm -f *.a
	rm -f fpc-res.res
	rm -f SrcUnits/*.o
	rm -f SrcUnits/*.ppu
	rm -f Main.res
