{$INCLUDE SaGe.inc}

//{$DEFINE RENDER_DX9_DEBUG}

unit SaGeRenderDirectX9;

interface

uses
	// Engine
	 SaGeBase
	,SaGeRender
	,SaGeRenderBase
	,SaGeRenderInterface
	,SaGeClasses
	,SaGeMatrix
	,SaGeCommonStructs
	
	// System
	,crt
	,windows
	,DynLibs
	
	// Direct X 9
	,DXTypes
	,DXErr9
	,D3DX9
	,Direct3D9
	;

type
	D3DXVector3 = TD3DXVector3;
	D3DVector = D3DXVector3;

	TSGRDTypeDataBuffer = (SGRDTypeDataBufferVertex, SGRDTypeDataBufferColor, SGRDTypeDataBufferNormal, SGRDTypeDataBufferTexVertex);
	TSGRenderDirectX9 = class(TSGRender)
			public
		constructor Create();override;
		destructor Destroy();override;
			protected
		pD3D      : IDirect3D9;
		pD3DEx    : IDirect3D9Ex;
		pDevice   : IDirect3DDevice9;
		pDeviceEx : IDirect3DDevice9Ex;
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
		procedure DeleteTextures(const VQuantity:Cardinal;const VTextures:PSGRenderTexture);override;
		procedure Lightfv(const VLight,VParam:Cardinal;const VParam2:Pointer);override;
		procedure GenTextures(const VQuantity:Cardinal;const VTextures:PSGRenderTexture);override;
		procedure BindTexture(const VParam:Cardinal;const VTexture:Cardinal);override;
		procedure TexParameteri(const VP1,VP2,VP3:Cardinal);override;
		procedure PixelStorei(const VParamName:Cardinal;const VParam:TSGInt32);override;
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
		procedure MultMatrixf(const Matrix : PSGMatrix4x4);override;
		procedure ColorMaterial(const r,g,b,a : TSGSingle);override;
		procedure MatrixMode(const Par:TSGLongWord);override;
		procedure LoadMatrixf(const Matrix : PSGMatrix4x4);override;
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
		// ��������� �����
		{function CreateShader(const VShaderType : TSGCardinal):TSGLongWord;override;
		procedure ShaderSource(const VShader : TSGLongWord; VSource : PChar; VSourceLength : integer);override;
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
		//����, � ������� ������������ ����� ��� �������
		FClearColor:LongWord;

			(*glBegin ... glEnd*)
			//���������� ������ � ��������� � Vertex-�� ������-�
		// ������� ��� ���������� (�������� � BeginScene)
		FPrimetiveType : LongWord;
		// ��� ��������� ����� (SGR_QUADS,..) ���������� ��������� �������������� ��������. ���� � �������� FPrimetivePrt
		FPrimetivePrt  : LongWord;
		// ������� ����
		FNowColor      : LongWord;
		// ������� �������
		FNowNormal     : packed record
			x,y,z:TSGSingle;
			end;
		// ������, ������� � ���������� ����������� � ������� pDevice.DrawPrimitiveUP(..)
		FArPoints:array[0..2]of
			packed record
				x,y,z : TSGSingle;
				Normalx,Normaly,Normalz: TSGSingle;
				Color : LongWord;
				tx,ty : TSGSingle;
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
			FTexture:IDirect3DTexture9;
			// for change fullscreen
			FBufferChangeFullscreen:PByte;
			// image info
			FWidth,FHeight,FChannels,FFormat:TSGLongWord;
			end;

			(* ===VBO=== or arrays *)
		// FArBuffers[i-1] �������� ���������� � i-�� ������.
		FArBuffers:packed array of
			packed record
			// ��� ������� SGR_ARRAY_BUFFER_ARB or SGR_ELEMENT_ARRAY_BUFFER_ARB
			FType:TSGLongWord;
			// ������. (�� IDirect3DVertexBuffer9 ��� IDirect3DIndexBuffer9)
			FResource:IDirect3DResource9;
			// ��� ������
			FResourceSize:QWord;
			// ��� ��������� ��������� ��� ������ ��� ����������.
			FVertexDeclaration:IDirect3DVertexDeclaration9;
			// ��� ������������ ��� �������� ������ ��� ���������� ���������.
			FBufferChangeFullscreen:PByte;
			end;
		FEnabledClientStateVertex    : TSGBoolean;
		FEnabledClientStateColor     : TSGBoolean;
		FEnabledClientStateNormal    : TSGBoolean;
		FEnabledClientStateTexVertex : Boolean;
		FVBOData:packed array [0..1] of TSGLongWord;
		// FVBOData[0] - SGR_ARRAY_BUFFER_ARB
		// FVBOData[1] - SGR_ELEMENT_ARRAY_BUFFER_ARB
		FArDataBuffers:packed array[TSGRDTypeDataBuffer] of
			packed record
			// ��������� �� ������ ��������������� ������ FVBOData[0]
			FVBOBuffer      : TSGLongWord;
			// � FVBOData ������������ ������� ��������� �����.
			// ���� ������� �� �������, �� ��������������� ��������, ������� ��������� � FVBOData[0]
			FQuantityParams : TSGByte;
			// FQuantityParams --- ���������� ���������� (������ �������� � gl*Pointer (��� �������� �� ������� 3)
			FDataType       : TSGLongWord;
			// FDataType --- ��� ������. ���� Float, Unsigned_byte ��� � �
			FSizeOfOneVertex: TSGByte;
			// FSizeOfOneVertex --- ������ ������ �������� � �������
			FShift          : TSGMaxEnum;
			// FShift --- ���� VBO - �������� � ������ ������������ ������ ����� ���������� �������.
			// � ���� �� VBO - ��������� �� ������ ������� �������. (��� �� ��������� ��������� ������)
			end;

			(* Light *)
		FLigth               : D3DLIGHT9;

			(* PushMatrix/PopMatrix *)
		FQuantitySavedMatrix : LongWord;
		FLengthArSavedMatrix : LongWord;
		FArSavedMatrix       : packed array of D3DMATRIX;

			(* Material *)
		FMaterial            : D3DMATERIAL9;

			(* Matrix Mode *)
		FNowMatrixMode : TSGLongWord;

			(* MultiTexturing *)
		FNowActiveNumberTexture : TSGLongWord;
		FNowActiveClientNumberTexture : TSGLongWord;
			private
		procedure AfterVertexProc();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure DropDeviceResources();
		procedure SetToNullTexture(var Texture : IDirect3DTexture9);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetToNullResource(var Resource : IDirect3DResource9);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;
type
	TSGRDXVertexDeclarationManipulator=class
			public
		constructor Create();
		destructor Destroy();override;
		procedure AddElement(const VOffset:TSGLongWord;const VType:_D3DDECLTYPE;const VUsage:_D3DDECLUSAGE);
		function CreateVertexDeclaration(const pDevice:IDirect3DDevice9):IDirect3DVertexDeclaration9;inline;
			private
		FEVArray:packed array of _D3DVERTEXELEMENT9;
		end;
function SGRDXGetD3DCOLORVALUE(const r,g,b,a:TSGSingle):D3DCOLORVALUE;inline;
function SGRDXGetNumPrimetives(const VParam:TSGLongWord;const VSize:TSGMaxEnum):TSGMaxEnum;inline;
function SGRDXConvertPrimetiveType(const VParam:TSGLongWord):_D3DPRIMITIVETYPE;inline;
function SGRDXVertex3fToRGBA(const v : TSGVertex3f ):TSGLongWord;inline;
procedure SGDX9LogAdapters(const pD3D : IDirect3D9);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeDllManager
	,SaGeStringUtils
	,SaGeLog
	,SaGeBaseUtils
	
	,SysUtils
	;

var
	AdaptersLoged : TSGBool = False;

procedure SGDX9LogAdapters(const pD3D : IDirect3D9);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	AdapterCount : TSGMaxEnum;
	i : TSGMaxEnum;
	Adapter : TD3DAdapterIdentifier9;
begin
AdapterCount := pD3D.GetAdapterCount();
SGLog.Source(['IDirect3D9: Finded ', AdapterCount, ' adapter(-s)', Iff(AdapterCount = 0, '.', ':')]);
if AdapterCount > 0 then
	for i := 0 to AdapterCount - 1 do
		if pD3D.GetAdapterIdentifier(i, 0, Adapter) = D3D_OK then
			begin
			SGLog.Source('Adapter #' + SGStr(i) + ':', False);
			SGLog.Source('	Driver:           ' + Adapter.Driver, False);
			SGLog.Source('	Description:      ' + Adapter.Description, False);
			SGLog.Source('	DeviceName:       ' + Adapter.DeviceName, False);
{$IFDEF WIN32}
			SGLog.Source(['	DriverVersion:    ', Adapter.DriverVersion], False);
{$ELSE}
			SGLog.Source(['	DriverVersionLowPart:   ', Adapter.DriverVersionLowPart], False);
			SGLog.Source(['	DriverVersionHighPart:  ', Adapter.DriverVersionHighPart], False);
{$ENDIF}
			SGLog.Source(['	VendorIdentifier: ', Adapter.VendorId], False);
			SGLog.Source(['	DeviceIdentifier: ', Adapter.DeviceId], False);
			SGLog.Source(['	SubSysIdentifier: ', Adapter.SubSysId], False);
			SGLog.Source(['	Revision:         ', Adapter.Revision], False);
			SGLog.Source(['	DeviceIdentifier: ', GUIDToString(Adapter.DeviceIdentifier)], False);
			SGLog.Source(['	WHQLLevel:        ', Adapter.WHQLLevel], False);
			end;
end;

class function TSGRenderDirectX9.ClassName() : TSGString;
begin
Result := 'TSGRenderDirectX9';
end;

class function TSGRenderDirectX9.Suppored() : TSGBoolean;
begin
Result := DllManager.Suppored('Direct3D9');
if Result then
	DllManager.Suppored('Direct3DX9');
end;

function TSGRenderDirectX9.SupporedShaders() : TSGBoolean;
begin
Result := False;
end;

{$IFNDEF MOBILE}
procedure TSGRenderDirectX9.GetVertexUnderPixel(const px,py : LongWord; out x,y,z : Real);
var
	pProjection,pView,pWorld : D3DMATRIX;
	pViewport : D3DVIEWPORT9;
	a,b : D3DXVector3;
begin
pDevice.GetViewport(pViewport);

a.x := px;
a.y := py;
a.z := 0;//depth
pDevice.GetTransform(D3DTS_PROJECTION, pProjection);
pDevice.GetTransform(D3DTS_VIEW, pView);
pDevice.GetTransform(D3DTS_WORLD, pWorld);
D3DXVec3UnProject(
	b,
	a,
	pViewport,
	pProjection,
	pView,
	pWorld);
end;
{$ENDIF}

function SGRDXVertex3fToRGBA(const v : TSGVertex3f ):TSGLongWord;inline;
begin
Result :=
	(Round(255.0 * 1.0) shl 24) +
	(Round(127.0 * v.x + 128.0) shl 16) +
	(Round(127.0 * v.y + 128.0) shl 8) +
	(Round(127.0 * v.z + 128.0) shl 0);
end;

procedure TSGRenderDirectX9.BeginBumpMapping(const Point : Pointer );
var
	v : TSGVertex3f;
begin
v := TSGVertex3f(Point^).Normalized();
pDevice.SetRenderState(D3DRS_TEXTUREFACTOR, SGRDXVertex3fToRGBA(v));
end;

procedure TSGRenderDirectX9.EndBumpMapping();
begin
pDevice.SetRenderState(D3DRS_TEXTUREFACTOR, 0);
end;

procedure TSGRenderDirectX9.ActiveTexture(const VTexture : TSGLongWord);
begin
FNowActiveNumberTexture := VTexture;
end;

procedure TSGRenderDirectX9.ActiveTextureDiffuse();
begin
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

procedure TSGRenderDirectX9.ActiveTextureBump();
begin
if FNowActiveNumberTexture = 0 then
	begin
	pDevice.SetTextureStageState( FNowActiveNumberTexture, D3DTSS_TEXCOORDINDEX, 0 );
	pDevice.SetTextureStageState( FNowActiveNumberTexture, D3DTSS_COLOROP,       D3DTOP_DOTPRODUCT3);
	pDevice.SetTextureStageState( FNowActiveNumberTexture, D3DTSS_COLORARG1,     D3DTA_TEXTURE);
	pDevice.SetTextureStageState( FNowActiveNumberTexture, D3DTSS_COLORARG2,     D3DTA_TFACTOR);
	end;
end;

procedure TSGRenderDirectX9.ClientActiveTexture(const VTexture : TSGLongWord);
begin
FNowActiveClientNumberTexture := VTexture;
end;

procedure TSGRenderDirectX9.ColorMaterial(const r,g,b,a : TSGSingle);
begin
FMaterial.Diffuse:=SGRDXGetD3DCOLORVALUE(r,g,b,a);
pDevice.SetMaterial(FMaterial);
end;

constructor TSGRDXVertexDeclarationManipulator.Create();
begin
FEVArray:=nil;
end;

destructor TSGRDXVertexDeclarationManipulator.Destroy();
begin
if FEVArray<>nil then
	SetLength(FEVArray,0);
inherited;
end;

procedure TSGRDXVertexDeclarationManipulator.AddElement(const VOffset:TSGLongWord;const VType:_D3DDECLTYPE;const VUsage:_D3DDECLUSAGE);
begin
if FEVArray=nil then
	SetLength(FEVArray,1)
else
	SetLength(FEVArray,Length(FEVArray)+1);
FEVArray[High(FEVArray)]._Type:=VType;
FEVArray[High(FEVArray)].Offset:=VOffset;
FEVArray[High(FEVArray)].Usage:=VUsage;
FEVArray[High(FEVArray)].Method:=D3DDECLMETHOD_DEFAULT;
end;

function TSGRDXVertexDeclarationManipulator.CreateVertexDeclaration(const pDevice:IDirect3DDevice9):IDirect3DVertexDeclaration9;inline;
begin
Result:=nil;
if FEVArray<>nil then
	begin
	SetLength(FEVArray,Length(FEVArray)+1);
	FEVArray[High(FEVArray)]:=D3DDECL_END;
	pDevice.CreateVertexDeclaration(@FEVArray[0],Result);
	end;
end;

function SGRDXConvertPrimetiveType(const VParam:TSGLongWord):_D3DPRIMITIVETYPE;inline;
begin
case VParam of
SGR_LINES:Result:=D3DPT_LINELIST;
SGR_TRIANGLES:Result:=D3DPT_TRIANGLELIST;
SGR_POINTS:Result:=D3DPT_POINTLIST;
SGR_LINE_STRIP:Result:=D3DPT_LINESTRIP;
SGR_TRIANGLE_STRIP:Result:=D3DPT_TRIANGLESTRIP;
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

function SGRDXGetNumPrimetives(const VParam:TSGLongWord;const VSize:TSGMaxEnum):TSGMaxEnum;inline;
begin
case VParam of
SGR_LINES:Result:=VSize div 2;
SGR_TRIANGLES:Result:=VSize div 3;
SGR_LINE_STRIP:Result:=VSize - 1;
else Result:=VSize;
end;
end;

function SGRDXGetD3DCOLORVALUE(const r,g,b,a:TSGSingle):D3DCOLORVALUE;inline;
begin
Result.r:=r;
Result.b:=b;
Result.g:=g;
Result.a:=a;
end;

procedure TSGRenderDirectX9.PushMatrix();
begin
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

procedure TSGRenderDirectX9.PopMatrix();
begin
if FQuantitySavedMatrix=0 then
	SGLog.Source('TSGRenderDirectX9.PopMatrix : Pop matrix before pushing')
else
	begin
	pDevice.SetTransform(FNowMatrixMode,FArSavedMatrix[FQuantitySavedMatrix-1]);
	FQuantitySavedMatrix-=1;
	end;
end;

procedure TSGRenderDirectX9.SwapBuffers();
begin
pDevice.Present(nil, nil, 0, nil);
end;

procedure TSGRenderDirectX9.AfterVertexProc();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (FNumberOfPoints=3) and  ((FPrimetiveType=SGR_QUADS) or (FPrimetiveType=SGR_TRIANGLES) or (FPrimetiveType=SGR_TRIANGLE_STRIP)) then
	begin
	pDevice.DrawPrimitiveUP( D3DPT_TRIANGLELIST, 1, FArPoints[0], sizeof(FArPoints[0]));
	end
else
	if (FNumberOfPoints=2) and ((FPrimetiveType=SGR_LINES) or (FPrimetiveType=SGR_LINE_LOOP) or (FPrimetiveType=SGR_LINE_STRIP)) then
		begin
		pDevice.DrawPrimitiveUP( D3DPT_LINELIST, 1, FArPoints[0], SizeOf(FArPoints[0]));
		end
	else
		if (FNumberOfPoints=1) and (FPrimetiveType=SGR_POINTS) then
			begin
			pDevice.DrawPrimitiveUP( D3DPT_POINTLIST, 1, FArPoints[0], sizeof(FArPoints[0]));
			end;
case FPrimetiveType of
SGR_POINTS:
	if (FNumberOfPoints=1) then
		FNumberOfPoints:=0;
SGR_TRIANGLES:
	if FNumberOfPoints=3 then
		FNumberOfPoints:=0;
SGR_QUADS:
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
SGR_LINE_LOOP:
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
SGR_LINE_STRIP:
	if FNumberOfPoints=2 then
		begin
		FArPoints[0]:=FArPoints[1];
		FNumberOfPoints:=1;
		end;
SGR_LINES:
	if FNumberOfPoints=2 then
		begin
		FNumberOfPoints:=0;
		end;
end;
end;

function TSGRenderDirectX9.SupporedVBOBuffers():Boolean;
begin
Result:=True;
end;

procedure TSGRenderDirectX9.PointSize(const PS:Single);
begin

end;

procedure TSGRenderDirectX9.LineWidth(const VLW:Single);
begin

end;

procedure TSGRenderDirectX9.Color3f(const r,g,b:single);
begin
Color4f(r,g,b,1);
end;

procedure TSGRenderDirectX9.TexCoord2f(const x,y:single);
begin
FArPoints[FNumberOfPoints].tx:=x;
FArPoints[FNumberOfPoints].ty:=y;
end;

procedure TSGRenderDirectX9.Vertex2f(const x,y:single);
begin
FArPoints[FNumberOfPoints].Color:=FNowColor;
FArPoints[FNumberOfPoints].x:=x;
FArPoints[FNumberOfPoints].y:=y;
FArPoints[FNumberOfPoints].z:=0;
FNumberOfPoints+=1;
AfterVertexProc();
end;

procedure TSGRenderDirectX9.Color4f(const r,g,b,a:single);
begin
FNowColor:=D3DCOLOR_ARGB(
	Byte(a>=1)*255+Byte((a<1) and (a>0))*round(255*a),
	Byte(r>=1)*255+Byte((r<1) and (r>0))*round(255*r),
	Byte(g>=1)*255+Byte((g<1) and (g>0))*round(255*g),
	Byte(b>=1)*255+Byte((b<1) and (b>0))*round(255*b));
end;

procedure TSGRenderDirectX9.LoadMatrixf(const Matrix : PSGMatrix4x4);
begin
pDevice.SetTransform(FNowMatrixMode, PD3DMATRIX(Matrix)^);
end;

procedure TSGRenderDirectX9.MultMatrixf(const Matrix : PSGMatrix4x4);
var
	Matrix1,MatrixOut:D3DMATRIX;
begin
pDevice.GetTransform(FNowMatrixMode, Matrix1);
D3DXMatrixMultiply(MatrixOut, PD3DMATRIX(Matrix)^, Matrix1);
pDevice.SetTransform(FNowMatrixMode, MatrixOut);
end;

procedure TSGRenderDirectX9.Translatef(const x,y,z:single);
var
	Matrix1,Matrix2,MatrixOut:D3DMATRIX;
begin
pDevice.GetTransform(FNowMatrixMode,Matrix1);
D3DXMatrixTranslation(Matrix2,x,y,z);
D3DXMatrixMultiply(MatrixOut,Matrix1,Matrix2);
pDevice.SetTransform(FNowMatrixMode,MatrixOut);
end;

procedure TSGRenderDirectX9.Rotatef(const angle:single;const x,y,z:single);
var
	Matrix1,Matrix2,MatrixOut:D3DMATRIX;
	v:TD3DXVector3;
begin
v.x:=x;
v.y:=y;
v.z:=z;
pDevice.GetTransform(FNowMatrixMode,Matrix1);
D3DXMatrixRotationAxis(Matrix2,v,angle/180*pi);
D3DXMatrixMultiply(MatrixOut,Matrix2,Matrix1);
pDevice.SetTransform(FNowMatrixMode,MatrixOut);
end;

procedure TSGRenderDirectX9.Enable(VParam:Cardinal);
begin
case VParam of
SGR_DEPTH_TEST:
	begin
	pDevice.SetRenderState(D3DRS_ZENABLE, 1);
	end;
SGR_LIGHTING:
	begin
	pDevice.SetRenderState(D3DRS_LIGHTING,1);
	end;
SGR_LIGHT0..SGR_LIGHT7:
	begin
	pDevice.LightEnable(VParam-SGR_LIGHT0,True);
	end;
SGR_BLEND:
	begin
	pDevice.SetRenderState( D3DRS_ALPHABLENDENABLE, 1);
	end;
end;
end;

procedure TSGRenderDirectX9.Disable(const VParam:Cardinal);
begin
case VParam of
SGR_DEPTH_TEST:
	begin
	pDevice.SetRenderState(D3DRS_ZENABLE, 0);
	end;
SGR_TEXTURE_2D:
	begin
	FNowTexture:=0;
	pDevice.SetTexture(FNowActiveNumberTexture,nil);
	end;
SGR_CULL_FACE:
	begin
	pDevice.SetRenderState( D3DRS_CULLMODE, D3DCULL_NONE );
	end;
SGR_LIGHTING:
	begin
	pDevice.SetRenderState(D3DRS_LIGHTING,0);
	end;
SGR_LIGHT0..SGR_LIGHT7:
	begin
	pDevice.LightEnable(VParam-SGR_LIGHT0,False);
	end;
SGR_BLEND:
	begin
	pDevice.SetRenderState( D3DRS_ALPHABLENDENABLE, 0);
	end;
end;
end;

procedure TSGRenderDirectX9.DeleteTextures(const VQuantity:Cardinal;const VTextures:PSGRenderTexture);
var
	i:LongWord;
begin
for i:=0 to VQuantity-1 do
	begin
	if (VTextures[i]>0) and (VTextures[i]<=Length(FArTextures)) and (FArTextures[VTextures[i]-1].FTexture<>nil) then
		begin
		SGDestroyInterface(FArTextures[VTextures[i]-1].FTexture);
		SetToNullTexture(FArTextures[VTextures[i]-1].FTexture);
		if FArTextures[VTextures[i]-1].FBufferChangeFullscreen<>nil then
			FreeMem(FArTextures[VTextures[i]-1].FBufferChangeFullscreen);
		FArTextures[VTextures[i]-1].FBufferChangeFullscreen:=nil;
		end;
	end;
end;

procedure TSGRenderDirectX9.Lightfv(const VLight,VParam:Cardinal;const VParam2:Pointer);
type
	PArS = ^ Single;
begin
case VLight of
SGR_LIGHT0:
	begin
	case VParam of
	SGR_AMBIENT:
		begin
		FLigth.AMBIENT.r:=PArS(VParam2)[0];
		FLigth.AMBIENT.g:=PArS(VParam2)[1];
		FLigth.AMBIENT.b:=PArS(VParam2)[2];
		FLigth.AMBIENT.a:=PArS(VParam2)[3];
		end;
	SGR_DIFFUSE:
		begin
		FLigth.Diffuse.r := PArS(VParam2)[0] ;
		FLigth.Diffuse.g := PArS(VParam2)[2] ;
		FLigth.Diffuse.b := PArS(VParam2)[3] ;
		FLigth.Diffuse.a := PArS(VParam2)[4] ;
		end;
	SGR_SPECULAR:
		begin
		FLigth.SPECULAR.r:= PArS(VParam2)[0] ;
		FLigth.SPECULAR.g:= PArS(VParam2)[1] ;
		FLigth.SPECULAR.b:= PArS(VParam2)[2] ;
		FLigth.SPECULAR.a:= PArS(VParam2)[3] ;
		end;
	SGR_POSITION:
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

procedure TSGRenderDirectX9.GenTextures(const VQuantity:Cardinal;const VTextures:PSGRenderTexture);
var
	I:LongWord;
begin
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

procedure TSGRenderDirectX9.BindTexture(const VParam:Cardinal;const VTexture:Cardinal);
begin
FNowTexture:=VTexture;
if (FArTextures<>nil) and (FNowTexture-1>=0) and (Length(FArTextures)>FNowTexture-1) and (FArTextures[FNowTexture-1].FTexture<>nil) then
	pDevice.SetTexture(FNowActiveNumberTexture, FArTextures[FNowTexture-1].FTexture);
end;

procedure TSGRenderDirectX9.TexParameteri(const VP1,VP2,VP3:Cardinal);
var
	Caps : D3DCAPS9;
begin
if (VP1 = SGR_TEXTURE_2D) or (VP1 = SGR_TEXTURE_1D) then
	begin
	case VP2 of
	SGR_TEXTURE_MIN_FILTER:
		case VP3 of
		SGR_POINT:
			pDevice.SetSamplerState( FNowActiveNumberTexture, D3DSAMP_MINFILTER, D3DTEXF_POINT);
		SGR_LINEAR:
			pDevice.SetSamplerState( FNowActiveNumberTexture, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
		SGR_NEAREST:
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
	SGR_TEXTURE_MAG_FILTER:
		case VP3 of
		SGR_POINT:
			pDevice.SetSamplerState( FNowActiveNumberTexture, D3DSAMP_MAGFILTER, D3DTEXF_POINT);
		SGR_LINEAR:
			pDevice.SetSamplerState( FNowActiveNumberTexture, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
		SGR_NEAREST:
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
end;

procedure TSGRenderDirectX9.PixelStorei(const VParamName:Cardinal;const VParam:TSGInt32);
begin

end;

procedure TSGRenderDirectX9.TexEnvi(const VP1,VP2,VP3:Cardinal);
begin

end;

procedure TSGRenderDirectX9.TexImage2D(const VTextureType:Cardinal;const VP1:Cardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:Cardinal;VBitMap:Pointer);
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
VTFormat:=0;
case VFormatType of
SGR_RGBA:VTFormat:=D3DFMT_A8R8G8B8;
SGR_RGB:VTFormat:=D3DFMT_X8R8G8B8;//������ ��� ����� --- D3DFMT_R8G8B8;
SGR_LUMINANCE_ALPHA:VTFormat:=D3DFMT_A8L8;
SGR_RED:;
SGR_INTENSITY:;
SGR_ALPHA:VTFormat:=D3DFMT_A8;
SGR_LUMINANCE:VTFormat:=D3DFMT_L8;
end;
FArTextures[FNowTexture-1].FWidth:=VWidth;
FArTextures[FNowTexture-1].FHeight:=VHeight;
FArTextures[FNowTexture-1].FChannels:=VChannels;
FArTextures[FNowTexture-1].FFormat:=VTFormat;
if pDevice.CreateTexture(VWidth,VHeight,VChannels,D3DUSAGE_DYNAMIC,VTFormat,D3DPOOL_DEFAULT,FArTextures[FNowTexture-1].FTexture,nil)<> D3D_OK then
	SGLog.Source('TSGRenderDirectX9__TexImage2D : "IDirect3DDevice9__CreateTexture" failed...')
else
	begin
	fillchar(rcLockedRect,sizeof(rcLockedRect),0);
	if FArTextures[FNowTexture-1].FTexture.LockRect(0, rcLockedRect, nil, D3DLOCK_DISCARD or D3DLOCK_NOOVERWRITE) <> D3D_OK then
		SGLog.Source('TSGRenderDirectX9__TexImage2D : "IDirect3DTexture9__LockRect" failed...')
	else
		begin
		if (VTFormat=D3DFMT_A8R8G8B8) and (VFormatType=SGR_RGBA) then
			begin
			RGBAToD3D_ARGB();
			end
		else if (VTFormat=D3DFMT_X8R8G8B8) and (VFormatType=SGR_RGB) then
			begin
			RGBToD3D_XRGB();
			end
		else
			System.Move(VBitMap^,rcLockedRect.pBits^,VWidth*VHeight*VChannels);
		if FArTextures[FNowTexture-1].FTexture.UnlockRect(0) <> D3D_OK then
			SGLog.Source('TSGRenderDirectX9__TexImage2D : "IDirect3DTexture9__UnlockRect" failed...');
		end;
	end;
end;

procedure TSGRenderDirectX9.ReadPixels(const x,y:Integer;const Vwidth,Vheight:Integer;const format, atype: Cardinal;const pixels: Pointer);
begin

end;

procedure TSGRenderDirectX9.CullFace(const VParam:Cardinal);
begin
case VParam of
SGR_BACK :pDevice.SetRenderState( D3DRS_CULLMODE, D3DCULL_CW );
SGR_FRONT:pDevice.SetRenderState( D3DRS_CULLMODE, D3DCULL_CCW );
end;
end;

procedure TSGRenderDirectX9.EnableClientState(const VParam:Cardinal);
begin
case VParam of
SGR_VERTEX_ARRAY:FEnabledClientStateVertex:=True;
SGR_NORMAL_ARRAY:FEnabledClientStateNormal:=True;
SGR_TEXTURE_COORD_ARRAY:FEnabledClientStateTexVertex:=True;
SGR_COLOR_ARRAY:FEnabledClientStateColor:=True;
end;
end;

procedure TSGRenderDirectX9.DisableClientState(const VParam:Cardinal);
begin
case VParam of
SGR_VERTEX_ARRAY:FEnabledClientStateVertex:=False;
SGR_NORMAL_ARRAY:FEnabledClientStateNormal:=False;
SGR_TEXTURE_COORD_ARRAY:FEnabledClientStateTexVertex:=False;
SGR_COLOR_ARRAY:FEnabledClientStateColor:=False;
end;
end;

procedure TSGRenderDirectX9.GenBuffersARB(const VQ:Integer;const PT:PCardinal);
var
	i:LongWord;
begin
for i:=0 to VQ-1 do
	begin
	if FArBuffers=nil then
		SetLength(FArBuffers,1)
	else
		SetLength(FArBuffers,Length(FArBuffers)+1);
	FArBuffers[High(FArBuffers)].FResource:=nil;
	FArBuffers[High(FArBuffers)].FResourceSize:=0;
	FArBuffers[High(FArBuffers)].FVertexDeclaration:=nil;
	FArBuffers[High(FArBuffers)].FBufferChangeFullscreen:=nil;
	FArBuffers[High(FArBuffers)].FType:=0;
	PT[i]:=Length(FArBuffers);
	end;
end;

procedure TSGRenderDirectX9.SetToNullTexture(var Texture : IDirect3DTexture9);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
try
Texture := nil;
except
end;
end;

procedure TSGRenderDirectX9.SetToNullResource(var Resource : IDirect3DResource9);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
try
Resource := nil;
except
end;
end;

procedure TSGRenderDirectX9.DeleteBuffersARB(const VQuantity:LongWord;VPoint:Pointer);
var
	i:LongWord;
begin
for i:=0 to VQuantity-1 do
	if FArBuffers[PLongWord(VPoint)[i]-1].FResource<>nil then
		begin
		SGDestroyInterface(FArBuffers[PLongWord(VPoint)[i]-1].FResource);
		SetToNullResource(FArBuffers[PLongWord(VPoint)[i]-1].FResource);
		FArBuffers[PLongWord(VPoint)[i]-1].FResourceSize:=0;
		FArBuffers[PLongWord(VPoint)[i]-1].FType:=0;
		if FArBuffers[PLongWord(VPoint)[i]-1].FVertexDeclaration<>nil then
			begin
			SGDestroyInterface(FArBuffers[PLongWord(VPoint)[i]-1].FVertexDeclaration);
			if Self <> nil then
				FArBuffers[PLongWord(VPoint)[i]-1].FVertexDeclaration := nil;
			end;
		PLongWord(VPoint)[i]:=0;
		end;
end;

procedure TSGRenderDirectX9.BindBufferARB(const VParam:Cardinal;const VParam2:Cardinal);
begin
case VParam of
SGR_ARRAY_BUFFER_ARB        :FVBOData[0]:=VParam2;
SGR_ELEMENT_ARRAY_BUFFER_ARB:FVBOData[1]:=VParam2;
end;
end;

procedure TSGRenderDirectX9.BufferDataARB(
	const VParam:Cardinal;   // SGR_ARRAY_BUFFER_ARB or SGR_ELEMENT_ARRAY_BUFFER_ARB
	const VSize:int64;       // ������ � ������
	VBuffer:Pointer;         // �����
	const VParam2:Cardinal;
	const VIndexPrimetiveType : TSGLongWord = 0);
var
	VVBuffer:PByte = nil;
begin
if (VParam=SGR_ARRAY_BUFFER_ARB) and (FVBOData[0]>0) then
	begin
	if pDevice.CreateVertexBuffer(VSize,0,0,D3DPOOL_DEFAULT,
		IDirect3DVertexBuffer9(Pointer(FArBuffers[FVBOData[0]-1].FResource)),
		nil)<>D3D_OK then
		begin
		SGLog.Source('TSGRenderDirectX9__BufferDataARB : Failed to Create vertex buffer!');
		Exit;
		end
	else
		begin
		FArBuffers[FVBOData[0]-1].FType:=VParam;
		if (FArBuffers[FVBOData[0]-1].FResource as IDirect3DVertexBuffer9).Lock(0,VSize,VVBuffer,0)<>D3D_OK then
			begin
			SGLog.Source('TSGRenderDirectX9__BufferDataARB : Failed to Lock vertex buffer!');
			Exit;
			end
		else
			begin
			System.Move(VBuffer^,VVBuffer^,VSize);
			FArBuffers[FVBOData[0]-1].FResourceSize:=VSize;
			if (FArBuffers[FVBOData[0]-1].FResource as IDirect3DVertexBuffer9).UnLock()<>D3D_OK then
				begin
				SGLog.Source('TSGRenderDirectX9__BufferDataARB : Failed to UnLock vertex buffer!');
				Exit;
				end;
			//SGLog.Source(['TSGRenderDirectX9__BufferDataARB : Sucssesful create and lock data to ',FVBOData[0],' vertex buffer!']);
			end;
		end;
	end
else if (VParam=SGR_ELEMENT_ARRAY_BUFFER_ARB) and (FVBOData[1]>0) then
	begin
	if pDevice.CreateIndexBuffer(VSize,0,
		TSGByte(VIndexPrimetiveType=SGR_UNSIGNED_SHORT)*D3DFMT_INDEX16+
		TSGByte(VIndexPrimetiveType=SGR_UNSIGNED_INT)*D3DFMT_INDEX32
		,D3DPOOL_DEFAULT,
		IDirect3DIndexBuffer9(Pointer(FArBuffers[FVBOData[1]-1].FResource)),nil)<>D3D_OK then
		begin
		SGLog.Source('TSGRenderDirectX9__BufferDataARB : Failed to Create index buffer!');
		exit;
		end
	else
		begin
		FArBuffers[FVBOData[1]-1].FType:=VParam;
		if (FArBuffers[FVBOData[1]-1].FResource as IDirect3DIndexBuffer9).Lock(0,VSize,VVBuffer,0)<>D3D_OK then
			begin
			SGLog.Source('TSGRenderDirectX9__BufferDataARB : Failed to Lock index buffer!');
			Exit;
			end
		else
			begin
			System.Move(VBuffer^,VVBuffer^,VSize);
			FArBuffers[FVBOData[1]-1].FResourceSize:=VSize;
			if (FArBuffers[FVBOData[1]-1].FResource as IDirect3DIndexBuffer9).UnLock()<>D3D_OK then
				begin
				SGLog.Source('TSGRenderDirectX9__BufferDataARB : Failed to UnLock index buffer!');
				Exit;
				end;
			//SGLog.Source(['TSGRenderDirectX9__BufferDataARB : Sucssesful create and lock data to ',FVBOData[1],' indexes buffer!']);
			end;
		end;
	end
else SGLog.Source('TSGRenderDirectX9__BufferDataARB : Some params incorect!');
end;

procedure TSGRenderDirectX9.DrawElements(
	const VParam:Cardinal;
	const VSize:int64;// �� � ������ � � 4*����
	const VParam2:Cardinal;
	VBuffer:Pointer);
var
	VertexManipulator:TSGRDXVertexDeclarationManipulator = nil;
begin
if (VBuffer<>nil) or (not FEnabledClientStateVertex) then
	Exit;
if (FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer<>0) and (VBuffer=nil) then
	begin
	if FArBuffers[FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer-1].FVertexDeclaration = nil then
		begin
		VertexManipulator:=TSGRDXVertexDeclarationManipulator.Create();
		if FEnabledClientStateVertex then
			VertexManipulator.AddElement(FArDataBuffers[SGRDTypeDataBufferVertex].FShift,D3DDECLTYPE_FLOAT3,D3DDECLUSAGE_POSITION);
		if FEnabledClientStateColor then
			VertexManipulator.AddElement(FArDataBuffers[SGRDTypeDataBufferColor].FShift,D3DDECLTYPE_D3DCOLOR,D3DDECLUSAGE_COLOR);
		if FEnabledClientStateNormal then
			VertexManipulator.AddElement(FArDataBuffers[SGRDTypeDataBufferNormal].FShift,D3DDECLTYPE_FLOAT3,D3DDECLUSAGE_NORMAL);
		if FEnabledClientStateTexVertex then
			VertexManipulator.AddElement(FArDataBuffers[SGRDTypeDataBufferTexVertex].FShift,D3DDECLTYPE_FLOAT2,D3DDECLUSAGE_TEXCOORD);
		//Create format of vertex
		FArBuffers[FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer-1].FVertexDeclaration:=VertexManipulator.CreateVertexDeclaration(pDevice);
		VertexManipulator.Destroy();
		VertexManipulator:=nil;
		end;
	pDevice.BeginScene();
	//Set format of vertex
	pDevice.SetVertexDeclaration(FArBuffers[FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer-1].FVertexDeclaration);
	//Set vertex buffer
	if pDevice.SetStreamSource(0,IDirect3DVertexBuffer9(Pointer(FArBuffers[FVBOData[0]-1].FResource)),0,FArDataBuffers[SGRDTypeDataBufferVertex].FSizeOfOneVertex)<>D3D_OK then
		SGLog.Source('TSGRenderDirectX9__DrawElements : SetStreamSource : Failed!!');
	//Set Index buffer
	if pDevice.SetIndices(IDirect3DIndexBuffer9(Pointer(FArBuffers[FVBOData[1]-1].FResource))) <> D3D_OK then
		SGLog.Source('TSGRenderDirectX9__DrawElements : SetIndices : Failed!!');
	//Draw
	if pDevice.DrawIndexedPrimitive(SGRDXConvertPrimetiveType(VParam),0,0,
		FArBuffers[FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer-1].FResourceSize div
		FArDataBuffers[SGRDTypeDataBufferVertex].FSizeOfOneVertex
		,0,SGRDXGetNumPrimetives(VParam,VSize))<>D3D_OK then
			SGLog.Source('TSGRenderDirectX9__DrawElements : DrawIndexedPrimitive : Draw Failed!!');
	pDevice.EndScene();
	end
else
	begin
	SGLog.Source('TSGRenderDirectX9__DrawElements : Draw indexed primitive without VBO not possible!');
	end;
end;

procedure TSGRenderDirectX9.DrawArrays(const VParam:TSGCardinal;const VFirst,VCount:TSGLongWord);
var
	VertexManipulator : TSGRDXVertexDeclarationManipulator = nil;
	BeginArray:TSGMaxEnum;
	VertexType:LongWord = D3DFVF_XYZ;
begin
if not FEnabledClientStateVertex then
	Exit;

if FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer=0 then
	begin
	BeginArray := FArDataBuffers[SGRDTypeDataBufferVertex].FShift;
	if FEnabledClientStateColor and (BeginArray>FArDataBuffers[SGRDTypeDataBufferColor].FShift) then
		BeginArray:=FArDataBuffers[SGRDTypeDataBufferColor].FShift;
	if FEnabledClientStateNormal and (BeginArray>FArDataBuffers[SGRDTypeDataBufferNormal].FShift) then
		BeginArray:=FArDataBuffers[SGRDTypeDataBufferNormal].FShift;
	if FEnabledClientStateTexVertex and (BeginArray>FArDataBuffers[SGRDTypeDataBufferTexVertex].FShift) then
		BeginArray:=FArDataBuffers[SGRDTypeDataBufferTexVertex].FShift;

	if FEnabledClientStateColor then
		VertexType:=VertexType or D3DFVF_DIFFUSE;
	if FEnabledClientStateTexVertex then
		VertexType:=VertexType or D3DFVF_TEX1;
	if FEnabledClientStateNormal then
		VertexType:=VertexType or D3DFVF_NORMAL;
	pDevice.BeginScene();
	pDevice.SetFVF( VertexType );
	pDevice.DrawPrimitiveUP(SGRDXConvertPrimetiveType(VParam),SGRDXGetNumPrimetives(VParam,VCount),
		TSGPointer(BeginArray+FArDataBuffers[SGRDTypeDataBufferVertex].FSizeOfOneVertex*VFirst)^,
		FArDataBuffers[SGRDTypeDataBufferVertex].FSizeOfOneVertex);
	pDevice.EndScene();
	end
else
	begin
	if FArBuffers[FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer - 1].FVertexDeclaration = nil then
		begin
		VertexManipulator:=TSGRDXVertexDeclarationManipulator.Create();
		if FEnabledClientStateVertex then
			VertexManipulator.AddElement(FArDataBuffers[SGRDTypeDataBufferVertex].FShift,D3DDECLTYPE_FLOAT3,D3DDECLUSAGE_POSITION);
		if FEnabledClientStateColor then
			VertexManipulator.AddElement(FArDataBuffers[SGRDTypeDataBufferColor].FShift,D3DDECLTYPE_D3DCOLOR,D3DDECLUSAGE_COLOR);
		if FEnabledClientStateNormal then
			VertexManipulator.AddElement(FArDataBuffers[SGRDTypeDataBufferNormal].FShift,D3DDECLTYPE_FLOAT3,D3DDECLUSAGE_NORMAL);
		if FEnabledClientStateTexVertex then
			VertexManipulator.AddElement(FArDataBuffers[SGRDTypeDataBufferTexVertex].FShift,D3DDECLTYPE_FLOAT2,D3DDECLUSAGE_TEXCOORD);
		//Create format of vertex
		FArBuffers[FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer-1].FVertexDeclaration:=VertexManipulator.CreateVertexDeclaration(pDevice);
		VertexManipulator.Destroy();
		VertexManipulator:=nil;
		end;
	pDevice.BeginScene();
	//Set format of vertex
	pDevice.SetVertexDeclaration(FArBuffers[FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer-1].FVertexDeclaration);
	//Set vertex buffer
	if pDevice.SetStreamSource(0,IDirect3DVertexBuffer9(Pointer(FArBuffers[FVBOData[0]-1].FResource)),0,FArDataBuffers[SGRDTypeDataBufferVertex].FSizeOfOneVertex)<>D3D_OK then
		SGLog.Source('TSGRenderDirectX9__DrawArrays : SetStreamSource : Failed!!');
	//Set Index buffer
	if pDevice.SetIndices(nil) <> D3D_OK then
		SGLog.Source('TSGRenderDirectX9__DrawArrays : SetIndices(nil) : Failed!!');
	pDevice.DrawPrimitive(SGRDXConvertPrimetiveType(VParam),VFirst,SGRDXGetNumPrimetives(VParam,VCount));
	pDevice.EndScene();
	end;
end;

procedure TSGRenderDirectX9.ColorPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);
begin
FArDataBuffers[SGRDTypeDataBufferColor].FQuantityParams:=VQChannels;
FArDataBuffers[SGRDTypeDataBufferColor].FVBOBuffer:=FVBOData[0];
FArDataBuffers[SGRDTypeDataBufferColor].FDataType:=VType;
FArDataBuffers[SGRDTypeDataBufferColor].FSizeOfOneVertex:=VSize;
FArDataBuffers[SGRDTypeDataBufferColor].FShift:=TSGMaxEnum(VBuffer);
end;

procedure TSGRenderDirectX9.TexCoordPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);
begin
FArDataBuffers[SGRDTypeDataBufferTexVertex].FQuantityParams:=VQChannels;
FArDataBuffers[SGRDTypeDataBufferTexVertex].FVBOBuffer:=FVBOData[0];
FArDataBuffers[SGRDTypeDataBufferTexVertex].FDataType:=VType;
FArDataBuffers[SGRDTypeDataBufferTexVertex].FSizeOfOneVertex:=VSize;
FArDataBuffers[SGRDTypeDataBufferTexVertex].FShift:=TSGMaxEnum(VBuffer);
end;

procedure TSGRenderDirectX9.NormalPointer(const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);
begin
FArDataBuffers[SGRDTypeDataBufferNormal].FQuantityParams:=3;
FArDataBuffers[SGRDTypeDataBufferNormal].FVBOBuffer:=FVBOData[0];
FArDataBuffers[SGRDTypeDataBufferNormal].FDataType:=VType;
FArDataBuffers[SGRDTypeDataBufferNormal].FSizeOfOneVertex:=VSize;
FArDataBuffers[SGRDTypeDataBufferNormal].FShift:=TSGMaxEnum(VBuffer);
end;

procedure TSGRenderDirectX9.VertexPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);
begin
FArDataBuffers[SGRDTypeDataBufferVertex].FQuantityParams:=VQChannels;
FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer:=FVBOData[0];
FArDataBuffers[SGRDTypeDataBufferVertex].FDataType:=VType;
FArDataBuffers[SGRDTypeDataBufferVertex].FSizeOfOneVertex:=VSize;
FArDataBuffers[SGRDTypeDataBufferVertex].FShift:=TSGMaxEnum(VBuffer);
end;

