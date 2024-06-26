{$INCLUDE Smooth.inc}

//{$DEFINE RENDER_DX8_DEBUG}
//{$DEFINE RENDER_DX8_DEBUG_LINK}

unit SmoothRenderDirectX8;

interface

uses
	// Smooth units
	 SmoothBase
	,SmoothRender
	,SmoothRenderBase
	,SmoothRenderInterface
	,SmoothBaseClasses
	,SmoothBaseContextInterface
	,SmoothMatrix
	,SmoothCommonStructs
	
	// OS units
	,crt
	,windows
	
	// DirectX 8 units
	,DXTypes
	,D3DX8
	,Direct3D8
	;

type
	D3DXVector3 = TD3DXVector3;
	D3DVector = D3DXVector3;

	TSRDTypeDataBuffer = (SRDTypeDataBufferVertex, SRDTypeDataBufferColor, SRDTypeDataBufferNormal, SRDTypeDataBufferTexVertex);
	TSRenderDirectX8 = class(TSRender)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function RenderName() : TSString; override;
			protected
		pD3D        : IDirect3D8;
		pDevice     : IDirect3DDevice8;
		D3DX8Loaded : TSBoolean;
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
		// ���������� �������� ������� � �������� ������ �������
		procedure LockResources();override;
		// ������������� ������� � �������� ����������� ��������
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
		// ��������� �����
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
		//����, � ������� ������������ ����� ��� �������
		FClearColor:LongWord;

			(*glBegin ... glEnd*)
			//���������� ������ � ��������� � Vertex-�� ������-�
		// ������� ��� ���������� (�������� � BeginScene)
		FPrimetiveType : LongWord;
		// ��� ��������� ����� (SR_QUADS,..) ���������� ��������� �������������� ��������. ���� � �������� FPrimetivePrt
		FPrimetivePrt  : LongWord;
		// ������� ����
		FNowColor      : LongWord;
		// ������� �������
		FNowNormal     : packed record
			x,y,z:TSSingle;
			end;
		// ������, ������� � ���������� ����������� � ������� pDevice.DrawPrimitiveUP(..)
		FArPoints:array[0..2]of
			packed record
				x,y,z : TSSingle;
				Normalx,Normaly,Normalz: TSSingle;
				Color : LongWord;
				tx,ty : TSSingle;
				end;
		// ���������� ������, ������� � ������ ������ ��� �������� ������ FArPoints
		FNumberOfPoints : LongWord;

			(* Textures *)
		// ������ ������� FArTextures[] �������� � ������ ������ ��������
		FNowTexture:LongWord;
		// ������ �������
		FArTextures:packed array of
			packed record
			// texture
			FTexture:IDirect3DTexture8;
			// for change fullscreen
			FBufferChangeFullscreen:PByte;
			// image info
			FWidth,FHeight,FChannels,FFormat:TSLongWord;
			end;

			(* ===VBO=== or arrays *)
		// FArBuffers[i-1] �������� ���������� � i-�� ������.
		FArBuffers:packed array of
			packed record
			// ��� ������� SR_ARRAY_BUFFER_ARB or SR_ELEMENT_ARRAY_BUFFER_ARB
			FType:TSLongWord;
			// ������. (�� IDirect3DVertexBuffer8 ��� IDirect3DIndexBuffer8)
			FResource:IDirect3DResource8;
			// ��� ������
			FResourceSize:QWord;
			// ��� ��������� ��������� ��� ������ ��� ����������.
			//!!FVertexDeclaration:IDirect3DVertexDeclaration8;
			// ��� ������������ ��� �������� ������ ��� ���������� ���������.
			FBufferChangeFullscreen:PByte;
			end;
		FEnabledClientStateVertex    : TSBoolean;
		FEnabledClientStateColor     : TSBoolean;
		FEnabledClientStateNormal    : TSBoolean;
		FEnabledClientStateTexVertex : Boolean;
		FVBOData:packed array [0..1] of TSLongWord;
		// FVBOData[0] - SR_ARRAY_BUFFER_ARB
		// FVBOData[1] - SR_ELEMENT_ARRAY_BUFFER_ARB
		FArDataBuffers:packed array[TSRDTypeDataBuffer] of
			packed record
			// ��������� �� ������ ��������������� ������ FVBOData[0]
			FVBOBuffer      : TSLongWord;
			// � FVBOData ������������ ������� ��������� �����.
			// ���� ������� �� �������, �� ��������������� ��������, ������� ��������� � FVBOData[0]
			FQuantityParams : TSByte;
			// FQuantityParams --- ���������� ���������� (������ �������� � gl*Pointer (��� �������� �� ������� 3)
			FDataType       : TSLongWord;
			// FDataType --- ��� ������. ���� Float, Unsigned_byte ��� � �
			FSizeOfOneVertex: TSByte;
			// FSizeOfOneVertex --- ������ ������ �������� � �������
			FShift          : TSMaxEnum;
			// FShift --- ���� VBO - �������� � ������ ������������ ������ ����� ���������� �������.
			// � ���� �� VBO - ��������� �� ������ ������� �������. (��� �� ��������� ��������� ������)
			end;

			(* Light *)
		FLigth               : D3DLIGHT8;

			(* PushMatrix/PopMatrix *)
		FQuantitySavedMatrix : LongWord;
		FLengthArSavedMatrix : LongWord;
		FArSavedMatrix       : packed array of D3DMATRIX;

			(* Material *)
		FMaterial            : D3DMATERIAL8;

			(* Matrix Mode *)
		FNowMatrixMode : TSLongWord;

			(* MultiTexturing *)
		FNowActiveNumberTexture : TSLongWord;
		FNowActiveClientNumberTexture : TSLongWord;
			private
		procedure AfterVertexProc();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure DropDeviceResources();
		procedure SetToNullTexture(var Texture : IDirect3DTexture8);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetToNullResource(var Resource : IDirect3DResource8);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;
type
	TSRDXVertexDeclarationManipulator=class
			public
		constructor Create();
		destructor Destroy();override;
		//!!procedure AddElement(const VOffset:TSLongWord;const VType:_D3DDECLTYPE;const VUSAGE:_D3DDECLUSAGE);
		//!!function CreateVertexDeclaration(const pDevice:IDirect3DDevice8):IDirect3DVertexDeclaration8;inline;
			private
		//!!FEVArray:packed array of _D3DVERTEXELEMENT8;
		end;
function SRDXGetD3DCOLORVALUE(const r,g,b,a:TSSingle):D3DCOLORVALUE;inline;
function SRDXGetNumPrimetives(const VParam:TSLongWord;const VSize:TSMaxEnum):TSMaxEnum;inline;
function SRDXConvertPrimetiveType(const VParam:TSLongWord):_D3DPRIMITIVETYPE;inline;
function SRDXVertex3fToRGBA(const v : TSVertex3f ):TSLongWord;inline;

operator := (Matrix : D3DMATRIX) : TSMatrix4x4; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
operator := (Matrix : TSMatrix4x4) : D3DMATRIX; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
operator *  (const Matrix1, Matrix2 : D3DMATRIX) : D3DMATRIX;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothDllManager
	,SmoothStringUtils
	,SmoothLog
	;

operator := (Matrix : D3DMATRIX) : TSMatrix4x4; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Move(Matrix, Result, SizeOf(Matrix));
end;

operator := (Matrix : TSMatrix4x4) : D3DMATRIX; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Move(Matrix, Result, SizeOf(Matrix));
end;

operator *  (const Matrix1, Matrix2 : D3DMATRIX) : D3DMATRIX;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := TSMatrix4x4(Matrix1) * TSMatrix4x4(Matrix2);
end;

class function TSRenderDirectX8.RenderName() : TSString;
begin
Result := 'DirectX 8';
end;

class function TSRenderDirectX8.ClassName() : TSString;
begin
Result := 'TSRenderDirectX8';
end;

class function TSRenderDirectX8.Supported() : TSBoolean;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.Supported'); {$ENDIF}
Result := DllManager.Supported('Direct3D8');
if Result then
	DllManager.Supported('Direct3DX8');
end;

function TSRenderDirectX8.SupportedShaders() : TSBoolean;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.SupportedShaders'); {$ENDIF}
Result := False;
end;

{$IFNDEF MOBILE}
procedure TSRenderDirectX8.GetVertexUnderPixel(const px,py : LongWord; out x,y,z : Real);
var
	pProjection,pView,pWorld : D3DMATRIX;
	pViewport : D3DVIEWPORT8;
	a,b : D3DXVector3;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.GetVertexUnderPixel'); {$ENDIF}
pDevice.GetViewport(pViewport);
x := 0;
y := 0;
z := 0;

a.x := px;
a.y := py;
a.z := 0;//depth
pDevice.GetTransform(D3DTS_PROJECTION, pProjection);
pDevice.GetTransform(D3DTS_VIEW, pView);
pDevice.GetTransform(D3DTS_WORLD, pWorld);
if D3DX8Loaded then
	D3DXVec3UnProject(
		b,
		a,
		pViewport,
		pProjection,
		pView,
		pWorld);
end;
{$ENDIF}

function SRDXVertex3fToRGBA(const v : TSVertex3f ):TSLongWord;inline;
begin
Result :=
	(Round(255.0 * 1.0) shl 24) +
	(Round(127.0 * v.x + 128.0) shl 16) +
	(Round(127.0 * v.y + 128.0) shl 8) +
	(Round(127.0 * v.z + 128.0) shl 0);
end;

procedure TSRenderDirectX8.BeginBumpMapping(const Point : Pointer );
var
	v : TSVertex3f;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.BeginBumpMapping'); {$ENDIF}
v := TSVertex3f(Point^).Normalized();
pDevice.SetRenderState(D3DRS_TEXTUREFACTOR, SRDXVertex3fToRGBA(v));
end;

procedure TSRenderDirectX8.EndBumpMapping();
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.EndBumpMapping'); {$ENDIF}
pDevice.SetRenderState(D3DRS_TEXTUREFACTOR, 0);
end;

procedure TSRenderDirectX8.ActiveTexture(const VTexture : TSLongWord);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.ActiveTexture'); {$ENDIF}
FNowActiveNumberTexture := VTexture;
end;

procedure TSRenderDirectX8.ActiveTextureDiffuse();
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.ActiveTextureDiffuse'); {$ENDIF}
if FNowActiveNumberTexture = 0 then
	begin
	pDevice.SetTextureStageState( FNowActiveNumberTexture, D3DTSS_TEXCOORDINDEX, 0);
	pDevice.SetTextureStageState( FNowActiveNumberTexture, D3DTSS_COLORARG1,     D3DTA_TEXTURE);
	pDevice.SetTextureStageState( FNowActiveNumberTexture, D3DTSS_COLORARG2,     D3DTA_DIFFUSE);
	pDevice.SetTextureStageState( FNowActiveNumberTexture, D3DTSS_COLOROP,       D3DTOP_MODULATE);
	end
