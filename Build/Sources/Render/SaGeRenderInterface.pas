{$INCLUDE SaGe.inc}

unit SaGeRenderInterface;

interface

uses
	 SaGeBase
	,SaGeCommon
	,SaGeClasses
	,SaGeRenderBase
	;

type
	ISGRender = interface;
	ISGAudioRender = interface;
type
	ISGAudioRender = interface
		['{cb4d7649-16ee-44f6-b9f1-bf393f6bb18c}']
		procedure Initialize();
		procedure Init();
		function CreateDevice() : TSGBool;
		procedure Kill();
		end;
	
	TSGRenderTexture = type TSGUInt32;
	PSGRenderTexture = ^ TSGRenderTexture;
	ISGRender = interface(ISGRectangle)
		['{6d0d4eb0-4de7-4000-bf5d-52a069a776d1}']
		function GetRenderType() : TSGRenderType;
		function SetPixelFormat():TSGBoolean;
		function MakeCurrent():TSGBoolean;
		procedure ReleaseCurrent();
		function CreateContext():TSGBoolean;
		procedure Viewport(const a,b,c,d:TSGAreaInt);
		procedure Init();
		function SupporedVBOBuffers():TSGBoolean;
		procedure SwapBuffers();
		procedure LockResources();
		procedure UnLockResources();
		procedure SetContext(const VContext : ISGNearlyContext);
		function GetContext() : ISGNearlyContext;

		procedure InitOrtho2d(const x0, y0, x1, y1:TSGSingle);
		procedure InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht : TSGFloat = 1);
		procedure BeginScene(const VPrimitiveType:TSGPrimtiveType);
		procedure EndScene();
		procedure Perspective(const vAngle,vAspectRatio,vNear,vFar : TSGFloat);
		procedure LoadIdentity();
		procedure ClearColor(const r,g,b,a : TSGFloat);
		procedure Vertex3f(const x,y,z:TSGSingle);
		procedure Scale(const x,y,z : TSGSingle);
		procedure Color3f(const r,g,b:TSGSingle);
		procedure TexCoord2f(const x,y:TSGSingle);
		procedure Vertex2f(const x,y:TSGSingle);
		procedure Color4f(const r,g,b,a:TSGSingle);
		procedure Normal3f(const x,y,z:TSGSingle);
		procedure Translatef(const x,y,z:TSGSingle);
		procedure Rotatef(const angle:TSGSingle;const x,y,z:TSGSingle);
		procedure Enable(VParam:TSGCardinal);
		procedure Disable(const VParam:TSGCardinal);
		procedure DeleteTextures(const VQuantity:TSGCardinal;const VTextures:PSGRenderTexture);
		procedure Lightfv(const VLight,VParam:TSGCardinal;const VParam2:TSGPointer);
		procedure GenTextures(const VQuantity:TSGCardinal;const VTextures:PSGRenderTexture);
		procedure BindTexture(const VParam:TSGCardinal;const VTexture:TSGCardinal);
		procedure TexParameteri(const VP1,VP2,VP3:TSGCardinal);
		procedure PixelStorei(const VParamName:TSGCardinal;const VParam:TSGInt32);
		procedure TexEnvi(const VP1,VP2,VP3:TSGCardinal);
		procedure TexImage2D(const VTextureType:TSGCardinal;const VP1:TSGCardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:TSGCardinal;VBitMap:TSGPointer);
		procedure ReadPixels(const x,y:TSGInteger;const Vwidth,Vheight:TSGInteger;const format, atype: TSGCardinal;const pixels: TSGPointer);
		procedure CullFace(const VParam:TSGCardinal);
		procedure EnableClientState(const VParam:TSGCardinal);
		procedure DisableClientState(const VParam:TSGCardinal);
		procedure GenBuffersARB(const VQ:TSGInteger;const PT:PCardinal);
		procedure DeleteBuffersARB(const VQuantity:TSGLongWord;VPoint:TSGPointer);
		procedure BindBufferARB(const VParam:TSGCardinal;const VParam2:TSGCardinal);
		procedure BufferDataARB(const VParam:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer;const VParam2:TSGCardinal;const VIndexPrimetiveType : TSGLongWord = 0);
		procedure DrawElements(const VParam:TSGCardinal;const VSize:TSGInt64;const VParam2:TSGCardinal;VBuffer:TSGPointer);
		procedure ColorPointer(const VQChannels:TSGLongWord;const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);
		procedure TexCoordPointer(const VQChannels:TSGLongWord;const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);
		procedure NormalPointer(const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);
		procedure VertexPointer(const VQChannels:TSGLongWord;const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);
		function IsEnabled(const VParam:TSGCardinal):Boolean;
		procedure Clear(const VParam:TSGCardinal);
		procedure LineWidth(const VLW:TSGSingle);
		procedure PointSize(const PS:Single);
		procedure PopMatrix();
		procedure PushMatrix();
		procedure DrawArrays(const VParam:TSGCardinal;const VFirst,VCount:TSGLongWord);
		procedure Vertex3fv(const Variable : TSGPointer);
		procedure Normal3fv(const Variable : TSGPointer);
		procedure MultMatrixf(const Variable : TSGPointer);
		procedure ColorMaterial(const r,g,b,a:TSGSingle);
		procedure MatrixMode(const Par:TSGLongWord);
		procedure LoadMatrixf(const Variable : TSGPointer);
		procedure ClientActiveTexture(const VTexture : TSGLongWord);
		procedure ActiveTexture(const VTexture : TSGLongWord);
		procedure ActiveTextureDiffuse();
		procedure ActiveTextureBump();
		procedure BeginBumpMapping(const Point : Pointer );
		procedure EndBumpMapping();
		procedure PolygonOffset(const VFactor, VUnits : TSGFloat);
		{$IFDEF MOBILE}
			procedure GenerateMipmap(const Param : TSGCardinal);
		{$ELSE}
			procedure GetVertexUnderPixel(const px,py : LongWord; out x,y,z : Real);
			{$ENDIF}

			(* Shaders *)
		function SupporedShaders() : TSGBoolean;
		function CreateShader(const VShaderType : TSGCardinal):TSGLongWord;
		procedure ShaderSource(const VShader : TSGLongWord; VSourse : PChar; VSourseLength : integer);
		procedure CompileShader(const VShader : TSGLongWord);
		procedure GetObjectParameteriv(const VObject : TSGLongWord; const VParamName : TSGCardinal; const VResult : TSGRPInteger);
		procedure GetInfoLog(const VHandle : TSGLongWord; const VMaxLength : TSGInteger; var VLength : TSGInteger; VLog : PChar);
		procedure DeleteShader(const VProgram : TSGLongWord);

		function CreateShaderProgram() : TSGLongWord;
		procedure AttachShader(const VProgram, VShader : TSGLongWord);
		procedure LinkShaderProgram(const VProgram : TSGLongWord);
		procedure DeleteShaderProgram(const VProgram : TSGLongWord);

		function GetUniformLocation(const VProgram : TSGLongWord; const VLocationName : PChar): TSGLongWord;
		procedure Uniform1i(const VLocationName : TSGLongWord; const VData:TSGLongWord);
		procedure UseProgram(const VProgram : TSGLongWord);
		procedure UniformMatrix4fv(const VLocationName : TSGLongWord; const VCount : TSGLongWord; const VTranspose : TSGBoolean; const VData : TSGPointer);
		procedure Uniform3f(const VLocationName : TSGLongWord; const VX,VY,VZ : TSGFloat);
		procedure Uniform1f(const VLocationName : TSGLongWord; const V : TSGFloat);
		procedure Uniform1iv (const VLocationName: TSGLongWord; const VCount: TSGLongWord; const VValue: Pointer);
		procedure Uniform1uiv (const VLocationName: TSGLongWord; const VCount: TSGLongWord; const VValue: Pointer);
		procedure Uniform3fv (const VLocationName: TSGLongWord; const VCount: TSGLongWord; const VValue: Pointer);

		function SupporedDepthTextures():TSGBoolean;
		procedure BindFrameBuffer(const VType : TSGCardinal; const VHandle : TSGLongWord);
		procedure GenFrameBuffers(const VCount : TSGLongWord;const VBuffers : PCardinal);
		procedure DrawBuffer(const VType : TSGCardinal);
		procedure ReadBuffer(const VType : TSGCardinal);
		procedure GenRenderBuffers(const VCount : TSGLongWord;const VBuffers : PCardinal);
		procedure BindRenderBuffer(const VType : TSGCardinal; const VHandle : TSGLongWord);
		procedure FrameBufferTexture2D(const VTarget: TSGCardinal; const VAttachment: TSGCardinal; const VRenderbuffertarget: TSGCardinal; const VRenderbuffer, VLevel: TSGLongWord);
		procedure FrameBufferRenderBuffer(const VTarget: TSGCardinal; const VAttachment: TSGCardinal; const VRenderbuffertarget: TSGCardinal; const VRenderbuffer: TSGLongWord);
		procedure RenderBufferStorage(const VTarget, VAttachment: TSGCardinal; const VWidth, VHeight: TSGLongWord);
		procedure GetFloatv(const VType : TSGCardinal; const VPointer : Pointer);

		property Width : TSGAreaInt read GetWidth write SetWidth;
		property Height : TSGAreaInt read GetHeight write SetHeight;
		property Context : ISGNearlyContext read GetContext write SetContext;
		property RenderType : TSGRenderType read GetRenderType;

		{$DEFINE INC_PLACE_RENDER_INTERFACE}
		{$INCLUDE SaGeCommonStructs.inc}
		{$UNDEF INC_PLACE_RENDER_INTERFACE}
		end;

	ISGRendered = interface
		['{535e900f-03d6-47d1-b2e1-9eadadf877f3}']
		function GetRender() : ISGRender;
		function RenderAssigned() : TSGBoolean;

		property Render : ISGRender read GetRender;
		end;

