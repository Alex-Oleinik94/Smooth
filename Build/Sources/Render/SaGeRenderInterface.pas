{$INCLUDE SaGe.inc}

unit SaGeRenderInterface;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
	,SaGeRenderBase
	,SaGeMatrix
	,SaGeCommonStructs
	,SaGeBaseContextInterface
	;

type
	ISGRender = interface;
type
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
		function SupporedGraphicalBuffers() : TSGBoolean;
		function SupporedMemoryBuffers() : TSGBoolean;
		procedure SwapBuffers();
		procedure LockResources();
		procedure UnLockResources();
		procedure SetContext(const VContext : ISGBaseContext);
		function GetContext() : ISGBaseContext;

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
		procedure MultMatrixf(const Matrix : PSGMatrix4x4);
		procedure ColorMaterial(const r,g,b,a:TSGSingle);
		procedure MatrixMode(const Par:TSGLongWord);
		procedure LoadMatrixf(const Matrix : PSGMatrix4x4);
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
		procedure UniformMatrix4fv(const VLocationName : TSGLongWord; const VCount : TSGLongWord; const VTranspose : TSGBoolean; const VData : PSGMatrix4x4);
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
		property Context : ISGBaseContext read GetContext write SetContext;
		property RenderType : TSGRenderType read GetRenderType;

		{$DEFINE INC_PLACE_RENDER_INTERFACE}
		{$INCLUDE SaGeCommonStructs.inc}
		{$UNDEF INC_PLACE_RENDER_INTERFACE}
		end;

	ISGRenderObject = interface(ISGInterface)
		['{535e900f-03d6-47d1-b2e1-9eadadf877f3}']
		function GetRender() : ISGRender;
		function RenderAssigned() : TSGBoolean;
		function Suppored() : TSGBoolean;
		procedure DeleteRenderResources();
		procedure LoadRenderResources();
		
		property Render : ISGRender read GetRender;
		end;

{$IFNDEF MOBILE}
function SGGetVertexUnderPixel(const VRender : ISGRender; const Pixel : TSGPoint2i32):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$ENDIF}

implementation

uses
	 SaGeCommon
	;

{$IFNDEF MOBILE}
function SGGetVertexUnderPixel(const VRender : ISGRender; const Pixel : TSGPoint2i32):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	x,y,z : Real;
begin
VRender.GetVertexUnderPixel(Pixel.x,Pixel.y,x,y,z);
Result.Import(x,y,z);
end;
{$ENDIF}

end.
