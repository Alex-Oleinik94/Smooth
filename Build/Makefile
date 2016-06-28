X32=-Pi386 
X64=-Px86_64
PASCALCOMPILER=fpc
CROSSPASCALCOMPILER="./../FPC/bin/i386-win32/$(PASCALCOMPILER)"
DESKTOPFILENAME=Main
LIBRARYFILENAME=SaGe
PROJECTSDIR=Sources/Projects
DESKTOPFILE=$(PROJECTSDIR)/$(DESKTOPFILENAME)
BASEARGS= -FiSources/Temp -FuSources/Temp -FuSources/Others/Synapse -FiSources/Includes -FiSources/Includes/Mesh -FiSources/Includes/Render -FiSources/Includes/Common -FiSources/Includes/Fractals -FuSources/Others/lNet -FuSources/Others/lNet/sys -FuSources -FuSources/Programs -FuSources/Others -FuSources/Others/PasJpeg -FiSources/Includes -Sm -dENGINE -Fu../Examples/* -Fu../Examples
RENDERARGS= -FuSources/DirectX -FuSources/OpenGL 
DARWINARGS=-k-framework -kOpenGL
ARGS= $(BASEARGS) $(RENDERARGS)
ANDROIDARGS= -FuSources/Android -FlAndroidTools/Libs/Others -FlAndroidTools/Libs -FuSources/OpenGL 
OUTPUTDESKTOP= -FUCompiledUnits/i386-other -FE./../Binaries
OUTPUTANDROID= -FUCompiledUnits/arm-android -oAndroidTools/SaGe/libs/armeabi/libmain.so
OUTPUTLIBRARY= -FUCompiledUnits/i386-other -FE./../Binaries
DESKTOPARGS= $(ARGS) $(OUTPUTDESKTOP) $(DESKTOPFILE)
DODEBUG= -Ci -Ct -Co -Sa -gl -Xg -dDEBUG
DORELEASE= -XX -O2 -CX -dRELEASE
DOWITHFPU= -CfVFPV3
DOANDROID= -Tandroid -Parm -dANDROID -CpARMV6 -Xs -Sgic -XParm-linux-androideabi- -XX -O3 -CX
SGTEMPUNITDIR=./../Build/Sources/Temp
SGRMFILE=$(SGTEMPUNITDIR)/SaGeRMFiles.inc
SAGE="./../Binaries/$(DESKTOPFILENAME)"
SAGELIB=$(PROJECTSDIR)/$(LIBRARYFILENAME)

release:
	@$(PASCALCOMPILER) $(DORELEASE) $(DESKTOPARGS)
release_x32:
	@$(PASCALCOMPILER) $(X32) $(DORELEASE) $(DESKTOPARGS)
release_x64:
	@$(PASCALCOMPILER) $(X64) $(DORELEASE) $(DESKTOPARGS)
release_libpng:
	@$(PASCALCOMPILER) $(X32) $(DORELEASE) -dENABLELIBPNG $(DESKTOPARGS)
debug_libpng:
	@$(PASCALCOMPILER) $(X32) $(DODEBUG) -dENABLELIBPNG $(DESKTOPARGS)
debug:
	@$(PASCALCOMPILER) $(DODEBUG) $(DESKTOPARGS)
debug_x32:
	@$(PASCALCOMPILER) $(X32) $(DODEBUG) $(DESKTOPARGS)
debug_x64:
	@$(PASCALCOMPILER) $(X64) $(DODEBUG) $(DESKTOPARGS)
darwin_debug:
	@$(PASCALCOMPILER) $(DODEBUG) $(DARWINARGS) $(DESKTOPARGS)
darwin_debug_x32:
	@$(PASCALCOMPILER) $(X32) $(DODEBUG) $(DARWINARGS) $(DESKTOPARGS)
darwin_release:
	@$(PASCALCOMPILER) $(DORELEASE) $(DARWINARGS) $(DESKTOPARGS)
darwin_release_x32:
	@$(PASCALCOMPILER) $(X32) $(DORELEASE) $(DARWINARGS) $(DESKTOPARGS)
darwin_debug_x64:
	@$(PASCALCOMPILER) $(X64) $(DODEBUG) $(DARWINARGS) $(DESKTOPARGS)
darwin_release_x64:
	@$(PASCALCOMPILER) $(X64) $(DORELEASE) $(DARWINARGS) $(DESKTOPARGS)
lib:
	@$(PASCALCOMPILER) -dLIBRARY $(DORELEASE) $(ARGS) $(OUTPUTLIBRARY) $(SAGELIB)
lib_x32:
	@$(PASCALCOMPILER) -dLIBRARY $(X32) $(DORELEASE) $(ARGS) $(OUTPUTLIBRARY) $(SAGELIB)
lib_x64:
	@$(PASCALCOMPILER) -dLIBRARY $(X64) $(DORELEASE) $(ARGS) $(OUTPUTLIBRARY) $(SAGELIB)
android:
	@$(CROSSPASCALCOMPILER) $(DOANDROID) $(BASEARGS) $(ANDROIDARGS) $(OUTPUTANDROID) $(DESKTOPFILE)
ios:
	
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
	@$(SAGE) -CDTPUARU "./../Data/Textures/Killer"                          $(SGTEMPUNITDIR)                      $(SGRMFILE)
	@$(SAGE) -CDTPUARU "./../Data/Fonts"                                    $(SGTEMPUNITDIR)                      $(SGRMFILE)
clear_files:
	@rm -f Sources/Temp/*
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
	@rm -f *.bak
	@rm -f *.a
	@rm -f fpc-res.res
	@rm -f Sources/*.o
	@rm -f Sources/*.ppu
	@rm -f Main.res
	@$(MAKE) clear_files