procedure SGRoundQuad(const VRender:ISGRender;const Vertex1,Vertex3: TSGVertex3f; const Radius:real; const Interval:LongInt;const QuadColor: TSGColor4f; const LinesColor: TSGColor4f; const WithLines:boolean = False;const WithQuad:boolean = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure SGRoundQuad(const VRender:ISGRender;const Vertex12,Vertex32: TSGVertex2f; const Radius:real; const Interval:LongInt;const QuadColor: TSGColor4f; const LinesColor: TSGColor4f; const WithLines:boolean = False;const WithQuad:boolean = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure SGRoundWindowQuad(const VRender:ISGRender;const Vertex11,Vertex13: TSGVertex3f;const Vertex21,Vertex23: TSGVertex3f;
	const Radius1:real;const Radius2:real; const Interval:LongInt;const QuadColor1: TSGColor4f;const QuadColor2: TSGColor4f;
	const WithLines:boolean; const LinesColor1: TSGColor4f; const LinesColor2: TSGColor4f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGConstructRoundQuad(const VRender:ISGRender;const ArVertex:TSGVertex3fList;const Interval:LongInt;const QuadColor: TSGColor4f; const LinesColor: TSGColor4f; const WithLines:boolean = False;const WithQuad:boolean = True);
procedure SGMultMatrixInRender(const VRender : ISGRender; Matrix : TSGMatrix4);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$IFNDEF MOBILE}
function SGGetVertexUnderPixel(const VRender : ISGRender; const Pixel : TSGPoint2i32):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$ENDIF}


implementation

{$IFNDEF MOBILE}
function SGGetVertexUnderPixel(const VRender : ISGRender; const Pixel : TSGPoint2i32):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	x,y,z : Real;
begin
VRender.GetVertexUnderPixel(Pixel.x,Pixel.y,x,y,z);
Result.Import(x,y,z);
end;
{$ENDIF}

procedure SGMultMatrixInRender(const VRender : ISGRender; Matrix : TSGMatrix4);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
VRender.MultMatrixf(@Matrix);
end;

procedure SGWndSomeQuad(const a,c: TSGVertex3f;const VRender:ISGRender);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	b,d: TSGVertex3f;
begin
b.Import(c.x,a.y,a.z);
d.Import(a.x,c.y,a.z);
VRender.BeginScene(SGR_QUADS);
VRender.TexCoord2f(0,1);VRender.Vertex(a);
VRender.TexCoord2f(1,1);VRender.Vertex(b);
VRender.TexCoord2f(1,0);VRender.Vertex(c);
VRender.TexCoord2f(0,0);VRender.Vertex(d);
VRender.EndScene();
end;

procedure SGSomeQuad(a,b,c,d: TSGVertex3f;vl,np:TSGPoint2int32;const VRender:ISGRender);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
VRender.BeginScene(SGR_QUADS);
VRender.TexCoord2f(vl.x, vl.y);
VRender.Vertex(a);
VRender.TexCoord2f(np.x, vl.y);
VRender.Vertex(b);
VRender.TexCoord2f(np.x, np.y);
VRender.Vertex(c);
VRender.TexCoord2f(vl.x, np.y);
VRender.Vertex(d);
VRender.EndScene();
end;

procedure SGRoundWindowQuad(const VRender:ISGRender;const Vertex11,Vertex13: TSGVertex3f;const Vertex21,Vertex23: TSGVertex3f;
	const Radius1:real;const Radius2:real; const Interval:LongInt;const QuadColor1: TSGColor4f;const QuadColor2: TSGColor4f;
	const WithLines:boolean; const LinesColor1: TSGColor4f; const LinesColor2: TSGColor4f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SGRoundQuad(VRender,Vertex11,Vertex13,Radius1,Interval,QuadColor1,LinesColor1,WithLines);
SGRoundQuad(VRender,Vertex21,Vertex23,Radius2,Interval,QuadColor2,LinesColor2,WithLines);
end;

procedure SGRoundQuad(
	const VRender:ISGRender;
	const Vertex12,Vertex32: TSGVertex2f;
	const Radius:real;
	const Interval:LongInt;
	const QuadColor: TSGColor4f;
	const LinesColor: TSGColor4f;
	const WithLines:boolean = False;
	const WithQuad:boolean = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	ArVertex : TSGVertex3fList = nil;
	Vertex1, Vertex3 : TSGVertex3f;
begin
Vertex1.Import(Vertex12.x, Vertex12.y);
Vertex3.Import(Vertex32.x, Vertex32.y);
ArVertex := SGGetArrayOfRoundQuad(Vertex1,Vertex3,Radius,Interval);
SGConstructRoundQuad(VRender,ArVertex,Interval,QuadColor,LinesColor,WithLines,WithQuad);
SetLength(ArVertex,0);
end;

procedure SGRoundQuad(
	const VRender:ISGRender;
	const Vertex1,Vertex3: TSGVertex3f;
	const Radius:real;
	const Interval:LongInt;
	const QuadColor: TSGColor4f;
	const LinesColor: TSGColor4f;
	const WithLines:boolean = False;
	const WithQuad:boolean = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	ArVertex : TSGVertex3fList = nil;
begin
ArVertex := SGGetArrayOfRoundQuad(Vertex1,Vertex3,Radius,Interval);
SGConstructRoundQuad(VRender,ArVertex,Interval,QuadColor,LinesColor,WithLines,WithQuad);
SetLength(ArVertex,0);
end;

procedure SGConstructRoundQuad(
	const VRender:ISGRender;
	const ArVertex:TSGVertex3fList;
	const Interval:LongInt;
	const QuadColor: TSGColor4f;
	const LinesColor: TSGColor4f;
	const WithLines:boolean = False;
	const WithQuad:boolean = True);
var
	I:LongInt;
begin
if WithQuad then
	begin
	VRender.Color(QuadColor);
	VRender.BeginScene(SGR_QUADS);
	for i:=0 to Interval-1 do
		begin
		VRender.Vertex(ArVertex[Interval-i]);
		VRender.Vertex(ArVertex[Interval+1+i]);
		VRender.Vertex(ArVertex[Interval+2+i]);
		VRender.Vertex(ArVertex[Interval-i-1]);
		end;
	VRender.Vertex(ArVertex[0]);
	VRender.Vertex(ArVertex[2*Interval+1]);
	VRender.Vertex(ArVertex[2*Interval+2]);
	VRender.Vertex(ArVertex[4*(Interval+1)-1]);
	for i:=0 to Interval-1 do
		begin
		VRender.Vertex(ArVertex[(Interval+1)*2+i]);
		VRender.Vertex(ArVertex[(Interval+1)*2+i+1]);
		VRender.Vertex(ArVertex[(Interval+1)*4-2-i]);
		VRender.Vertex(ArVertex[(Interval+1)*4-1-i]);
		end;
	VRender.EndScene();
	end;
if WithLines then
	begin
	VRender.Color(LinesColor);
	VRender.BeginScene(SGR_LINE_LOOP);
	for i:=Low(ArVertex) to High(ArVertex) do
		VRender.Vertex(ArVertex[i]);
	VRender.EndScene();
	end;
end;

end.
