{$IFDEF UNIX}
	{$ERROR "�� ��� �������????"}
{$ELSE}
	{$IFDEF MSWINDOW}
		{$ENDIF}
	{$ENDIF}

{$INCLUDE Includes\SaGe.inc}
unit SaGeRenderDirectX;
interface
uses
	 SaGeBase
	,SaGeBased
	,SaGeRender
	,windows
	,DynLibs
	,DXTypes
	,D3DX9
	,Direct3D9
	;

type
	D3DXVector3 = TD3DXVector3;
	D3DVector = D3DXVector3;
	
	TSGRDTypeDataBuffer=(SGRDTypeDataBufferVertex,SGRDTypeDataBufferColor,SGRDTypeDataBufferNormal,SGRDTypeDataBufferTexVertex);
	TSGRenderDirectX=class(TSGRender)
			public
		constructor Create;override;
		destructor Destroy;override;
			protected
			//FOR USE
		pD3D:IDirect3D9;
		pDevice:IDirect3DDevice9;
			public
		function SetPixelFormat():Boolean;override;overload;
		function CreateContext():Boolean;override;
		function MakeCurrent():Boolean;override;
		procedure ReleaseCurrent();override;
		procedure Init();override;
		procedure Viewport(const a,b,c,d:LongWord);override;
		procedure SwapBuffers();override;
		procedure MouseShift(var x,y:LongInt;const VFullscreen:Boolean = False);override;
		function SupporedVBOBuffers:Boolean;override;
			public
		procedure InitOrtho2d(const x0,y0,x1,y1:TSGSingle);override;
		procedure InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht:Real = 1);override;
		procedure LoadIdentity();override;
		procedure Vertex3f(const x,y,z:single);override;
		procedure BeginScene(const VPrimitiveType:TSGPrimtiveType);override;
		procedure EndScene();override;
		// ���������� �������� ������� � �������� ������ �������
		procedure LockResourses();override;
		// ������������� ������� � �������� ����������� ��������
		procedure UnLockResourses();override;
		
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
		procedure TexImage2D(const VTextureType:Cardinal;const VP1:Cardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:Cardinal;var VBitMap:Pointer);override;
		procedure ReadPixels(const x,y:Integer;const Vwidth,Vheight:Integer;const format, atype: Cardinal;const pixels: Pointer);override;
		procedure CullFace(const VParam:Cardinal);override;
		procedure EnableClientState(const VParam:Cardinal);override;
		procedure DisableClientState(const VParam:Cardinal);override;
		procedure GenBuffersARB(const VQ:Integer;const PT:PCardinal);override;
		procedure DeleteBuffersARB(const VQuantity:LongWord;VPoint:Pointer);override;
		procedure BindBufferARB(const VParam:Cardinal;const VParam2:Cardinal);override;
		procedure BufferDataARB(const VParam:Cardinal;const VSize:int64;VBuffer:Pointer;const VParam2:Cardinal);override;
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
		// ������, ������� � ���������� ����������� � ������� pDevice.DrawPrimitiveUP(..)
		FArPoints:array[0..2]of 
			packed record
				x,y,z : single;
				Color : LongWord;
				tx,ty : Single;
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
			FResourse:IDirect3DResource9;
			// ��� ������
			FResourseSize:QWord;
			// ��� ��������� ��������� ��� ������ ��� ����������.
			FVertexDeclaration:IDirect3DVertexDeclaration9;
			// ��� ������������ ��� �������� ������ ��� ���������� ���������.
			FBufferChangeFullscreen:PByte;
			end;
		FEnabledClientStateVertex    : Boolean;
		FEnabledClientStateColor     : Boolean;
		FEnabledClientStateNormal    : Boolean;
		FEnabledClientStateTexVertex : Boolean;
		FVBOData:packed array [0..1] of LongWord;
		// FVBOData[0] - SGR_ARRAY_BUFFER_ARB
		// FVBOData[1] - SGR_ELEMENT_ARRAY_BUFFER_ARB
		FArDataBuffers:packed array[TSGRDTypeDataBuffer] of 
			packed record
			// ��������� �� ������ ��������������� ������ FVBOData[0]
			FVBOBuffer:LongWord;
			// � FVBOData ������������ ������� ��������� �����.
			// ���� ������� �� �������, �� ��������������� ��������, ������� ��������� � FVBOData[0]
			FQuantityParams:Byte;
			// FQuantityParams --- ���������� ���������� (������ �������� � gl*Pointer (��� �������� �� ������� 3)
			FDataType:LongWOrd;
			// FDataType --- ��� ������. ���� Float, Unsigned_byte ��� � �
			FSizeOfOneVertex:Byte;
			// FSizeOfOneVertex --- ������ ������ �������� � �������
			FShift:TSGMaxEnum;
			// FShift --- ���� VBO - �������� � ������ ������������ ������ ����� ���������� �������.
			// � ���� �� VBO - ��������� �� ������ ������� �������. (��� �� ��������� ��������� ������)
			end;
		
			(* Light *)
		FLigth               : D3DLIGHT9;
		
			(* PushMatrix/PopMatrix *)
		FQuantitySavedMatrix : LongWord;
		FLengthArSavedMatrix : LongWord;
		FArSavedMatrix       : packed array of D3DMATRIX;
			private
		procedure AfterVertexProc();inline;
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

implementation

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

procedure TSGRenderDirectX.PushMatrix();
begin
if FQuantitySavedMatrix+1<=FLengthArSavedMatrix then
	begin
	pDevice.GetTransform(D3DTS_VIEW,FArSavedMatrix[FQuantitySavedMatrix]);
	FQuantitySavedMatrix+=1;
	end
else
	begin
	FQuantitySavedMatrix+=1;
	FLengthArSavedMatrix+=1;
	SetLength(FArSavedMatrix,FLengthArSavedMatrix);
	pDevice.GetTransform(D3DTS_VIEW,FArSavedMatrix[FQuantitySavedMatrix-1]);
	end;
