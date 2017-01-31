{$INCLUDE SaGe.inc}

unit SaGeRenderConstants;

interface

uses
	 SaGeBase
	;

const
	TSGRenderFar  = 5000;
	TSGRenderNear = 1;
const
	SG_3D =                              $000011;
	SG_3D_ORTHO =                        $000012;
	SG_2D =                              $000027;
	SG_GLSL_3_0 =                        $000028;
	SG_GLSL_ARB =                        $000029;
type
	TSGRPInteger = ^ integer;
	
	TSGMatrixMode   = TSGUInt32;
	TSGPrimtiveType = TSGUInt32;
	
	TSGRenderType   = (SGRenderNone, SGRenderOpenGL, SGRenderDirectX9, SGRenderDirectX8, SGRenderGLES);

{$INCLUDE SaGeRenderConstants.inc}

implementation

end.
