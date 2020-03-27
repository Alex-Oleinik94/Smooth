{$INCLUDE Smooth.inc}

unit SmoothRenderInterface;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothRenderBase
	,SmoothMatrix
	,SmoothCommonStructs
	,SmoothBaseContextInterface
	;

type
	ISRender = interface;
type
	TSRenderTexture = type TSUInt32;
	PSRenderTexture = ^ TSRenderTexture;
	ISRender = interface(ISRectangle)
		['{6d0d4eb0-4de7-4000-bf5d-52a069a776d1}']
		function GetRenderType() : TSRenderType;
		function SetPixelFormat():TSBoolean;
		function MakeCurrent():TSBoolean;
		procedure ReleaseCurrent();
		function CreateContext():TSBoolean;
		procedure Viewport(const a,b,c,d:TSAreaInt);
		procedure Init();
		function SupportedGraphicalBuffers() : TSBoolean;
		function SupportedMemoryBuffers() : TSBoolean;
		procedure SwapBuffers();
		procedure LockResources();
		procedure UnLockResources();
		procedure SetContext(const VContext : ISBaseContext);
		function GetContext() : ISBaseContext;

		procedure InitOrtho2d(const x0, y0, x1, y1:TSSingle);
		procedure InitMatrixMode(const Mode:TSMatrixMode = S_3D; const dncht : TSFloat = 1);
		procedure BeginScene(const VPrimitiveType:TSPrimtiveType);
		procedure EndScene();
		procedure Perspective(const vAngle,vAspectRatio,vNear,vFar : TSFloat);
		procedure LoadIdentity();
		procedure ClearColor(const r,g,b,a : TSFloat);
		procedure Vertex3f(const x,y,z:TSSingle);
		procedure Scale(const x,y,z : TSSingle);
		procedure Color3f(const r,g,b:TSSingle);
		procedure TexCoord2f(const x,y:TSSingle);
		procedure Vertex2f(const x,y:TSSingle);
		procedure Color4f(const r,g,b,a:TSSingle);
		procedure Normal3f(const x,y,z:TSSingle);
		procedure Translatef(const x,y,z:TSSingle);
		procedure Rotatef(const angle:TSSingle;const x,y,z:TSSingle);
		procedure Enable(VParam:TSCardinal);
		procedure Disable(const VParam:TSCardinal);
		procedure DeleteTextures(const VQuantity:TSCardinal;const VTextures:PSRenderTexture);
		procedure Lightfv(const VLight,VParam:TSCardinal;const VParam2:TSPointer);
		procedure GenTextures(const VQuantity:TSCardinal;const VTextures:PSRenderTexture);
		procedure BindTexture(const VParam:TSCardinal;const VTexture:TSCardinal);
		procedure TexParameteri(const VP1,VP2,VP3:TSCardinal);
		procedure PixelStorei(const VParamName:TSCardinal;const VParam:TSInt32);
		procedure TexEnvi(const VP1,VP2,VP3:TSCardinal);
		procedure TexImage2D(const VTextureType:TSCardinal;const VP1:TSCardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:TSCardinal;VBitMap:TSPointer);
		procedure ReadPixels(const x,y:TSInteger;const Vwidth,Vheight:TSInteger;const format, atype: TSCardinal;const pixels: TSPointer);
		procedure CullFace(const VParam:TSCardinal);
		procedure EnableClientState(const VParam:TSCardinal);
		procedure DisableClientState(const VParam:TSCardinal);
		procedure GenBuffersARB(const VQ:TSInteger;const PT:PCardinal);
		procedure DeleteBuffersARB(const VQuantity:TSLongWord;VPoint:TSPointer);
		procedure BindBufferARB(const VParam:TSCardinal;const VParam2:TSCardinal);
		procedure BufferDataARB(const VParam:TSCardinal;const VSize:TSInt64;VBuffer:TSPointer;const VParam2:TSCardinal;const VIndexPrimetiveType : TSLongWord = 0);
		procedure DrawElements(const VParam:TSCardinal;const VSize:TSInt64;const VParam2:TSCardinal;VBuffer:TSPointer);
		procedure ColorPointer(const VQChannels:TSLongWord;const VType:TSCardinal;const VSize:TSInt64;VBuffer:TSPointer);
		procedure TexCoordPointer(const VQChannels:TSLongWord;const VType:TSCardinal;const VSize:TSInt64;VBuffer:TSPointer);
		procedure NormalPointer(const VType:TSCardinal;const VSize:TSInt64;VBuffer:TSPointer);
		procedure VertexPointer(const VQChannels:TSLongWord;const VType:TSCardinal;const VSize:TSInt64;VBuffer:TSPointer);
		function IsEnabled(const VParam:TSCardinal):Boolean;
		procedure Clear(const VParam:TSCardinal);
		procedure LineWidth(const VLW:TSSingle);
		procedure PointSize(const PS:Single);
		procedure PopMatrix();
		procedure PushMatrix();
		procedure DrawArrays(const VParam:TSCardinal;const VFirst,VCount:TSLongWord);
		procedure Vertex3fv(const Variable : TSPointer);
		procedure Normal3fv(const Variable : TSPointer);
		procedure MultMatrixf(const Matrix : PSMatrix4x4);
		procedure ColorMaterial(const r,g,b,a:TSSingle);
		procedure MatrixMode(const Par:TSLongWord);
		procedure LoadMatrixf(const Matrix : PSMatrix4x4);
		procedure ClientActiveTexture(const VTexture : TSLongWord);
		procedure ActiveTexture(const VTexture : TSLongWord);
		procedure ActiveTextureDiffuse();
		procedure ActiveTextureBump();
		procedure BeginBumpMapping(const Point : Pointer );
		procedure EndBumpMapping();
		procedure PolygonOffset(const VFactor, VUnits : TSFloat);
		{$IFDEF MOBILE}
			procedure GenerateMipmap(const Param : TSCardinal);
		{$ELSE}
			procedure GetVertexUnderPixel(const px,py : LongWord; out x,y,z : Real);
			{$ENDIF}

			(* Shaders *)
		function SupportedShaders() : TSBoolean;
		function CreateShader(const VShaderType : TSCardinal):TSLongWord;
		procedure ShaderSource(const VShader : TSLongWord; VSourse : PChar; VSourseLength : integer);
		procedure CompileShader(const VShader : TSLongWord);
		procedure GetObjectParameteriv(const VObject : TSLongWord; const VParamName : TSCardinal; const VResult : TSRPInteger);
		procedure GetInfoLog(const VHandle : TSLongWord; const VMaxLength : TSInteger; var VLength : TSInteger; VLog : PChar);
		procedure DeleteShader(const VProgram : TSLongWord);

		function CreateShaderProgram() : TSLongWord;
		procedure AttachShader(const VProgram, VShader : TSLongWord);
		procedure LinkShaderProgram(const VProgram : TSLongWord);
		procedure DeleteShaderProgram(const VProgram : TSLongWord);

		function GetUniformLocation(const VProgram : TSLongWord; const VLocationName : PChar): TSLongWord;
		procedure Uniform1i(const VLocationName : TSLongWord; const VData:TSLongWord);
		procedure UseProgram(const VProgram : TSLongWord);
		procedure UniformMatrix4fv(const VLocationName : TSLongWord; const VCount : TSLongWord; const VTranspose : TSBoolean; const VData : PSMatrix4x4);
		procedure Uniform3f(const VLocationName : TSLongWord; const VX,VY,VZ : TSFloat);
		procedure Uniform1f(const VLocationName : TSLongWord; const V : TSFloat);
		procedure Uniform1iv (const VLocationName: TSLongWord; const VCount: TSLongWord; const VValue: Pointer);
		procedure Uniform1uiv (const VLocationName: TSLongWord; const VCount: TSLongWord; const VValue: Pointer);
		procedure Uniform3fv (const VLocationName: TSLongWord; const VCount: TSLongWord; const VValue: Pointer);

		function SupportedDepthTextures():TSBoolean;
		procedure BindFrameBuffer(const VType : TSCardinal; const VHandle : TSLongWord);
		procedure GenFrameBuffers(const VCount : TSLongWord;const VBuffers : PCardinal);
		procedure DrawBuffer(const VType : TSCardinal);
		procedure ReadBuffer(const VType : TSCardinal);
		procedure GenRenderBuffers(const VCount : TSLongWord;const VBuffers : PCardinal);
		procedure BindRenderBuffer(const VType : TSCardinal; const VHandle : TSLongWord);
		procedure FrameBufferTexture2D(const VTarget: TSCardinal; const VAttachment: TSCardinal; const VRenderbuffertarget: TSCardinal; const VRenderbuffer, VLevel: TSLongWord);
		procedure FrameBufferRenderBuffer(const VTarget: TSCardinal; const VAttachment: TSCardinal; const VRenderbuffertarget: TSCardinal; const VRenderbuffer: TSLongWord);
		procedure RenderBufferStorage(const VTarget, VAttachment: TSCardinal; const VWidth, VHeight: TSLongWord);
		procedure GetFloatv(const VType : TSCardinal; const VPointer : Pointer);

		property Width : TSAreaInt read GetWidth write SetWidth;
		property Height : TSAreaInt read GetHeight write SetHeight;
		property Context : ISBaseContext read GetContext write SetContext;
		property RenderType : TSRenderType read GetRenderType;

		{$DEFINE INC_PLACE_RENDER_INTERFACE}
		{$INCLUDE SmoothCommonStructs.inc}
		{$UNDEF INC_PLACE_RENDER_INTERFACE}
		end;

	ISRenderObject = interface(ISInterface)
		['{535e900f-03d6-47d1-b2e1-9eadadf877f3}']
		function GetRender() : ISRender;
		function RenderAssigned() : TSBoolean;
		procedure DeleteRenderResources();
		procedure LoadRenderResources();
		
		property Render : ISRender read GetRender;
		end;

{$IFNDEF MOBILE}
function SGetVertexUnderPixel(const VRender : ISRender; const Pixel : TSPoint2i32):TSVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$ENDIF}

implementation

uses
	 SmoothCommon
	;

{$IFNDEF MOBILE}
function SGetVertexUnderPixel(const VRender : ISRender; const Pixel : TSPoint2i32):TSVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	x,y,z : Real;
begin
VRender.GetVertexUnderPixel(Pixel.x,Pixel.y,x,y,z);
Result.Import(x,y,z);
end;
{$ENDIF}

end.
