{$INCLUDE SaGe.inc}

//{$DEFINE RENDER_DX12_DEBUG}

unit SaGeRenderDirectX12;

interface

uses
	 SaGeBase
	,SaGeBased
	,SaGeRender
	,SaGeCommon
	,SaGeRenderConstants
	,SaGeClasses
	
	,crt
	,windows
	,DynLibs
	
	,DX12.D3D12
	,DX12.D2D1
	,DX12.DXGI
	,DX12.D3DCommon
	,DX12.DWrite
	;

type
	TSGRenderDirectX12 = class(TSGRender)
			public
		constructor Create();override;
		destructor Destroy();override;
			protected
		
			public
		class function Suppored() : TSGBoolean;override;
		function SetPixelFormat():Boolean;override;overload;
		function CreateContext():Boolean;override;
		function MakeCurrent():Boolean;override;
		procedure ReleaseCurrent();override;
		procedure Init();override;
		procedure Kill();override;
		procedure Viewport(const a,b,c,d:TSGAreaInt);override;
		procedure SwapBuffers();override;
		function SupporedVBOBuffers:Boolean;override;
		class function ClassName() : TSGString; override;
			public
		procedure InitOrtho2d(const x0,y0,x1,y1:TSGSingle);override;
		procedure InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht : TSGFloat = 1);override;
		procedure LoadIdentity();override;
		procedure Vertex3f(const x,y,z:single);override;
		procedure BeginScene(const VPrimitiveType:TSGPrimtiveType);override;
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
		procedure DeleteTextures(const VQuantity:Cardinal;const VTextures:PSGUInt);override;
		procedure Lightfv(const VLight,VParam:Cardinal;const VParam2:Pointer);override;
		procedure GenTextures(const VQuantity:Cardinal;const VTextures:PSGUInt);override;
		procedure BindTexture(const VParam:Cardinal;const VTexture:Cardinal);override;
		procedure TexParameteri(const VP1,VP2,VP3:Cardinal);override;
		procedure PixelStorei(const VParamName:Cardinal;const VParam:SGInt);override;
		procedure TexEnvi(const VP1,VP2,VP3:Cardinal);override;
		procedure TexImage2D(const VTextureType:Cardinal;const VP1:Cardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:Cardinal;VBitMap:Pointer);override;
		procedure ReadPixels(const x,y:Integer;const Vwidth,Vheight:Integer;const format, atype: Cardinal;const pixels: Pointer);override;
		procedure CullFace(const VParam:Cardinal);override;
		procedure EnableClientState(const VParam:Cardinal);override;
		procedure DisableClientState(const VParam:Cardinal);override;
		procedure GenBuffersARB(const VQ:Integer;const PT:PCardinal);override;
		procedure DeleteBuffersARB(const VQuantity:LongWord;VPoint:Pointer);override;
		procedure BindBufferARB(const VParam:Cardinal;const VParam2:Cardinal);override;
		procedure BufferDataARB(const VParam:Cardinal;const VSize:int64;VBuffer:Pointer;const VParam2:Cardinal;const VIndexPrimetiveType : TSGLongWord = 0);override;
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
		procedure DrawArrays(const VParam:TSGCardinal;const VFirst,VCount:TSGLongWord);override;
		procedure Vertex3fv(const Variable : TSGPointer);override;
		procedure Normal3fv(const Variable : TSGPointer);override;
		procedure MultMatrixf(const Variable : TSGPointer);override;
		procedure ColorMaterial(const r,g,b,a : TSGSingle);override;
		procedure MatrixMode(const Par:TSGLongWord);override;
		procedure LoadMatrixf(const Variable : TSGPointer);override;
		procedure ClientActiveTexture(const VTexture : TSGLongWord);override;
		procedure ActiveTexture(const VTexture : TSGLongWord);override;
		procedure ActiveTextureDiffuse();override;
		procedure ActiveTextureBump();override;
		procedure BeginBumpMapping(const Point : Pointer );override;
		procedure EndBumpMapping();override;
		{$IFNDEF MOBILE}
			procedure GetVertexUnderPixel(const px,py : LongWord; out x,y,z : Real);override;
			{$ENDIF}
		
		function SupporedShaders() : TSGBoolean;override;
		// Остальное потом
		{function CreateShader(const VShaderType : TSGCardinal):TSGLongWord;override;
		procedure ShaderSource(const VShader : TSGLongWord; VSourse : PChar; VSourseLength : integer);override;
		procedure CompileShader(const VShader : TSGLongWord);override;
		procedure GetObjectParameteriv(const VObject : TSGLongWord; const VParamName : TSGCardinal; const VResult : TSGRPInteger);override;
		procedure GetInfoLog(const VHandle : TSGLongWord; const VMaxLength : TSGInteger; var VLength : TSGInteger; VLog : PChar);override;
		procedure DeleteShader(const VProgram : TSGLongWord);override;
		
		function CreateShaderProgram() : TSGLongWord;override;
		procedure AttachShader(const VProgram, VShader : TSGLongWord);override;
		procedure LinkShaderProgram(const VProgram : TSGLongWord);override;
		procedure DeleteShaderProgram(const VProgram : TSGLongWord);override;
		
		function GetUniformLocation(const VProgram : TSGLongWord; const VLocationName : PChar): TSGLongWord;override;
		procedure Uniform1i(const VLocationName : TSGLongWord; const VData:TSGLongWord);override;
		procedure UseProgram(const VProgram : TSGLongWord);override;
		procedure UniformMatrix4fv(const VLocationName : TSGLongWord; const VCount : TSGLongWord; const VTranspose : TSGBoolean; const VData : TSGPointer);override;}
			private
		
		end;

