DX32=-Pi386 -FUOutput/i386-debug-desktop
DX64=-Px86_64 -FUOutput/x86_64-debug-desktop
RX32=-Pi386 -FUOutput/i386-release-desktop
RX64=-Px86_64 -FUOutput/x86_64-release-desktop
LX32=-Pi386 -FUOutput/i386-library
LX64=-Px86_64 -FUOutput/x86_64-library
PASCALCOMPILER=fpc
CROSSPASCALCOMPILER="./../FPC/bin/i386-win32/$(PASCALCOMPILER)"
DESKTOPFILENAME=Main
LIBRARYFILENAME=SaGe
PROJECTSDIR=Sources/Projects
DESKTOPFILE=$(PROJECTSDIR)/$(DESKTOPFILENAME)
BASEARGS= -FiSources/Temp -FuSources/ConsolePrograms -FuSources/Context -FuSources/Render -FuSources/Temp -FuSources/Others/Synapse -FiSources/Includes/Screen -FiSources/Includes -FiSources/Includes/Mesh -FiSources/Includes/Render -FiSources/Includes/Examples -FiSources/Includes/Common -FiSources/Includes/Fractals -FuSources/Others/lNet -FuSources/Others/lNet/sys -FuSources -FuSources/Programs -FuSources/Others -FuSources/Others/PasJpeg -FiSources/Includes -Sm -dENGINE -Fu../Examples/* -Fu../Examples
RENDERARGS= -FuSources/DirectX -FuSources/DirectX/9 -FuSources/DirectX/12 -FuSources/OpenGL 
DARWINARGS=-k-framework -kOpenGL
ARGS= $(BASEARGS) $(RENDERARGS)
ANDROIDARGS= -FuSources/Android -FlAndroidTools/Libs/Others -FlAndroidTools/Libs -FuSources/OpenGL 
OUTPUTDESKTOP= -FE./../Binaries
OUTPUTANDROID= -FUOutput/arm-android -oAndroidTools/SaGe/libs/armeabi/libmain.so
DESKTOPARGS= $(ARGS) $(OUTPUTDESKTOP) $(DESKTOPFILE)
DODEBUG= -Ci -Ct -Co -Sa -gl -Xg -dDEBUG
DORELEASE= -XX -O2 -CX -dRELEASE
DOWITHFPU= -CfVFPV3
DOANDROID= -Tandroid -Parm -dANDROID -CpARMV6 -Xs -Sgic -XParm-linux-androideabi- -XX -O3 -CX
SGTEMPUNITDIR=./../Build/Sources/Temp
SGRMFILE=$(SGTEMPUNITDIR)/SaGeRMFiles.inc
SAGE="./../Binaries/$(DESKTOPFILENAME)"
SAGELIB=$(PROJECTSDIR)/$(LIBRARYFILENAME)
SG_TARGET_LIST=release_x32, release_x64, debug_x32, debug_x64, lib_x32, lib_x64
SG_TARGET=

release_x32, release:
	@$(PASCALCOMPILER) $(RX32) $(DORELEASE) $(DESKTOPARGS)
release_x64:
	@$(PASCALCOMPILER) $(RX64) $(DORELEASE) $(DESKTOPARGS)
debug_x32, debug:
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(DESKTOPARGS)
debug_x64:
	@$(PASCALCOMPILER) $(DX64) $(DODEBUG) $(DESKTOPARGS)
darwin_debug_x32, darwin_debug:
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(DARWINARGS) $(DESKTOPARGS)
darwin_release_x32, darwin_release:
	@$(PASCALCOMPILER) $(RX32) $(DORELEASE) $(DARWINARGS) $(DESKTOPARGS)
darwin_debug_x64:
	@$(PASCALCOMPILER) $(DX64) $(DODEBUG) $(DARWINARGS) $(DESKTOPARGS)
darwin_release_x64:
	@$(PASCALCOMPILER) $(RX64) $(DORELEASE) $(DARWINARGS) $(DESKTOPARGS)
lib_x32, lib:
	@$(PASCALCOMPILER) -dLIBRARY $(LX32) $(DORELEASE) $(ARGS) $(OUTPUTDESKTOP) $(SAGELIB)
lib_x64:
	@$(PASCALCOMPILER) -dLIBRARY $(LX64) $(DORELEASE) $(ARGS) $(OUTPUTDESKTOP) $(SAGELIB)
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
	@rm -f Output/arm-android/*
	@rm -f Output/i386-library/*
	@rm -f Output/x86_64-library/*
	@rm -f Output/i386-debug-desktop/*
	@rm -f Output/i386-release-desktop/*
	@rm -f Output/x86_64-debug-desktop/*
	@rm -f Output/x86_64-release-desktop/*
	@rm -f Output/*.o
	@rm -f Output/*.ppu
	@rm -f Output/*.res
	@rm -f Output/*.or
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
sg_compile:
	$(MAKE) clear_files
	$(SAGE) --sco $(SG_TARGET)
	$(MAKE) $(SG_TARGET)
	$(MAKE) clear_files
