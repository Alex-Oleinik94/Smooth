OutputDirectory=Output
DX32=-Pi386 -FU$(OutputDirectory)/i386-debug-desktop
DX64=-Px86_64 -FU$(OutputDirectory)/x86_64-debug-desktop
RX32=-Pi386 -FU$(OutputDirectory)/i386-release-desktop
RX64=-Px86_64 -FU$(OutputDirectory)/x86_64-release-desktop
LX32=-Pi386 -FU$(OutputDirectory)/i386-library
LX64=-Px86_64 -FU$(OutputDirectory)/x86_64-library
SGBUILDPATH=./../Build
SGBINARYPATH=./../Binaries
SGDATAPATH=./../Data
SGPACKAGESPATH=Packages
SGRESOURCESDIR=$(OutputDirectory)/Resources
SGRESOURCESPATH=$(SGBUILDPATH)/$(SGRESOURCESDIR)
SGRESOURCESCACHEDIR=$(OutputDirectory)/ResourcesCache
SGRESOURCESCACHEPATH=$(SGBUILDPATH)/$(SGRESOURCESCACHEDIR)
SGFILEREGISTRATIONRESOURCES=$(SGRESOURCESPATH)/SaGeFileRegistrationResources.inc
SGFILEREGISTRATIONPACKAGES=$(SGRESOURCESPATH)/SaGeFileRegistrationPackages.inc
PASCALCOMPILER=fpc
CROSSPASCALCOMPILER="./../FPC/bin/i386-win32/$(PASCALCOMPILER)"
DESKTOPFILENAME=Main
LIBRARYFILENAME=SaGe
PROJECTSDIR=Sources/Projects
DESKTOPFILE=$(PROJECTSDIR)/$(DESKTOPFILENAME)
EXTERNALARGS= -FuExternalSources/OpenAL -FuExternalSources/sdl2 -FuExternalSources/sdl -FuExternalSources/ffmpeg -FuExternalSources/DCP/Ciphers -FuExternalSources/DCP/Hashes -FuExternalSources/DCP -FuExternalSources/Ogg -FuExternalSources/Synapse -FuExternalSources/lNet -FuExternalSources/lNet/sys -FuExternalSources -FuExternalSources/PasJpeg 
INCLUDESARGS= -FiSources/Includes/Screen -FiSources/Includes -FiSources/Includes/Mesh -FiSources/Includes/Render -FiSources/Includes/Common -FiSources/Includes/Fractals -FiSources/Includes
SOURCEARGS= -FuSources/Images -FuSources/ConsoleTools -FuSources/Base -FuSources/ConsoleTools/Programs -FuSources/Audio -FuSources/Console -FuSources/Context -FuSources/Render -FuSources -FuSources/Programs 
EXAMPLESARGS= -Fu../Examples/* -Fu../Examples
BASEARGS= -FiOutput/Resources -FuOutput/Resources -Sm -dENGINE  $(EXAMPLESARGS) $(SOURCEARGS) $(INCLUDESARGS) $(EXTERNALARGS)
RENDERARGS= -FuExternalSources/DirectX/9 -FuExternalSources/DirectX/12 -FuExternalSources/OpenGL
DARWINARGS=-k-framework -kOpenGL
ARGS= $(BASEARGS) $(RENDERARGS)
ANDROIDARGS= -FuExternalSources/Android -FlAndroidTools/Libs/Others -FlAndroidTools/Libs -FuExternalSources/OpenGL
OUTPUTDESKTOP= -FE$(SGBINARYPATH)
OUTPUTANDROID= -FUOutput/arm-android -oAndroidTools/SaGe/libs/armeabi/libmain.so
DESKTOPARGS= $(ARGS) $(OUTPUTDESKTOP) $(DESKTOPFILE)
DODEBUG= -Ci -Ct -Co -Sa -gl -Xg -dDEBUG
DORELEASE= -XX -O2 -CX -dRELEASE
DOWITHFPU= -CfVFPV3
DOANDROID= -Tandroid -Parm -dANDROID -CpARMV6 -Xs -Sgic -XParm-linux-androideabi- -XX -O3 -CX
SAGE="$(SGBINARYPATH)/$(DESKTOPFILENAME)"
SAGELIB=$(PROJECTSDIR)/$(LIBRARYFILENAME)
SG_TARGET_LIST=debug, release, release_x32, release_x64, debug_x32, debug_x64, lib_x32, lib_x64
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
	@$(SAGE) -CCFTPUARU "$(SGDATAPATH)/Engine/version.txt" $(SGRESOURCESPATH) $(SGRESOURCESCACHEPATH) SaGeVersionFile $(SGFILEREGISTRATIONRESOURCES)
inc_version_release:
	@$(SAGE) -iv 1
	@$(SAGE) -CCFTPUARU "$(SGDATAPATH)/Engine/version.txt" $(SGRESOURCESPATH) $(SGRESOURCESCACHEPATH) SaGeVersionFile $(SGFILEREGISTRATIONRESOURCES)
build_files:
	@$(MAKE) clear_files
	@$(SAGE) -bf "$(SGBUILDPATH)/BuildFiles.ini" $(SGRESOURCESPATH) $(SGRESOURCESCACHEPATH) $(SGFILEREGISTRATIONRESOURCES)
clear_files:
	@rm -f $(SGRESOURCESDIR)/*.pas
	@rm -f $(SGRESOURCESDIR)/*.inc
	@$(SAGE) -cfrr $(SGFILEREGISTRATIONRESOURCES)
	@$(SAGE) -cfrp $(SGFILEREGISTRATIONPACKAGES)
clear:
	@rm -f $(OutputDirectory)/arm-android/*
	@rm -f $(OutputDirectory)/i386-library/*
	@rm -f $(OutputDirectory)/x86_64-library/*
	@rm -f $(OutputDirectory)/i386-debug-desktop/*
	@rm -f $(OutputDirectory)/i386-release-desktop/*
	@rm -f $(OutputDirectory)/x86_64-debug-desktop/*
	@rm -f $(OutputDirectory)/x86_64-release-desktop/*
	@rm -f $(OutputDirectory)/*.o
	@rm -f $(OutputDirectory)/*.ppu
	@rm -f $(OutputDirectory)/*.res
	@rm -f $(OutputDirectory)/*.or
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