end;

procedure TSGRenderDirectX.PopMatrix();
begin
if FQuantitySavedMatrix=0 then
	SGLog.Sourse('TSGRenderDirectX.PopMatrix : Pop matrix before pushing')
else
	begin
	pDevice.SetTransform(D3DTS_VIEW,FArSavedMatrix[FQuantitySavedMatrix-1]);
	FQuantitySavedMatrix-=1;
	end;
end;

procedure TSGRenderDirectX.MouseShift(var x,y:LongInt;const VFullscreen:Boolean = False);
begin
x:=
	Byte(not VFullscreen)*(-8+
	Round(LongWord(FWindow.Get('CURPOSX'))/LongWord(FWindow.Get('WIDTH'))*15));
y:=
	Byte(not VFullscreen)*(-28+
	Round(LongWord(FWindow.Get('CURPOSY'))/LongWord(FWindow.Get('HEIGHT'))*33));
end;

procedure TSGRenderDirectX.SwapBuffers();
begin
pDevice.Present(nil, nil, 0, nil);
end;

procedure TSGRenderDirectX.AfterVertexProc();inline;
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

function TSGRenderDirectX.SupporedVBOBuffers():Boolean;
begin
Result:=True;
end;

procedure TSGRenderDirectX.PointSize(const PS:Single);
begin

end;

procedure TSGRenderDirectX.LineWidth(const VLW:Single);
begin

end;

procedure TSGRenderDirectX.Color3f(const r,g,b:single);
begin
Color4f(r,g,b,1);
end;

procedure TSGRenderDirectX.TexCoord2f(const x,y:single); 
begin 
FArPoints[FNumberOfPoints].tx:=x;
FArPoints[FNumberOfPoints].ty:=y;
end;

procedure TSGRenderDirectX.Vertex2f(const x,y:single); 
begin
FArPoints[FNumberOfPoints].Color:=FNowColor;
FArPoints[FNumberOfPoints].x:=x;
FArPoints[FNumberOfPoints].y:=y;
FArPoints[FNumberOfPoints].z:=0;
FNumberOfPoints+=1;
AfterVertexProc();
end;

procedure TSGRenderDirectX.Color4f(const r,g,b,a:single); 
begin
FNowColor:=D3DCOLOR_ARGB(
	Byte(a>=1)*255+Byte((a<1) and (a>0))*round(255*a),
	Byte(r>=1)*255+Byte((r<1) and (r>0))*round(255*r),
	Byte(g>=1)*255+Byte((g<1) and (g>0))*round(255*g),
	Byte(b>=1)*255+Byte((b<1) and (b>0))*round(255*b));
end;

procedure TSGRenderDirectX.MultMatrixf(const Variable : TSGPointer);
var
	Matrix1,MatrixOut:D3DMATRIX;
begin 
pDevice.GetTransform(D3DTS_VIEW,Matrix1);
D3DXMatrixMultiply(MatrixOut,PD3DMATRIX(Variable)^,Matrix1);
pDevice.SetTransform(D3DTS_VIEW,MatrixOut);
end;

procedure TSGRenderDirectX.Translatef(const x,y,z:single); 
var
	Matrix1,Matrix2,MatrixOut:D3DMATRIX;
begin 
pDevice.GetTransform(D3DTS_VIEW,Matrix1);
D3DXMatrixTranslation(Matrix2,x,y,-z);
D3DXMatrixMultiply(MatrixOut,Matrix1,Matrix2);
pDevice.SetTransform(D3DTS_VIEW,MatrixOut);
end;

procedure TSGRenderDirectX.Rotatef(const angle:single;const x,y,z:single); 
var
	Matrix1,Matrix2,MatrixOut:D3DMATRIX;
	v:TD3DXVector3;
begin 
v.x:=x;
v.y:=y;
v.z:=z;
pDevice.GetTransform(D3DTS_VIEW,Matrix1);
D3DXMatrixRotationAxis(Matrix2,v,angle/180*pi);
D3DXMatrixMultiply(MatrixOut,Matrix2,Matrix1);
pDevice.SetTransform(D3DTS_VIEW,MatrixOut);
end;

procedure TSGRenderDirectX.Enable(VParam:Cardinal); 
begin
case VParam of
SGR_LIGHTING:
	begin
	pDevice.SetRenderState(D3DRS_LIGHTING,1);
	end;
SGR_LIGHT0..SGR_LIGHT7:
	begin
	pDevice.LightEnable(VParam-SGR_LIGHT0,True);
	end;
end;
end;

procedure TSGRenderDirectX.Disable(const VParam:Cardinal); 
begin 
case VParam of
SGR_TEXTURE_2D:
	begin
	FNowTexture:=0;
	pDevice.SetTexture(0,nil);
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
end;
end;

procedure TSGRenderDirectX.DeleteTextures(const VQuantity:Cardinal;const VTextures:PSGUInt); 
var
	i:LongWord;
begin 
for i:=0 to VQuantity-1 do
	begin
	if (VTextures[i]>0) and (VTextures[i]<=Length(FArTextures)) and (FArTextures[VTextures[i]-1].FTexture<>nil) then
		begin
		FArTextures[VTextures[i]-1].FTexture._Release();
		FArTextures[VTextures[i]-1].FTexture:=nil;
		if FArTextures[VTextures[i]-1].FBufferChangeFullscreen<>nil then
			FreeMem(FArTextures[VTextures[i]-1].FBufferChangeFullscreen);
		FArTextures[VTextures[i]-1].FBufferChangeFullscreen:=nil;
		end;
	end;
end;

procedure TSGRenderDirectX.Lightfv(const VLight,VParam:Cardinal;const VParam2:Pointer); 
type
	PArS = ^ Single;
begin 
{FLigth._Type:=D3DLIGHT_POINT;}
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
		//FLigth.Attenuation1:=0;
		//FLigth.Attenuation2:=0.01;
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

