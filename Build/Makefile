OutputDirectory=Output
DX32=-Pi386 -FU$(OutputDirectory)/i386-debug-desktop
DX64=-Px86_64 -FU$(OutputDirectory)/x86_64-debug-desktop
RX32=-Pi386 -FU$(OutputDirectory)/i386-release-desktop
RX64=-Px86_64 -FU$(OutputDirectory)/x86_64-release-desktop
LX32=-Pi386 -FU$(OutputDirectory)/i386-library
LX64=-Px86_64 -FU$(OutputDirectory)/x86_64-library
SBUILDPATH=./../Build
SBINARYPATH=./../Binaries
SDATAPATH=./../Data
SEXTENSIONSPATH=ExtensionSources
SRESOURCESDIR=$(OutputDirectory)/Resources
SRESOURCESPATH=$(SBUILDPATH)/$(SRESOURCESDIR)
SRESOURCESCACHEDIR=$(OutputDirectory)/ResourcesCache
SRESOURCESCACHEPATH=$(SBUILDPATH)/$(SRESOURCESCACHEDIR)
SFILEREGISTRATIONRESOURCES=$(SRESOURCESPATH)/SmoothFileRegistrationResources.inc
SFILEFORREGISTRATIONEXTENSIONS=$(SRESOURCESPATH)/SmoothFileForRegistrationExtensions.inc
PASCALCOMPILER=fpc
CROSSPASCALCOMPILER=$(PASCALCOMPILER)
DESKTOPFILENAME=Smooth
LIBRARYFILENAME=Smooth
DESKTOPFILE=Sources/$(DESKTOPFILENAME)
EXTERNALARGS= -FuExternalSources/NVidia -FuExternalSources/OpenAL -FuExternalSources/OpenSSL -FuExternalSources/sdl2 -FuExternalSources/sdl -FuExternalSources/ffmpeg -FuExternalSources/DCP/Ciphers -FuExternalSources/DCP/Hashes -FuExternalSources/DCP -FuExternalSources/Ogg -FuExternalSources/Synapse -FuExternalSources/lNet -FuExternalSources/lNet/sys -FuExternalSources -FuExternalSources/PasJpeg 
INCLUDESARGS= -FiSources/Includes/Screen -FiSources/Includes/Encoding -FiSources/Includes -FiSources/Includes/Mesh -FiSources/Includes/Render -FiSources/Includes/Common -FiSources/Includes/Fractals -FiSources/Includes
SOURCEARGS= -FuSources/Image -FuSources/ConsoleTools -FuSources/SystemTray -FuSources/Base -FuSources/Game -FuSources/3dObject -FuSources/RenderUtils -FuSources/Screen -FuSources/Fractals -FuSources/Managers -FuSources/ConsolePrograms -FuSources/Audio -FuSources/Console -FuSources/Context -FuSources/Render -FuSources/Programs -FuSources/Internet 
BASEARGS= -FiOutput/Resources -FuOutput/Resources -Sm $(SOURCEARGS) $(INCLUDESARGS) $(EXTERNALARGS)
RENDERARGS= -FuExternalSources/DirectX/9 -FuExternalSources/DirectX/12 -FuExternalSources/OpenGL
DARWINARGS=-k-framework -kOpenGL
ARGS= $(BASEARGS) $(RENDERARGS)
ANDROIDARGS= -FuExternalSources/Android -FuExternalSources/OpenGL -dENGINE 
OUTPUTDESKTOP= -FE$(SBINARYPATH)
OUTPUTANDROID_ARM= -FUOutput/arm-android -FlPlatforms/Android/Libs -FlPlatforms/Android/Libs/Others -oOutput/AndroidApplication/libs/armeabi/libmain.so
OUTPUTANDROID_I386= -FUOutput/i386-android -oOutput/AndroidApplication/libs/i386eabi/libmain.so
EXAMPLESARGS= $(ARGS) -Fu$(SEXTENSIONSPATH)\Examples\Sources -Fu$(SEXTENSIONSPATH)\Examples\Sources\Graphical -Fu$(SEXTENSIONSPATH)\Examples\Sources\Console -Fu$(SEXTENSIONSPATH)/Graphic_Viewer/Sources -Fi$(SEXTENSIONSPATH)/Graphic_Viewer/Sources/Includes -Fu$(SEXTENSIONSPATH)/Genetical_Algoritm/Sources $(OUTPUTDESKTOP)
DESKTOPARGS= $(ARGS) -dENGINE $(OUTPUTDESKTOP) $(DESKTOPFILE)
DODEBUG= -Ci -Ct -Co -Sa -gl -Xg -dDEBUG
DORELEASE= -XX -O2 -CX -dRELEASE
DOWITHFPU= -CfVFPV3
DOANDROID= -Tandroid -dANDROID -Xs -Sic -XX -O3 -CX
DOANDROID_ARM= $(DOANDROID) -Parm -CpARMV6 -XParm-linux-androideabi-
DOANDROID_I386= $(DOANDROID) -Pi386 -XPi686-linux-android- 
Smooth="$(SBINARYPATH)/$(DESKTOPFILENAME)"
SmoothLIB=Sources/Library/$(LIBRARYFILENAME)
S_TARGET_LIST=debug, release, release_x32, release_x64, debug_x32, debug_x64, lib_x32, lib_x64, android_arm, android_i386
S_TARGET=