else if FNowActiveNumberTexture = 1 then
	begin
	pDevice.SetTextureStageState( FNowActiveNumberTexture, D3DTSS_TEXCOORDINDEX, 0);
	pDevice.SetTextureStageState( FNowActiveNumberTexture, D3DTSS_COLOROP,       D3DTOP_MODULATE);
	pDevice.SetTextureStageState( FNowActiveNumberTexture, D3DTSS_COLORARG1,     D3DTA_TEXTURE);
	//D3DTSS_COLORARG2 ���������� � ����������� ����� ��������� ����������� (c 0)
	end;
end;

procedure TSRenderDirectX8.ActiveTextureBump();
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.ActiveTextureBump'); {$ENDIF}
if FNowActiveNumberTexture = 0 then
	begin
	pDevice.SetTextureStageState( FNowActiveNumberTexture, D3DTSS_TEXCOORDINDEX, 0 );
	pDevice.SetTextureStageState( FNowActiveNumberTexture, D3DTSS_COLOROP,       D3DTOP_DOTPRODUCT3);
	pDevice.SetTextureStageState( FNowActiveNumberTexture, D3DTSS_COLORARG1,     D3DTA_TEXTURE);
	pDevice.SetTextureStageState( FNowActiveNumberTexture, D3DTSS_COLORARG2,     D3DTA_TFACTOR);
	end;
end;

procedure TSRenderDirectX8.ClientActiveTexture(const VTexture : TSLongWord);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.ClientActiveTexture'); {$ENDIF}
FNowActiveClientNumberTexture := VTexture;
end;

procedure TSRenderDirectX8.ColorMaterial(const r,g,b,a : TSSingle);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.ColorMaterial'); {$ENDIF}
FMaterial.Diffuse:=SRDXGetD3DCOLORVALUE(r,g,b,a);
pDevice.SetMaterial(FMaterial);
end;

constructor TSRDXVertexDeclarationManipulator.Create();
begin
//!!FEVArray:=nil;
end;

destructor TSRDXVertexDeclarationManipulator.Destroy();
begin
//!!if FEVArray<>nil then
//!!	SetLength(FEVArray,0);
inherited;
end;

{!!
procedure TSRDXVertexDeclarationManipulator.AddElement(const VOffset:TSLongWord;const VType:_D3DDECLTYPE;const VUSAGE:_D3DDECLUSAGE);
begin
if FEVArray=nil then
	SetLength(FEVArray,1)
else
	SetLength(FEVArray,Length(FEVArray)+1);
FEVArray[High(FEVArray)]._Type:=VType;
FEVArray[High(FEVArray)].Offset:=VOffset;
FEVArray[High(FEVArray)].USAGE:=VUSAGE;
FEVArray[High(FEVArray)].Method:=D3DDECLMETHOD_DEFAULT;
end;

function TSRDXVertexDeclarationManipulator.CreateVertexDeclaration(const pDevice:IDirect3DDevice8):IDirect3DVertexDeclaration8;inline;
begin
Result:=nil;
if FEVArray<>nil then
	begin
	SetLength(FEVArray,Length(FEVArray)+1);
	FEVArray[High(FEVArray)]:=D3DDECL_END;
	pDevice.CreateVertexDeclaration(@FEVArray[0],Result);
	end;
end;
}

function SRDXConvertPrimetiveType(const VParam:TSLongWord):_D3DPRIMITIVETYPE;inline;
begin
case VParam of
SR_LINES:Result:=D3DPT_LINELIST;
SR_TRIANGLES:Result:=D3DPT_TRIANGLELIST;
SR_POINTS:Result:=D3DPT_POINTLIST;
SR_LINE_STRIP:Result:=D3DPT_LINESTRIP;
SR_TRIANGLE_STRIP:Result:=D3DPT_TRIANGLESTRIP;
else
	Result:=D3DPT_INVALID_0;
end;
end;
(*for look at*)
{//������ ��������������� �������
D3DXVECTOR3 position(5.0f, 3.0f, �10.0f);
D3DXVECTOR3 target(0.0f, 0.0f, 0.0f);
D3DXVECTOR3 up(0.0f, 1.0f, 0.0f);
//������� �������
D3DXMATRIX V;
//�������������� �
D3DXMatrixLookAtLH(&V, &position, &target, &up);
//� ������ ��� ������� ����
pDevice->SetTransform(D3DTS_VIEW, &V);}

function SRDXGetNumPrimetives(const VParam:TSLongWord;const VSize:TSMaxEnum):TSMaxEnum;inline;
begin
case VParam of
SR_LINES:Result:=VSize div 2;
SR_TRIANGLES:Result:=VSize div 3;
SR_LINE_STRIP:Result:=VSize - 1;
else Result:=VSize;
end;
end;

function SRDXGetD3DCOLORVALUE(const r,g,b,a:TSSingle):D3DCOLORVALUE;inline;
begin
Result.r:=r;
Result.b:=b;
Result.g:=g;
Result.a:=a;
end;

procedure TSRenderDirectX8.PushMatrix();
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.PushMatrix'); {$ENDIF}
if FQuantitySavedMatrix+1<=FLengthArSavedMatrix then
	begin
	pDevice.GetTransform(FNowMatrixMode,FArSavedMatrix[FQuantitySavedMatrix]);
	FQuantitySavedMatrix+=1;
	end
else
	begin
	FQuantitySavedMatrix+=1;
	FLengthArSavedMatrix+=1;
	SetLength(FArSavedMatrix,FLengthArSavedMatrix);
	pDevice.GetTransform(FNowMatrixMode,FArSavedMatrix[FQuantitySavedMatrix-1]);
	end;
end;

procedure TSRenderDirectX8.PopMatrix();
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.PopMatrix'); {$ENDIF}
if FQuantitySavedMatrix=0 then
	SLog.Source('TSRenderDirectX8.PopMatrix : Pop matrix before pushing')
else
	begin
	pDevice.SetTransform(FNowMatrixMode,FArSavedMatrix[FQuantitySavedMatrix-1]);
	FQuantitySavedMatrix-=1;
	end;
end;

procedure TSRenderDirectX8.SwapBuffers();
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.SwapBuffers'); {$ENDIF}
pDevice.Present(nil, nil, 0, nil);
end;

procedure TSRenderDirectX8.AfterVertexProc();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.AfterVertexProc'); {$ENDIF}
if (FNumberOfPoints=3) and  ((FPrimetiveType=SR_QUADS) or (FPrimetiveType=SR_TRIANGLES) or (FPrimetiveType=SR_TRIANGLE_STRIP)) then
	begin
	pDevice.DrawPrimitiveUP( D3DPT_TRIANGLELIST, 1, FArPoints[0], sizeof(FArPoints[0]));
	end
else
	if (FNumberOfPoints=2) and ((FPrimetiveType=SR_LINES) or (FPrimetiveType=SR_LINE_LOOP) or (FPrimetiveType=SR_LINE_STRIP)) then
		begin
		pDevice.DrawPrimitiveUP( D3DPT_LINELIST, 1, FArPoints[0], SizeOf(FArPoints[0]));
		end
	else
		if (FNumberOfPoints=1) and (FPrimetiveType=SR_POINTS) then
			begin
			pDevice.DrawPrimitiveUP( D3DPT_POINTLIST, 1, FArPoints[0], sizeof(FArPoints[0]));
			end;
case FPrimetiveType of
SR_POINTS:
	if (FNumberOfPoints=1) then
		FNumberOfPoints:=0;
SR_TRIANGLES:
	if FNumberOfPoints=3 then
		FNumberOfPoints:=0;
SR_QUADS:
	if FNumberOfPoints=3 then
		begin
		if FPrimetivePrt=0 then
			begin
			FPrimetivePrt:=1;
			FNumberOfPoints:=2;
			FArPoints[1]:=FArPoints[2];
			end
		else
			begin
			FPrimetivePrt:=0;
			FNumberOfPoints:=0;
			end;
		end;
SR_LINE_LOOP:
	if FNumberOfPoints=2 then
		begin
		if FPrimetivePrt=0 then
			begin
			FArPoints[2]:=FArPoints[0];
			FPrimetivePrt:=1;
			end;
		FArPoints[0]:=FArPoints[1];
		FNumberOfPoints:=1;
		end;
SR_LINE_STRIP:
	if FNumberOfPoints=2 then
		begin
		FArPoints[0]:=FArPoints[1];
		FNumberOfPoints:=1;
		end;
SR_LINES:
	if FNumberOfPoints=2 then
		begin
		FNumberOfPoints:=0;
		end;
end;
end;

function TSRenderDirectX8.SupportedGraphicalBuffers() : TSBoolean;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.SupportedGraphicalBuffers'); {$ENDIF}
Result := False;
end;

function TSRenderDirectX8.SupportedMemoryBuffers() : TSBoolean;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.SupportedMemoryBuffers'); {$ENDIF}
Result := True;
end;

procedure TSRenderDirectX8.PointSize(const PS:Single);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.PointSize'); {$ENDIF}
end;

procedure TSRenderDirectX8.LineWidth(const VLW:Single);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.LineWidth'); {$ENDIF}
end;

procedure TSRenderDirectX8.Color3f(const r,g,b:single);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.Color3f'); {$ENDIF}
Color4f(r,g,b,1);
end;

procedure TSRenderDirectX8.TexCoord2f(const x,y:single);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.TexCoord2f'); {$ENDIF}
FArPoints[FNumberOfPoints].tx:=x;
FArPoints[FNumberOfPoints].ty:=y;
end;

procedure TSRenderDirectX8.Vertex2f(const x,y:single);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.Vertex2f'); {$ENDIF}
FArPoints[FNumberOfPoints].Color:=FNowColor;
FArPoints[FNumberOfPoints].x:=x;
FArPoints[FNumberOfPoints].y:=y;
FArPoints[FNumberOfPoints].z:=0;
FNumberOfPoints+=1;
AfterVertexProc();
end;

procedure TSRenderDirectX8.Color4f(const r,g,b,a:single);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.Color4f'); {$ENDIF}
FNowColor:=D3DCOLOR_ARGB(
	Byte(a>=1)*255+Byte((a<1) and (a>0))*round(255*a),
	Byte(r>=1)*255+Byte((r<1) and (r>0))*round(255*r),
	Byte(g>=1)*255+Byte((g<1) and (g>0))*round(255*g),
	Byte(b>=1)*255+Byte((b<1) and (b>0))*round(255*b));
end;

procedure TSRenderDirectX8.LoadMatrixf(const Matrix : PSMatrix4x4);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.LoadMatrixf'); {$ENDIF}
pDevice.SetTransform(FNowMatrixMode, PD3DMATRIX(Matrix)^);
end;

procedure TSRenderDirectX8.MultMatrixf(const Matrix : PSMatrix4x4);
var
	Matrix1, MatrixOut : D3DMATRIX;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.MultMatrixf'); {$ENDIF}
pDevice.GetTransform(FNowMatrixMode, Matrix1);
if D3DX8Loaded then
	D3DXMatrixMultiply(MatrixOut, PD3DMATRIX(Matrix)^, Matrix1)
else
	MatrixOut := Matrix^ * Matrix1;
pDevice.SetTransform(FNowMatrixMode, MatrixOut);
end;

