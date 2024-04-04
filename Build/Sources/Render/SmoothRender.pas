{$INCLUDE Smooth.inc}

//{$DEFINE RENDER_DEBUG}

unit SmoothRender;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothRenderBase
	,SmoothRenderInterface
	,SmoothMatrix
	,SmoothCommonStructs
	,SmoothBaseContextInterface
	;

type
	TSRender = class(TSNamed, ISRender)
			public
		constructor Create();override;
		destructor Destroy();override;
		function GetRenderType():TSRenderType; virtual;
		class function Supported() : TSBoolean; virtual;
		class function RenderName() : TSString; virtual;
			protected
		function GetWidth() : TSAreaInt;virtual;
		function GetHeight() : TSAreaInt;virtual;
			private
		procedure SetContext(const VContext : ISBaseContext);
		function  GetContext() : ISBaseContext;
		procedure SetWidth(const VWidth : TSAreaInt);virtual;abstract;
		procedure SetHeight(const VHeight : TSAreaInt);virtual;abstract;
		function  GetOption(const VOption : TSString) : TSPointer;virtual;abstract;
		procedure SetOption(const VOption : TSString; const VValue : TSPointer);virtual;abstract;
		procedure Paint();virtual;abstract;
			private
		FType   : TSRenderType;
		FContext : ISBaseContext;
			protected
		procedure SetRenderType(const VType : TSRenderType);
			public
		function SetPixelFormat():TSBoolean;virtual;abstract;
		function MakeCurrent():TSBoolean;virtual;
		procedure ReleaseCurrent();virtual;abstract;
		function CreateContext():TSBoolean;virtual;abstract;
		procedure Viewport(const a,b,c,d : TSAreaInt);virtual;abstract;
		procedure Init();virtual;abstract;
		procedure Kill();virtual;abstract;
		function SupportedGraphicalBuffers() : TSBoolean; virtual;
		function SupportedMemoryBuffers() : TSBoolean; virtual;
		procedure SwapBuffers();virtual;abstract;
		procedure LockResources();virtual;
		procedure UnLockResources();virtual;
			public
		property Width : TSAreaInt read GetWidth write SetWidth;
		property Height : TSAreaInt read GetHeight write SetHeight;
		property RenderType : TSRenderType read FType;
		property Context : ISBaseContext read GetContext write SetContext;
			public
		procedure InitOrtho2d(const x0,y0,x1,y1:TSSingle);virtual;abstract;
		procedure InitMatrixMode(const Mode:TSMatrixMode = S_3D; const dncht : TSFloat = 1);virtual;abstract;
		procedure BeginScene(const VPrimitiveType:TSPrimtiveType);virtual;abstract;
		procedure EndScene();virtual;abstract;
		procedure Perspective(const vAngle,vAspectRatio,vNear,vFar : TSFloat);virtual;abstract;
		procedure LoadIdentity();virtual;abstract;
		procedure ClearColor(const r,g,b,a : TSFloat);virtual;abstract;
		procedure Vertex3f(const x,y,z:TSSingle);virtual;abstract;
		procedure Scale(const x,y,z : TSSingle);virtual;abstract;
		procedure Color3f(const r,g,b:TSSingle);virtual;abstract;
		procedure TexCoord2f(const x,y:TSSingle);virtual;abstract;
		procedure Vertex2f(const x,y:TSSingle);virtual;abstract;
		procedure Color4f(const r,g,b,a:TSSingle);virtual;abstract;
		procedure Normal3f(const x,y,z:TSSingle);virtual;abstract;
		procedure Translatef(const x,y,z:TSSingle);virtual;abstract;
		procedure Rotatef(const angle:TSSingle;const x,y,z:TSSingle);virtual;abstract;
		procedure Enable(VParam:TSCardinal);virtual;
		procedure Disable(const VParam:TSCardinal);virtual;abstract;
		procedure DeleteTextures(const VQuantity:TSCardinal;const VTextures:PSRenderTexture);virtual;abstract;
		procedure Lightfv(const VLight,VParam:TSCardinal;const VParam2:TSPointer);virtual;abstract;
		procedure GenTextures(const VQuantity:TSCardinal;const VTextures:PSRenderTexture);virtual;abstract;
		procedure BindTexture(const VParam:TSCardinal;const VTexture:TSCardinal);virtual;abstract;
		procedure TexParameteri(const VP1,VP2,VP3:TSCardinal);virtual;abstract;
		procedure PixelStorei(const VParamName:TSCardinal;const VParam:TSInt32);virtual;abstract;
		procedure TexEnvi(const VP1,VP2,VP3:TSCardinal);virtual;abstract;
		procedure TexImage2D(const VTextureType:TSCardinal;const VP1:TSCardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:TSCardinal;VBitMap:TSPointer);virtual;abstract;
		procedure ReadPixels(const x,y:TSInteger;const Vwidth,Vheight:TSInteger;const format, atype: TSCardinal;const pixels: TSPointer);virtual;abstract;
		procedure CullFace(const VParam:TSCardinal);virtual;abstract;
		procedure EnableClientState(const VParam:TSCardinal);virtual;abstract;
		procedure DisableClientState(const VParam:TSCardinal);virtual;abstract;
		procedure GenBuffersARB(const VQ:TSInteger;const PT:PCardinal);virtual;abstract;
		procedure DeleteBuffersARB(const VQuantity:TSLongWord;VPoint:TSPointer);virtual;abstract;
		procedure BindBufferARB(const VParam:TSCardinal;const VParam2:TSCardinal);virtual;abstract;
		procedure BufferDataARB(const VParam:TSCardinal;const VSize:TSInt64;VBuffer:TSPointer;const VParam2:TSCardinal;const VIndexPrimetiveType : TSLongWord = 0);virtual;abstract;
		procedure DrawElements(const VParam:TSCardinal;const VSize:TSInt64;const VParam2:TSCardinal;VBuffer:TSPointer);virtual;abstract;
		procedure ColorPointer(const VQChannels:TSLongWord;const VType:TSCardinal;const VSize:TSInt64;VBuffer:TSPointer);virtual;abstract;
		procedure TexCoordPointer(const VQChannels:TSLongWord;const VType:TSCardinal;const VSize:TSInt64;VBuffer:TSPointer);virtual;abstract;
		procedure NormalPointer(const VType:TSCardinal;const VSize:TSInt64;VBuffer:TSPointer);virtual;abstract;
		procedure VertexPointer(const VQChannels:TSLongWord;const VType:TSCardinal;const VSize:TSInt64;VBuffer:TSPointer);virtual;abstract;
		function IsEnabled(const VParam:TSCardinal):Boolean;virtual;abstract;
		procedure Clear(const VParam:TSCardinal);virtual;abstract;
		procedure LineWidth(const VLW:TSSingle);virtual;abstract;
		procedure PointSize(const PS:Single);virtual;abstract;
		procedure PopMatrix();virtual;abstract;
		procedure PushMatrix();virtual;abstract;
		procedure DrawArrays(const VParam:TSCardinal;const VFirst,VCount:TSLongWord);virtual;abstract;
		procedure Vertex3fv(const Variable : TSPointer);virtual;abstract;
		procedure Normal3fv(const Variable : TSPointer);virtual;abstract;
		procedure MultMatrixf(const Matrix : PSMatrix4x4);virtual;abstract;
		procedure ColorMaterial(const r,g,b,a:TSSingle);virtual;abstract;
		procedure MatrixMode(const Par:TSLongWord);virtual;abstract;
		procedure LoadMatrixf(const Matrix : PSMatrix4x4);virtual;abstract;
		procedure ClientActiveTexture(const VTexture : TSLongWord);virtual;abstract;
		procedure ActiveTexture(const VTexture : TSLongWord);virtual;abstract;
		procedure ActiveTextureDiffuse();virtual;abstract;
		procedure ActiveTextureBump();virtual;abstract;
		procedure BeginBumpMapping(const Point : Pointer );virtual;abstract;
		procedure EndBumpMapping();virtual;abstract;
		procedure PolygonOffset(const VFactor, VUnits : TSFloat);virtual;abstract;
		{$IFDEF MOBILE}
			procedure GenerateMipmap(const Param : TSCardinal);virtual;
		{$ELSE}
			procedure GetVertexUnderPixel(const px,py : LongWord; out x,y,z : Real);virtual;abstract;
			{$ENDIF}

			(* Shaders *)
		function SupportedShaders() : TSBoolean;virtual;abstract;
		function CreateShader(const VShaderType : TSCardinal):TSLongWord;virtual;abstract;
		procedure ShaderSource(const VShader : TSLongWord; VSource : PChar; VSourceLength : integer);virtual;abstract;
		procedure CompileShader(const VShader : TSLongWord);virtual;abstract;
		procedure GetObjectParameteriv(const VObject : TSLongWord; const VParamName : TSCardinal; const VResult : TSRPInteger);virtual;abstract;
		procedure GetInfoLog(const VHandle : TSLongWord; const VMaxLength : TSInteger; var VLength : TSInteger; VLog : PChar);virtual;abstract;
		procedure DeleteShader(const VProgram : TSLongWord);virtual;abstract;

		function CreateShaderProgram() : TSLongWord;virtual;abstract;
		procedure AttachShader(const VProgram, VShader : TSLongWord);virtual;abstract;
		procedure LinkShaderProgram(const VProgram : TSLongWord);virtual;abstract;
		procedure DeleteShaderProgram(const VProgram : TSLongWord);virtual;abstract;

		function GetUniformLocation(const VProgram : TSLongWord; const VLocationName : PChar): TSLongWord;virtual;abstract;
		procedure Uniform1i(const VLocationName : TSLongWord; const VData:TSLongWord);virtual;abstract;
		procedure UseProgram(const VProgram : TSLongWord);virtual;abstract;
		procedure UniformMatrix4fv(const VLocationName : TSLongWord; const VCount : TSLongWord; const VTranspose : TSBoolean; const VData : PSMatrix4x4);virtual;abstract;
		procedure Uniform3f(const VLocationName : TSLongWord; const VX,VY,VZ : TSFloat);virtual;abstract;
		procedure Uniform1f(const VLocationName : TSLongWord; const V : TSFloat);virtual;abstract;
		procedure Uniform1iv (const VLocationName: TSLongWord; const VCount: TSLongWord; const VValue: Pointer);virtual;abstract;
		procedure Uniform1uiv (const VLocationName: TSLongWord; const VCount: TSLongWord; const VValue: Pointer);virtual;abstract;
		procedure Uniform3fv (const VLocationName: TSLongWord; const VCount: TSLongWord; const VValue: Pointer);virtual;abstract;

		function SupportedDepthTextures():TSBoolean;virtual;
		procedure BindFrameBuffer(const VType : TSCardinal; const VHandle : TSLongWord);virtual;abstract;
		procedure GenFrameBuffers(const VCount : TSLongWord;const VBuffers : PCardinal); virtual;abstract;
		procedure DrawBuffer(const VType : TSCardinal);virtual;abstract;
		procedure ReadBuffer(const VType : TSCardinal);virtual;abstract;
		procedure GenRenderBuffers(const VCount : TSLongWord;const VBuffers : PCardinal); virtual;abstract;
		procedure BindRenderBuffer(const VType : TSCardinal; const VHandle : TSLongWord);virtual;abstract;
		procedure FrameBufferTexture2D(const VTarget: TSCardinal; const VAttachment: TSCardinal; const VRenderbuffertarget: TSCardinal; const VRenderbuffer, VLevel: TSLongWord);virtual;abstract;
		procedure FrameBufferRenderBuffer(const VTarget: TSCardinal; const VAttachment: TSCardinal; const VRenderbuffertarget: TSCardinal; const VRenderbuffer: TSLongWord);virtual;abstract;
		procedure RenderBufferStorage(const VTarget, VAttachment: TSCardinal; const VWidth, VHeight: TSLongWord);virtual;abstract;
		procedure GetFloatv(const VType : TSCardinal; const VPointer : Pointer);virtual;abstract;

		{$DEFINE INC_PLACE_RENDER_CLASS}
		{$INCLUDE SmoothCommonStructs.inc}
		{$UNDEF INC_PLACE_RENDER_CLASS}
		end;

	TSRenderClass  = class of TSRender;

