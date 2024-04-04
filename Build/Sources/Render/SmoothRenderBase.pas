{$INCLUDE Smooth.inc}

unit SmoothRenderBase;

interface

uses
	 SmoothBase
	;
type
	TSVertexFormat = (SVertexFormat2f, SVertexFormat3f, SVertexFormat4f);
const
	TSRenderFar  = 5000.0; //Depth
	TSRenderNear = 0.3;
const
	S_3D =                              $000011;
	S_3D_ORTHO =                        $000012;
	S_2D =                              $000027;
	S_GLSL_3_0 =                        $000028;
	S_GLSL_ARB =                        $000029;
type
	TSRPInteger = ^ integer;
	
	TSMatrixMode   = TSUInt32;
	TSPrimtiveType = TSUInt32;
	
	TSRenderType   = (SRenderNull, SRenderOpenGL, SRenderDirectX9, SRenderDirectX8, SRenderGLES);
	TSMemoryDataType = (SRAM, SVRAM);

{$INCLUDE SmoothRenderConstants.inc}

function SStrPolygonsType(const PrimetiveType : TSPrimtiveType) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SStrVertexFormat(const VertexFormat : TSVertexFormat) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothStringUtils
	;

function SStrVertexFormat(const VertexFormat : TSVertexFormat) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case VertexFormat of
SVertexFormat2f : Result := 'SVertexFormat2f';
SVertexFormat3f : Result := 'SVertexFormat3f';
SVertexFormat4f : Result := 'SVertexFormat4f';
else              Result := 'INVALID(' + SStr(TSByte(VertexFormat)) + ')';
end;
end;

function SStrPolygonsType(const PrimetiveType : TSPrimtiveType) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case PrimetiveType of
SR_LINES      : Result := 'SR_LINES';
SR_TRIANGLES  : Result := 'SR_TRIANGLES';
SR_QUADS      : Result := 'SR_QUADS';
SR_POINTS     : Result := 'SR_POINTS';
SR_LINE_STRIP : Result := 'SR_LINE_STRIP';
SR_LINE_LOOP  : Result := 'SR_LINE_LOOP';
else            Result := 'INVALID(' + SStr(PrimetiveType) + ')';
end;
end;

end.
