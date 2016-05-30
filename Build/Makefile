PP=fpc
CROSSPP="./../FPC/bin/i386-win32/$(PP)"
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
SGRMFILE=./../Build/SrcUnits/Temp/SaGeRMFiles.inc
SGTEMPUNITDIR=./../Build/SrcUnits/Temp
SAGE="./../Binaries/Main"

release:
	@$(PP) $(DORELEASE) $(BASEARGS) $(RENDERARGS) $(OUTPUTUNIXORWIN) $(OPT) Main
release_libpng:
	@$(PP) $(DORELEASE) -dENABLELIBPNG $(BASEARGS) $(RENDERARGS) $(OUTPUTUNIXORWIN) $(OPT) Main
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
	@$(SAGE) -iv 0
	@$(SAGE) -CFTPUARU "./../Data/Engine/version.txt" $(SGTEMPUNITDIR) SaGeVersionFile $(SGRMFILE)
inc_version_release:
	@$(SAGE) -iv 1
	@$(SAGE) -CFTPUARU "./../Data/Engine/version.txt" $(SGTEMPUNITDIR) SaGeVersionFile $(SGRMFILE)
build_files:
	@$(MAKE) clear_files
	@$(SAGE) -CFTPUARU "./../Data/Textures/ComboBoxImage.sgia"              $(SGTEMPUNITDIR) combo_box_image      $(SGRMFILE)
	@$(SAGE) -CFTPUARU "./../Data/Textures/radiobox.sgia"                   $(SGTEMPUNITDIR) radio_box_image      $(SGRMFILE)
	@$(SAGE) -CFTPUARU "./../Data/Textures/checkbox.sgia"                   $(SGTEMPUNITDIR) check_box_image      $(SGRMFILE)
	@$(SAGE) -CDTPUARU "./../Data/Examples"                                 $(SGTEMPUNITDIR)                      $(SGRMFILE)
	@$(SAGE) -CDTPUARU "./../Data/Textures/KillKostia"                      $(SGTEMPUNITDIR)                      $(SGRMFILE)
	@$(SAGE) -CDTPUARU "./../Data/Fonts"                                    $(SGTEMPUNITDIR)                      $(SGRMFILE)
clear_files:
	@rm -f SrcUnits/Temp/*
	@$(SAGE) -crf $(SGRMFILE)
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
	