function TSCompatibleRender():TSRenderClass;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$IFDEF MSWINDOWS}
procedure SLogVideoInfo();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$ENDIF}

implementation

uses
	 SmoothRenderOpenGL
	,SmoothLog
	,SmoothCasesOfPrint
	{$IFDEF MSWINDOWS}
		,SmoothRenderDirectX12
		,SmoothRenderDirectX11
		//,SmoothRenderDirectX10
		,SmoothRenderDirectX9
		,SmoothRenderDirectX8
		,SmoothNvidiaInformationUtils
		,SmoothWinAPIUtils
		{$ENDIF}
	;

{$IFDEF MSWINDOWS}
var
	VideoInfoLoged : TSBoolean = False;

procedure SLogVideoInfo();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SViewVideoDevices([SCaseLog]);
SNVidiaViewInfo([SCaseLog]);
end;
{$ENDIF}

function TSCompatibleRender():TSRenderClass;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := nil;
if TSRenderOpenGL.Supported then
	Result := TSRenderOpenGL;
{$IFDEF MSWINDOWS}
if (Result = nil) and (TSRenderDirectX12.Supported) then
	Result := TSRenderDirectX12;
if (Result = nil) and (TSRenderDirectX9.Supported) then
	Result := TSRenderDirectX9;
