PP=fpc
CROSSPP=../FPC/bin/i386-win32/$(PP)
BASEARGS= -FuSrcUnits/Temp -FuSrcUnits/Includes -FuSrcUnits/lNet -FuSrcUnits/lNet/sys -FuSrcUnits -FuSrcUnits/Programs -FuSrcUnits/Others -FuSrcUnits/Others/PasJpeg -FiSrcUnits/Includes -Sm -dENGINE -Fu../Examples/* -Fu../Examples
RENDERARGS= -FuSrcUnits/DirectX -FuSrcUnits/OpenGL 
ANDROIDARGS= -FuSrcUnits/Android -FlAndroidTools/Libs/Others -FlAndroidTools/Libs -FuSrcUnits/OpenGL 
OUTPUTUNIXORWIN= -FUCompiledUnits/i386-other -FE./../Binaries
OUTPUTANDROID= -FUCompiledUnits/arm-android -oAndroidTools/SaGe/libs/armeabi/libmain.so
OUTPUTLIBRARY= -FUCompiledUnits/i386-other -FE./../Binaries
DODEBUG= -Ci -Ct -Co -Sa -gl -Xg
DORELEASE= -XX -O2 -CX -dRELEASE
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
	@$(CROSSPP) $(DOANDROID) $(BASEARGS) $(ANDROIDARGS) $(OUTPUTANDROID) $(OPT) Main
darwin_debug:
	@$(PP) $(DODEBUG) $(BASEARGS) $(RENDERARGS) $(OUTPUTUNIXORWIN) $(OPT) $(DODARWIN) Main 
darwin_release:
	@$(PP) $(DORELEASE) $(BASEARGS) $(RENDERARGS) $(OUTPUTUNIXORWIN) $(OPT) $(DODARWIN) Main
lib:
	$(PP) $(DORELEASE) $(BASEARGS) $(RENDERARGS) $(OUTPUTLIBRARY) $(OPT) SaGeLib
inc_version_debug:
	@"./../Binaries/Main" -iv 0
	@"./../Binaries/Main" -CFTPUARU "./../Data/Engine/version.txt" ./../Build/SrcUnits/Temp SaGeVersionFile ./../Build/SrcUnits/Temp/SaGeRMFiles.inc
inc_version_release:
	@"./../Binaries/Main" -iv 1
	@"./../Binaries/Main" -CFTPUARU "./../Data/Engine/version.txt" ./../Build/SrcUnits/Temp SaGeVersionFile ./../Build/SrcUnits/Temp/SaGeRMFiles.inc
build_files:
	@$(MAKE) clear_files
	@"./../Binaries/Main" -CFTPUARU "./../Data/Fonts/Tahoma.sgf"                         ../Build/SrcUnits/Temp tahoma_font          ../Build/SrcUnits/Temp/SaGeRMFiles.inc
	@"./../Binaries/Main" -CFTPUARU "./../Data/Fonts/Times New Roman.sgf"                ../Build/SrcUnits/Temp times_new_roman_font ../Build/SrcUnits/Temp/SaGeRMFiles.inc
	@"./../Binaries/Main" -CFTPUARU "./../Data/Textures/ComboBoxImage.sgia"              ../Build/SrcUnits/Temp combo_box_image      ../Build/SrcUnits/Temp/SaGeRMFiles.inc
	@"./../Binaries/Main" -CFTPUARU "./../Data/Textures/KillKostia/Block.sgia"           ../Build/SrcUnits/Temp KillKostia_Block     ../Build/SrcUnits/Temp/SaGeRMFiles.inc
	@"./../Binaries/Main" -CFTPUARU "./../Data/Textures/KillKostia/Bullet.sgia"          ../Build/SrcUnits/Temp KillKostia_Bullet    ../Build/SrcUnits/Temp/SaGeRMFiles.inc
	@"./../Binaries/Main" -CFTPUARU "./../Data/Textures/KillKostia/Skull.sgia"           ../Build/SrcUnits/Temp KillKostia_Skull     ../Build/SrcUnits/Temp/SaGeRMFiles.inc
	@"./../Binaries/Main" -CFTPUARU "./../Data/Textures/KillKostia/Standart Kostia.sgia" ../Build/SrcUnits/Temp KillKostia_sk        ../Build/SrcUnits/Temp/SaGeRMFiles.inc
	@"./../Binaries/Main" -CFTPUARU "./../Data/Textures/KillKostia/You.sgia"             ../Build/SrcUnits/Temp KillKostia_You       ../Build/SrcUnits/Temp/SaGeRMFiles.inc
	@"./../Binaries/Main" -CFTPUARU "./../Data/Textures/radiobox.sgia"                   ../Build/SrcUnits/Temp radio_box_image      ../Build/SrcUnits/Temp/SaGeRMFiles.inc
	@"./../Binaries/Main" -CFTPUARU "./../Data/Textures/checkbox.sgia"                   ../Build/SrcUnits/Temp check_box_image      ../Build/SrcUnits/Temp/SaGeRMFiles.inc
	@"./../Binaries/Main" -CDTPUARU "./../Data/Examples" ../Build/SrcUnits/Temp ../Build/SrcUnits/Temp/SaGeRMFiles.inc
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
ios:
	
