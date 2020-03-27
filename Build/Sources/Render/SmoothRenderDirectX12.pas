{$INCLUDE Smooth.inc}

//{$DEFINE RENDER_DX12_DEBUG}

unit SmoothRenderDirectX12;

interface

uses
	// Smooth units
	 SmoothBase
	,SmoothRender
	,SmoothRenderBase
	,SmoothRenderInterface
	,SmoothBaseClasses
	,SmoothMatrix
	,SmoothBaseContextInterface
	
	// OS units
	,crt
	,windows
	,DynLibs
	
	// DirectX unit
	,DX12.D3D12
	,DX12.D2D1
	,DX12.DXGI
	,DX12.D3DCommon
	,DX12.DWrite
	;

type
	TSRenderDirectX12 = class(TSRender)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function RenderName() : TSString; override;
			protected
		
			public
		class function Supported() : TSBoolean;override;
		function SetPixelFormat():Boolean;override;overload;
		function CreateContext():Boolean;override;
		function MakeCurrent():Boolean;override;
		procedure ReleaseCurrent();override;
		procedure Init();override;
		procedure Kill();override;
		procedure Viewport(const a,b,c,d:TSAreaInt);override;
		procedure SwapBuffers();override;
		function SupportedGraphicalBuffers() : TSBoolean; override;
		function SupportedMemoryBuffers() : TSBoolean; override;
		class function ClassName() : TSString; override;
			public
		procedure InitOrtho2d(const x0,y0,x1,y1:TSSingle);override;
		procedure InitMatrixMode(const Mode:TSMatrixMode = S_3D; const dncht : TSFloat = 1);override;
		procedure LoadIdentity();override;
		procedure Vertex3f(const x,y,z:single);override;
		procedure BeginScene(const VPrimitiveType:TSPrimtiveType);override;
		procedure EndScene();override;
		// Сохранения ресурсов рендера и убивание самого рендера
		procedure LockResources();override;
		// Инициализация рендера и загрузка сохраненных ресурсов
		procedure UnLockResources();override;
		
		procedure Color3f(const r,g,b:single);override;
		procedure TexCoord2f(const x,y:single);override;
		procedure Vertex2f(const x,y:single);override;
		procedure Color4f(const r,g,b,a:single);override;
		procedure Normal3f(const x,y,z:single);override;
		procedure Translatef(const x,y,z:single);override;
		procedure Rotatef(const angle:single;const x,y,z:single);override;
		procedure Enable(VParam:Cardinal);override;
		procedure Disable(const VParam:Cardinal);override;
		procedure DeleteTextures(const VQuantity:Cardinal;const VTextures:PSRenderTexture);override;
		procedure Lightfv(const VLight,VParam:Cardinal;const VParam2:Pointer);override;
		procedure GenTextures(const VQuantity:Cardinal;const VTextures:PSRenderTexture);override;
		procedure BindTexture(const VParam:Cardinal;const VTexture:Cardinal);override;
		procedure TexParameteri(const VP1,VP2,VP3:Cardinal);override;
		procedure PixelStorei(const VParamName:Cardinal;const VParam:TSInt32);override;
		procedure TexEnvi(const VP1,VP2,VP3:Cardinal);override;
		procedure TexImage2D(const VTextureType:Cardinal;const VP1:Cardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:Cardinal;VBitMap:Pointer);override;
		procedure ReadPixels(const x,y:Integer;const Vwidth,Vheight:Integer;const format, atype: Cardinal;const pixels: Pointer);override;
		procedure CullFace(const VParam:Cardinal);override;
		procedure EnableClientState(const VParam:Cardinal);override;
		procedure DisableClientState(const VParam:Cardinal);override;
		procedure GenBuffersARB(const VQ:Integer;const PT:PCardinal);override;
		procedure DeleteBuffersARB(const VQuantity:LongWord;VPoint:Pointer);override;
		procedure BindBufferARB(const VParam:Cardinal;const VParam2:Cardinal);override;
		procedure BufferDataARB(const VParam:Cardinal;const VSize:int64;VBuffer:Pointer;const VParam2:Cardinal;const VIndexPrimetiveType : TSLongWord = 0);override;
		procedure DrawElements(const VParam:Cardinal;const VSize:int64;const VParam2:Cardinal;VBuffer:Pointer);override;
		procedure ColorPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);override;
		procedure TexCoordPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);override;
		procedure NormalPointer(const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);override;
		procedure VertexPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);override;
		function IsEnabled(const VParam:Cardinal):Boolean;override;
		procedure Clear(const VParam:Cardinal);override;
		procedure LineWidth(const VLW:Single);override;
		procedure PointSize(const PS:Single);override;
		procedure PushMatrix();override;
		procedure PopMatrix();override;
		procedure DrawArrays(const VParam:TSCardinal;const VFirst,VCount:TSLongWord);override;
		procedure Vertex3fv(const Variable : TSPointer);override;
		procedure Normal3fv(const Variable : TSPointer);override;
		procedure MultMatrixf(const Matrix : PSMatrix4x4);override;
		procedure ColorMaterial(const r,g,b,a : TSSingle);override;
		procedure MatrixMode(const Par:TSLongWord);override;
		procedure LoadMatrixf(const Matrix : PSMatrix4x4);override;
		procedure ClientActiveTexture(const VTexture : TSLongWord);override;
		procedure ActiveTexture(const VTexture : TSLongWord);override;
		procedure ActiveTextureDiffuse();override;
		procedure ActiveTextureBump();override;
		procedure BeginBumpMapping(const Point : Pointer );override;
		procedure EndBumpMapping();override;
		{$IFNDEF MOBILE}
			procedure GetVertexUnderPixel(const px,py : LongWord; out x,y,z : Real);override;
			{$ENDIF}
		
		function SupportedShaders() : TSBoolean;override;
		// Остальное потом
		{function CreateShader(const VShaderType : TSCardinal):TSLongWord;override;
		procedure ShaderSource(const VShader : TSLongWord; VSource : PChar; VSourceLength : integer);override;
		procedure CompileShader(const VShader : TSLongWord);override;
		procedure GetObjectParameteriv(const VObject : TSLongWord; const VParamName : TSCardinal; const VResult : TSRPInteger);override;
		procedure GetInfoLog(const VHandle : TSLongWord; const VMaxLength : TSInteger; var VLength : TSInteger; VLog : PChar);override;
		procedure DeleteShader(const VProgram : TSLongWord);override;
		
		function CreateShaderProgram() : TSLongWord;override;
		procedure AttachShader(const VProgram, VShader : TSLongWord);override;
		procedure LinkShaderProgram(const VProgram : TSLongWord);override;
		procedure DeleteShaderProgram(const VProgram : TSLongWord);override;
		
		function GetUniformLocation(const VProgram : TSLongWord; const VLocationName : PChar): TSLongWord;override;
		procedure Uniform1i(const VLocationName : TSLongWord; const VData:TSLongWord);override;
		procedure UseProgram(const VProgram : TSLongWord);override;
		procedure UniformMatrix4fv(const VLocationName : TSLongWord; const VCount : TSLongWord; const VTranspose : TSBoolean; const VData : TSPointer);override;}
			private
		
		end;

