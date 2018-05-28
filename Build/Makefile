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
CROSSPASCALCOMPILER=$(PASCALCOMPILER)
DESKTOPFILENAME=Main
LIBRARYFILENAME=SaGe
PROJECTSDIR=Sources/Projects
DESKTOPFILE=$(PROJECTSDIR)/$(DESKTOPFILENAME)
EXTERNALARGS= -FuExternalSources/NVidia -FuExternalSources/OpenAL -FuExternalSources/OpenSSL -FuExternalSources/sdl2 -FuExternalSources/sdl -FuExternalSources/ffmpeg -FuExternalSources/DCP/Ciphers -FuExternalSources/DCP/Hashes -FuExternalSources/DCP -FuExternalSources/Ogg -FuExternalSources/Synapse -FuExternalSources/lNet -FuExternalSources/lNet/sys -FuExternalSources -FuExternalSources/PasJpeg 
INCLUDESARGS= -FiSources/Includes/Screen -FiSources/Includes/Encoding -FiSources/Includes -FiSources/Includes/Mesh -FiSources/Includes/Render -FiSources/Includes/Common -FiSources/Includes/Fractals -FiSources/Includes
SOURCEARGS= -FuSources/Images -FuSources/ConsoleTools -FuSources/Base -FuSources/Game -FuSources/Model -FuSources/RenderUtils -FuSources/Screen -FuSources/Fractals -FuSources/Managers -FuSources/ConsoleTools/Programs -FuSources/Audio -FuSources/Console -FuSources/Context -FuSources/Render -FuSources -FuSources/Programs -FuSources/Internet 
BASEARGS= -FiOutput/Resources -FuOutput/Resources -Sm $(SOURCEARGS) $(INCLUDESARGS) $(EXTERNALARGS)
RENDERARGS= -FuExternalSources/DirectX/9 -FuExternalSources/DirectX/12 -FuExternalSources/OpenGL
DARWINARGS=-k-framework -kOpenGL
ARGS= $(BASEARGS) $(RENDERARGS)
ANDROIDARGS= -FuExternalSources/Android -FuExternalSources/OpenGL -dENGINE 
OUTPUTDESKTOP= -FE$(SGBINARYPATH)
OUTPUTANDROID_ARM= -FUOutput/arm-android -FlPlatforms/Android/Libs -FlPlatforms/Android/Libs/Others -oOutput/AndroidApplication/libs/armeabi/libmain.so
OUTPUTANDROID_I386= -FUOutput/i386-android -oOutput/AndroidApplication/libs/i386eabi/libmain.so
EXAMPLESARGS= $(ARGS) -FuPackages\Examples\Sources\Examples -FuPackages\Examples\Sources\ConsoleExamples -FuPackages/Graphic_Viewer/Sources -FiPackages/Graphic_Viewer/Sources/Includes -FuPackages/Genetical_Algoritm/Sources $(OUTPUTDESKTOP)
DESKTOPARGS= $(ARGS) -dENGINE $(OUTPUTDESKTOP) $(DESKTOPFILE)
DODEBUG= -Ci -Ct -Co -Sa -gl -Xg -dDEBUG
DORELEASE= -XX -O2 -CX -dRELEASE
DOWITHFPU= -CfVFPV3
DOANDROID= -Tandroid -dANDROID -Xs -Sgic -XX -O3 -CX
DOANDROID_ARM= $(DOANDROID) -Parm -CpARMV6 -XParm-linux-androideabi-
DOANDROID_I386= $(DOANDROID) -Pi386 -XPi686-linux-android- 
SAGE="$(SGBINARYPATH)/$(DESKTOPFILENAME)"
SAGELIB=$(PROJECTSDIR)/$(LIBRARYFILENAME)
SG_TARGET_LIST=debug, release, release_x32, release_x64, debug_x32, debug_x64, lib_x32, lib_x64, android_arm, android_i386
SG_TARGET=

examples:
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/Examples/Ex1
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/Examples/Ex2
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/Examples/Ex2_2
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/Examples/Ex3
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/Examples/Ex4_1
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/Examples/Ex4_2
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/Examples/Ex4_3
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/Examples/Ex5
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/Examples/Ex5_2
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/Examples/Ex5_4
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/Examples/Ex6
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/Examples/Ex6_2
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/Examples/Ex7
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/ConsoleExamples/Ex8
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/ConsoleExamples/Ex9
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/ConsoleExamples/Ex10
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/ConsoleExamples/Ex11
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/ConsoleExamples/Ex12
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/Examples/Ex13
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/Examples/Ex14
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/Examples/Ex15
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) Packages/Examples/Sources/Examples/Ex16
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
android_arm:
	@$(CROSSPASCALCOMPILER) $(DOANDROID_ARM) $(BASEARGS) $(ANDROIDARGS) $(OUTPUTANDROID_ARM) $(DESKTOPFILE)
android_i386:
	@$(CROSSPASCALCOMPILER) $(DOANDROID_I386) $(BASEARGS) $(ANDROIDARGS) $(OUTPUTANDROID_I386) $(DESKTOPFILE)
ios:

inc_version_debug:
	@$(SAGE) --bt --iv 0
	@$(SAGE) --bt --CCFTPUARU "$(SGDATAPATH)/Engine/version.txt" $(SGRESOURCESPATH) $(SGRESOURCESCACHEPATH) SaGeVersionFile $(SGFILEREGISTRATIONRESOURCES)
inc_version_release:
	@$(SAGE) --bt --iv 1
	@$(SAGE) --bt --CCFTPUARU "$(SGDATAPATH)/Engine/version.txt" $(SGRESOURCESPATH) $(SGRESOURCESCACHEPATH) SaGeVersionFile $(SGFILEREGISTRATIONRESOURCES)
build_files:
	@$(MAKE) clear_files
	@$(SAGE) --bt --bf "$(SGBUILDPATH)/BuildFiles.ini" $(SGRESOURCESPATH) $(SGRESOURCESCACHEPATH) $(SGFILEREGISTRATIONRESOURCES)
clear_files:
	@rm -f $(SGRESOURCESDIR)/*.pas
	@rm -f $(SGRESOURCESDIR)/*.inc
	@$(SAGE) --bt --cfrr $(SGFILEREGISTRATIONRESOURCES)
	@$(SAGE) --bt --cfrp $(SGFILEREGISTRATIONPACKAGES)
clear:
	@rm -f $(OutputDirectory)/i386-android/*
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
	$(SAGE) --bt --sco $(SG_TARGET)
	$(MAKE) $(SG_TARGET)
	$(MAKE) clear_files