procedure TSGRenderDirectX.GenTextures(const VQuantity:Cardinal;const VTextures:PSGUInt); 
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

procedure TSGRenderDirectX.BindTexture(const VParam:Cardinal;const VTexture:Cardinal); 
begin 
FNowTexture:=VTexture;
if (FArTextures<>nil) and (FNowTexture-1>=0) and (Length(FArTextures)>FNowTexture-1) and (FArTextures[FNowTexture-1].FTexture<>nil) then
	pDevice.SetTexture(0, FArTextures[FNowTexture-1].FTexture);
end;

procedure TSGRenderDirectX.TexParameteri(const VP1,VP2,VP3:Cardinal);
begin 
if (VP1 = SGR_TEXTURE_2D) or (VP1 = SGR_TEXTURE_1D) then//or (VP1 = SGR_TEXTURE_3D) then
	begin
	case VP2 of
	SGR_TEXTURE_MIN_FILTER:
		if VP3 = SGR_LINEAR then
			pDevice.SetSamplerState( 0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR)
		else if VP3 = SGR_NEAREST then
			pDevice.SetSamplerState( 0, D3DSAMP_MINFILTER, D3DTEXF_POINT); 
	SGR_TEXTURE_MAG_FILTER:
		if VP3 = SGR_LINEAR then
			pDevice.SetSamplerState( 0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR)
		else if VP3 = SGR_NEAREST then
			pDevice.SetSamplerState( 0, D3DSAMP_MAGFILTER, D3DTEXF_POINT); 
	end;
	end;
end;

procedure TSGRenderDirectX.PixelStorei(const VParamName:Cardinal;const VParam:SGInt); 
begin 

end;

procedure TSGRenderDirectX.TexEnvi(const VP1,VP2,VP3:Cardinal); 
begin 

end;

procedure TSGRenderDirectX.TexImage2D(const VTextureType:Cardinal;const VP1:Cardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:Cardinal;var VBitMap:Pointer); 
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
	SGLog.Sourse('TSGRenderDirectX__TexImage2D : "IDirect3DDevice9__CreateTexture" failed...')
else
	begin
	fillchar(rcLockedRect,sizeof(rcLockedRect),0);
	if FArTextures[FNowTexture-1].FTexture.LockRect(0, rcLockedRect, nil, D3DLOCK_DISCARD or D3DLOCK_NOOVERWRITE) <> D3D_OK then
		SGLog.Sourse('TSGRenderDirectX__TexImage2D : "IDirect3DTexture9__LockRect" failed...')
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
			SGLog.Sourse('TSGRenderDirectX__TexImage2D : "IDirect3DTexture9__UnlockRect" failed...');
		end;
	end;
end;

procedure TSGRenderDirectX.ReadPixels(const x,y:Integer;const Vwidth,Vheight:Integer;const format, atype: Cardinal;const pixels: Pointer); 
begin 

end;

procedure TSGRenderDirectX.CullFace(const VParam:Cardinal); 
begin 
case VParam of
SGR_BACK:pDevice.SetRenderState( D3DRS_CULLMODE, D3DCULL_CW );
SGR_FRONT:pDevice.SetRenderState( D3DRS_CULLMODE, D3DCULL_CCW );
end;
end;

procedure TSGRenderDirectX.EnableClientState(const VParam:Cardinal); 
begin 
case VParam of
SGR_VERTEX_ARRAY:FEnabledClientStateVertex:=True;
SGR_NORMAL_ARRAY:FEnabledClientStateNormal:=True;
SGR_TEXTURE_COORD_ARRAY:FEnabledClientStateTexVertex:=True;
SGR_COLOR_ARRAY:FEnabledClientStateColor:=True;
end;
end;

procedure TSGRenderDirectX.DisableClientState(const VParam:Cardinal); 
begin 
case VParam of
SGR_VERTEX_ARRAY:FEnabledClientStateVertex:=False;
SGR_NORMAL_ARRAY:FEnabledClientStateNormal:=False;
SGR_TEXTURE_COORD_ARRAY:FEnabledClientStateTexVertex:=False;
SGR_COLOR_ARRAY:FEnabledClientStateColor:=False;
end;
end;

procedure TSGRenderDirectX.GenBuffersARB(const VQ:Integer;const PT:PCardinal); 
var
	i:LongWord;
begin 
for i:=0 to VQ-1 do
	begin
	if FArBuffers=nil then
		SetLength(FArBuffers,1)
	else
		SetLength(FArBuffers,Length(FArBuffers)+1);
	FArBuffers[High(FArBuffers)].FResourse:=nil;
	FArBuffers[High(FArBuffers)].FResourseSize:=0;
	FArBuffers[High(FArBuffers)].FVertexDeclaration:=nil;
	FArBuffers[High(FArBuffers)].FBufferChangeFullscreen:=nil;
	FArBuffers[High(FArBuffers)].FType:=0;
	PT[i]:=Length(FArBuffers);
	end;
end;

procedure TSGRenderDirectX.DeleteBuffersARB(const VQuantity:LongWord;VPoint:Pointer); 
var
	i:LongWord;
begin 
for i:=0 to VQuantity-1 do
	if FArBuffers[PLongWord(VPoint)[i]-1].FResourse<>nil then
		begin
		FArBuffers[PLongWord(VPoint)[i]-1].FResourse._Release();
		FArBuffers[PLongWord(VPoint)[i]-1].FResourse:=nil;
		FArBuffers[PLongWord(VPoint)[i]-1].FResourseSize:=0;
		FArBuffers[PLongWord(VPoint)[i]-1].FType:=0;
		if FArBuffers[PLongWord(VPoint)[i]-1].FVertexDeclaration<>nil then
			begin
			FArBuffers[PLongWord(VPoint)[i]-1].FVertexDeclaration._Release();
			FArBuffers[PLongWord(VPoint)[i]-1].FVertexDeclaration:=nil;
			end;
		PLongWord(VPoint)[i]:=0;
		end;
end;