implementation


class function TSRenderDirectX12.RenderName() : TSString;
begin
Result := 'DirectX 12';
end;

class function TSRenderDirectX12.ClassName() : TSString; 
begin
Result := 'TSRenderDirectX12';
end;

class function TSRenderDirectX12.Supported() : TSBoolean;
begin
Result := False;
end;

function TSRenderDirectX12.SupportedShaders() : TSBoolean;
begin
Result := False;
end;

{$IFNDEF MOBILE}
procedure TSRenderDirectX12.GetVertexUnderPixel(const px,py : LongWord; out x,y,z : Real);
begin

end;
{$ENDIF}

procedure TSRenderDirectX12.BeginBumpMapping(const Point : Pointer );
begin

end;

procedure TSRenderDirectX12.EndBumpMapping();
begin

end;

procedure TSRenderDirectX12.ActiveTexture(const VTexture : TSLongWord);
begin

end;

procedure TSRenderDirectX12.ActiveTextureDiffuse();
begin

end;

procedure TSRenderDirectX12.ActiveTextureBump();
begin

end;

procedure TSRenderDirectX12.ClientActiveTexture(const VTexture : TSLongWord);
begin

end;

procedure TSRenderDirectX12.ColorMaterial(const r,g,b,a : TSSingle);
begin

