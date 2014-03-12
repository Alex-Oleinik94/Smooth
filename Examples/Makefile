PP=fpc
BASEARGS= -Fu. -Fu./../Build/SrcUnits/Includes -Fu./../Build/SrcUnits/Inet -Fu./../Build/SrcUnits/Inet/sys -Fu./../Build/SrcUnits -Fu./../Build/SrcUnits/Others -Fi./../Build/SrcUnits/Includes -Sm
RENDERARGS= -Fu./../Build/SrcUnits/DirectX -Fu./../Build/SrcUnits/OpenGL 
OUTPUTUNIXORWIN= -FU./../Build/CompiledUnits/i386-other -FE.

default:
	$(PP) $(BASEARGS) $(RENDERARGS) $(OUTPUTUNIXORWIN) $(OPT) Example3/Example3
	$(PP) $(BASEARGS) $(RENDERARGS) $(OUTPUTUNIXORWIN) $(OPT) Example2/Example2
	$(PP) $(BASEARGS) $(RENDERARGS) $(OUTPUTUNIXORWIN) $(OPT) Example1/Example1