procedure TSGRenderDirectX.BindBufferARB(const VParam:Cardinal;const VParam2:Cardinal);
begin 
case VParam of
SGR_ARRAY_BUFFER_ARB:FVBOData[0]:=VParam2;
SGR_ELEMENT_ARRAY_BUFFER_ARB:FVBOData[1]:=VParam2;
end;
end;

procedure TSGRenderDirectX.BufferDataARB(
	const VParam:Cardinal;   // SGR_ARRAY_BUFFER_ARB or SGR_ELEMENT_ARRAY_BUFFER_ARB
	const VSize:int64;       // ������ � ������
	VBuffer:Pointer;         // �����
	const VParam2:Cardinal);
var
	VVBuffer:PByte = nil;
begin 
if (VParam=SGR_ARRAY_BUFFER_ARB) and (FVBOData[0]>0) then
	begin
	if pDevice.CreateVertexBuffer(VSize,0,0,D3DPOOL_DEFAULT,
		IDirect3DVertexBuffer9(Pointer(FArBuffers[FVBOData[0]-1].FResourse)),
		nil)<>D3D_OK then
		begin
		SGLog.Sourse('TSGRenderDirectX__BufferDataARB : Failed to Create vertex buffer!');
		Exit;
		end
	else
		begin
		FArBuffers[FVBOData[0]-1].FType:=VParam;
		if (FArBuffers[FVBOData[0]-1].FResourse as IDirect3DVertexBuffer9).Lock(0,VSize,VVBuffer,0)<>D3D_OK then
			begin
			SGLog.Sourse('TSGRenderDirectX__BufferDataARB : Failed to Lock vertex buffer!');
			Exit;
			end
		else
			begin
			System.Move(VBuffer^,VVBuffer^,VSize);
			FArBuffers[FVBOData[0]-1].FResourseSize:=VSize;
			if (FArBuffers[FVBOData[0]-1].FResourse as IDirect3DVertexBuffer9).UnLock()<>D3D_OK then
				begin
				SGLog.Sourse('TSGRenderDirectX__BufferDataARB : Failed to UnLock vertex buffer!');
				Exit;
				end;
			//SGLog.Sourse(['TSGRenderDirectX__BufferDataARB : Sucssesful create and lock data to ',FVBOData[0],' vertex buffer!']);
			end;
		end;
	end
else if (VParam=SGR_ELEMENT_ARRAY_BUFFER_ARB) and (FVBOData[1]>0) then
	begin
	if pDevice.CreateIndexBuffer(VSize,0,D3DFMT_INDEX16,D3DPOOL_DEFAULT,
		IDirect3DIndexBuffer9(Pointer(FArBuffers[FVBOData[1]-1].FResourse)),nil)<>D3D_OK then
		begin
		SGLog.Sourse('TSGRenderDirectX__BufferDataARB : Failed to Create index buffer!');
		exit;
		end
	else
		begin
		FArBuffers[FVBOData[1]-1].FType:=VParam;
		if (FArBuffers[FVBOData[1]-1].FResourse as IDirect3DIndexBuffer9).Lock(0,VSize,VVBuffer,0)<>D3D_OK then
			begin
			SGLog.Sourse('TSGRenderDirectX__BufferDataARB : Failed to Lock index buffer!');
			Exit;
			end
		else
			begin
			System.Move(VBuffer^,VVBuffer^,VSize);
			FArBuffers[FVBOData[1]-1].FResourseSize:=VSize;
			if (FArBuffers[FVBOData[1]-1].FResourse as IDirect3DIndexBuffer9).UnLock()<>D3D_OK then
				begin
				SGLog.Sourse('TSGRenderDirectX__BufferDataARB : Failed to UnLock index buffer!');
				Exit;
				end;
			//SGLog.Sourse(['TSGRenderDirectX__BufferDataARB : Sucssesful create and lock data to ',FVBOData[1],' indexes buffer!']);
			end;
		end;
	end
else SGLog.Sourse('TSGRenderDirectX__BufferDataARB : Some params incorect!');
end;