procedure TSRenderDirectX8.Translatef(const x,y,z:single);
var
	Matrix1, Matrix2, MatrixOut : D3DMATRIX;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.Translatef'); {$ENDIF}
pDevice.GetTransform(FNowMatrixMode,Matrix1);
if D3DX8Loaded then
	begin
	D3DXMatrixTranslation(Matrix2, x, y, z);
	D3DXMatrixMultiply(MatrixOut, Matrix1, Matrix2);
	end
else
	begin
	Matrix2 := STranslateMatrix(SVertex3fImport(x, y, z));
	MatrixOut := Matrix1 * Matrix2;
	end;
pDevice.SetTransform(FNowMatrixMode, MatrixOut);
end;

procedure TSRenderDirectX8.Rotatef(const angle:single;const x,y,z:single);
var
	Matrix1, Matrix2, MatrixOut : D3DMATRIX;
	v : TD3DXVector3;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.Rotatef'); {$ENDIF}
v.x:=x;
v.y:=y;
v.z:=z;
pDevice.GetTransform(FNowMatrixMode,Matrix1);
if D3DX8Loaded then
	begin
	D3DXMatrixRotationAxis(Matrix2, v, angle / 180 * pi);
	D3DXMatrixMultiply(MatrixOut, Matrix2, Matrix1);
	end
else
	begin
	Matrix2 := SRotateMatrix(angle, SVertex3fImport(x, y, z));
	MatrixOut := Matrix1 * Matrix2;
	end;
pDevice.SetTransform(FNowMatrixMode, MatrixOut);
end;

procedure TSRenderDirectX8.Enable(VParam:Cardinal);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.Enable - Begin'); {$ENDIF}
case VParam of
SR_DEPTH_TEST:
	begin
	pDevice.SetRenderState(D3DRS_ZENABLE, 1);
	end;
SR_LIGHTING:
	begin
	pDevice.SetRenderState(D3DRS_LIGHTING,1);
	end;
SR_LIGHT0..SR_LIGHT7:
	begin
	pDevice.LightEnable(VParam-SR_LIGHT0,True);
	end;
SR_BLEND:
	begin
	pDevice.SetRenderState( D3DRS_ALPHABLENDENABLE, 1);
	end;
end;
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.Enable - End'); {$ENDIF}
end;

procedure TSRenderDirectX8.Disable(const VParam:Cardinal);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.Disable'); {$ENDIF}
case VParam of
SR_DEPTH_TEST:
	begin
	pDevice.SetRenderState(D3DRS_ZENABLE, 0);
	end;
SR_TEXTURE_2D:
	begin
	FNowTexture:=0;
	pDevice.SetTexture(FNowActiveNumberTexture,nil);
	end;
SR_CULL_FACE:
	begin
	pDevice.SetRenderState( D3DRS_CULLMODE, D3DCULL_NONE );
	end;
SR_LIGHTING:
	begin
	pDevice.SetRenderState(D3DRS_LIGHTING,0);
	end;
SR_LIGHT0..SR_LIGHT7:
	begin
	pDevice.LightEnable(VParam-SR_LIGHT0,False);
	end;
SR_BLEND:
	begin
	pDevice.SetRenderState( D3DRS_ALPHABLENDENABLE, 0);
	end;
end;
end;

procedure TSRenderDirectX8.DeleteTextures(const VQuantity:Cardinal;const VTextures:PSRenderTexture);
var
	i:LongWord;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.DeleteTextures'); {$ENDIF}
for i:=0 to VQuantity-1 do
	begin
	if (VTextures[i]>0) and (VTextures[i]<=Length(FArTextures)) and (FArTextures[VTextures[i]-1].FTexture<>nil) then
		begin
		SDestroyInterface(FArTextures[VTextures[i]-1].FTexture);
		SetToNullTexture(FArTextures[VTextures[i]-1].FTexture);
		if FArTextures[VTextures[i]-1].FBufferChangeFullscreen<>nil then
			FreeMem(FArTextures[VTextures[i]-1].FBufferChangeFullscreen);
		FArTextures[VTextures[i]-1].FBufferChangeFullscreen:=nil;
		end;
	end;
end;

procedure TSRenderDirectX8.Lightfv(const VLight,VParam:Cardinal;const VParam2:Pointer);
type
	PArS = ^ Single;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.Lightfv'); {$ENDIF}
case VLight of
SR_LIGHT0:
	begin
	case VParam of
	SR_AMBIENT:
		begin
		FLigth.AMBIENT.r:=PArS(VParam2)[0];
		FLigth.AMBIENT.g:=PArS(VParam2)[1];
		FLigth.AMBIENT.b:=PArS(VParam2)[2];
		FLigth.AMBIENT.a:=PArS(VParam2)[3];
		end;
	SR_DIFFUSE:
		begin
		FLigth.Diffuse.r := PArS(VParam2)[0] ;
		FLigth.Diffuse.g := PArS(VParam2)[2] ;
		FLigth.Diffuse.b := PArS(VParam2)[3] ;
		FLigth.Diffuse.a := PArS(VParam2)[4] ;
		end;
	SR_SPECULAR:
		begin
		FLigth.SPECULAR.r:= PArS(VParam2)[0] ;
		FLigth.SPECULAR.g:= PArS(VParam2)[1] ;
		FLigth.SPECULAR.b:= PArS(VParam2)[2] ;
		FLigth.SPECULAR.a:= PArS(VParam2)[3] ;
		end;
	SR_POSITION:
		begin
		FLigth._Type:=D3DLIGHT_POINT;
		FLigth.Attenuation0:=1;
		FLigth.Position.x:=PArS(VParam2)[0];
		FLigth.Position.y:=PArS(VParam2)[1];
		FLigth.Position.z:=PArS(VParam2)[2];
		pDevice.SetLight(0, FLigth);
		pDevice.LightEnable(0, True);
		pDevice.SetRenderState(D3DRS_LIGHTING,1);
		pDevice.SetRenderState(D3DRS_AMBIENT, 1);
		end;
	else
		begin
		end;
	end;
	end;
else
	begin
	end;
end;
end;

procedure TSRenderDirectX8.GenTextures(const VQuantity:Cardinal;const VTextures:PSRenderTexture);
var
	I:LongWord;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.GenTextures'); {$ENDIF}
for i:=0 to VQuantity-1 do
	begin
	if FArTextures=nil then
		SetLength(FArTextures,1)
	else
		SetLength(FArTextures,Length(FArTextures)+1);
	FArTextures[High(FArTextures)].FTexture:=nil;
	FArTextures[High(FArTextures)].FBufferChangeFullscreen:=nil;
	VTextures[i]:=Length(FArTextures);
	end;
end;

procedure TSRenderDirectX8.BindTexture(const VParam:Cardinal;const VTexture:Cardinal);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.BindTexture'); {$ENDIF}
FNowTexture:=VTexture;
if (FArTextures<>nil) and (FNowTexture-1>=0) and (Length(FArTextures)>FNowTexture-1) and (FArTextures[FNowTexture-1].FTexture<>nil) then
	pDevice.SetTexture(FNowActiveNumberTexture, FArTextures[FNowTexture-1].FTexture);
end;