implementation

class function TSGRenderDirectX12.ClassName() : TSGString; 
begin
Result := 'TSGRenderDirectX12';
end;

class function TSGRenderDirectX12.Suppored() : TSGBoolean;
begin
Result := False;
end;

function TSGRenderDirectX12.SupporedShaders() : TSGBoolean;
begin
Result := False;
end;

{$IFNDEF MOBILE}
procedure TSGRenderDirectX12.GetVertexUnderPixel(const px,py : LongWord; out x,y,z : Real);
begin

end;
{$ENDIF}

procedure TSGRenderDirectX12.BeginBumpMapping(const Point : Pointer );
begin

end;

procedure TSGRenderDirectX12.EndBumpMapping();
begin

end;

procedure TSGRenderDirectX12.ActiveTexture(const VTexture : TSGLongWord);
begin

end;

procedure TSGRenderDirectX12.ActiveTextureDiffuse();
begin

end;

procedure TSGRenderDirectX12.ActiveTextureBump();
begin

end;

procedure TSGRenderDirectX12.ClientActiveTexture(const VTexture : TSGLongWord);
begin

end;

procedure TSGRenderDirectX12.ColorMaterial(const r,g,b,a : TSGSingle);
begin

end;

procedure TSGRenderDirectX12.PushMatrix();
begin

end;

procedure TSGRenderDirectX12.PopMatrix();
begin

end;

procedure TSGRenderDirectX12.SwapBuffers();
begin

end;

function TSGRenderDirectX12.SupporedVBOBuffers():Boolean;
begin
Result:=False;
end;

procedure TSGRenderDirectX12.PointSize(const PS:Single);
begin

end;

procedure TSGRenderDirectX12.LineWidth(const VLW:Single);
begin

end;

procedure TSGRenderDirectX12.Color3f(const r,g,b:single);
begin
Color4f(r,g,b,1);
end;

procedure TSGRenderDirectX12.TexCoord2f(const x,y:single); 
begin 

end;

procedure TSGRenderDirectX12.Vertex2f(const x,y:single); 
begin

end;

procedure TSGRenderDirectX12.Color4f(const r,g,b,a:single); 
begin

end;

procedure TSGRenderDirectX12.LoadMatrixf(const Variable : TSGPointer);
begin

end;

procedure TSGRenderDirectX12.MultMatrixf(const Variable : TSGPointer);
begin 

end;

procedure TSGRenderDirectX12.Translatef(const x,y,z:single);
begin 

end;

procedure TSGRenderDirectX12.Rotatef(const angle:single;const x,y,z:single);
begin

end;

procedure TSGRenderDirectX12.Enable(VParam:Cardinal); 
begin

end;

procedure TSGRenderDirectX12.Disable(const VParam:Cardinal); 
begin 

end;

procedure TSGRenderDirectX12.DeleteTextures(const VQuantity:Cardinal;const VTextures:PSGUInt); 
begin 

end;

procedure TSGRenderDirectX12.Lightfv(const VLight,VParam:Cardinal;const VParam2:Pointer); 
begin 

end;

procedure TSGRenderDirectX12.GenTextures(const VQuantity:Cardinal;const VTextures:PSGUInt);
begin 

end;

procedure TSGRenderDirectX12.BindTexture(const VParam:Cardinal;const VTexture:Cardinal); 
begin 

end;

procedure TSGRenderDirectX12.TexParameteri(const VP1,VP2,VP3:Cardinal);
begin 

end;

procedure TSGRenderDirectX12.PixelStorei(const VParamName:Cardinal;const VParam:SGInt); 
begin 