function TSGRenderDirectX9.IsEnabled(const VParam:Cardinal):Boolean;
begin
Result:=False;
end;

procedure TSGRenderDirectX9.Clear(const VParam:Cardinal);
begin
pDevice.Clear( 0, nil, D3DCLEAR_TARGET or D3DCLEAR_ZBUFFER, FClearColor, 1.0, 0 );
end;

procedure TSGRenderDirectX9.BeginScene(const VPrimitiveType:TSGPrimtiveType);
const
	MyVertexType:LongWord = D3DFVF_XYZ or D3DFVF_NORMAL or D3DFVF_DIFFUSE  or D3DFVF_TEX1;
begin
FPrimetiveType:=VPrimitiveType;
FPrimetivePrt:=0;
FNumberOfPoints:=0;
pDevice.BeginScene();
pDevice.SetFVF( MyVertexType );
end;

procedure TSGRenderDirectX9.EndScene();
begin
if (FPrimetiveType=SGR_LINE_LOOP) and (FNumberOfPoints=1) and (FPrimetivePrt=1) then
	begin
	pDevice.DrawPrimitiveUP( D3DPT_LINELIST, 1, FArPoints[1], sizeof(FArPoints[0]));
	end;
pDevice.EndScene();
end;

procedure TSGRenderDirectX9.Init();
//var VectorDir:D3DXVECTOR3;
begin
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
FMaterial.Diffuse:=SGRDXGetD3DCOLORVALUE(1,1,1,1);
FMaterial.Ambient:=SGRDXGetD3DCOLORVALUE(0,0,0,0);
FMaterial.Specular:=SGRDXGetD3DCOLORVALUE(0.4,0.4,0.4,1);
FMaterial.Emissive:=SGRDXGetD3DCOLORVALUE(0,0,0,0);
FMaterial.Power:=2;
pDevice.SetMaterial(FMaterial);

