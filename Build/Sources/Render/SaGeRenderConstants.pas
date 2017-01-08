{$INCLUDE SaGe.inc}

unit SaGeRenderConstants;

interface

uses
	SaGeBased;

const
	TSGRenderFar = 5000;
	TSGRenderNear = 1;

type
	TSGRPInteger = ^ integer;
	
	TSGMatrixMode   = TSGLongWord;
	TSGPrimtiveType = TSGLongWord;
	
	TSGRenderType   = (SGRenderNone,SGRenderOpenGL,SGRenderDirectX9,SGRenderDirectX8,SGRenderGLES);

{$INCLUDE SaGeRenderConstants.inc}

implementation

end.