end;

procedure TSGRenderDirectX12.TexEnvi(const VP1,VP2,VP3:Cardinal); 
begin 

end;

procedure TSGRenderDirectX12.TexImage2D(const VTextureType:Cardinal;const VP1:Cardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:Cardinal;VBitMap:Pointer); 
begin 

end;

procedure TSGRenderDirectX12.ReadPixels(const x,y:Integer;const Vwidth,Vheight:Integer;const format, atype: Cardinal;const pixels: Pointer); 
begin 

end;

procedure TSGRenderDirectX12.CullFace(const VParam:Cardinal); 
begin 

end;

procedure TSGRenderDirectX12.EnableClientState(const VParam:Cardinal); 
begin 

end;

procedure TSGRenderDirectX12.DisableClientState(const VParam:Cardinal); 
begin 

end;

procedure TSGRenderDirectX12.GenBuffersARB(const VQ:Integer;const PT:PCardinal);
begin 

end;

procedure TSGRenderDirectX12.DeleteBuffersARB(const VQuantity:LongWord;VPoint:Pointer);
begin 

end;

procedure TSGRenderDirectX12.BindBufferARB(const VParam:Cardinal;const VParam2:Cardinal);
begin 

end;

procedure TSGRenderDirectX12.BufferDataARB(
	const VParam:Cardinal;   // SGR_ARRAY_BUFFER_ARB or SGR_ELEMENT_ARRAY_BUFFER_ARB
	const VSize:int64;       // Размер в байтах
	VBuffer:Pointer;         // Буфер
	const VParam2:Cardinal;
	const VIndexPrimetiveType : TSGLongWord = 0);
begin 

end;

procedure TSGRenderDirectX12.DrawElements(
	const VParam:Cardinal;
	const VSize:int64;// не в байтах а в 4*байт
	const VParam2:Cardinal;
	VBuffer:Pointer);
begin 

end;

procedure TSGRenderDirectX12.DrawArrays(const VParam:TSGCardinal;const VFirst,VCount:TSGLongWord);
begin

end;

procedure TSGRenderDirectX12.ColorPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 

end;

procedure TSGRenderDirectX12.TexCoordPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 

end;

procedure TSGRenderDirectX12.NormalPointer(const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 

end;

procedure TSGRenderDirectX12.VertexPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 

end;

function TSGRenderDirectX12.IsEnabled(const VParam:Cardinal):Boolean; 
begin 
Result:=False;
end;

procedure TSGRenderDirectX12.Clear(const VParam:Cardinal); 
begin 

end;

procedure TSGRenderDirectX12.BeginScene(const VPrimitiveType:TSGPrimtiveType);
begin

end;

procedure TSGRenderDirectX12.EndScene();
begin

end;

procedure TSGRenderDirectX12.Init();
begin

end;

constructor TSGRenderDirectX12.Create();
begin
inherited Create();

end;

procedure TSGRenderDirectX12.Kill();
begin

end;

destructor TSGRenderDirectX12.Destroy();
begin
inherited Destroy();
{$IFDEF RENDER_DX12_DEBUG}
	WriteLn('TSGRenderDirectX12.Destroy(): End');
	{$ENDIF}
end;

procedure TSGRenderDirectX12.InitOrtho2d(const x0,y0,x1,y1:TSGSingle);
begin

end;

procedure TSGRenderDirectX12.MatrixMode(const Par:TSGLongWord);
begin

end;

procedure TSGRenderDirectX12.InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht : TSGFloat = 1);
begin

end;

procedure TSGRenderDirectX12.Viewport(const a,b,c,d:TSGAreaInt);
begin

end;

procedure TSGRenderDirectX12.LoadIdentity();
begin

end;

procedure TSGRenderDirectX12.Vertex3fv(const Variable : TSGPointer);
begin

end;

procedure TSGRenderDirectX12.Normal3f(const x,y,z:single); 
begin 

end;

procedure TSGRenderDirectX12.Normal3fv(const Variable : TSGPointer);
begin

end;

procedure TSGRenderDirectX12.Vertex3f(const x,y,z:single);
begin

end;


function TSGRenderDirectX12.CreateContext():Boolean;
begin
Result := False;
end;

procedure TSGRenderDirectX12.ReleaseCurrent();
begin

end;

function TSGRenderDirectX12.SetPixelFormat():Boolean;overload;
begin
Result:=True;
end;

function TSGRenderDirectX12.MakeCurrent():Boolean;
begin

end;

procedure TSGRenderDirectX12.LockResources();
begin

end;

procedure TSGRenderDirectX12.UnLockResources();
begin

end;

end.
