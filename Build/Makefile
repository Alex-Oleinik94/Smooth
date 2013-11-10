PP=fpc
BASEARGS= -FuSrcUnits\Includes -FuSrcUnits/Inet -FuSrcUnits/Inet/sys -FuSrcUnits -FuSrcUnits/DirectX -FuSrcUnits/OpenGL -FiSrcUnits/Includes -Sm -FUCompiledUnits -FE./../BinDebug/
DODEBUG= -gl 
DORELEASE= -XX -O3 -CX -dRELEASE

enigma:
	./EnigmaVB/enigmavbconsole.exe Main.evb
release:
	$(PP) $(DORELEASE) $(BASEARGS) $(OPT) Main
	strip ../BinDebug/Main
debug:
	$(PP) $(DODEBUG) $(BASEARGS) $(OPT) Main
lib:
	$(PP) $(DORELEASE) $(BASEARGS) $(OPT) SaGeLib
	$(MAKE) clear
clear:
	rm -f CompiledUnits/*
	rm -f *.o
	rm -f *.ppu
	rm -f *.or
	rm -f ppas.bat
	rm -f *.a
	rm -f fpc-res.res
	rm -f SrcUnits/*.o
	rm -f SrcUnits/*.ppu
