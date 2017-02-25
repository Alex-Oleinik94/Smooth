{$INCLUDE SaGe.inc}

//{$DEFINE RENDER_DEBUG}

unit SaGeRender;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeRenderBase
	,SaGeRenderInterface
	,SaGeCommon
	{$IFDEF MSWINDOWS}
		,multimon
		{$ENDIF}
	;

type
	TSGRender = class(TSGNamed, ISGRender)
			public
		constructor Create();override;
		destructor Destroy();override;
		function GetRenderType():TSGRenderType;virtual;
		class function Suppored() : TSGBoolean;virtual;
			protected
		function GetWidth() : TSGAreaInt;virtual;
		function GetHeight() : TSGAreaInt;virtual;
			private
		procedure SetContext(const VContext : ISGNearlyContext);
		function  GetContext() : ISGNearlyContext;
		procedure SetWidth(const VWidth : TSGAreaInt);virtual;abstract;
		procedure SetHeight(const VHeight : TSGAreaInt);virtual;abstract;
		function  GetOption(const VOption : TSGString) : TSGPointer;virtual;abstract;
		procedure SetOption(const VOption : TSGString; const VValue : TSGPointer);virtual;abstract;
		procedure Paint();virtual;abstract;
			private
		FType   : TSGRenderType;
		FContext : ISGNearlyContext;
			protected
		procedure SetRenderType(const VType : TSGRenderType);
			public
		function SetPixelFormat():TSGBoolean;virtual;abstract;
		function MakeCurrent():TSGBoolean;virtual;
		procedure ReleaseCurrent();virtual;abstract;
		function CreateContext():TSGBoolean;virtual;abstract;
		procedure Viewport(const a,b,c,d : TSGAreaInt);virtual;abstract;
		procedure Init();virtual;abstract;
		procedure Kill();virtual;abstract;
		function SupporedVBOBuffers():TSGBoolean;virtual;
		procedure SwapBuffers();virtual;abstract;
		procedure LockResources();virtual;
		procedure UnLockResources();virtual;
			public
		property Width : TSGAreaInt read GetWidth write SetWidth;
		property Height : TSGAreaInt read GetHeight write SetHeight;
		property RenderType : TSGRenderType read FType;
		property Context : ISGNearlyContext read GetContext write SetContext;
			public
		procedure InitOrtho2d(const x0,y0,x1,y1:TSGSingle);virtual;abstract;
		procedure InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht : TSGFloat = 1);virtual;abstract;
		procedure BeginScene(const VPrimitiveType:TSGPrimtiveType);virtual;abstract;
		procedure EndScene();virtual;abstract;
		procedure Perspective(const vAngle,vAspectRatio,vNear,vFar : TSGFloat);virtual;abstract;
		procedure LoadIdentity();virtual;abstract;
		procedure ClearColor(const r,g,b,a : TSGFloat);virtual;abstract;
		procedure Vertex3f(const x,y,z:TSGSingle);virtual;abstract;
		procedure Scale(const x,y,z : TSGSingle);virtual;abstract;
		procedure Color3f(const r,g,b:TSGSingle);virtual;abstract;
		procedure TexCoord2f(const x,y:TSGSingle);virtual;abstract;
		procedure Vertex2f(const x,y:TSGSingle);virtual;abstract;
		procedure Color4f(const r,g,b,a:TSGSingle);virtual;abstract;
		procedure Normal3f(const x,y,z:TSGSingle);virtual;abstract;
		procedure Translatef(const x,y,z:TSGSingle);virtual;abstract;
		procedure Rotatef(const angle:TSGSingle;const x,y,z:TSGSingle);virtual;abstract;
		procedure Enable(VParam:TSGCardinal);virtual;
		procedure Disable(const VParam:TSGCardinal);virtual;abstract;
		procedure DeleteTextures(const VQuantity:TSGCardinal;const VTextures:PSGRenderTexture);virtual;abstract;
		procedure Lightfv(const VLight,VParam:TSGCardinal;const VParam2:TSGPointer);virtual;abstract;
		procedure GenTextures(const VQuantity:TSGCardinal;const VTextures:PSGRenderTexture);virtual;abstract;
		procedure BindTexture(const VParam:TSGCardinal;const VTexture:TSGCardinal);virtual;abstract;
		procedure TexParameteri(const VP1,VP2,VP3:TSGCardinal);virtual;abstract;
		procedure PixelStorei(const VParamName:TSGCardinal;const VParam:TSGInt32);virtual;abstract;
		procedure TexEnvi(const VP1,VP2,VP3:TSGCardinal);virtual;abstract;
		procedure TexImage2D(const VTextureType:TSGCardinal;const VP1:TSGCardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:TSGCardinal;VBitMap:TSGPointer);virtual;abstract;
		procedure ReadPixels(const x,y:TSGInteger;const Vwidth,Vheight:TSGInteger;const format, atype: TSGCardinal;const pixels: TSGPointer);virtual;abstract;
		procedure CullFace(const VParam:TSGCardinal);virtual;abstract;
		procedure EnableClientState(const VParam:TSGCardinal);virtual;abstract;
		procedure DisableClientState(const VParam:TSGCardinal);virtual;abstract;
		procedure GenBuffersARB(const VQ:TSGInteger;const PT:PCardinal);virtual;abstract;
		procedure DeleteBuffersARB(const VQuantity:TSGLongWord;VPoint:TSGPointer);virtual;abstract;
		procedure BindBufferARB(const VParam:TSGCardinal;const VParam2:TSGCardinal);virtual;abstract;
		procedure BufferDataARB(const VParam:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer;const VParam2:TSGCardinal;const VIndexPrimetiveType : TSGLongWord = 0);virtual;abstract;
		procedure DrawElements(const VParam:TSGCardinal;const VSize:TSGInt64;const VParam2:TSGCardinal;VBuffer:TSGPointer);virtual;abstract;
		procedure ColorPointer(const VQChannels:TSGLongWord;const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);virtual;abstract;
		procedure TexCoordPointer(const VQChannels:TSGLongWord;const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);virtual;abstract;
		procedure NormalPointer(const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);virtual;abstract;
		procedure VertexPointer(const VQChannels:TSGLongWord;const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);virtual;abstract;
		function IsEnabled(const VParam:TSGCardinal):Boolean;virtual;abstract;
		procedure Clear(const VParam:TSGCardinal);virtual;abstract;
		procedure LineWidth(const VLW:TSGSingle);virtual;abstract;
		procedure PointSize(const PS:Single);virtual;abstract;
		procedure PopMatrix();virtual;abstract;
		procedure PushMatrix();virtual;abstract;
		procedure DrawArrays(const VParam:TSGCardinal;const VFirst,VCount:TSGLongWord);virtual;abstract;
		procedure Vertex3fv(const Variable : TSGPointer);virtual;abstract;
		procedure Normal3fv(const Variable : TSGPointer);virtual;abstract;
		procedure MultMatrixf(const Variable : TSGPointer);virtual;abstract;
		procedure ColorMaterial(const r,g,b,a:TSGSingle);virtual;abstract;
		procedure MatrixMode(const Par:TSGLongWord);virtual;abstract;
		procedure LoadMatrixf(const Variable : TSGPointer);virtual;abstract;
		procedure ClientActiveTexture(const VTexture : TSGLongWord);virtual;abstract;
		procedure ActiveTexture(const VTexture : TSGLongWord);virtual;abstract;
		procedure ActiveTextureDiffuse();virtual;abstract;
		procedure ActiveTextureBump();virtual;abstract;
		procedure BeginBumpMapping(const Point : Pointer );virtual;abstract;
		procedure EndBumpMapping();virtual;abstract;
		procedure PolygonOffset(const VFactor, VUnits : TSGFloat);virtual;abstract;
		{$IFDEF MOBILE}
			procedure GenerateMipmap(const Param : TSGCardinal);virtual;
		{$ELSE}
			procedure GetVertexUnderPixel(const px,py : LongWord; out x,y,z : Real);virtual;abstract;
			{$ENDIF}

			(* Shaders *)
		function SupporedShaders() : TSGBoolean;virtual;abstract;
		function CreateShader(const VShaderType : TSGCardinal):TSGLongWord;virtual;abstract;
		procedure ShaderSource(const VShader : TSGLongWord; VSource : PChar; VSourceLength : integer);virtual;abstract;
		procedure CompileShader(const VShader : TSGLongWord);virtual;abstract;
		procedure GetObjectParameteriv(const VObject : TSGLongWord; const VParamName : TSGCardinal; const VResult : TSGRPInteger);virtual;abstract;
		procedure GetInfoLog(const VHandle : TSGLongWord; const VMaxLength : TSGInteger; var VLength : TSGInteger; VLog : PChar);virtual;abstract;
		procedure DeleteShader(const VProgram : TSGLongWord);virtual;abstract;

		function CreateShaderProgram() : TSGLongWord;virtual;abstract;
		procedure AttachShader(const VProgram, VShader : TSGLongWord);virtual;abstract;
		procedure LinkShaderProgram(const VProgram : TSGLongWord);virtual;abstract;
		procedure DeleteShaderProgram(const VProgram : TSGLongWord);virtual;abstract;

		function GetUniformLocation(const VProgram : TSGLongWord; const VLocationName : PChar): TSGLongWord;virtual;abstract;
		procedure Uniform1i(const VLocationName : TSGLongWord; const VData:TSGLongWord);virtual;abstract;
		procedure UseProgram(const VProgram : TSGLongWord);virtual;abstract;
		procedure UniformMatrix4fv(const VLocationName : TSGLongWord; const VCount : TSGLongWord; const VTranspose : TSGBoolean; const VData : TSGPointer);virtual;abstract;
		procedure Uniform3f(const VLocationName : TSGLongWord; const VX,VY,VZ : TSGFloat);virtual;abstract;
		procedure Uniform1f(const VLocationName : TSGLongWord; const V : TSGFloat);virtual;abstract;
		procedure Uniform1iv (const VLocationName: TSGLongWord; const VCount: TSGLongWord; const VValue: Pointer);virtual;abstract;
		procedure Uniform1uiv (const VLocationName: TSGLongWord; const VCount: TSGLongWord; const VValue: Pointer);virtual;abstract;
		procedure Uniform3fv (const VLocationName: TSGLongWord; const VCount: TSGLongWord; const VValue: Pointer);virtual;abstract;

		function SupporedDepthTextures():TSGBoolean;virtual;
		procedure BindFrameBuffer(const VType : TSGCardinal; const VHandle : TSGLongWord);virtual;abstract;
		procedure GenFrameBuffers(const VCount : TSGLongWord;const VBuffers : PCardinal); virtual;abstract;
		procedure DrawBuffer(const VType : TSGCardinal);virtual;abstract;
		procedure ReadBuffer(const VType : TSGCardinal);virtual;abstract;
		procedure GenRenderBuffers(const VCount : TSGLongWord;const VBuffers : PCardinal); virtual;abstract;
		procedure BindRenderBuffer(const VType : TSGCardinal; const VHandle : TSGLongWord);virtual;abstract;
		procedure FrameBufferTexture2D(const VTarget: TSGCardinal; const VAttachment: TSGCardinal; const VRenderbuffertarget: TSGCardinal; const VRenderbuffer, VLevel: TSGLongWord);virtual;abstract;
		procedure FrameBufferRenderBuffer(const VTarget: TSGCardinal; const VAttachment: TSGCardinal; const VRenderbuffertarget: TSGCardinal; const VRenderbuffer: TSGLongWord);virtual;abstract;
		procedure RenderBufferStorage(const VTarget, VAttachment: TSGCardinal; const VWidth, VHeight: TSGLongWord);virtual;abstract;
		procedure GetFloatv(const VType : TSGCardinal; const VPointer : Pointer);virtual;abstract;

		{$DEFINE INC_PLACE_RENDER_CLASS}
		{$INCLUDE SaGeCommonStructs.inc}
		{$UNDEF INC_PLACE_RENDER_CLASS}
		end;

	TSGRenderClass  = class of TSGRender;