procedure TSGRenderDirectX.DrawElements(
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
	if pDevice.SetStreamSource(0,IDirect3DVertexBuffer9(Pointer(FArBuffers[FVBOData[0]-1].FResourse)),0,FArDataBuffers[SGRDTypeDataBufferVertex].FSizeOfOneVertex)<>D3D_OK then
		SGLog.Sourse('TSGRenderDirectX__DrawElements : SetStreamSource : Failed!!');
	//Set Index buffer
	if pDevice.SetIndices(IDirect3DIndexBuffer9(Pointer(FArBuffers[FVBOData[1]-1].FResourse))) <> D3D_OK then
		SGLog.Sourse('TSGRenderDirectX__DrawElements : SetIndices : Failed!!');
	//Draw
	if pDevice.DrawIndexedPrimitive(SGRDXConvertPrimetiveType(VParam),0,0,
		FArBuffers[FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer-1].FResourseSize div 
		FArDataBuffers[SGRDTypeDataBufferVertex].FSizeOfOneVertex
		,0,SGRDXGetNumPrimetives(VParam,VSize))<>D3D_OK then
			SGLog.Sourse('TSGRenderDirectX__DrawElements : DrawIndexedPrimitive : Draw Failed!! ');
	pDevice.EndScene();
	end
else
	begin
	SGLog.Sourse('TSGRenderDirectX__DrawElements : Draw indexed primitive without VBO not possible!');
	end;
end;

procedure TSGRenderDirectX.DrawArrays(const VParam:TSGCardinal;const VFirst,VCount:TSGLongWord);
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
	if pDevice.SetStreamSource(0,IDirect3DVertexBuffer9(Pointer(FArBuffers[FVBOData[0]-1].FResourse)),0,FArDataBuffers[SGRDTypeDataBufferVertex].FSizeOfOneVertex)<>D3D_OK then
		SGLog.Sourse('TSGRenderDirectX__DrawArrays : SetStreamSource : Failed!!');
	//Set Index buffer
	if pDevice.SetIndices(nil) <> D3D_OK then
		SGLog.Sourse('TSGRenderDirectX__DrawArrays : SetIndices(nil) : Failed!!');
	pDevice.DrawPrimitive(SGRDXConvertPrimetiveType(VParam),VFirst,SGRDXGetNumPrimetives(VParam,VCount));
	pDevice.EndScene();
	end;
end;

procedure TSGRenderDirectX.ColorPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 
FArDataBuffers[SGRDTypeDataBufferColor].FQuantityParams:=VQChannels;
FArDataBuffers[SGRDTypeDataBufferColor].FVBOBuffer:=FVBOData[0];
FArDataBuffers[SGRDTypeDataBufferColor].FDataType:=VType;
FArDataBuffers[SGRDTypeDataBufferColor].FSizeOfOneVertex:=VSize;
FArDataBuffers[SGRDTypeDataBufferColor].FShift:=TSGMaxEnum(VBuffer);
end;

procedure TSGRenderDirectX.TexCoordPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 
FArDataBuffers[SGRDTypeDataBufferTexVertex].FQuantityParams:=VQChannels;
FArDataBuffers[SGRDTypeDataBufferTexVertex].FVBOBuffer:=FVBOData[0];
FArDataBuffers[SGRDTypeDataBufferTexVertex].FDataType:=VType;
FArDataBuffers[SGRDTypeDataBufferTexVertex].FSizeOfOneVertex:=VSize;
FArDataBuffers[SGRDTypeDataBufferTexVertex].FShift:=TSGMaxEnum(VBuffer);
end;

procedure TSGRenderDirectX.NormalPointer(const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 
FArDataBuffers[SGRDTypeDataBufferNormal].FQuantityParams:=3;
FArDataBuffers[SGRDTypeDataBufferNormal].FVBOBuffer:=FVBOData[0];
FArDataBuffers[SGRDTypeDataBufferNormal].FDataType:=VType;
FArDataBuffers[SGRDTypeDataBufferNormal].FSizeOfOneVertex:=VSize;
FArDataBuffers[SGRDTypeDataBufferNormal].FShift:=TSGMaxEnum(VBuffer);
end;

procedure TSGRenderDirectX.VertexPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 
FArDataBuffers[SGRDTypeDataBufferVertex].FQuantityParams:=VQChannels;
FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer:=FVBOData[0];
FArDataBuffers[SGRDTypeDataBufferVertex].FDataType:=VType;
FArDataBuffers[SGRDTypeDataBufferVertex].FSizeOfOneVertex:=VSize;
FArDataBuffers[SGRDTypeDataBufferVertex].FShift:=TSGMaxEnum(VBuffer);
end;

function TSGRenderDirectX.IsEnabled(const VParam:Cardinal):Boolean; 
begin 
Result:=False;
end;

procedure TSGRenderDirectX.Clear(const VParam:Cardinal); 
begin 
pDevice.Clear( 0, nil, D3DCLEAR_TARGET or D3DCLEAR_ZBUFFER, FClearColor, 1.0, 0 );
end;

procedure TSGRenderDirectX.BeginScene(const VPrimitiveType:TSGPrimtiveType);
const
	MyVertexType:LongWord = D3DFVF_XYZ or D3DFVF_DIFFUSE or D3DFVF_TEX1;
begin
FPrimetiveType:=VPrimitiveType;
FPrimetivePrt:=0;
FNumberOfPoints:=0;
pDevice.BeginScene();
pDevice.SetFVF( MyVertexType );
end;

procedure TSGRenderDirectX.EndScene();
begin
if (FPrimetiveType=SGR_LINE_LOOP) and (FNumberOfPoints=1) and (FPrimetivePrt=1) then
	begin
	pDevice.DrawPrimitiveUP( D3DPT_LINELIST, 1, FArPoints[1], sizeof(FArPoints[0]));
	end;
pDevice.EndScene();
end;

procedure TSGRenderDirectX.Init();
var
	Material:D3DMATERIAL9;
	VectorDir:D3DXVECTOR3;
begin
FNowColor:=D3DCOLOR_ARGB(255,255,255,255);
FClearColor:=D3DCOLOR_COLORVALUE(0.0,0.0,0.0,1.0);
FNowTexture:=0;

//�������� Z-�����
pDevice.SetRenderState(D3DRS_ZENABLE, 1);

//������������� ��������
(*�������!*)
{Diffuse - ������������ ����. 
 Ambient - ������� ����. 
 Specular - ���������� ����. 
 Emissive - ����������� �������� �������. 
 Power - �������� ���������.}
FillChar(Material,SizeOf(Material),0);
Material.Diffuse:=SGRDXGetD3DCOLORVALUE(1,1,1,1);
Material.Ambient:=SGRDXGetD3DCOLORVALUE(0,0,0,0);
Material.Specular:=SGRDXGetD3DCOLORVALUE(0.4,0.4,0.4,1);
Material.Emissive:=SGRDXGetD3DCOLORVALUE(0,0,0,0);
Material.Power:=2;
pDevice.SetMaterial(Material);

//������������� ���������
FillChar(FLigth,SizeOf(FLigth),0);
FLigth._Type:=D3DLIGHT_POINT;
FLigth.Diffuse:=SGRDXGetD3DCOLORVALUE(1,1,1,1);
FLigth.Ambient:=SGRDXGetD3DCOLORVALUE(0.5,0.5,0.5,1.0);
FLigth.Specular:=SGRDXGetD3DCOLORVALUE(1.0,1.0,1.0,1.0);
// ������ ����������, �� ������� ���������� ���������, ������ �� ������.
FLigth.Range := 1000;
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

//�������� ���������� �������
pDevice.SetSamplerState( 0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR); 
pDevice.SetSamplerState( 0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
//�� MIP �������� � ������� ��������� ��������
//pDevice.SetSamplerState( 0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR); 

//T�������� ���������� �������
(*pDevice.SetSamplerState( 0, D3DSAMP_MINFILTER, D3DTEXF_POINT); 
pDevice.SetSamplerState( 0, D3DSAMP_MAGFILTER, D3DTEXF_POINT);*)

//������������ ���������� �������
(*pDevice.SetSamplerState(0,D3DSAMP_MAGFILTER,D3DTEXF_ANISOTROPIC);
pDevice.SetSamplerState(0,D3DSAMP_MINFILTER,D3DTEXF_ANISOTROPIC);
pDevice.SetSamplerState(0, D3DSAMP_MAXANISOTROPY, 4);*)

//������ ����������� ������� 
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

constructor TSGRenderDirectX.Create();
begin
inherited Create();
FType:=SGRenderDirectX;
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

destructor TSGRenderDirectX.Destroy();
var
	i:Cardinal;
begin
if FArBuffers<>nil then
	begin
	for i:=0 to High(FArBuffers) do
		begin
		if FArBuffers[i].FResourse<>nil then
			FArBuffers[i].FResourse._Release();
		if FArBuffers[i].FVertexDeclaration<>nil then
			FArBuffers[i].FVertexDeclaration._Release();
		end;
	SetLength(FArBuffers,0);
	end;
if FArTextures<>nil then
	begin
	for i:=0 to High(FArTextures) do
		begin
		if FArTextures[i].FTexture<>nil then
			FArTextures[i].FTexture._Release;
		if FArTextures[i].FBufferChangeFullscreen<>nil then
			FreeMem(FArTextures[i].FBufferChangeFullscreen);
		end;
	SetLength(FArTextures,0);
	end;
if (pDevice<>nil)  then
	pDevice._Release();
if(pD3d<>nil) then
	pD3d._Release();
inherited Destroy();
end;

procedure TSGRenderDirectX.InitOrtho2d(const x0,y0,x1,y1:TSGSingle);
var
	Matrix:D3DMATRIX;
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
end;

procedure TSGRenderDirectX.InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht:Real = 1);
var
	Matrix:D3DMATRIX;
var
	CWidth,CHeight:LongWord;
begin
CWidth:=LongWord(FWindow.Get('WIDTH'));
CHeight:=LongWord(FWindow.Get('HEIGHT'));
LoadIdentity();
if Mode=SG_3D then
	begin
	D3DXMatrixPerspectiveFovLH(Matrix,            // ������������� ��������
		D3DX_PI/4,                                // ���� ������ 
		CWidth/CHeight,                           // ��������� ������ ������
		0.0011,                                   // �������� ��������� ���������
		500);                                     // ������ ��������� ���������
	pDevice.SetTransform(D3DTS_PROJECTION, Matrix);
	D3DXMatrixScaling(Matrix,1,1,-1);
	pDevice.SetTransform(D3DTS_VIEW, Matrix);
	end
else
	if Mode=SG_3D_ORTHO then
		begin
		D3DXMatrixOrthoLH(Matrix,D3DX_PI/4*dncht*30,D3DX_PI/4*dncht*30/CWidth*CHeight,0.0011,500);
		pDevice.SetTransform(D3DTS_PROJECTION, Matrix);
		D3DXMatrixScaling(Matrix,1,1,-1);
		pDevice.SetTransform(D3DTS_VIEW, Matrix);
		end
	else if Mode=SG_2D then
		begin
		D3DXMatrixOrthoLH(Matrix,CWidth,-CHeight,-0.001,0.1);
		pDevice.SetTransform(D3DTS_PROJECTION, Matrix);
		
		D3DXMatrixTranslation(Matrix,-CWidth/2,-CHeight/2,0);
		pDevice.SetTransform(D3DTS_VIEW, Matrix);
		end;
end;

procedure TSGRenderDirectX.Viewport(const a,b,c,d:LongWord);
begin

end;

procedure TSGRenderDirectX.LoadIdentity();
var
	Matrix:D3DMATRIX;
begin
D3DXMatrixIdentity(Matrix);
pDevice.SetTransform(D3DTS_WORLD,Matrix);
pDevice.SetTransform(D3DTS_VIEW,Matrix);
pDevice.SetTransform(D3DTS_PROJECTION,Matrix);
end;


procedure TSGRenderDirectX.Vertex3fv(const Variable : TSGPointer);
begin
FArPoints[FNumberOfPoints].Color:=FNowColor;
System.Move(Variable^,FArPoints[FNumberOfPoints].x,SizeOf(Single)*3);
FNumberOfPoints+=1;
AfterVertexProc();
end;

procedure TSGRenderDirectX.Normal3f(const x,y,z:single); 
begin 

end;

procedure TSGRenderDirectX.Normal3fv(const Variable : TSGPointer);
begin

end;

procedure TSGRenderDirectX.Vertex3f(const x,y,z:single);
begin
FArPoints[FNumberOfPoints].Color:=FNowColor;
FArPoints[FNumberOfPoints].x:=x;
FArPoints[FNumberOfPoints].y:=y;
FArPoints[FNumberOfPoints].z:=z;
FNumberOfPoints+=1;
AfterVertexProc();
end;

function TSGRenderDirectX.CreateContext():Boolean;
var
	//d3ddm:D3DDISPLAYMODE;
	d3dpp:D3DPRESENT_PARAMETERS;
begin
if (pD3D=nil) then
	begin
	pD3D:=Direct3DCreate9( D3D_SDK_VERSION );
	SGLog.Sourse(['TSGRenderDirectX__CreateContext : IDirect3D9="',TSGMaxEnum(Pointer(pD3D)),'"']);
	if pD3d = nil then
		begin
		Result:=False;
		exit;
		end;
	end;
if pDevice=nil then
	begin
	//pD3D.GetAdapterDisplayMode( D3DADAPTER_DEFAULT,d3ddm);
	
	FillChar(d3dpp,SizeOf(d3dpp),0);
	d3dpp.Windowed := True;
	d3dpp.SwapEffect := D3DSWAPEFFECT_DISCARD;
	d3dpp.hDeviceWindow := LongWord(FWindow.Get('WINDOW HANDLE'));
	d3dpp.BackBufferFormat := D3DFMT_X8R8G8B8;
	d3dpp.BackBufferWidth :=  LongWord(FWindow.Get('WIDTH'));
	d3dpp.BackBufferHeight := LongWord(FWindow.Get('HEIGHT'));
	d3dpp.EnableAutoDepthStencil:= True;
	d3dpp.AutoDepthStencilFormat := D3DFMT_D24X8;
	d3dpp.PresentationInterval   := D3DPRESENT_INTERVAL_IMMEDIATE;

	//� ���� ��  ������� �������� � ���� ����������
	//d3dpp.MultiSampleType:=D3DMULTISAMPLE_4_SAMPLES;

	if( 0 <> ( pD3d.CreateDevice( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, LongWord(FWindow.Get('WINDOW HANDLE')),
			D3DCREATE_SOFTWARE_VERTEXPROCESSING, @d3dpp, pDevice))) then
		begin
		SGLog.Sourse(['TSGRenderDirectX__CreateContext : IDirect3DDevice9="',TSGMaxEnum(Pointer(pDevice)),'"']);
		Result:=False;
		exit;
		end;
	SGLog.Sourse(['TSGRenderDirectX__CreateContext : IDirect3DDevice9="',TSGMaxEnum(Pointer(pDevice)),'"']);
	Result:=True;
	end
else
	begin
	pDevice._Release();
	pDevice:=nil;
	Result:=CreateContext();
	end;
end;

procedure TSGRenderDirectX.ReleaseCurrent();
begin
if (pDevice<>nil)  then
	begin
	pDevice._Release();
	pDevice:=nil;
	end;
end;

function TSGRenderDirectX.SetPixelFormat():Boolean;overload;
begin
Result:=True;
end;

function TSGRenderDirectX.MakeCurrent():Boolean;
begin
Result:=False;
if FWindow<>nil then
	if ((pD3D=nil) and (pDevice=nil)) or ((pD3D<>nil) and (pDevice=nil)) then
		begin
		Result:=CreateContext();
		if Result then
			Init();
		end;
end;

// ���������� �������� ������� � �������� ������ �������
procedure TSGRenderDirectX.LockResourses();
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
SGLog.Sourse('TSGRenderDirectX__LockResourses : Entering!');
if FArTextures<>nil then
	begin
	//SGLog.Sourse('TSGRenderDirectX__LockResourses : Begin to lock textures!');
	for i:=0 to High(FArTextures) do
		begin
		if (FArTextures[i].FTexture<>nil) then
			begin
			//SGLog.Sourse('TSGRenderDirectX__LockResourses : Begin to lock texture "'+SGStr(i)+'"!');
			FillChar(rcLockedRect,SizeOf(rcLockedRect),0);
			if FArTextures[i].FTexture.LockRect(0, rcLockedRect, nil, D3DLOCK_READONLY) <> D3D_OK then
				begin
				SGLog.Sourse('TSGRenderDirectX__LockResourses : Errior while IDirect3DTexture9__LockRect');
				end
			else
				begin
				System.GetMem(VVBuffer,FArTextures[i].FWidth*FArTextures[i].FHeight*GetRealChannels(FArTextures[i].FFormat,FArTextures[i].FChannels));
				System.Move(rcLockedRect.pBits^,VVBuffer^,FArTextures[i].FWidth*FArTextures[i].FHeight*GetRealChannels(FArTextures[i].FFormat,FArTextures[i].FChannels));
				FArTextures[i].FBufferChangeFullscreen:=VVBuffer;
				VVBuffer:=nil;
				if FArTextures[i].FTexture.UnlockRect(0) <> D3D_OK then
					begin
					SGLog.Sourse('TSGRenderDirectX__LockResourses : Errior while IDirect3DTexture9__UnlockRect');
					end;
				end;
			FArTextures[i].FTexture._Release();
			FArTextures[i].FTexture:=nil;
			end;
		end;
	end;
if FArBuffers<>nil then
	begin
	for i:=0 to High(FArBuffers) do
		if (FArBuffers[i].FResourse<>nil) and (FArBuffers[i].FType<>0) then
			begin
			if FArBuffers[i].FVertexDeclaration <> nil then
				begin
				FArBuffers[i].FVertexDeclaration._Release();
				FArBuffers[i].FVertexDeclaration:=nil;
				end;
			//SGLog.Sourse('TSGRenderDirectX__LockResourses : Begin to lock buffer "'+SGStr(i)+'"!');
			if FArBuffers[i].FType=SGR_ELEMENT_ARRAY_BUFFER_ARB then 
				begin
				if (FArBuffers[i].FResourse as IDirect3DIndexBuffer9).Lock(0,FArBuffers[i].FResourseSize,VVBuffer,0)<>D3D_OK then
					begin
					SGLog.Sourse('TSGRenderDirectX__LockResourses : Errior while IDirect3DIndexBuffer9__Lock');
					end
				else
					begin
					System.GetMem(FArBuffers[i].FBufferChangeFullscreen,FArBuffers[i].FResourseSize);
					System.Move(VVBuffer^,FArBuffers[i].FBufferChangeFullscreen^,FArBuffers[i].FResourseSize);
					if (FArBuffers[i].FResourse as IDirect3DIndexBuffer9).UnLock()<>D3D_OK then
						begin
						SGLog.Sourse('TSGRenderDirectX__LockResourses : Errior while IDirect3DIndexBuffer9__UnLock');
						if VVBuffer<>nil then
							FreeMem(VVBuffer);
						end;
					VVBuffer:=nil;
					end;
				end
			else if FArBuffers[i].FType=SGR_ARRAY_BUFFER_ARB then
				begin
				if (FArBuffers[i].FResourse as IDirect3DVertexBuffer9).Lock(0,FArBuffers[i].FResourseSize,VVBuffer,0)<>D3D_OK then
					begin
					SGLog.Sourse('TSGRenderDirectX__LockResourses : Errior while IDirect3DIndexBuffer9__Lock');
					end
				else
					begin
					System.GetMem(FArBuffers[i].FBufferChangeFullscreen,FArBuffers[i].FResourseSize);
					System.Move(VVBuffer^,FArBuffers[i].FBufferChangeFullscreen^,FArBuffers[i].FResourseSize);
					if (FArBuffers[i].FResourse as IDirect3DVertexBuffer9).UnLock()<>D3D_OK then
						begin
						SGLog.Sourse('TSGRenderDirectX__LockResourses : Errior while IDirect3DIndexBuffer9__UnLock');
						if VVBuffer<>nil then
							FreeMem(VVBuffer);
						end;
					VVBuffer:=nil;
					end;
				end;
			FArBuffers[i].FResourse._Release();
			FArBuffers[i].FResourse:=nil;
			end;
	end;
SGLog.Sourse('TSGRenderDirectX__LockResourses : Leaving!');
end;

// ������������� ������� � �������� ����������� ��������
procedure TSGRenderDirectX.UnLockResourses();
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
SGLog.Sourse('TSGRenderDirectX__UnLockResourses : Entering!');
if FArTextures<>nil then
	begin
	for i:=0 to High(FArTextures) do
		if (FArTextures[i].FBufferChangeFullscreen<>nil) then
			begin
			if pDevice.CreateTexture(FArTextures[i].FWidth,FArTextures[i].FHeight,FArTextures[i].FChannels,
					D3DUSAGE_DYNAMIC,FArTextures[i].FFormat,D3DPOOL_DEFAULT,FArTextures[i].FTexture,nil)<> D3D_OK then
				begin
				SGLog.Sourse('TSGRenderDirectX__UnLockResourses : Errior while IDirect3DDevice9__CreateTexture');
				end
			else
				begin
				FillChar(rcLockedRect,SizeOf(rcLockedRect),0);
				if FArTextures[i].FTexture.LockRect(0, rcLockedRect, nil, D3DLOCK_DISCARD or D3DLOCK_NOOVERWRITE) <> D3D_OK then
					begin
					SGLog.Sourse('TSGRenderDirectX__UnLockResourses : Errior while IDirect3DTexture9__LockRect');
					end
				else
					begin
					System.Move(FArTextures[i].FBufferChangeFullscreen^,rcLockedRect.pBits^,
						FArTextures[i].FWidth*FArTextures[i].FHeight*GetRealChannels(FArTextures[i].FFormat,FArTextures[i].FChannels));
					System.FreeMem(FArTextures[i].FBufferChangeFullscreen);
					FArTextures[i].FBufferChangeFullscreen:=nil;
					if FArTextures[i].FTexture.UnlockRect(0) <> D3D_OK then
						begin
						SGLog.Sourse('TSGRenderDirectX__UnLockResourses : Errior while IDirect3DTexture9__UnlockRect');
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
				if pDevice.CreateVertexBuffer(FArBuffers[i].FResourseSize,0,0,D3DPOOL_DEFAULT,
					IDirect3DVertexBuffer9(Pointer(FArBuffers[i].FResourse)),
					nil)<>D3D_OK then
					begin
					SGLog.Sourse('TSGRenderDirectX__BufferDataARB : Failed to Create vertex buffer!');
					end
				else
					begin
					if (FArBuffers[i].FResourse as IDirect3DVertexBuffer9).Lock(0,FArBuffers[i].FResourseSize,VVBuffer,0)<>D3D_OK then
						begin
						SGLog.Sourse('TSGRenderDirectX__BufferDataARB : Failed to Lock vertex buffer!');
						end
					else
						begin
						System.Move(FArBuffers[i].FBufferChangeFullscreen^,VVBuffer^,FArBuffers[i].FResourseSize);
						System.FreeMem(FArBuffers[i].FBufferChangeFullscreen);
						FArBuffers[i].FBufferChangeFullscreen:=nil;
						if (FArBuffers[i].FResourse as IDirect3DVertexBuffer9).UnLock()<>D3D_OK then
							begin
							SGLog.Sourse('TSGRenderDirectX__BufferDataARB : Failed to UnLock vertex buffer!');
							end;
						end;
					end;
				end;
			SGR_ELEMENT_ARRAY_BUFFER_ARB:
				begin
				if pDevice.CreateIndexBuffer(FArBuffers[i].FResourseSize,0,D3DFMT_INDEX16,D3DPOOL_DEFAULT,
						IDirect3DIndexBuffer9(Pointer(FArBuffers[i].FResourse)),nil)<>D3D_OK then
					begin
					SGLog.Sourse('TSGRenderDirectX__UnLockResourses : Errior while IDirect3DDevice9__CreateIndexBuffer');
					end
				else
					begin
					if (FArBuffers[i].FResourse as IDirect3DIndexBuffer9).Lock(0,FArBuffers[i].FResourseSize,VVBuffer,0)<>D3D_OK then
						begin
						SGLog.Sourse('TSGRenderDirectX__UnLockResourses : Failed to Lock index buffer!');
						end
					else
						begin
						System.Move(FArBuffers[i].FBufferChangeFullscreen^,VVBuffer^,FArBuffers[i].FResourseSize);
						System.FreeMem(FArBuffers[i].FBufferChangeFullscreen);
						FArBuffers[i].FBufferChangeFullscreen:=nil;
						if (FArBuffers[i].FResourse as IDirect3DIndexBuffer9).UnLock()<>D3D_OK then
							begin
							SGLog.Sourse('TSGRenderDirectX__UnLockResourses : Failed to UnLock index buffer!');
							end;
						end;
					end;
				end;
			end;
			end;
	end;
SGLog.Sourse('TSGRenderDirectX__UnLockResourses : Leaving!');
end;

end.