examples:
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Graphical/Ex1
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Graphical/Ex2
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Graphical/Ex2_2
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Graphical/Ex3
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Graphical/Ex4_1
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Graphical/Ex4_2
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Graphical/Ex4_3
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Graphical/Ex5
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Graphical/Ex5_2
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Graphical/Ex5_4
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Graphical/Ex6
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Graphical/Ex6_2
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Graphical/Ex7
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Console/Ex8
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Console/Ex9
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Console/Ex10
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Console/Ex11
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Console/Ex12
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Graphical/Ex13
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Graphical/Ex14
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Graphical/Ex15
	@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Graphical/Ex16
#@$(PASCALCOMPILER) $(DX32) $(DODEBUG) $(EXAMPLESARGS) ExtensionSources/Examples/Sources/Kraft/ExKraft
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
	@$(PASCALCOMPILER) -dLIBRARY $(LX32) $(DORELEASE) $(ARGS) $(OUTPUTDESKTOP) $(SmoothLIB)
lib_x64:
	@$(PASCALCOMPILER) -dLIBRARY $(LX64) $(DORELEASE) $(ARGS) $(OUTPUTDESKTOP) $(SmoothLIB)
android_arm:
	@$(CROSSPASCALCOMPILER) $(DOANDROID_ARM) $(BASEARGS) $(ANDROIDARGS) $(OUTPUTANDROID_ARM) $(DESKTOPFILE)
android_i386:
	@$(CROSSPASCALCOMPILER) $(DOANDROID_I386) $(BASEARGS) $(ANDROIDARGS) $(OUTPUTANDROID_I386) $(DESKTOPFILE)
ios:
	
inc_version_debug:
	@$(Smooth) --bt --iv 0
	@$(Smooth) --bt --CCFTPUARU "$(SDATAPATH)/Engine/version.txt" $(SRESOURCESPATH) $(SRESOURCESCACHEPATH) SmoothVersionFile $(SFILEREGISTRATIONRESOURCES)
inc_version_release:
	@$(Smooth) --bt --iv 1
	@$(Smooth) --bt --CCFTPUARU "$(SDATAPATH)/Engine/version.txt" $(SRESOURCESPATH) $(SRESOURCESCACHEPATH) SmoothVersionFile $(SFILEREGISTRATIONRESOURCES)
build_files:
	@$(MAKE) clear_files
	@$(Smooth) --bt --bf "$(SBUILDPATH)/BuildFiles.ini" $(SRESOURCESPATH) $(SRESOURCESCACHEPATH) $(SFILEREGISTRATIONRESOURCES)
clear_files:
	@rm -f $(SRESOURCESDIR)/*.pas
	@rm -f $(SRESOURCESDIR)/*.inc
	@$(Smooth) --bt --cfrr $(SFILEREGISTRATIONRESOURCES)
	@$(Smooth) --bt --cffre $(SFILEFORREGISTRATIONEXTENSIONS)
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
	@rm -f Smooth.res
	@$(MAKE) clear_files
S_compile:
	$(MAKE) clear_files
	$(Smooth) --bt --sco $(S_TARGET)
	$(MAKE) $(S_TARGET)
	$(MAKE) clear_files
