{$INCLUDE SaGe.inc}

unit SaGeRenderBase;

interface

uses
	 SaGeBase
	;
type
	TSGVertexFormat = (SGVertexFormat2f, SGVertexFormat3f, SGVertexFormat4f);
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

function SGStrPoligonesType(const PrimetiveType : TSGPrimtiveType) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGStrVertexFormat(const VertexFormat : TSGVertexFormat) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeStringUtils
	;

function SGStrVertexFormat(const VertexFormat : TSGVertexFormat) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case VertexFormat of
SGVertexFormat2f : Result := 'SGVertexFormat2f';
SGVertexFormat3f : Result := 'SGVertexFormat3f';
SGVertexFormat4f : Result := 'SGVertexFormat4f';
else               Result := 'INVALID(' + SGStr(TSGByte(VertexFormat)) + ')';
end;
end;

function SGStrPoligonesType(const PrimetiveType : TSGPrimtiveType) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case PrimetiveType of
SGR_LINES      : Result := 'SGR_LINES';
SGR_TRIANGLES  : Result := 'SGR_TRIANGLES';
SGR_QUADS      : Result := 'SGR_QUADS';
SGR_POINTS     : Result := 'SGR_POINTS';
SGR_LINE_STRIP : Result := 'SGR_LINE_STRIP';
SGR_LINE_LOOP  : Result := 'SGR_LINE_LOOP';
else             Result := 'INVALID(' + SGStr(PrimetiveType) + ')';
end;
end;

end.