if (Result = nil) and (TSRenderDirectX8.Supported) then
	Result := TSRenderDirectX8;
{$ENDIF}
end;

{$DEFINE RENDER_CLASS := TSRender}
{$DEFINE INC_PLACE_RENDER_IMPLEMENTATION}
{$INCLUDE SmoothCommonStructs.inc}
{$UNDEF INC_PLACE_RENDER_IMPLEMENTATION}
{$UNDEF RENDER_CLASS}

class function TSRender.RenderName() : TSString;
begin
Result := 'Unknown';
end;

class function TSRender.Supported() : TSBoolean;
begin
Result := False;
end;

procedure TSRender.SetRenderType(const VType : TSRenderType);
begin
FType := VType;
end;

function TSRender.GetRenderType():TSRenderType;
begin
Result := FType;
end;

procedure TSRender.SetContext(const VContext : ISBaseContext);
begin
FContext := VContext;
end;

function TSRender.GetContext() : ISBaseContext;
begin
Result := FContext;
end;

function TSRender.SupportedDepthTextures():TSBoolean;
begin
Result := False;
end;

{$IFDEF MOBILE}
procedure TSRender.GenerateMipmap(const Param : TSCardinal);
begin
end;
{$ENDIF}

procedure TSRender.UnLockResources();
begin
end;