procedure SGPrintVideoDevices();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function TSGCompatibleRender():TSGRenderClass;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeRenderOpenGL
	,SaGeLog
	{$IFDEF MSWINDOWS}
		,SaGeRenderDirectX12
		,SaGeRenderDirectX9
		,SaGeRenderDirectX8
		{$ENDIF}
	;

function TSGCompatibleRender():TSGRenderClass;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := nil;
if TSGRenderOpenGL.Suppored then
	Result := TSGRenderOpenGL;
{$IFDEF MSWINDOWS}
if (Result = nil) and (TSGRenderDirectX12.Suppored) then
	Result := TSGRenderDirectX12;
if (Result = nil) and (TSGRenderDirectX9.Suppored) then
	Result := TSGRenderDirectX9;
if (Result = nil) and (TSGRenderDirectX8.Suppored) then
	Result := TSGRenderDirectX8;
{$ENDIF}
end;

{$DEFINE RENDER_CLASS := TSGRender}
{$DEFINE INC_PLACE_RENDER_IMPLEMENTATION}
{$INCLUDE SaGeCommonStructs.inc}
{$UNDEF INC_PLACE_RENDER_IMPLEMENTATION}
{$UNDEF RENDER_CLASS}

procedure SGPrintVideoDevices();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$IFDEF MSWINDOWS}
var
	lpDisplayDevice : TDisplayDevice;
	dwFlags : TSGLongWord;
	cc : TSGLongWord;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
