PP=fpc
CROSSPP=../FPC/bin/i386-win32/$(PP)
BASEARGS= -FuSrcUnits/Temp -FuSrcUnits/Includes -FuSrcUnits/Inet -FuSrcUnits/Inet/sys -FuSrcUnits -FuSrcUnits/Others -FuSrcUnits/Others/PasJpeg -FiSrcUnits/Includes -FuExamples -Sm
RENDERARGS= -FuSrcUnits/DirectX -FuSrcUnits/OpenGL 
ANDROIDARGS= -FuSrcUnits/Android -FlAndroidTools/Libs/Others -FlAndroidTools/Libs -FuSrcUnits/OpenGL 
OUTPUTUNIXORWIN= -FUCompiledUnits/i386-other -FE./../Binaries
OUTPUTANDROID= -FUCompiledUnits/arm-android -oAndroidTools/SaGe/libs/armeabi/libmain.so
OUTPUTLIBRARY= -FUCompiledUnits/i386-other -FE./../Binaries
DODEBUG= -gl
DORELEASE= -XX -O3 -CX -dRELEASE
DOANDROID= -Tandroid -Parm -dANDROID -CpARMV6 -Xs -Sgic -XParm-linux-androideabi- -XX -O3 -CX
DOWITHFPU= -CfVFPV3
DODARWIN=-k-framework -kOpenGL

enigma:
	./EnigmaVB/enigmavbconsole.exe Main.evb
release:
	@$(PP) $(DORELEASE) $(BASEARGS) $(RENDERARGS) $(OUTPUTUNIXORWIN) $(OPT) Main
debug:
	@$(PP) $(DODEBUG) $(BASEARGS) $(RENDERARGS) $(OUTPUTUNIXORWIN) $(OPT) Main
android:
	$(CROSSPP) $(DOANDROID) $(BASEARGS) $(ANDROIDARGS) $(OUTPUTANDROID) $(OPT) Main
darwin_debug:
	@$(PP) $(DODEBUG) $(BASEARGS) $(RENDERARGS) $(OUTPUTUNIXORWIN) $(OPT) $(DODARWIN) Main 
darwin_release:
	@$(PP) $(DORELEASE) $(BASEARGS) $(RENDERARGS) $(OUTPUTUNIXORWIN) $(OPT) $(DODARWIN) Main
ios:
	
lib:
	$(PP) $(DORELEASE) $(BASEARGS) $(RENDERARGS) $(OUTPUTLIBRARY) $(OPT) SaGeLib
build_files:
	@$(MAKE) clear_files
	@"./../Binaries/Main" -CFTPUARU "./../data/fonts/Tahoma.sgf"                         ../build/srcunits/temp tahoma_font          ../build/srcunits/temp/SaGeRMFiles.inc
	@"./../Binaries/Main" -CFTPUARU "./../data/fonts/Times New Roman.sgf"                ../build/srcunits/temp times_new_roman_font ../build/srcunits/temp/SaGeRMFiles.inc
	@"./../Binaries/Main" -CFTPUARU "./../data/textures/ComboBoxImage.sgia"              ../build/srcunits/temp combo_box_image      ../build/srcunits/temp/SaGeRMFiles.inc
	@"./../Binaries/Main" -CFTPUARU "./../data/textures/KillKostia/Block.sgia"           ../build/srcunits/temp KillKostia_Block     ../build/srcunits/temp/SaGeRMFiles.inc
	@"./../Binaries/Main" -CFTPUARU "./../data/textures/KillKostia/Bullet.sgia"          ../build/srcunits/temp KillKostia_Bullet    ../build/srcunits/temp/SaGeRMFiles.inc
	@"./../Binaries/Main" -CFTPUARU "./../data/textures/KillKostia/Skull.sgia"           ../build/srcunits/temp KillKostia_Skull     ../build/srcunits/temp/SaGeRMFiles.inc
	@"./../Binaries/Main" -CFTPUARU "./../data/textures/KillKostia/Standart Kostia.sgia" ../build/srcunits/temp KillKostia_sk        ../build/srcunits/temp/SaGeRMFiles.inc
	@"./../Binaries/Main" -CFTPUARU "./../data/textures/KillKostia/You.sgia"             ../build/srcunits/temp KillKostia_You       ../build/srcunits/temp/SaGeRMFiles.inc
clear_files:
	@rm -f SrcUnits/Temp/*
	@"./../Binaries/Main" -crf ./../Build/SrcUnits/Temp/SaGeRMFiles.inc
clear:
	@rm -f CompiledUnits/arm-android/*
	@rm -f CompiledUnits/i386-other/*
	@rm -f CompiledUnits/*.o
	@rm -f CompiledUnits/*.ppu
	@rm -f CompiledUnits/*.res
	@rm -f CompiledUnits/*.or
	@rm -f *.o
	@rm -f *.ppu
	@rm -f *.or
	@rm -f ppas.bat
	@rm -f *.a
	@rm -f fpc-res.res
	@rm -f SrcUnits/*.o
	@rm -f SrcUnits/*.ppu
	@rm -f Main.res
	@$(MAKE) clear_files