procedure TSRenderDirectX8.TexParameteri(const VP1,VP2,VP3:Cardinal);
//var Caps : D3DCAPS8;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.TexParameteri'); {$ENDIF}
{!!
if (VP1 = SR_TEXTURE_2D) or (VP1 = SR_TEXTURE_1D) then
	begin
	case VP2 of
	SR_TEXTURE_MIN_FILTER:
		case VP3 of
		SR_POINT:
			pDevice.SetSamplerState( FNowActiveNumberTexture, D3DSAMP_MINFILTER, D3DTEXF_POINT);
		SR_LINEAR:
			pDevice.SetSamplerState( FNowActiveNumberTexture, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
		SR_NEAREST:
			begin
			pDevice.GetDeviceCaps(Caps);
			if Caps.MaxAnisotropy > 0 then
				begin
				pDevice.SetSamplerState( FNowActiveNumberTexture, D3DSAMP_MINFILTER, D3DTEXF_ANISOTROPIC);
				pDevice.SetSamplerState( FNowActiveNumberTexture, D3DSAMP_MAXANISOTROPY, Caps.MaxAnisotropy);
				end
			else
				pDevice.SetSamplerState( FNowActiveNumberTexture, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
			end;
		end;
	SR_TEXTURE_MAG_FILTER:
		case VP3 of
		SR_POINT:
			pDevice.SetSamplerState( FNowActiveNumberTexture, D3DSAMP_MAGFILTER, D3DTEXF_POINT);
		SR_LINEAR:
			pDevice.SetSamplerState( FNowActiveNumberTexture, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
		SR_NEAREST:
			begin
			pDevice.GetDeviceCaps(Caps);
			if Caps.MaxAnisotropy > 0 then
				begin
				pDevice.SetSamplerState( FNowActiveNumberTexture, D3DSAMP_MAGFILTER, D3DTEXF_ANISOTROPIC);
				pDevice.SetSamplerState( FNowActiveNumberTexture, D3DSAMP_MAXANISOTROPY, Caps.MaxAnisotropy);
				end
			else
				pDevice.SetSamplerState( FNowActiveNumberTexture, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
			end;
		end;
	end;
	end;
}
end;

procedure TSRenderDirectX8.PixelStorei(const VParamName:Cardinal;const VParam:TSInt32);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.PixelStorei'); {$ENDIF}
end;

procedure TSRenderDirectX8.TexEnvi(const VP1,VP2,VP3:Cardinal);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.TexEnvi'); {$ENDIF}
end;

procedure TSRenderDirectX8.TexImage2D(const VTextureType:Cardinal;const VP1:Cardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:Cardinal;VBitMap:Pointer);
var
	VTFormat:LongWord;
	rcLockedRect:D3DLOCKED_RECT;

procedure RGBAToD3D_ARGB();inline;
type
	PLongWord = ^ LongWord;
var
	I,II:LongWord;
begin
i:=0;
ii:=VWidth*VHeight;
repeat
PLongWord(rcLockedRect.pBits)[i]:=D3DCOLOR_ARGB(
PByte(VBitMap)[i*VChannels+3],
PByte(VBitMap)[i*VChannels+0],
PByte(VBitMap)[i*VChannels+1],
PByte(VBitMap)[i*VChannels+2]);
i+=1;
until i=ii;
end;

procedure RGBToD3D_XRGB();inline;
type
	PLongWord = ^ LongWord;
var
	i,ii:LongWord;
begin
i:=0;
ii:=VWidth*VHeight;
repeat
PLongWord(rcLockedRect.pBits)[i]:=
	D3DCOLOR_XRGB(PByte(VBitMap)[i*3],PByte(VBitMap)[i*3+1],PByte(VBitMap)[i*3+2]);
i+=1;
until i=ii;
end;

begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.TexImage2D'); {$ENDIF}
VTFormat:=0;
case VFormatType of
SR_RGBA:VTFormat:=D3DFMT_A8R8G8B8;
SR_RGB:VTFormat:=D3DFMT_X8R8G8B8;//������ ��� ����� --- D3DFMT_R8G8B8;
SR_LUMINANCE_ALPHA:VTFormat:=D3DFMT_A8L8;
SR_RED:;
SR_INTENSITY:;
SR_ALPHA:VTFormat:=D3DFMT_A8;
SR_LUMINANCE:VTFormat:=D3DFMT_L8;
end;
FArTextures[FNowTexture-1].FWidth:=VWidth;
FArTextures[FNowTexture-1].FHeight:=VHeight;
FArTextures[FNowTexture-1].FChannels:=VChannels;
FArTextures[FNowTexture-1].FFormat:=VTFormat;
if pDevice.CreateTexture(VWidth,VHeight,VChannels,D3DUSAGE_DYNAMIC,VTFormat,D3DPOOL_DEFAULT,FArTextures[FNowTexture-1].FTexture) <> D3D_OK then
	SLog.Source('TSRenderDirectX8__TexImage2D : "IDirect3DDevice8__CreateTexture" failed...')
else
	begin
	fillchar(rcLockedRect,sizeof(rcLockedRect),0);
	if FArTextures[FNowTexture-1].FTexture.LockRect(0, rcLockedRect, nil, D3DLOCK_DISCARD or D3DLOCK_NOOVERWRITE) <> D3D_OK then
		SLog.Source('TSRenderDirectX8__TexImage2D : "IDirect3DTexture8__LockRect" failed...')
	else
		begin
		if (VTFormat=D3DFMT_A8R8G8B8) and (VFormatType=SR_RGBA) then
			begin
			RGBAToD3D_ARGB();
			end
		else if (VTFormat=D3DFMT_X8R8G8B8) and (VFormatType=SR_RGB) then
			begin
			RGBToD3D_XRGB();
			end
		else
			System.Move(VBitMap^,rcLockedRect.pBits^,VWidth*VHeight*VChannels);
		if FArTextures[FNowTexture-1].FTexture.UnlockRect(0) <> D3D_OK then
			SLog.Source('TSRenderDirectX8__TexImage2D : "IDirect3DTexture8__UnlockRect" failed...');
		end;
	end;
end;

procedure TSRenderDirectX8.ReadPixels(const x,y:Integer;const Vwidth,Vheight:Integer;const format, atype: Cardinal;const pixels: Pointer);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.ReadPixels'); {$ENDIF}
end;

procedure TSRenderDirectX8.CullFace(const VParam:Cardinal);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.CullFace'); {$ENDIF}
case VParam of
SR_BACK :pDevice.SetRenderState( D3DRS_CULLMODE, D3DCULL_CW );
SR_FRONT:pDevice.SetRenderState( D3DRS_CULLMODE, D3DCULL_CCW );
end;
end;

procedure TSRenderDirectX8.EnableClientState(const VParam:Cardinal);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.EnableClientState'); {$ENDIF}
case VParam of
SR_VERTEX_ARRAY:FEnabledClientStateVertex:=True;
SR_NORMAL_ARRAY:FEnabledClientStateNormal:=True;
SR_TEXTURE_COORD_ARRAY:FEnabledClientStateTexVertex:=True;
SR_COLOR_ARRAY:FEnabledClientStateColor:=True;
end;
end;

procedure TSRenderDirectX8.DisableClientState(const VParam:Cardinal);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.DisableClientState'); {$ENDIF}
case VParam of
SR_VERTEX_ARRAY:FEnabledClientStateVertex:=False;
SR_NORMAL_ARRAY:FEnabledClientStateNormal:=False;
SR_TEXTURE_COORD_ARRAY:FEnabledClientStateTexVertex:=False;
SR_COLOR_ARRAY:FEnabledClientStateColor:=False;
end;
end;

procedure TSRenderDirectX8.GenBuffersARB(const VQ:Integer;const PT:PCardinal);
var
	i:LongWord;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.GenBuffersARB'); {$ENDIF}
for i:=0 to VQ-1 do
	begin
	if FArBuffers=nil then
		SetLength(FArBuffers,1)
	else
		SetLength(FArBuffers,Length(FArBuffers)+1);
	FArBuffers[High(FArBuffers)].FResource:=nil;
	FArBuffers[High(FArBuffers)].FResourceSize:=0;
	//!!FArBuffers[High(FArBuffers)].FVertexDeclaration:=nil;
	FArBuffers[High(FArBuffers)].FBufferChangeFullscreen:=nil;
	FArBuffers[High(FArBuffers)].FType:=0;
	PT[i]:=Length(FArBuffers);
	end;
end;

procedure TSRenderDirectX8.SetToNullTexture(var Texture : IDirect3DTexture8);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
try
Texture := nil;
except
end;
end;

procedure TSRenderDirectX8.SetToNullResource(var Resource : IDirect3DResource8);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
try
Resource := nil;
except
end;
end;

procedure TSRenderDirectX8.DeleteBuffersARB(const VQuantity:LongWord;VPoint:Pointer);
var
	i:LongWord;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.DeleteBuffersARB'); {$ENDIF}
for i:=0 to VQuantity-1 do
	if FArBuffers[PLongWord(VPoint)[i]-1].FResource<>nil then
		begin
		SDestroyInterface(FArBuffers[PLongWord(VPoint)[i]-1].FResource);
		SetToNullResource(FArBuffers[PLongWord(VPoint)[i]-1].FResource);
		FArBuffers[PLongWord(VPoint)[i]-1].FResourceSize:=0;
		FArBuffers[PLongWord(VPoint)[i]-1].FType:=0;
		{!!
		if FArBuffers[PLongWord(VPoint)[i]-1].FVertexDeclaration<>nil then
			begin
			SDestroyInterface(FArBuffers[PLongWord(VPoint)[i]-1].FVertexDeclaration);
			if Self <> nil then
				FArBuffers[PLongWord(VPoint)[i]-1].FVertexDeclaration := nil;
			end;
		}
		PLongWord(VPoint)[i]:=0;
		end;
end;

procedure TSRenderDirectX8.BindBufferARB(const VParam:Cardinal;const VParam2:Cardinal);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.BindBufferARB'); {$ENDIF}
case VParam of
SR_ARRAY_BUFFER_ARB        :FVBOData[0]:=VParam2;
SR_ELEMENT_ARRAY_BUFFER_ARB:FVBOData[1]:=VParam2;
end;
end;

procedure TSRenderDirectX8.BufferDataARB(
	const VParam:Cardinal;   // SR_ARRAY_BUFFER_ARB or SR_ELEMENT_ARRAY_BUFFER_ARB
	const VSize:int64;       // ������ � ������
	VBuffer:Pointer;         // �����
	const VParam2:Cardinal;
	const VIndexPrimetiveType : TSLongWord = 0);
var
	VVBuffer:PByte = nil;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.BufferDataARB'); {$ENDIF}
if (VParam=SR_ARRAY_BUFFER_ARB) and (FVBOData[0]>0) then
	begin
	if pDevice.CreateVertexBuffer(VSize,0,0,D3DPOOL_DEFAULT,
		IDirect3DVertexBuffer8(Pointer(FArBuffers[FVBOData[0]-1].FResource))) <> D3D_OK then
		begin
		SLog.Source('TSRenderDirectX8__BufferDataARB : Failed to Create vertex buffer!');
		Exit;
		end
	else
		begin
		FArBuffers[FVBOData[0]-1].FType:=VParam;
		if (FArBuffers[FVBOData[0]-1].FResource as IDirect3DVertexBuffer8).Lock(0,VSize,VVBuffer,0)<>D3D_OK then
			begin
			SLog.Source('TSRenderDirectX8__BufferDataARB : Failed to Lock vertex buffer!');
			Exit;
			end
		else
			begin
			System.Move(VBuffer^,VVBuffer^,VSize);
			FArBuffers[FVBOData[0]-1].FResourceSize:=VSize;
			if (FArBuffers[FVBOData[0]-1].FResource as IDirect3DVertexBuffer8).UnLock()<>D3D_OK then
				begin
				SLog.Source('TSRenderDirectX8__BufferDataARB : Failed to UnLock vertex buffer!');
				Exit;
				end;
			//SLog.Source(['TSRenderDirectX8__BufferDataARB : Sucssesful create and lock data to ',FVBOData[0],' vertex buffer!']);
			end;
		end;
	end
else if (VParam=SR_ELEMENT_ARRAY_BUFFER_ARB) and (FVBOData[1]>0) then
	begin
	if pDevice.CreateIndexBuffer(VSize,0,
		TSByte(VIndexPrimetiveType=SR_UNSIGNED_SHORT)*D3DFMT_INDEX16+
		TSByte(VIndexPrimetiveType=SR_UNSIGNED_INT)*D3DFMT_INDEX32
		,D3DPOOL_DEFAULT,
		IDirect3DIndexBuffer8(Pointer(FArBuffers[FVBOData[1]-1].FResource))) <> D3D_OK then
		begin
		SLog.Source('TSRenderDirectX8__BufferDataARB : Failed to Create index buffer!');
		exit;
		end
	else
		begin
		FArBuffers[FVBOData[1]-1].FType:=VParam;
		if (FArBuffers[FVBOData[1]-1].FResource as IDirect3DIndexBuffer8).Lock(0,VSize,VVBuffer,0)<>D3D_OK then
			begin
			SLog.Source('TSRenderDirectX8__BufferDataARB : Failed to Lock index buffer!');
			Exit;
			end
		else
			begin
			System.Move(VBuffer^,VVBuffer^,VSize);
			FArBuffers[FVBOData[1]-1].FResourceSize:=VSize;
			if (FArBuffers[FVBOData[1]-1].FResource as IDirect3DIndexBuffer8).UnLock()<>D3D_OK then
				begin
				SLog.Source('TSRenderDirectX8__BufferDataARB : Failed to UnLock index buffer!');
				Exit;
				end;
			//SLog.Source(['TSRenderDirectX8__BufferDataARB : Sucssesful create and lock data to ',FVBOData[1],' indexes buffer!']);
			end;
		end;
	end
else SLog.Source('TSRenderDirectX8__BufferDataARB : Some params incorect!');
end;

procedure TSRenderDirectX8.DrawElements(
	const VParam:Cardinal;
	const VSize:int64;// �� � ������ � � 4*����
	const VParam2:Cardinal;
	VBuffer:Pointer);
//var VertexManipulator:TSRDXVertexDeclarationManipulator = nil;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.DrawElements'); {$ENDIF}
if (VBuffer<>nil) or (not FEnabledClientStateVertex) then
	Exit;
if (FArDataBuffers[SRDTypeDataBufferVertex].FVBOBuffer<>0) and (VBuffer=nil) then
	begin
	{!!
	if FArBuffers[FArDataBuffers[SRDTypeDataBufferVertex].FVBOBuffer-1].FVertexDeclaration = nil then
		begin
		VertexManipulator:=TSRDXVertexDeclarationManipulator.Create();
		if FEnabledClientStateVertex then
			VertexManipulator.AddElement(FArDataBuffers[SRDTypeDataBufferVertex].FShift,D3DDECLTYPE_FLOAT3,D3DDECLUSAGE_POSITION);
		if FEnabledClientStateColor then
			VertexManipulator.AddElement(FArDataBuffers[SRDTypeDataBufferColor].FShift,D3DDECLTYPE_D3DCOLOR,D3DDECLUSAGE_COLOR);
		if FEnabledClientStateNormal then
			VertexManipulator.AddElement(FArDataBuffers[SRDTypeDataBufferNormal].FShift,D3DDECLTYPE_FLOAT3,D3DDECLUSAGE_NORMAL);
		if FEnabledClientStateTexVertex then
			VertexManipulator.AddElement(FArDataBuffers[SRDTypeDataBufferTexVertex].FShift,D3DDECLTYPE_FLOAT2,D3DDECLUSAGE_TEXCOORD);
		//Create format of vertex
		FArBuffers[FArDataBuffers[SRDTypeDataBufferVertex].FVBOBuffer-1].FVertexDeclaration:=VertexManipulator.CreateVertexDeclaration(pDevice);
		VertexManipulator.Destroy();
		VertexManipulator:=nil;
		end;
	}
	pDevice.BeginScene();
	//Set format of vertex
	//!!pDevice.SetVertexDeclaration(FArBuffers[FArDataBuffers[SRDTypeDataBufferVertex].FVBOBuffer-1].FVertexDeclaration);
	//Set vertex buffer
	if pDevice.SetStreamSource(
		0,
		IDirect3DVertexBuffer8(Pointer(FArBuffers[FVBOData[0]-1].FResource)),
		//!!0,
		FArDataBuffers[SRDTypeDataBufferVertex].FSizeOfOneVertex
		) <> D3D_OK then
			SLog.Source('TSRenderDirectX8__DrawElements : SetStreamSource : Failed!!');
	//Set Index buffer
	if pDevice.SetIndices(IDirect3DIndexBuffer8(Pointer(FArBuffers[FVBOData[1]-1].FResource)),0) <> D3D_OK then
		SLog.Source('TSRenderDirectX8__DrawElements : SetIndices : Failed!!');
	//Draw
	if pDevice.DrawIndexedPrimitive(SRDXConvertPrimetiveType(VParam),0,0,
		FArBuffers[FArDataBuffers[SRDTypeDataBufferVertex].FVBOBuffer-1].FResourceSize div
		FArDataBuffers[SRDTypeDataBufferVertex].FSizeOfOneVertex
		,SRDXGetNumPrimetives(VParam,VSize))<>D3D_OK then
			SLog.Source('TSRenderDirectX8__DrawElements : DrawIndexedPrimitive : Draw Failed!!');
	pDevice.EndScene();
	end
else
	begin
	SLog.Source('TSRenderDirectX8__DrawElements : Draw indexed primitive without VBO not possible!');
	end;
end;

procedure TSRenderDirectX8.DrawArrays(const VParam:TSCardinal;const VFirst,VCount:TSLongWord);
var
	//VertexManipulator : TSRDXVertexDeclarationManipulator = nil;
	BeginArray:TSMaxEnum;
	VertexType:LongWord = D3DFVF_XYZ;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.DrawArrays'); {$ENDIF}
if not FEnabledClientStateVertex then
	Exit;

if FArDataBuffers[SRDTypeDataBufferVertex].FVBOBuffer=0 then
	begin
	BeginArray := FArDataBuffers[SRDTypeDataBufferVertex].FShift;
	if FEnabledClientStateColor and (BeginArray>FArDataBuffers[SRDTypeDataBufferColor].FShift) then
		BeginArray:=FArDataBuffers[SRDTypeDataBufferColor].FShift;
	if FEnabledClientStateNormal and (BeginArray>FArDataBuffers[SRDTypeDataBufferNormal].FShift) then
		BeginArray:=FArDataBuffers[SRDTypeDataBufferNormal].FShift;
	if FEnabledClientStateTexVertex and (BeginArray>FArDataBuffers[SRDTypeDataBufferTexVertex].FShift) then
		BeginArray:=FArDataBuffers[SRDTypeDataBufferTexVertex].FShift;

	if FEnabledClientStateColor then
		VertexType:=VertexType or D3DFVF_DIFFUSE;
	if FEnabledClientStateTexVertex then
		VertexType:=VertexType or D3DFVF_TEX1;
	if FEnabledClientStateNormal then
		VertexType:=VertexType or D3DFVF_NORMAL;
	pDevice.BeginScene();
	pDevice.SetVertexShader( VertexType );
	pDevice.DrawPrimitiveUP(SRDXConvertPrimetiveType(VParam),SRDXGetNumPrimetives(VParam,VCount),
		TSPointer(BeginArray+FArDataBuffers[SRDTypeDataBufferVertex].FSizeOfOneVertex*VFirst)^,
		FArDataBuffers[SRDTypeDataBufferVertex].FSizeOfOneVertex);
	pDevice.EndScene();
	end
else
	begin
	{!!
	if FArBuffers[FArDataBuffers[SRDTypeDataBufferVertex].FVBOBuffer-1].FVertexDeclaration = nil then
		begin
		VertexManipulator:=TSRDXVertexDeclarationManipulator.Create();
		if FEnabledClientStateVertex then
			VertexManipulator.AddElement(FArDataBuffers[SRDTypeDataBufferVertex].FShift,D3DDECLTYPE_FLOAT3,D3DDECLUSAGE_POSITION);
		if FEnabledClientStateColor then
			VertexManipulator.AddElement(FArDataBuffers[SRDTypeDataBufferColor].FShift,D3DDECLTYPE_D3DCOLOR,D3DDECLUSAGE_COLOR);
		if FEnabledClientStateNormal then
			VertexManipulator.AddElement(FArDataBuffers[SRDTypeDataBufferNormal].FShift,D3DDECLTYPE_FLOAT3,D3DDECLUSAGE_NORMAL);
		if FEnabledClientStateTexVertex then
			VertexManipulator.AddElement(FArDataBuffers[SRDTypeDataBufferTexVertex].FShift,D3DDECLTYPE_FLOAT2,D3DDECLUSAGE_TEXCOORD);
		//Create format of vertex
		FArBuffers[FArDataBuffers[SRDTypeDataBufferVertex].FVBOBuffer-1].FVertexDeclaration:=VertexManipulator.CreateVertexDeclaration(pDevice);
		VertexManipulator.Destroy();
		VertexManipulator:=nil;
		end;
	}
	pDevice.BeginScene();
	//Set format of vertex
	//!!pDevice.SetVertexDeclaration(FArBuffers[FArDataBuffers[SRDTypeDataBufferVertex].FVBOBuffer-1].FVertexDeclaration);
	//Set vertex buffer
	if pDevice.SetStreamSource(0,IDirect3DVertexBuffer8(Pointer(FArBuffers[FVBOData[0]-1].FResource)),FArDataBuffers[SRDTypeDataBufferVertex].FSizeOfOneVertex)<>D3D_OK then
		SLog.Source('TSRenderDirectX8__DrawArrays : SetStreamSource : Failed!!');
	//Set Index buffer
	if pDevice.SetIndices(nil,0) <> D3D_OK then
		SLog.Source('TSRenderDirectX8__DrawArrays : SetIndices(nil) : Failed!!');
	pDevice.DrawPrimitive(SRDXConvertPrimetiveType(VParam),VFirst,SRDXGetNumPrimetives(VParam,VCount));
	pDevice.EndScene();
	end;
end;

procedure TSRenderDirectX8.ColorPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.ColorPointer'); {$ENDIF}
FArDataBuffers[SRDTypeDataBufferColor].FQuantityParams:=VQChannels;
FArDataBuffers[SRDTypeDataBufferColor].FVBOBuffer:=FVBOData[0];
FArDataBuffers[SRDTypeDataBufferColor].FDataType:=VType;
FArDataBuffers[SRDTypeDataBufferColor].FSizeOfOneVertex:=VSize;
FArDataBuffers[SRDTypeDataBufferColor].FShift:=TSMaxEnum(VBuffer);
end;

procedure TSRenderDirectX8.TexCoordPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.TexCoordPointer'); {$ENDIF}
FArDataBuffers[SRDTypeDataBufferTexVertex].FQuantityParams:=VQChannels;
FArDataBuffers[SRDTypeDataBufferTexVertex].FVBOBuffer:=FVBOData[0];
FArDataBuffers[SRDTypeDataBufferTexVertex].FDataType:=VType;
FArDataBuffers[SRDTypeDataBufferTexVertex].FSizeOfOneVertex:=VSize;
FArDataBuffers[SRDTypeDataBufferTexVertex].FShift:=TSMaxEnum(VBuffer);
end;

procedure TSRenderDirectX8.NormalPointer(const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.NormalPointer'); {$ENDIF}
FArDataBuffers[SRDTypeDataBufferNormal].FQuantityParams:=3;
FArDataBuffers[SRDTypeDataBufferNormal].FVBOBuffer:=FVBOData[0];
FArDataBuffers[SRDTypeDataBufferNormal].FDataType:=VType;
FArDataBuffers[SRDTypeDataBufferNormal].FSizeOfOneVertex:=VSize;
FArDataBuffers[SRDTypeDataBufferNormal].FShift:=TSMaxEnum(VBuffer);
end;

procedure TSRenderDirectX8.VertexPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.VertexPointer'); {$ENDIF}
FArDataBuffers[SRDTypeDataBufferVertex].FQuantityParams:=VQChannels;
FArDataBuffers[SRDTypeDataBufferVertex].FVBOBuffer:=FVBOData[0];
FArDataBuffers[SRDTypeDataBufferVertex].FDataType:=VType;
FArDataBuffers[SRDTypeDataBufferVertex].FSizeOfOneVertex:=VSize;
FArDataBuffers[SRDTypeDataBufferVertex].FShift:=TSMaxEnum(VBuffer);
end;

function TSRenderDirectX8.IsEnabled(const VParam:Cardinal):Boolean;
begin
Result:=False;
end;

procedure TSRenderDirectX8.Clear(const VParam:Cardinal);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.Clear'); {$ENDIF}
pDevice.Clear( 0, nil, D3DCLEAR_TARGET or D3DCLEAR_ZBUFFER, FClearColor, 1.0, 0 );
end;

procedure TSRenderDirectX8.BeginScene(const VPrimitiveType:TSPrimtiveType);
const
	MyVertexType:LongWord = D3DFVF_XYZ or D3DFVF_NORMAL or D3DFVF_DIFFUSE  or D3DFVF_TEX1;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.BeginScene'); {$ENDIF}
FPrimetiveType:=VPrimitiveType;
FPrimetivePrt:=0;
FNumberOfPoints:=0;
pDevice.BeginScene();
pDevice.SetVertexShader( MyVertexType );
end;

procedure TSRenderDirectX8.EndScene();
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.EndScene'); {$ENDIF}
if (FPrimetiveType=SR_LINE_LOOP) and (FNumberOfPoints=1) and (FPrimetivePrt=1) then
	begin
	pDevice.DrawPrimitiveUP( D3DPT_LINELIST, 1, FArPoints[1], sizeof(FArPoints[0]));
	end;
pDevice.EndScene();
end;

procedure TSRenderDirectX8.Init();
//var VectorDir:D3DXVECTOR3;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.Init'); {$ENDIF}
FNowColor:=D3DCOLOR_ARGB(255,255,255,255);
FClearColor:=D3DCOLOR_COLORVALUE(0.0,0.0,0.0,1.0);
FNowTexture:=0;
FNowActiveNumberTexture:=0;
FNowActiveClientNumberTexture:=0;

//==========�������� Z-�����
pDevice.SetRenderState(D3DRS_ZENABLE, 1);

//==========������������� ��������
(*�������!*)
{Diffuse - ������������ ����.
 Ambient - ������� ����.
 Specular - ���������� ����.
 Emissive - ����������� �������� �������.
 Power - �������� ���������.}
FillChar(FMaterial,SizeOf(FMaterial),0);
FMaterial.Diffuse:=SRDXGetD3DCOLORVALUE(1,1,1,1);
FMaterial.Ambient:=SRDXGetD3DCOLORVALUE(0,0,0,0);
FMaterial.Specular:=SRDXGetD3DCOLORVALUE(0.4,0.4,0.4,1);
FMaterial.Emissive:=SRDXGetD3DCOLORVALUE(0,0,0,0);
FMaterial.Power:=2;
pDevice.SetMaterial(FMaterial);

//=========������������� ���������
FillChar(FLigth,SizeOf(FLigth),0);
FLigth._Type:=D3DLIGHT_POINT;
FLigth.Diffuse:=SRDXGetD3DCOLORVALUE(1,1,1,1);
FLigth.Ambient:=SRDXGetD3DCOLORVALUE(0.5,0.5,0.5,1.0);
FLigth.Specular:=SRDXGetD3DCOLORVALUE(1.0,1.0,1.0,1.0);
// ������ ����������, �� ������� ���������� ���������, ������ �� ������.
FLigth.Range := TSRenderFar;
// ����������� (������ ��� directional and spotlights)
{FLigth.Direction.x:=0;
 FLigth.Direction.y:=1;
 FLigth.Direction.z:=0;}
pDevice.SetLight(0, FLigth);
pDevice.LightEnable(0, True);
pDevice.SetRenderState(D3DRS_LIGHTING,1);
pDevice.SetRenderState(D3DRS_AMBIENT, 0);
//��������� ����
pDevice.SetRenderState(D3DRS_LIGHTING,0);

//========��������� �������
//�������� ���������� ����� �� �������� RGB �������
pDevice.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE);
pDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
pDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
//��������� ALPHA ������������ ��������(�������� ���������� ������������ �� Alpha ������)
pDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);

//============������������
pDevice.SetRenderState( D3DRS_ALPHABLENDENABLE, 1);
pDevice.SetRenderState( D3DRS_SRCBLEND, D3DBLEND_SRCALPHA );
pDevice.SetRenderState( D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA );

//===========CULL FACE
//����� ���������� ��� ���������, � �� ������ ��, � �������
//������� ���������� � ������� ������
pDevice.SetRenderState( D3DRS_CULLMODE, D3DCULL_NONE );

//===================�����������
//pDevice.SetRenderState(D3DRS_MULTISAMPLEANTIALIAS,1);
//���� ��� ������ �����, ����� ������� ���������� �� ����� ���������
//pDevice.SetRenderState(D3DRS_ANTIALIASEDLINEENABLE,1);

//========�������� ���������� �������
//!!pDevice.SetSamplerState( 0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
//!!pDevice.SetSamplerState( 0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
//�� MIP �������� � ������� ��������� ��������
//pDevice.SetSamplerState( 0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);

//========T�������� ���������� �������
(*pDevice.SetSamplerState( 0, D3DSAMP_MINFILTER, D3DTEXF_POINT);
pDevice.SetSamplerState( 0, D3DSAMP_MAGFILTER, D3DTEXF_POINT);*)

//=========������������ ���������� �������
(*pDevice.SetSamplerState(0,D3DSAMP_MAGFILTER,D3DTEXF_ANISOTROPIC);
pDevice.SetSamplerState(0,D3DSAMP_MINFILTER,D3DTEXF_ANISOTROPIC);
pDevice.SetSamplerState(0, D3DSAMP_MAXANISOTROPY, 4);*)

//========������ ����������� �������
//(����� ��� �������� ������� �������������� ��������� �������, ������� ����������)
//!!pDevice.SetSamplerState(0,D3DSAMP_MIPFILTER,D3DTEXF_NONE);
//pDevice.SetSamplerState(0,D3DSAMP_MIPFILTER,D3DTEXF_POINT);
//pDevice.SetSamplerState(0,D3DSAMP_MIPFILTER,D3DTEXF_LINEAR);

//=====������� ��������� �������
//�������� �������
//pDevice.SetRenderState(D3DRS_SHADEMODE, D3DSHADE_FLAT);
//������� �� ������ ���� (����������)
pDevice.SetRenderState(D3DRS_SHADEMODE, D3DSHADE_GOURAUD);
end;

constructor TSRenderDirectX8.Create();
begin
inherited Create();
D3DX8Loaded := DllManager.Supported('Direct3DX8');
FNowActiveNumberTexture:=0;
FNowActiveClientNumberTexture:=0;
SetRenderType(SRenderDirectX8);
FArTextures:=nil;
pDevice:=nil;
pD3D:=nil;
FArBuffers:=nil;
FEnabledClientStateVertex:=False;
FEnabledClientStateColor:=False;
FEnabledClientStateNormal:=False;
FEnabledClientStateTexVertex:=False;
FVBOData[0]:=0;
FVBOData[1]:=0;
FillChar(FArDataBuffers,SizeOf(FArDataBuffers),0);
FArSavedMatrix:=nil;
FQuantitySavedMatrix:=0;
FLengthArSavedMatrix:=0;
end;

procedure TSRenderDirectX8.DropDeviceResources();
var
	i : TSLongWord;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.DropDeviceResources'); {$ENDIF}
if FArBuffers<>nil then if Length(FArBuffers)>0 then
	begin
	for i:=0 to High(FArBuffers) do
		begin
		if FArBuffers[i].FResource<>nil then
			begin
			SDestroyInterface(FArBuffers[i].FResource);
			SetToNullResource(FArBuffers[i].FResource);
			end;
		{!!if FArBuffers[i].FVertexDeclaration<>nil then
			begin
			SDestroyInterface(FArBuffers[i].FVertexDeclaration);
			if Self <> nil then
				FArBuffers[i].FVertexDeclaration := nil;
			end;}
		end;
	SetLength(FArBuffers, 0);
	FArBuffers := nil;
	end;
if FArTextures <> nil then if Length(FArTextures) > 0 then
	begin
	for i:=0 to High(FArTextures) do
		begin
		if FArTextures[i].FTexture<>nil then
			begin
			SDestroyInterface(FArTextures[i].FTexture);
			SetToNullTexture(FArTextures[i].FTexture);
			end;
		if FArTextures[i].FBufferChangeFullscreen <> nil then
			begin
			FreeMem(FArTextures[i].FBufferChangeFullscreen);
			FArTextures[i].FBufferChangeFullscreen := nil;
			end;
		end;
	SetLength(FArTextures, 0);
	FArTextures := nil;
	end;
end;

procedure TSRenderDirectX8.Kill();
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.Kill'); {$ENDIF}
DropDeviceResources();
if (pDevice<>nil)  then
	begin
	SDestroyInterface(pDevice);
	if Self <> nil then
		TSPointer(pDevice) := nil;
	end;
if (pD3d <> nil) then
	begin
	SDestroyInterface(pD3d);
	if Self <> nil then
		TSPointer(pD3d) := nil;
	end;
end;

destructor TSRenderDirectX8.Destroy();
begin
Kill();
inherited Destroy();
{$IFDEF RENDER_DX8_DEBUG}
	WriteLn('TSRenderDirectX8.Destroy(): End');
	{$ENDIF}
end;

procedure TSRenderDirectX8.InitOrtho2d(const x0,y0,x1,y1:TSSingle);
var
	Matrix1,Matrix2:D3DMATRIX;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.InitOrtho2d'); {$ENDIF}
if D3DX8Loaded then
	begin
	if x0<x1 then
		if y0<y1 then
			D3DXMatrixOrthoLH(Matrix1,Abs(x1-x0),Abs(y1-y0),-0.001,0.1)
		else
			D3DXMatrixOrthoLH(Matrix1,Abs(x1-x0),-Abs(y1-y0),-0.001,0.1)
	else
		if y0<y1 then
			D3DXMatrixOrthoLH(Matrix1,-Abs(x1-x0),Abs(y1-y0),-0.001,0.1)
		else
			D3DXMatrixOrthoLH(Matrix1,-Abs(x1-x0),-Abs(y1-y0),-0.001,0.1);
	D3DXMatrixTranslation(Matrix2,-(x0+x1)/2,-(y0+y1)/2,0);
	end
else
	begin
	Matrix2 := D3DMATRIX(SIdentityMatrix());
	Matrix1 := D3DMATRIX(SGetOrthoMatrix(x0,x1,y0,y1,0,0.1));
	end;
pDevice.SetTransform(D3DTS_PROJECTION, Matrix1);
pDevice.SetTransform(D3DTS_VIEW, Matrix2);

FNowMatrixMode:=D3DTS_WORLD;
LoadIdentity();
FNowMatrixMode:=D3DTS_VIEW;
end;

procedure TSRenderDirectX8.MatrixMode(const Par:TSLongWord);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.MatrixMode'); {$ENDIF}
case Par of
SR_PROJECTION:
	FNowMatrixMode:=D3DTS_PROJECTION;
SR_MODELVIEW:
	FNowMatrixMode:=D3DTS_VIEW;
else
	FNowMatrixMode:=D3DTS_WORLD;
end;
end;

procedure TSRenderDirectX8.InitMatrixMode(const Mode:TSMatrixMode = S_3D; const dncht : TSFloat = 1);
var
	Matrix, Matrix1, Matrix2 : D3DMATRIX;
var
	CWidth, CHeight : TSLongWord;
{$IFDEF RENDER_DX8_DEBUG_LINK}
function StrMatrixMode() : TSString;
begin
case Mode of
S_3D : Result := 'S_3D';
S_3D_ORTHO : Result := 'S_3D_ORTHO';
S_2D : Result := 'S_2D';
else
	Result := '';
end;
end;
{$ENDIF}
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.InitMatrixMode - Begin, Mode = "' + StrMatrixMode() +'"'); {$ENDIF}
CWidth := Width;
CHeight := Height;
FNowMatrixMode:=D3DTS_WORLD;
LoadIdentity();
FNowMatrixMode:=D3DTS_VIEW;
LoadIdentity();
if Mode=S_3D then
	begin
	Matrix:=D3DMATRIX(SGetPerspectiveMatrix(45,CWidth/CHeight,TSRenderNear,TSRenderFar));
	pDevice.SetTransform(D3DTS_PROJECTION, Matrix);
	Enable(SR_DEPTH_TEST);
	end
else if Mode=S_3D_ORTHO then
	if D3DX8Loaded then
		begin
		D3DXMatrixOrthoLH(Matrix1,D3DX_PI/4*dncht*30,D3DX_PI/4*dncht*30/CWidth*CHeight,TSRenderNear,TSRenderFar);
		D3DXMatrixScaling(Matrix2,1,1,-1);
		D3DXMatrixMultiply(Matrix,Matrix1,Matrix2);
		pDevice.SetTransform(D3DTS_PROJECTION, Matrix);
		Enable(SR_DEPTH_TEST);
		end
	else
		begin
		Matrix := (D3DMATRIX(SGetOrthoMatrix(
			-(CWidth / (1/dncht*120)),
			CWidth / (1/dncht*120),
			-CHeight / (1/dncht*120),
			(CHeight / (1/dncht*120)),
			TSRenderNear,
			TSRenderFar)));
		pDevice.SetTransform(D3DTS_PROJECTION, Matrix);
		Enable(SR_DEPTH_TEST);
		end
else if Mode=S_2D then
	if D3DX8Loaded then
		begin
		D3DXMatrixOrthoLH(Matrix1,CWidth,-CHeight,-0.001,0.1);
		D3DXMatrixTranslation(Matrix2,-CWidth/2,-CHeight/2,0);
		D3DXMatrixMultiply(Matrix,Matrix2,Matrix1);
		pDevice.SetTransform(D3DTS_PROJECTION, Matrix);
		Disable(SR_DEPTH_TEST);
		end
	else
		begin
		Matrix1 := D3DMATRIX(SGetOrthoMatrix(0, CWidth,CHeight,0,-0.001,0.1));
		pDevice.SetTransform(D3DTS_PROJECTION, Matrix1);
		Disable(SR_DEPTH_TEST);
		end;
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.InitMatrixMode - End'); {$ENDIF}
end;

procedure TSRenderDirectX8.Viewport(const a,b,c,d:TSAreaInt);
begin

end;

procedure TSRenderDirectX8.LoadIdentity();
var
	Matrix:D3DMATRIX;
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.LoadIdentity - Begin'); {$ENDIF}
if D3DX8Loaded then
	D3DXMatrixIdentity(Matrix)
else
	Matrix := D3DMATRIX(SIdentityMatrix());
pDevice.SetTransform(FNowMatrixMode,Matrix);
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.LoadIdentity - End'); {$ENDIF}
end;


procedure TSRenderDirectX8.Vertex3fv(const Variable : TSPointer);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.Vertex3fv'); {$ENDIF}
FArPoints[FNumberOfPoints].Color:=FNowColor;
System.Move(FNowNormal,FArPoints[FNumberOfPoints].Normalx,3*SizeOf(TSSingle));
System.Move(Variable^,FArPoints[FNumberOfPoints].x,SizeOf(TSSingle)*3);
FNumberOfPoints+=1;
AfterVertexProc();
end;

procedure TSRenderDirectX8.Normal3f(const x,y,z:single);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.Normal3f'); {$ENDIF}
FNowNormal.x:=x;
FNowNormal.y:=y;
FNowNormal.z:=z;
end;

procedure TSRenderDirectX8.Normal3fv(const Variable : TSPointer);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.Normal3fv'); {$ENDIF}
System.Move(Variable^,FNowNormal,3*SizeOf(TSSingle));
end;

procedure TSRenderDirectX8.Vertex3f(const x,y,z:single);
begin
{$IFDEF RENDER_DX8_DEBUG_LINK} SHint('DX8_Debug_Linck' + 'TSRenderDirectX8.Vertex3f'); {$ENDIF}
FArPoints[FNumberOfPoints].Color:=FNowColor;
System.Move(FNowNormal,FArPoints[FNumberOfPoints].Normalx,3*SizeOf(TSSingle));
FArPoints[FNumberOfPoints].x:=x;
FArPoints[FNumberOfPoints].y:=y;
FArPoints[FNumberOfPoints].z:=z;
FNumberOfPoints+=1;
AfterVertexProc();
end;


function TSRenderDirectX8.CreateContext():Boolean;
var
	d3dpp                 : D3DPRESENT_PARAMETERS;
	D3DFMT_List : array[0..7] of TSMaxEnum = (
		D3DFMT_UNKNOWN,
		D3DFMT_D15S1,
		D3DFMT_D16_LOCKABLE,
		D3DFMT_D16,
		D3DFMT_D24X8,
		D3DFMT_D24S8,
		D3DFMT_D24X4S4,
		D3DFMT_D32
		);
	D3DMULTISAMPLE_List : array[0..15] of D3DMULTISAMPLE_TYPE = (
		D3DMULTISAMPLE_NONE,
		D3DMULTISAMPLE_2_SAMPLES,
		D3DMULTISAMPLE_3_SAMPLES,
		D3DMULTISAMPLE_4_SAMPLES,
		D3DMULTISAMPLE_5_SAMPLES,
		D3DMULTISAMPLE_6_SAMPLES,
		D3DMULTISAMPLE_7_SAMPLES,
		D3DMULTISAMPLE_8_SAMPLES,
		D3DMULTISAMPLE_9_SAMPLES,
		D3DMULTISAMPLE_10_SAMPLES,
		D3DMULTISAMPLE_11_SAMPLES,
		D3DMULTISAMPLE_12_SAMPLES,
		D3DMULTISAMPLE_13_SAMPLES,
		D3DMULTISAMPLE_14_SAMPLES,
		D3DMULTISAMPLE_15_SAMPLES,
		D3DMULTISAMPLE_16_SAMPLES );

function D3DMULTISAMPLE_Str(const MS : D3DMULTISAMPLE_TYPE):TSString;
begin
case MS of
D3DMULTISAMPLE_NONE       : Result := 'D3DMULTISAMPLE_NONE';
D3DMULTISAMPLE_2_SAMPLES  : Result := 'D3DMULTISAMPLE_2_SAMPLES';
D3DMULTISAMPLE_3_SAMPLES  : Result := 'D3DMULTISAMPLE_3_SAMPLES';
D3DMULTISAMPLE_4_SAMPLES  : Result := 'D3DMULTISAMPLE_4_SAMPLES';
D3DMULTISAMPLE_5_SAMPLES  : Result := 'D3DMULTISAMPLE_5_SAMPLES';
D3DMULTISAMPLE_6_SAMPLES  : Result := 'D3DMULTISAMPLE_6_SAMPLES';
D3DMULTISAMPLE_7_SAMPLES  : Result := 'D3DMULTISAMPLE_7_SAMPLES';
D3DMULTISAMPLE_8_SAMPLES  : Result := 'D3DMULTISAMPLE_8_SAMPLES';
D3DMULTISAMPLE_9_SAMPLES  : Result := 'D3DMULTISAMPLE_9_SAMPLES';
D3DMULTISAMPLE_10_SAMPLES : Result := 'D3DMULTISAMPLE_10_SAMPLES';
D3DMULTISAMPLE_11_SAMPLES : Result := 'D3DMULTISAMPLE_11_SAMPLES';
D3DMULTISAMPLE_12_SAMPLES : Result := 'D3DMULTISAMPLE_12_SAMPLES';
D3DMULTISAMPLE_13_SAMPLES : Result := 'D3DMULTISAMPLE_13_SAMPLES';
D3DMULTISAMPLE_14_SAMPLES : Result := 'D3DMULTISAMPLE_14_SAMPLES';
D3DMULTISAMPLE_15_SAMPLES : Result := 'D3DMULTISAMPLE_15_SAMPLES';
D3DMULTISAMPLE_16_SAMPLES : Result := 'D3DMULTISAMPLE_16_SAMPLES';
end;
end;

function D3DFMT_Str(const FMT : TSMaxEnum) : TSString;
begin
case FMT of
D3DFMT_UNKNOWN       : Result := 'D3DFMT_UNKNOWN';
D3DFMT_D15S1         : Result := 'D3DFMT_D15S1';
D3DFMT_D16_LOCKABLE  : Result := 'D3DFMT_D16_LOCKABLE';
D3DFMT_D16           : Result := 'D3DFMT_D16';
D3DFMT_D24X8         : Result := 'D3DFMT_D24X8';
D3DFMT_D24S8         : Result := 'D3DFMT_D24S8';
D3DFMT_D24X4S4       : Result := 'D3DFMT_D24X4S4';
D3DFMT_D32           : Result := 'D3DFMT_D32';
end;
end;

var
	i, ii : TSByte;
begin
if (pD3D = nil) then
	begin
	pD3D := Direct3DCreate8( D3D_SDK_VERSION );
	SLog.Source(['TSRenderDirectX8__CreateContext : IDirect3D8 = ',SAddrStr(pD3D)]);
	if pD3d = nil then
		begin
		Result:=False;
		exit;
		end;
	end;
if pDevice = nil then
	begin
	Result := False;
	for i := High(D3DFMT_List) downto Low(D3DFMT_List) do
		begin
		for ii := High(D3DMULTISAMPLE_List) downto Low(D3DMULTISAMPLE_List) do
			begin
			FillChar(d3dpp,SizeOf(d3dpp),0);
			d3dpp.Windowed               := True;
			d3dpp.SwapEffect             := D3DSWAPEFFECT_DISCARD;
			d3dpp.hDeviceWindow          := TSMaxEnum(Context.Window);
			d3dpp.BackBufferCount        := 1;
			d3dpp.BackBufferFormat       := D3DFMT_X8R8G8B8;
			d3dpp.BackBufferWidth        := Context.Width;
			d3dpp.BackBufferHeight       := Context.Height;
			d3dpp.EnableAutoDepthStencil := True;
			d3dpp.AutoDepthStencilFormat := D3DFMT_List[i];
			d3dpp.MultiSampleType        := D3DMULTISAMPLE_List[ii];

			if( 0 <> ( pD3d.CreateDevice( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, TSMaxEnum(Context.Window),
					D3DCREATE_SOFTWARE_VERTEXPROCESSING, d3dpp, pDevice))) then
				begin
				{$IFDEF RENDER_DX8_DEBUG}
				SLog.Source(['TSRenderDirectX8__CreateContext : Failed create device with: DepthFormat = '+D3DFMT_Str(d3dpp.AutoDepthStencilFormat)+', MultiSampleType = ',D3DMULTISAMPLE_Str(d3dpp.MultiSampleType)]);
				{$ENDIF}
				end
			else
				break;
			end;
		if pDevice <> nil then
			break;
		end;
	if pDevice <> nil then
		begin
		SLog.Source(['TSRenderDirectX8__CreateContext : IDirect3DDevice8 = ',SAddrStr(pDevice),', DepthFormat = '+D3DFMT_Str(d3dpp.AutoDepthStencilFormat)+', MultiSampleType = ',D3DMULTISAMPLE_Str(d3dpp.MultiSampleType)]);
		Result := True;
		end
	else
		begin
		SLog.Source(['TSRenderDirectX8__CreateContext : Failed create device with anything params...']);
		end;
	end
else
	begin
	SDestroyInterface(pDevice);
	if Self <> nil then
		pDevice:=nil;
	Result := CreateContext();
	end;
end;

procedure TSRenderDirectX8.ReleaseCurrent();
begin
if (pDevice <> nil) then
	begin
	SDestroyInterface(pDevice);
	if Self <> nil then
		TSPointer(pDevice) := nil;
	end;
end;

function TSRenderDirectX8.SetPixelFormat():Boolean;overload;
begin
Result:=True;
end;

function TSRenderDirectX8.MakeCurrent():Boolean;
begin
Result := False;
if Context.Window <> nil then
	if ((pD3D=nil) and (pDevice=nil)) or ((pD3D<>nil) and (pDevice=nil)) then
		begin
		Result := CreateContext();
		if Result then
			Init();
		end;
end;

// ���������� �������� ������� � �������� ������ �������
procedure TSRenderDirectX8.LockResources();
var
	// �������
	i:TSMaxEnum;
	//�����
	VVBuffer: PByte = nil;
	// ��� Lock �������
	rcLockedRect:D3DLOCKED_RECT;

function GetRealChannels(const Format,Channels:TSLongWord):TSLongWord;inline;
begin
if (Format=D3DFMT_X8R8G8B8) then
	Result:=4
else
	Result:=Channels;
end;

begin
SLog.Source('TSRenderDirectX8__LockResources : Entering!');
if FArTextures<>nil then
	begin
	//SLog.Source('TSRenderDirectX8__LockResources : Begin to lock textures!');
	for i:=0 to High(FArTextures) do
		begin
		if (FArTextures[i].FTexture<>nil) then
			begin
			//SLog.Source('TSRenderDirectX8__LockResources : Begin to lock texture "'+SStr(i)+'"!');
			FillChar(rcLockedRect,SizeOf(rcLockedRect),0);
			if FArTextures[i].FTexture.LockRect(0, rcLockedRect, nil, D3DLOCK_READONLY) <> D3D_OK then
				begin
				SLog.Source('TSRenderDirectX8__LockResources : Errior while IDirect3DTexture8__LockRect');
				end
			else
				begin
				System.GetMem(VVBuffer,FArTextures[i].FWidth*FArTextures[i].FHeight*GetRealChannels(FArTextures[i].FFormat,FArTextures[i].FChannels));
				System.Move(rcLockedRect.pBits^,VVBuffer^,FArTextures[i].FWidth*FArTextures[i].FHeight*GetRealChannels(FArTextures[i].FFormat,FArTextures[i].FChannels));
				FArTextures[i].FBufferChangeFullscreen:=VVBuffer;
				VVBuffer:=nil;
				if FArTextures[i].FTexture.UnlockRect(0) <> D3D_OK then
					begin
					SLog.Source('TSRenderDirectX8__LockResources : Errior while IDirect3DTexture8__UnlockRect');
					end;
				end;
			SDestroyInterface(FArTextures[i].FTexture);
			if Self <> nil then
				FArTextures[i].FTexture:=nil;
			end;
		end;
	end;
if FArBuffers<>nil then
	begin
	for i:=0 to High(FArBuffers) do
		if (FArBuffers[i].FResource<>nil) and (FArBuffers[i].FType<>0) then
			begin
			{!!if FArBuffers[i].FVertexDeclaration <> nil then
				begin
				SDestroyInterface(FArBuffers[i].FVertexDeclaration);
				if Self <> nil then
					FArBuffers[i].FVertexDeclaration:=nil;
				end;}
			//SLog.Source('TSRenderDirectX8__LockResources : Begin to lock buffer "'+SStr(i)+'"!');
			if FArBuffers[i].FType=SR_ELEMENT_ARRAY_BUFFER_ARB then
				begin
				if (FArBuffers[i].FResource as IDirect3DIndexBuffer8).Lock(0,FArBuffers[i].FResourceSize,VVBuffer,0)<>D3D_OK then
					begin
					SLog.Source('TSRenderDirectX8__LockResources : Errior while IDirect3DIndexBuffer8__Lock');
					end
				else
					begin
					System.GetMem(FArBuffers[i].FBufferChangeFullscreen,FArBuffers[i].FResourceSize);
					System.Move(VVBuffer^,FArBuffers[i].FBufferChangeFullscreen^,FArBuffers[i].FResourceSize);
					if (FArBuffers[i].FResource as IDirect3DIndexBuffer8).UnLock()<>D3D_OK then
						begin
						SLog.Source('TSRenderDirectX8__LockResources : Errior while IDirect3DIndexBuffer8__UnLock');
						if VVBuffer<>nil then
							FreeMem(VVBuffer);
						end;
					VVBuffer:=nil;
					end;
				end
			else if FArBuffers[i].FType=SR_ARRAY_BUFFER_ARB then
				begin
				if (FArBuffers[i].FResource as IDirect3DVertexBuffer8).Lock(0,FArBuffers[i].FResourceSize,VVBuffer,0)<>D3D_OK then
					begin
					SLog.Source('TSRenderDirectX8__LockResources : Errior while IDirect3DIndexBuffer8__Lock');
					end
				else
					begin
					System.GetMem(FArBuffers[i].FBufferChangeFullscreen,FArBuffers[i].FResourceSize);
					System.Move(VVBuffer^,FArBuffers[i].FBufferChangeFullscreen^,FArBuffers[i].FResourceSize);
					if (FArBuffers[i].FResource as IDirect3DVertexBuffer8).UnLock()<>D3D_OK then
						begin
						SLog.Source('TSRenderDirectX8__LockResources : Errior while IDirect3DIndexBuffer8__UnLock');
						if VVBuffer<>nil then
							FreeMem(VVBuffer);
						end;
					VVBuffer:=nil;
					end;
				end;
			SDestroyInterface(FArBuffers[i].FResource);
			if Self <> nil then
				FArBuffers[i].FResource:=nil;
			end;
	end;
SLog.Source('TSRenderDirectX8__LockResources : Leaving!');
end;

// ������������� ������� � �������� ����������� ��������
procedure TSRenderDirectX8.UnLockResources();
var
	i:TSMaxEnum;
	//�����
	VVBuffer: PByte = nil;
	// ��� Lock �������
	rcLockedRect:D3DLOCKED_RECT;

function GetRealChannels(const Format,Channels:TSLongWord):TSLongWord;inline;
begin
if (Format=D3DFMT_X8R8G8B8) then
	Result:=4
else
	Result:=Channels;
end;

begin
SLog.Source('TSRenderDirectX8__UnLockResources : Entering!');
if FArTextures<>nil then
	begin
	for i:=0 to High(FArTextures) do
		if (FArTextures[i].FBufferChangeFullscreen<>nil) then
			begin
			if pDevice.CreateTexture(FArTextures[i].FWidth,FArTextures[i].FHeight,FArTextures[i].FChannels,
					D3DUSAGE_DYNAMIC,FArTextures[i].FFormat,D3DPOOL_DEFAULT,FArTextures[i].FTexture)<> D3D_OK then
				begin
				SLog.Source('TSRenderDirectX8__UnLockResources : Errior while IDirect3DDevice8__CreateTexture');
				end
			else
				begin
				FillChar(rcLockedRect,SizeOf(rcLockedRect),0);
				if FArTextures[i].FTexture.LockRect(0, rcLockedRect, nil, D3DLOCK_DISCARD or D3DLOCK_NOOVERWRITE) <> D3D_OK then
					begin
					SLog.Source('TSRenderDirectX8__UnLockResources : Errior while IDirect3DTexture8__LockRect');
					end
				else
					begin
					System.Move(FArTextures[i].FBufferChangeFullscreen^,rcLockedRect.pBits^,
						FArTextures[i].FWidth*FArTextures[i].FHeight*GetRealChannels(FArTextures[i].FFormat,FArTextures[i].FChannels));
					System.FreeMem(FArTextures[i].FBufferChangeFullscreen);
					FArTextures[i].FBufferChangeFullscreen:=nil;
					if FArTextures[i].FTexture.UnlockRect(0) <> D3D_OK then
						begin
						SLog.Source('TSRenderDirectX8__UnLockResources : Errior while IDirect3DTexture8__UnlockRect');
						end;
					end;
				end;
			end;
	end;
if FArBuffers<>nil then
	begin
	for i:=0 to High(FArBuffers) do
		if FArBuffers[i].FBufferChangeFullscreen<>nil then
			begin
			case FArBuffers[i].FType of
			SR_ARRAY_BUFFER_ARB:
				begin
				if pDevice.CreateVertexBuffer(FArBuffers[i].FResourceSize,0,0,D3DPOOL_DEFAULT,
					IDirect3DVertexBuffer8(Pointer(FArBuffers[i].FResource))) <> D3D_OK then
					begin
					SLog.Source('TSRenderDirectX8__BufferDataARB : Failed to Create vertex buffer!');
					end
				else
					begin
					if (FArBuffers[i].FResource as IDirect3DVertexBuffer8).Lock(0,FArBuffers[i].FResourceSize,VVBuffer,0)<>D3D_OK then
						begin
						SLog.Source('TSRenderDirectX8__BufferDataARB : Failed to Lock vertex buffer!');
						end
					else
						begin
						System.Move(FArBuffers[i].FBufferChangeFullscreen^,VVBuffer^,FArBuffers[i].FResourceSize);
						System.FreeMem(FArBuffers[i].FBufferChangeFullscreen);
						FArBuffers[i].FBufferChangeFullscreen:=nil;
						if (FArBuffers[i].FResource as IDirect3DVertexBuffer8).UnLock()<>D3D_OK then
							begin
							SLog.Source('TSRenderDirectX8__BufferDataARB : Failed to UnLock vertex buffer!');
							end;
						end;
					end;
				end;
			SR_ELEMENT_ARRAY_BUFFER_ARB:
				begin
				if pDevice.CreateIndexBuffer(FArBuffers[i].FResourceSize,0,D3DFMT_INDEX16,D3DPOOL_DEFAULT,
						IDirect3DIndexBuffer8(Pointer(FArBuffers[i].FResource))) <> D3D_OK then
					begin
					SLog.Source('TSRenderDirectX8__UnLockResources : Errior while IDirect3DDevice8__CreateIndexBuffer');
					end
				else
					begin
					if (FArBuffers[i].FResource as IDirect3DIndexBuffer8).Lock(0,FArBuffers[i].FResourceSize,VVBuffer,0)<>D3D_OK then
						begin
						SLog.Source('TSRenderDirectX8__UnLockResources : Failed to Lock index buffer!');
						end
					else
						begin
						System.Move(FArBuffers[i].FBufferChangeFullscreen^,VVBuffer^,FArBuffers[i].FResourceSize);
						System.FreeMem(FArBuffers[i].FBufferChangeFullscreen);
						FArBuffers[i].FBufferChangeFullscreen:=nil;
						if (FArBuffers[i].FResource as IDirect3DIndexBuffer8).UnLock()<>D3D_OK then
							begin
							SLog.Source('TSRenderDirectX8__UnLockResources : Failed to UnLock index buffer!');
							end;
						end;
					end;
				end;
			end;
			end;
	end;
SLog.Source('TSRenderDirectX8__UnLockResources : Leaving!');
end;

end.