lpDisplayDevice.cb := sizeof(lpDisplayDevice);
dwFlags := 0;
cc := 0;
while (EnumDisplayDevices(nil, cc, @lpDisplayDevice, dwFlags)) do
	begin
	WriteLn(cc,' - ',lpDisplayDevice.DeviceString,' - ',lpDisplayDevice.DeviceName);
	cc := cc + 1;
	end;
{$ENDIF}
end;

class function TSGRender.Suppored() : TSGBoolean;
begin
Result := False;
end;

procedure TSGRender.SetRenderType(const VType : TSGRenderType);
begin
FType := VType;
end;

function TSGRender.GetRenderType():TSGRenderType;
begin
Result := FType;
end;

procedure TSGRender.SetContext(const VContext : ISGNearlyContext);
begin
FContext := VContext;
end;

function TSGRender.GetContext() : ISGNearlyContext;
begin
Result := FContext;
end;

function TSGRender.SupporedDepthTextures():TSGBoolean;
begin
Result := False;
end;

{$IFDEF MOBILE}
procedure TSGRender.GenerateMipmap(const Param : TSGCardinal);
begin
end;
{$ENDIF}

procedure TSGRender.UnLockResources();
begin
end;

procedure TSGRender.LockResources();
begin
end;

function TSGRender.MakeCurrent():Boolean;
begin
Result := False;
SGLog.Source('TSGRender__MakeCurrent() : Error : Call inherited method!!');
end;

procedure TSGRender.Enable(VParam:Cardinal);
begin
SGLog.Source('TSGRender__Enable(Cardinal) : Error : Call inherited methad!!');
end;

function TSGRender.SupporedVBOBuffers():Boolean;
begin
Result:=False;
end;

constructor TSGRender.Create();
begin
inherited Create();
FContext := nil;
FType    := SGRenderNone;
end;

destructor TSGRender.Destroy();
begin
{$IFDEF RENDER_DEBUG}
	SGLog.Source(['TSGRender__Destroy()']);
	WriteLn('TSGRender__Destroy(): Before "inherited"');
	{$ENDIF}
inherited Destroy();
{$IFDEF RENDER_DEBUG}
	WriteLn('TSGRender__Destroy(): After "inherited"');
	{$ENDIF}
end;

function TSGRender.GetWidth() : TSGAreaInt;
begin
if FContext = nil then
	Result := 0
else
	begin
	Result := Context.ClientWidth;
	if Result = 0 then
		Result := Context.Width;
	end;
end;

function TSGRender.GetHeight() : TSGAreaInt;
begin
if FContext = nil then
	Result := 0
else
	begin
	Result := Context.ClientHeight;
	if Result = 0 then
		Result := Context.Height;
	end;
end;

end.