end;

procedure TSRenderDirectX12.PushMatrix();
begin

end;

procedure TSRenderDirectX12.PopMatrix();
begin

end;

procedure TSRenderDirectX12.SwapBuffers();
begin

end;

function TSRenderDirectX12.SupportedMemoryBuffers():Boolean;
begin
Result:=False;
end;

function TSRenderDirectX12.SupportedGraphicalBuffers():Boolean;
begin
Result:=False;
end;

procedure TSRenderDirectX12.PointSize(const PS:Single);
begin

end;

procedure TSRenderDirectX12.LineWidth(const VLW:Single);
begin

end;

procedure TSRenderDirectX12.Color3f(const r,g,b:single);
begin
Color4f(r,g,b,1);
end;

procedure TSRenderDirectX12.TexCoord2f(const x,y:single); 
begin 

end;

procedure TSRenderDirectX12.Vertex2f(const x,y:single); 
begin

end;

procedure TSRenderDirectX12.Color4f(const r,g,b,a:single); 
begin

end;

procedure TSRenderDirectX12.LoadMatrixf(const Matrix : PSMatrix4x4);
begin

end;

procedure TSRenderDirectX12.MultMatrixf(const Matrix : PSMatrix4x4);
begin 

end;

procedure TSRenderDirectX12.Translatef(const x,y,z:single);
begin 

end;

procedure TSRenderDirectX12.Rotatef(const angle:single;const x,y,z:single);
begin

end;

procedure TSRenderDirectX12.Enable(VParam:Cardinal); 
begin

end;

procedure TSRenderDirectX12.Disable(const VParam:Cardinal); 
begin 

end;

procedure TSRenderDirectX12.DeleteTextures(const VQuantity:Cardinal;const VTextures:PSRenderTexture); 
begin 

end;

procedure TSRenderDirectX12.Lightfv(const VLight,VParam:Cardinal;const VParam2:Pointer); 
begin 

end;

procedure TSRenderDirectX12.GenTextures(const VQuantity:Cardinal;const VTextures:PSRenderTexture);
begin 

end;

procedure TSRenderDirectX12.BindTexture(const VParam:Cardinal;const VTexture:Cardinal); 
begin 

end;

procedure TSRenderDirectX12.TexParameteri(const VP1,VP2,VP3:Cardinal);
begin 

end;

procedure TSRenderDirectX12.PixelStorei(const VParamName:Cardinal;const VParam:TSInt32); 
begin 

end;

procedure TSRenderDirectX12.TexEnvi(const VP1,VP2,VP3:Cardinal); 
begin 

end;

procedure TSRenderDirectX12.TexImage2D(const VTextureType:Cardinal;const VP1:Cardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:Cardinal;VBitMap:Pointer); 
begin 

end;

procedure TSRenderDirectX12.ReadPixels(const x,y:Integer;const Vwidth,Vheight:Integer;const format, atype: Cardinal;const pixels: Pointer); 
begin 

end;

procedure TSRenderDirectX12.CullFace(const VParam:Cardinal); 
begin 

end;

procedure TSRenderDirectX12.EnableClientState(const VParam:Cardinal); 
begin 