procedure TSRender.LockResources();
begin
end;

function TSRender.MakeCurrent():Boolean;
begin
Result := False;
SLog.Source('TSRender__MakeCurrent() : Error : Call inherited method!!');
end;

procedure TSRender.Enable(VParam:Cardinal);
begin
SLog.Source('TSRender__Enable(Cardinal) : Error : Call inherited method!!');
end;

function TSRender.SupportedMemoryBuffers() : TSBoolean;
begin
Result:=False;
end;

function TSRender.SupportedGraphicalBuffers() : TSBoolean;
begin
Result:=False;
end;

constructor TSRender.Create();
begin
inherited Create();
FContext := nil;
FType    := SRenderNull;
{$IFDEF MSWINDOWS}
if not VideoInfoLoged then
	begin
	SLogVideoInfo();
	VideoInfoLoged := True;
	end;
{$ENDIF}
end;

destructor TSRender.Destroy();
begin
{$IFDEF RENDER_DEBUG}
	SLog.Source(['TSRender__Destroy()']);
	WriteLn('TSRender__Destroy(): Before "inherited"');
	{$ENDIF}
inherited Destroy();
{$IFDEF RENDER_DEBUG}
	WriteLn('TSRender__Destroy(): After "inherited"');
	{$ENDIF}
end;

function TSRender.GetWidth() : TSAreaInt;
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

function TSRender.GetHeight() : TSAreaInt;
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