//=========������������� ���������
FillChar(FLigth,SizeOf(FLigth),0);
FLigth._Type:=D3DLIGHT_POINT;
FLigth.Diffuse:=SGRDXGetD3DCOLORVALUE(1,1,1,1);
FLigth.Ambient:=SGRDXGetD3DCOLORVALUE(0.5,0.5,0.5,1.0);
FLigth.Specular:=SGRDXGetD3DCOLORVALUE(1.0,1.0,1.0,1.0);
// ������ ����������, �� ������� ���������� ���������, ������ �� ������.
FLigth.Range := TSGRenderFar;
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
pDevice.SetSamplerState( 0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
pDevice.SetSamplerState( 0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
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
pDevice.SetSamplerState(0,D3DSAMP_MIPFILTER,D3DTEXF_NONE);
//pDevice.SetSamplerState(0,D3DSAMP_MIPFILTER,D3DTEXF_POINT);
//pDevice.SetSamplerState(0,D3DSAMP_MIPFILTER,D3DTEXF_LINEAR);

//=====������� ��������� �������
//�������� �������
//pDevice.SetRenderState(D3DRS_SHADEMODE, D3DSHADE_FLAT);
//������� �� ������ ���� (����������)
pDevice.SetRenderState(D3DRS_SHADEMODE, D3DSHADE_GOURAUD);
end;

constructor TSGRenderDirectX9.Create();
begin
inherited Create();
pDevice   := nil;
pDeviceEx := nil;
pD3DEx    := nil;
pD3D      := nil;
FNowActiveNumberTexture:=0;
FNowActiveClientNumberTexture:=0;
SetRenderType(SGRenderDirectX9);
FArTextures:=nil;
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

procedure TSGRenderDirectX9.DropDeviceResources();
var
	i : TSGLongWord;
begin
if FArBuffers<>nil then if Length(FArBuffers)>0 then
	begin
	for i:=0 to High(FArBuffers) do
		begin
		if FArBuffers[i].FResource<>nil then
			begin
			SGDestroyInterface(FArBuffers[i].FResource);
			SetToNullResource(FArBuffers[i].FResource);
			end;
		if FArBuffers[i].FVertexDeclaration<>nil then
			begin
			SGDestroyInterface(FArBuffers[i].FVertexDeclaration);
			if Self <> nil then
				FArBuffers[i].FVertexDeclaration := nil;
			end;
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
			SGDestroyInterface(FArTextures[i].FTexture);
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

procedure TSGRenderDirectX9.Kill();
begin
DropDeviceResources();
if (pDevice<>nil)  then
	begin
	pDeviceEx := nil;
	SGDestroyInterface(pDevice);
	if Self <> nil then
		TSGPointer(pDevice) := nil;
	end;
if (pD3D <> nil) then
	begin
	pD3DEx := nil;
	SGDestroyInterface(pD3D);
	if Self <> nil then
		TSGPointer(pD3D) := nil;
	end;
end;

destructor TSGRenderDirectX9.Destroy();
begin
Kill();
inherited Destroy();
{$IFDEF RENDER_DX9_DEBUG}
	WriteLn('TSGRenderDirectX9.Destroy(): End');
	{$ENDIF}
end;

procedure TSGRenderDirectX9.InitOrtho2d(const x0,y0,x1,y1:TSGSingle);
var
	Matrix{,Matrix1,Matrix2}:D3DMATRIX;
begin
if x0<x1 then
	if y0<y1 then
		D3DXMatrixOrthoLH(Matrix,Abs(x1-x0),Abs(y1-y0),-0.001,0.1)
	else
		D3DXMatrixOrthoLH(Matrix,Abs(x1-x0),-Abs(y1-y0),-0.001,0.1)
else
	if y0<y1 then
		D3DXMatrixOrthoLH(Matrix,-Abs(x1-x0),Abs(y1-y0),-0.001,0.1)
	else
		D3DXMatrixOrthoLH(Matrix,-Abs(x1-x0),-Abs(y1-y0),-0.001,0.1);
pDevice.SetTransform(D3DTS_PROJECTION, Matrix);

D3DXMatrixTranslation(Matrix,-(x0+x1)/2,-(y0+y1)/2,0);
pDevice.SetTransform(D3DTS_VIEW, Matrix);
FNowMatrixMode:=D3DTS_WORLD;
LoadIdentity();
FNowMatrixMode:=D3DTS_VIEW;
end;

procedure TSGRenderDirectX9.MatrixMode(const Par:TSGLongWord);
begin
case Par of
SGR_PROJECTION:
	FNowMatrixMode:=D3DTS_PROJECTION;
SGR_MODELVIEW:
	FNowMatrixMode:=D3DTS_VIEW;
else
	FNowMatrixMode:=D3DTS_WORLD;
end;
end;

procedure TSGRenderDirectX9.InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht : TSGFloat = 1);
var
	Matrix, Matrix1, Matrix2 : D3DMATRIX;
var
	CWidth, CHeight : TSGLongWord;
begin
CWidth := Width;
CHeight := Height;
FNowMatrixMode:=D3DTS_WORLD;
LoadIdentity();
FNowMatrixMode:=D3DTS_VIEW;
LoadIdentity();
if Mode=SG_3D then
	begin
	Matrix:=D3DMATRIX(SGGetPerspectiveMatrix(45,CWidth/CHeight,TSGRenderNear,TSGRenderFar));
	pDevice.SetTransform(D3DTS_PROJECTION, Matrix);
	Enable(SGR_DEPTH_TEST);
	end
else
	if Mode=SG_3D_ORTHO then
		begin
		D3DXMatrixOrthoLH(Matrix1,D3DX_PI/4*dncht*30,D3DX_PI/4*dncht*30/CWidth*CHeight,TSGRenderNear,TSGRenderFar);
		D3DXMatrixScaling(Matrix2,1,1,-1);
		D3DXMatrixMultiply(Matrix,Matrix1,Matrix2);
		pDevice.SetTransform(D3DTS_PROJECTION, Matrix);
		Enable(SGR_DEPTH_TEST);
		end
	else if Mode=SG_2D then
		begin
		D3DXMatrixOrthoLH(Matrix1,CWidth,-CHeight,-0.001,0.1);
		D3DXMatrixTranslation(Matrix2,-CWidth/2,-CHeight/2,0);
		D3DXMatrixMultiply(Matrix,Matrix2,Matrix1);
		pDevice.SetTransform(D3DTS_PROJECTION, Matrix);
		Disable(SGR_DEPTH_TEST);
		end;
end;

procedure TSGRenderDirectX9.Viewport(const a,b,c,d:TSGAreaInt);
begin

end;

procedure TSGRenderDirectX9.LoadIdentity();
var
	Matrix:D3DMATRIX;
begin
D3DXMatrixIdentity(Matrix);
pDevice.SetTransform(FNowMatrixMode,Matrix);
end;


procedure TSGRenderDirectX9.Vertex3fv(const Variable : TSGPointer);
begin
FArPoints[FNumberOfPoints].Color:=FNowColor;
System.Move(FNowNormal,FArPoints[FNumberOfPoints].Normalx,3*SizeOf(TSGSingle));
System.Move(Variable^,FArPoints[FNumberOfPoints].x,SizeOf(TSGSingle)*3);
FNumberOfPoints+=1;
AfterVertexProc();
end;

procedure TSGRenderDirectX9.Normal3f(const x,y,z:single);
begin
FNowNormal.x:=x;
FNowNormal.y:=y;
FNowNormal.z:=z;
end;

procedure TSGRenderDirectX9.Normal3fv(const Variable : TSGPointer);
begin
System.Move(Variable^,FNowNormal,3*SizeOf(TSGSingle));
end;

procedure TSGRenderDirectX9.Vertex3f(const x,y,z:single);
begin
FArPoints[FNumberOfPoints].Color:=FNowColor;
System.Move(FNowNormal,FArPoints[FNumberOfPoints].Normalx,3*SizeOf(TSGSingle));
FArPoints[FNumberOfPoints].x:=x;
FArPoints[FNumberOfPoints].y:=y;
FArPoints[FNumberOfPoints].z:=z;
FNumberOfPoints+=1;
AfterVertexProc();
end;

function TSGRenderDirectX9.CreateContext():Boolean;
var
	d3dpp                 : D3DPRESENT_PARAMETERS;
	MultiSampleType       : D3DMULTISAMPLE_TYPE;
	MultiSampleMaxQuality : TSGLongWord;

procedure FindMaxMultisample();
var
	Samples : array[0..16] of D3DMULTISAMPLE_TYPE = (
		D3DMULTISAMPLE_NONE,
		D3DMULTISAMPLE_NONMASKABLE,
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
	Index : TSGLongWord;
	Finded : TSGBoolean = False;

function D3DMULTISAMPLE_Str(const MS : D3DMULTISAMPLE_TYPE):TSGString;
begin
case MS of
D3DMULTISAMPLE_NONE       : Result := 'D3DMULTISAMPLE_NONE';
D3DMULTISAMPLE_NONMASKABLE: Result := 'D3DMULTISAMPLE_NONMASKABLE';
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

begin
for Index := High(Samples) downto Low(Samples) do
	begin
	if SUCCEEDED(pD3D.CheckDeviceMultiSampleType(
          D3DADAPTER_DEFAULT,
          D3DDEVTYPE_HAL,
          D3DFMT_X8R8G8B8,
          False,
          Samples[Index],
          @MultiSampleMaxQuality
       )) then
		begin
		Finded := True;
		MultiSampleType := Samples[Index];
		SGLog.Source(['TSGRenderDirectX9__CreateContext_FindMaxMultisample : ',D3DMULTISAMPLE_Str(MultiSampleType),', MaxQuality = ',MultiSampleMaxQuality,'']);
		break;
		end;
	end;
if not Finded then
	begin
	MultiSampleType := D3DMULTISAMPLE_NONE;
	MultiSampleMaxQuality := 0;
	end;
end;

var
	D3DFMT_List : array[0..7] of TSGMaxEnum = (
		D3DFMT_UNKNOWN,
		D3DFMT_D15S1,
		D3DFMT_D16_LOCKABLE,
		D3DFMT_D16,
		D3DFMT_D24X8,
		D3DFMT_D24S8,
		D3DFMT_D24X4S4,
		D3DFMT_D32
		);

function D3DFMT_Str(const FMT : TSGMaxEnum) : TSGString;
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

procedure LogDirectXLastError(const Error : TSGMaxEnum);
begin
SGLog.Source(['TSGRenderDirectX9__CreateContext: DirectX Error: "',Error,'"/"',SGAddrStr(TSGPointer(Error)),'"']);
SGLog.Source(['TSGRenderDirectX9__CreateContext: DirectX Error Discription: "',SGPCharToString(DXGetErrorString9(Error)),'"']);
end;

procedure TryCreateD3DEx(const Version : TSGMaxEnum);

function StrSDKVersion(const Version : TSGMaxEnum) : TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
case Version of
D3D9b_SDK_VERSION : Result := 'D3D9b_SDK_VERSION';
D3D_SDK_VERSION   : Result := 'D3D_SDK_VERSION';
else
	Result := '';
end;
end;

var
	DirectXErrorCode : TSGMaxEnum = 0;
begin
if pD3DEx <> nil then
	Exit;
DirectXErrorCode := Direct3DCreate9Ex(Version, pD3DEx);
if (DirectXErrorCode = D3D_OK) and (pD3DEx <> nil) then
	begin
	SGLog.Source(['TSGRenderDirectX9__CreateContext: Created extension context with sdk version "',StrSDKVersion(Version),'".']);
	pD3D := pD3DEx;
	end
else
	begin
	SGLog.Source(['TSGRenderDirectX9__CreateContext: Failed create extension context with sdk version "',StrSDKVersion(Version),'".']);
	LogDirectXLastError(DirectXErrorCode);
	end;
end;

procedure FillPresendParameters(var d3dpp : D3DPRESENT_PARAMETERS);
begin
FillChar(d3dpp, SizeOf(d3dpp), 0);
d3dpp.Windowed               := True;
d3dpp.SwapEffect             := D3DSWAPEFFECT_DISCARD;
d3dpp.hDeviceWindow          := TSGMaxEnum(Context.Window);
d3dpp.BackBufferFormat       := D3DFMT_X8R8G8B8;
d3dpp.BackBufferWidth        := Context.Width;
d3dpp.BackBufferHeight       := Context.Height;
d3dpp.EnableAutoDepthStencil := True;
d3dpp.AutoDepthStencilFormat := D3DFMT_D24S8;
d3dpp.PresentationInterval   := D3DPRESENT_INTERVAL_IMMEDIATE;
d3dpp.MultiSampleType        := MultiSampleType;
d3dpp.MultiSampleQuality     := 0;
end;

var
	DirectXErrorCode   : TSGMaxEnum = 0;

procedure TryCreateDevice();
var
	Index : TSGByte;
begin
for Index := High(D3DFMT_List) downto Low(D3DFMT_List) do
	begin
	FillPresendParameters(d3dpp);
	d3dpp.AutoDepthStencilFormat := D3DFMT_List[Index];
	
	DirectXErrorCode :=  pD3D.CreateDevice( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, TSGMaxEnum(Context.Window),
			D3DCREATE_SOFTWARE_VERTEXPROCESSING, @d3dpp, pDevice);
	
	if( DirectXErrorCode <> D3D_OK) then
		begin
		{$IFDEF RENDER_DX9_DEBUG}
		SGLog.Source(['TSGRenderDirectX9__CreateContext: Failed create device with: DepthFormat = ', D3DFMT_Str(d3dpp.AutoDepthStencilFormat)]);
		LogDirectXLastError(DirectXErrorCode);
		{$ENDIF}
		end
	else
		break;
	end;
end;

procedure TryCreateDeviceEx();
var
	Index : TSGByte;
begin
if pD3DEx = nil then
	exit;
for Index := High(D3DFMT_List) downto Low(D3DFMT_List) do
	begin
	FillPresendParameters(d3dpp);
	d3dpp.AutoDepthStencilFormat := D3DFMT_List[Index];
	
	DirectXErrorCode :=  pD3DEx.CreateDeviceEx( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, TSGMaxEnum(Context.Window),
			D3DCREATE_SOFTWARE_VERTEXPROCESSING, @d3dpp, nil, pDeviceEx);
	
	if(DirectXErrorCode <> D3D_OK) then
		begin
		pDeviceEx := nil;
		pDevice := nil;
		{$IFDEF RENDER_DX9_DEBUG}
		SGLog.Source(['TSGRenderDirectX9__CreateContext: Failed create device with: DepthFormat = ', D3DFMT_Str(d3dpp.AutoDepthStencilFormat)]);
		LogDirectXLastError(DirectXErrorCode);
		{$ENDIF}
		end
	else
		begin
		SGLog.Source(['TSGRenderDirectX9__CreateContext: Created extension device.']);
		pDevice := pDeviceEx;
		break;
		end;
	end;
end;

begin
Result := False;
if (pD3D = nil) then
	begin
	pD3DEx := nil;
	TryCreateD3DEx(D3D9b_SDK_VERSION);
	if pD3DEx = nil then
		TryCreateD3DEx(D3D_SDK_VERSION);
	if pD3D = nil then
		pD3D := Direct3DCreate9(D3D_SDK_VERSION);
	SGLog.Source(['TSGRenderDirectX9__CreateContext: IDirect3D9',SGStringIf(pD3DEx <> nil,'Ex'),'="',SGAddrStr(pD3D),'"']);
	if pD3D = nil then
		exit
	else if not AdaptersLoged then
		begin
		SGDX9LogAdapters(pD3D);
		AdaptersLoged := True;
		end;
	end;
if pDevice = nil then
	begin
	FindMaxMultisample();
	{$IFDEF RENDER_DX9_DEBUG}
	SGLog.Source('TSGRenderDirectX9__CreateContext: SizeOf(D3DPRESENT_PARAMETERS) = ' + SGStr(SizeOf(D3DPRESENT_PARAMETERS)));
	{$ENDIF}
	FillPresendParameters(d3dpp);
	end;
if pDevice = nil then
	begin
	pDeviceEx := nil;
	if pD3DEx <> nil then
		TryCreateDeviceEx();
	if pDevice = nil then
		TryCreateDevice();
	if pDevice <> nil then
		begin
		SGLog.Source(['TSGRenderDirectX9__CreateContext: IDirect3DDevice9',SGStringIf(pDeviceEx <> nil, 'Ex'),'="',SGAddrStr(pDevice),'", DepthFormat = ',D3DFMT_Str(d3dpp.AutoDepthStencilFormat)]);
		Result := True;
		end
	else
		begin
		SGLog.Source(['TSGRenderDirectX9__CreateContext: Failed create device with anything params, hWindow="',SGAddrStr(Context.Window),'".']);
		{$IFNDEF RENDER_DX9_DEBUG}
		LogDirectXLastError(DirectXErrorCode);
		{$ENDIF}
		end;
	end
else
	begin
	SGDestroyInterface(pDevice);
	if Self <> nil then
		pDevice := nil;
	Result := CreateContext();
	end;
end;

procedure TSGRenderDirectX9.ReleaseCurrent();
begin
if (pDevice <> nil) then
	begin
	SGDestroyInterface(pDevice);
	if Self <> nil then
		TSGPointer(pDevice) := nil;
	end;
end;

function TSGRenderDirectX9.SetPixelFormat():Boolean;overload;
begin
Result:=True;
end;

function TSGRenderDirectX9.MakeCurrent():Boolean;
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
procedure TSGRenderDirectX9.LockResources();
var
	// �������
	i:TSGMaxEnum;
	//�����
	VVBuffer: PByte = nil;
	// ��� Lock �������
	rcLockedRect:D3DLOCKED_RECT;

function GetRealChannels(const Format,Channels:TSGLongWord):TSGLongWord;inline;
begin
if (Format=D3DFMT_X8R8G8B8) then
	Result:=4
else
	Result:=Channels;
end;

begin
SGLog.Source('TSGRenderDirectX9__LockResources : Entering!');
if FArTextures<>nil then
	begin
	//SGLog.Source('TSGRenderDirectX9__LockResources : Begin to lock textures!');
	for i:=0 to High(FArTextures) do
		begin
		if (FArTextures[i].FTexture<>nil) then
			begin
			//SGLog.Source('TSGRenderDirectX9__LockResources : Begin to lock texture "'+SGStr(i)+'"!');
			FillChar(rcLockedRect,SizeOf(rcLockedRect),0);
			if FArTextures[i].FTexture.LockRect(0, rcLockedRect, nil, D3DLOCK_READONLY) <> D3D_OK then
				begin
				SGLog.Source('TSGRenderDirectX9__LockResources : Errior while IDirect3DTexture9__LockRect');
				end
			else
				begin
				System.GetMem(VVBuffer,FArTextures[i].FWidth*FArTextures[i].FHeight*GetRealChannels(FArTextures[i].FFormat,FArTextures[i].FChannels));
				System.Move(rcLockedRect.pBits^,VVBuffer^,FArTextures[i].FWidth*FArTextures[i].FHeight*GetRealChannels(FArTextures[i].FFormat,FArTextures[i].FChannels));
				FArTextures[i].FBufferChangeFullscreen:=VVBuffer;
				VVBuffer:=nil;
				if FArTextures[i].FTexture.UnlockRect(0) <> D3D_OK then
					begin
					SGLog.Source('TSGRenderDirectX9__LockResources : Errior while IDirect3DTexture9__UnlockRect');
					end;
				end;
			SGDestroyInterface(FArTextures[i].FTexture);
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
			if FArBuffers[i].FVertexDeclaration <> nil then
				begin
				SGDestroyInterface(FArBuffers[i].FVertexDeclaration);
				if Self <> nil then
					FArBuffers[i].FVertexDeclaration:=nil;
				end;
			//SGLog.Source('TSGRenderDirectX9__LockResources : Begin to lock buffer "'+SGStr(i)+'"!');
			if FArBuffers[i].FType=SGR_ELEMENT_ARRAY_BUFFER_ARB then
				begin
				if (FArBuffers[i].FResource as IDirect3DIndexBuffer9).Lock(0,FArBuffers[i].FResourceSize,VVBuffer,0)<>D3D_OK then
					begin
					SGLog.Source('TSGRenderDirectX9__LockResources : Errior while IDirect3DIndexBuffer9__Lock');
					end
				else
					begin
					System.GetMem(FArBuffers[i].FBufferChangeFullscreen,FArBuffers[i].FResourceSize);
					System.Move(VVBuffer^,FArBuffers[i].FBufferChangeFullscreen^,FArBuffers[i].FResourceSize);
					if (FArBuffers[i].FResource as IDirect3DIndexBuffer9).UnLock()<>D3D_OK then
						begin
						SGLog.Source('TSGRenderDirectX9__LockResources : Errior while IDirect3DIndexBuffer9__UnLock');
						if VVBuffer<>nil then
							FreeMem(VVBuffer);
						end;
					VVBuffer:=nil;
					end;
				end
			else if FArBuffers[i].FType=SGR_ARRAY_BUFFER_ARB then
				begin
				if (FArBuffers[i].FResource as IDirect3DVertexBuffer9).Lock(0,FArBuffers[i].FResourceSize,VVBuffer,0)<>D3D_OK then
					begin
					SGLog.Source('TSGRenderDirectX9__LockResources : Errior while IDirect3DIndexBuffer9__Lock');
					end
				else
					begin
					System.GetMem(FArBuffers[i].FBufferChangeFullscreen,FArBuffers[i].FResourceSize);
					System.Move(VVBuffer^,FArBuffers[i].FBufferChangeFullscreen^,FArBuffers[i].FResourceSize);
					if (FArBuffers[i].FResource as IDirect3DVertexBuffer9).UnLock()<>D3D_OK then
						begin
						SGLog.Source('TSGRenderDirectX9__LockResources : Errior while IDirect3DIndexBuffer9__UnLock');
						if VVBuffer<>nil then
							FreeMem(VVBuffer);
						end;
					VVBuffer:=nil;
					end;
				end;
			SGDestroyInterface(FArBuffers[i].FResource);
			if Self <> nil then
				FArBuffers[i].FResource:=nil;
			end;
	end;
SGLog.Source('TSGRenderDirectX9__LockResources : Leaving!');
end;

// ������������� ������� � �������� ����������� ��������
procedure TSGRenderDirectX9.UnLockResources();
var
	i:TSGMaxEnum;
	//�����
	VVBuffer: PByte = nil;
	// ��� Lock �������
	rcLockedRect:D3DLOCKED_RECT;

function GetRealChannels(const Format,Channels:TSGLongWord):TSGLongWord;inline;
begin
if (Format=D3DFMT_X8R8G8B8) then
	Result:=4
else
	Result:=Channels;
end;

begin
SGLog.Source('TSGRenderDirectX9__UnLockResources : Entering!');
if FArTextures<>nil then
	begin
	for i:=0 to High(FArTextures) do
		if (FArTextures[i].FBufferChangeFullscreen<>nil) then
			begin
			if pDevice.CreateTexture(FArTextures[i].FWidth,FArTextures[i].FHeight,FArTextures[i].FChannels,
					D3DUSAGE_DYNAMIC,FArTextures[i].FFormat,D3DPOOL_DEFAULT,FArTextures[i].FTexture,nil)<> D3D_OK then
				begin
				SGLog.Source('TSGRenderDirectX9__UnLockResources : Errior while IDirect3DDevice9__CreateTexture');
				end
			else
				begin
				FillChar(rcLockedRect,SizeOf(rcLockedRect),0);
				if FArTextures[i].FTexture.LockRect(0, rcLockedRect, nil, D3DLOCK_DISCARD or D3DLOCK_NOOVERWRITE) <> D3D_OK then
					begin
					SGLog.Source('TSGRenderDirectX9__UnLockResources : Errior while IDirect3DTexture9__LockRect');
					end
				else
					begin
					System.Move(FArTextures[i].FBufferChangeFullscreen^,rcLockedRect.pBits^,
						FArTextures[i].FWidth*FArTextures[i].FHeight*GetRealChannels(FArTextures[i].FFormat,FArTextures[i].FChannels));
					System.FreeMem(FArTextures[i].FBufferChangeFullscreen);
					FArTextures[i].FBufferChangeFullscreen:=nil;
					if FArTextures[i].FTexture.UnlockRect(0) <> D3D_OK then
						begin
						SGLog.Source('TSGRenderDirectX9__UnLockResources : Errior while IDirect3DTexture9__UnlockRect');
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
			SGR_ARRAY_BUFFER_ARB:
				begin
				if pDevice.CreateVertexBuffer(FArBuffers[i].FResourceSize,0,0,D3DPOOL_DEFAULT,
					IDirect3DVertexBuffer9(Pointer(FArBuffers[i].FResource)),
					nil)<>D3D_OK then
					begin
					SGLog.Source('TSGRenderDirectX9__BufferDataARB : Failed to Create vertex buffer!');
					end
				else
					begin
					if (FArBuffers[i].FResource as IDirect3DVertexBuffer9).Lock(0,FArBuffers[i].FResourceSize,VVBuffer,0)<>D3D_OK then
						begin
						SGLog.Source('TSGRenderDirectX9__BufferDataARB : Failed to Lock vertex buffer!');
						end
					else
						begin
						System.Move(FArBuffers[i].FBufferChangeFullscreen^,VVBuffer^,FArBuffers[i].FResourceSize);
						System.FreeMem(FArBuffers[i].FBufferChangeFullscreen);
						FArBuffers[i].FBufferChangeFullscreen:=nil;
						if (FArBuffers[i].FResource as IDirect3DVertexBuffer9).UnLock()<>D3D_OK then
							begin
							SGLog.Source('TSGRenderDirectX9__BufferDataARB : Failed to UnLock vertex buffer!');
							end;
						end;
					end;
				end;
			SGR_ELEMENT_ARRAY_BUFFER_ARB:
				begin
				if pDevice.CreateIndexBuffer(FArBuffers[i].FResourceSize,0,D3DFMT_INDEX16,D3DPOOL_DEFAULT,
						IDirect3DIndexBuffer9(Pointer(FArBuffers[i].FResource)),nil)<>D3D_OK then
					begin
					SGLog.Source('TSGRenderDirectX9__UnLockResources : Errior while IDirect3DDevice9__CreateIndexBuffer');
					end
				else
					begin
					if (FArBuffers[i].FResource as IDirect3DIndexBuffer9).Lock(0,FArBuffers[i].FResourceSize,VVBuffer,0)<>D3D_OK then
						begin
						SGLog.Source('TSGRenderDirectX9__UnLockResources : Failed to Lock index buffer!');
						end
					else
						begin
						System.Move(FArBuffers[i].FBufferChangeFullscreen^,VVBuffer^,FArBuffers[i].FResourceSize);
						System.FreeMem(FArBuffers[i].FBufferChangeFullscreen);
						FArBuffers[i].FBufferChangeFullscreen:=nil;
						if (FArBuffers[i].FResource as IDirect3DIndexBuffer9).UnLock()<>D3D_OK then
							begin
							SGLog.Source('TSGRenderDirectX9__UnLockResources : Failed to UnLock index buffer!');
							end;
						end;
					end;
				end;
			end;
			end;
	end;
SGLog.Source('TSGRenderDirectX9__UnLockResources : Leaving!');
end;

end.