end;

procedure TSRenderDirectX12.DisableClientState(const VParam:Cardinal); 
begin 

end;

procedure TSRenderDirectX12.GenBuffersARB(const VQ:Integer;const PT:PCardinal);
begin 

end;

procedure TSRenderDirectX12.DeleteBuffersARB(const VQuantity:LongWord;VPoint:Pointer);
begin 

end;

procedure TSRenderDirectX12.BindBufferARB(const VParam:Cardinal;const VParam2:Cardinal);
begin 

end;

procedure TSRenderDirectX12.BufferDataARB(
	const VParam:Cardinal;   // SR_ARRAY_BUFFER_ARB or SR_ELEMENT_ARRAY_BUFFER_ARB
	const VSize:int64;       // Размер в байтах
	VBuffer:Pointer;         // Буфер
	const VParam2:Cardinal;
	const VIndexPrimetiveType : TSLongWord = 0);
begin 

end;

procedure TSRenderDirectX12.DrawElements(
	const VParam:Cardinal;
	const VSize:int64;// не в байтах а в 4*байт
	const VParam2:Cardinal;
	VBuffer:Pointer);
begin 

end;

procedure TSRenderDirectX12.DrawArrays(const VParam:TSCardinal;const VFirst,VCount:TSLongWord);
begin

end;

procedure TSRenderDirectX12.ColorPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 

end;

procedure TSRenderDirectX12.TexCoordPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 

end;

procedure TSRenderDirectX12.NormalPointer(const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 

end;

procedure TSRenderDirectX12.VertexPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 

end;

function TSRenderDirectX12.IsEnabled(const VParam:Cardinal):Boolean; 
begin 
Result:=False;
end;

procedure TSRenderDirectX12.Clear(const VParam:Cardinal); 
begin 

end;

procedure TSRenderDirectX12.BeginScene(const VPrimitiveType:TSPrimtiveType);
begin

end;

procedure TSRenderDirectX12.EndScene();
begin

end;

procedure TSRenderDirectX12.Init();
begin

end;

constructor TSRenderDirectX12.Create();
begin
inherited Create();

end;

procedure TSRenderDirectX12.Kill();
begin

end;

destructor TSRenderDirectX12.Destroy();
begin
inherited Destroy();
{$IFDEF RENDER_DX12_DEBUG}
	WriteLn('TSRenderDirectX12.Destroy(): End');
	{$ENDIF}
end;

procedure TSRenderDirectX12.InitOrtho2d(const x0,y0,x1,y1:TSSingle);
begin

end;

procedure TSRenderDirectX12.MatrixMode(const Par:TSLongWord);
begin

end;

procedure TSRenderDirectX12.InitMatrixMode(const Mode:TSMatrixMode = S_3D; const dncht : TSFloat = 1);
begin

end;

procedure TSRenderDirectX12.Viewport(const a,b,c,d:TSAreaInt);
begin

end;

procedure TSRenderDirectX12.LoadIdentity();
begin

end;

procedure TSRenderDirectX12.Vertex3fv(const Variable : TSPointer);
begin

end;

procedure TSRenderDirectX12.Normal3f(const x,y,z:single); 
begin 

end;

procedure TSRenderDirectX12.Normal3fv(const Variable : TSPointer);
begin

end;

procedure TSRenderDirectX12.Vertex3f(const x,y,z:single);
begin

end;


function TSRenderDirectX12.CreateContext():Boolean;
begin
Result := False;
end;

procedure TSRenderDirectX12.ReleaseCurrent();
begin

end;

function TSRenderDirectX12.SetPixelFormat():Boolean;overload;
begin
Result:=True;
end;

function TSRenderDirectX12.MakeCurrent():Boolean;
begin

end;

procedure TSRenderDirectX12.LockResources();
begin

end;

procedure TSRenderDirectX12.UnLockResources();
begin

end;

end.
