{$include Includes\SaGe.inc}
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
			//for init
		d3ddm:D3DDISPLAYMODE;
		d3dpp:D3DPRESENT_PARAMETERS;
			//FOR USE
		pD3D:IDirect3D9;
		pDevice:IDirect3DDevice9;
			public
		function SetPixelFormat():Boolean;override;overload;
		function CreateContext():Boolean;override;
		procedure MakeCurrent();override;
		procedure ReleaseCurrent();override;
		procedure Init();override;
		procedure Viewport(const a,b,c,d:LongWord);override;
		procedure SwapBuffers();override;
		procedure MouseShift(var x,y:LongInt;const VFullscreen:Boolean = False);override;
		function SupporedVBOBuffers:Boolean;override;
			public
		procedure InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht:Real = 120);override;
		procedure LoadIdentity();override;
		procedure Vertex3f(const x,y,z:single);override;
		procedure BeginScene(const VPrimitiveType:TSGPrimtiveType);override;
		procedure EndScene();override;
		
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
			private
			//цвет, в который окрашивается буфер при очистке
		FClearColor:LongWord;
			//приведение цветов и полигонов к Vertex-ам опенжл-я
		FPrimetiveType:LongWord;
		FPrimetivePrt:LongWord;
		FNowColor:LongWord;
		FArPoints:array[0..2]of 
			packed record
				x,y,z:single;
				Color:LongWord;
				tx,ty:Single;
				end;
		FNumberOfPoints:LongWord;
			//Textures
		FNowTexture:LongWord;
		FArTextures:packed array of IDirect3DTexture9;
			// ===VBO=== 
		FArBuffers:packed array of 
			packed record 
			FResourse:IDirect3DResource9;
			FResourseSize:QWord;
			FVertexDeclaration:IDirect3DVertexDeclaration9;
			end;
		FEnabledClientStateVertex:Boolean;
		FEnabledClientStateColor:Boolean;
		FEnabledClientStateNormal:Boolean;
		FEnabledClientStateTexVertex:Boolean;
		// 0 - SGR_ARRAY_BUFFER_ARB
		// 1 - SGR_ELEMENT_ARRAY_BUFFER_ARB
		FVBOData:packed array [0..1] of LongWord;
		FArDataBuffers:packed array[TSGRDTypeDataBuffer] of 
			packed record
			FVBOBuffer:LongWord;
			FQuantityParams:Byte;
			FDataType:LongWOrd;
			FSizeOfOneVertex:Byte;
			FShift:Cardinal;
			end;
		// Light
		FLigth:D3DLIGHT9;
			private
		procedure AfterVertexProc();inline;
		end;

implementation

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

procedure TSGRenderDirectX.Normal3f(const x,y,z:single); 
begin 

end;

procedure TSGRenderDirectX.Translatef(const x,y,z:single); 
var
	Matrix1,Matrix2,MatrixOut:D3DMATRIX;
begin 
pDevice.GetTransform(D3DTS_WORLD,Matrix1);
D3DXMatrixTranslation(Matrix2,x,y,-z);
D3DXMatrixMultiply(MatrixOut,Matrix1,Matrix2);
pDevice.SetTransform(D3DTS_WORLD,MatrixOut);
end;

procedure TSGRenderDirectX.Rotatef(const angle:single;const x,y,z:single); 
var
	Matrix1,Matrix2,MatrixOut:D3DMATRIX;
	v:TD3DXVector3;
begin 
v.x:=x;
v.y:=y;
v.z:=z;
pDevice.GetTransform(D3DTS_WORLD,Matrix1);
D3DXMatrixRotationAxis(Matrix2,v,angle/180*pi);
D3DXMatrixMultiply(MatrixOut,Matrix2,Matrix1);
pDevice.SetTransform(D3DTS_WORLD,MatrixOut);
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
	if (VTextures[i]>0) and (VTextures[i]<=Length(FArTextures)) and (FArTextures[VTextures[i]-1]<>nil) then
		begin
		FArTextures[VTextures[i]-1]._Release();
		FArTextures[VTextures[i]-1]:=nil;
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
	FArTextures[High(FArTextures)]:=nil;
	VTextures[i]:=Length(FArTextures);
	end;
end;

procedure TSGRenderDirectX.BindTexture(const VParam:Cardinal;const VTexture:Cardinal); 
begin 
FNowTexture:=VTexture;
if (FArTextures<>nil) and (FNowTexture-1>=0) and (Length(FArTextures)>FNowTexture-1) and (FArTextures[FNowTexture-1]<>nil) then
	pDevice.SetTexture(0, FArTextures[FNowTexture-1]);
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
SGR_RGB:VTFormat:=D3DFMT_X8R8G8B8;//D3DFMT_R8G8B8;
SGR_LUMINANCE_ALPHA:VTFormat:=D3DFMT_A8L8;
SGR_RED:;
SGR_INTENSITY:;
SGR_ALPHA:VTFormat:=D3DFMT_A8;
SGR_LUMINANCE:VTFormat:=D3DFMT_L8;
end;
if VTFormat=D3DFMT_R8G8B8 then
	WriteLn('D3DFMT_R8G8B8');
if pDevice.CreateTexture(VWidth,VHeight,VChannels,D3DUSAGE_DYNAMIC, VTFormat,D3DPOOL_DEFAULT,FArTextures[FNowTexture-1],nil)<> D3D_OK then
	SGLog.Sourse('TSGRenderDirectX__TexImage2D : "D3DXCreateTexture" failed...')
else
	begin
	fillchar(rcLockedRect,sizeof(rcLockedRect),0);

	if FArTextures[FNowTexture-1].LockRect(0, rcLockedRect, nil, D3DLOCK_DISCARD or D3DLOCK_NOOVERWRITE) <> D3D_OK then
		SGLog.Sourse('TSGRenderDirectX__TexImage2D : "pTexture__LockRect" failed...')
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
			Move(VBitMap^,rcLockedRect.pBits^,VWidth*VHeight*VChannels);
		if FArTextures[FNowTexture-1].UnlockRect(0) <> D3D_OK then
			SGLog.Sourse('TSGRenderDirectX__TexImage2D : "pTexture__UnlockRect" failed...');
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
		if FArBuffers[PLongWord(VPoint)[i]-1].FVertexDeclaration<>nil then
			begin
			FArBuffers[PLongWord(VPoint)[i]-1].FVertexDeclaration._Release();
			FArBuffers[PLongWord(VPoint)[i]-1].FVertexDeclaration:=nil;
			end;
		PLongWord(VPoint)[i]:=0;
		end;
end;

procedure TSGRenderDirectX.BindBufferARB(const VParam:Cardinal;const VParam2:Cardinal); 
//SGR_ELEMENT_ARRAY_BUFFER_ARB
//SGR_ARRAY_BUFFER_ARB
begin 
case VParam of
SGR_ARRAY_BUFFER_ARB:FVBOData[0]:=VParam2;
SGR_ELEMENT_ARRAY_BUFFER_ARB:FVBOData[1]:=VParam2;
end;
end;

procedure TSGRenderDirectX.BufferDataARB(
	const VParam:Cardinal;
	const VSize:int64;
	VBuffer:Pointer;
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
			SGLog.Sourse(['TSGRenderDirectX__BufferDataARB : Sucssesful create and lock data to ',FVBOData[0],' vertex buffer!']);
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
			SGLog.Sourse(['TSGRenderDirectX__BufferDataARB : Sucssesful create and lock data to ',FVBOData[1],' indexes buffer!']);
			end;
		end;
	end;
end;

procedure TSGRenderDirectX.DrawElements(
	const VParam:Cardinal;
	const VSize:int64;// не в байтах а в 4*байт
	const VParam2:Cardinal;
	VBuffer:Pointer); 
{var
	VVMyVertexType:Cardinal = 0;}

function GetNumPrimetives:LongWord;inline;
begin
case VParam of
SGR_LINES:Result:=VSize div 2;
SGR_TRIANGLES:Result:=VSize div 3;
SGR_LINE_STRIP:Result:=VSize -1;
else
	Result:=VSize;
end;
end;

function FPT:_D3DPRIMITIVETYPE;inline;
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

var
	VFVFArray:packed array of _D3DVERTEXELEMENT9 = nil;

procedure AddElVFVF();inline;
begin
if VFVFArray= nil then
	SetLength(VFVFArray,1)
else
	SetLength(VFVFArray,Length(VFVFArray)+1);
FillChar(VFVFArray[High(VFVFArray)],SizeOf(_D3DVERTEXELEMENT9),0);
end;

begin 
if VBuffer<>nil then
	Exit;
if (FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer<>0) and (VBuffer=nil) then 
	begin
	if FArBuffers[FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer-1].FVertexDeclaration = nil then
		begin
		if FEnabledClientStateVertex then
			begin
			AddElVFVF();
			VFVFArray[High(VFVFArray)].Offset:=FArDataBuffers[SGRDTypeDataBufferVertex].FShift;
			VFVFArray[High(VFVFArray)]._Type:=D3DDECLTYPE_FLOAT3;
			VFVFArray[High(VFVFArray)].Method:=D3DDECLMETHOD_DEFAULT;
			VFVFArray[High(VFVFArray)].Usage:=D3DDECLUSAGE_POSITION;
			end;
		if FEnabledClientStateColor then
			begin
			AddElVFVF();
			VFVFArray[High(VFVFArray)].Offset:=FArDataBuffers[SGRDTypeDataBufferColor].FShift;
			VFVFArray[High(VFVFArray)]._Type:=D3DDECLTYPE_D3DCOLOR;
			VFVFArray[High(VFVFArray)].Method:=D3DDECLMETHOD_DEFAULT;
			VFVFArray[High(VFVFArray)].Usage:=D3DDECLUSAGE_COLOR;
			end;
		if FEnabledClientStateNormal then
			begin
			AddElVFVF();
			VFVFArray[High(VFVFArray)].Offset:=FArDataBuffers[SGRDTypeDataBufferNormal].FShift;
			VFVFArray[High(VFVFArray)]._Type:=D3DDECLTYPE_FLOAT3;
			VFVFArray[High(VFVFArray)].Method:=D3DDECLMETHOD_DEFAULT;
			VFVFArray[High(VFVFArray)].Usage:=D3DDECLUSAGE_NORMAL;
			end;
		if FEnabledClientStateTexVertex then
			begin
			AddElVFVF();
			VFVFArray[High(VFVFArray)].Offset:=FArDataBuffers[SGRDTypeDataBufferTexVertex].FShift;
			VFVFArray[High(VFVFArray)]._Type:=D3DDECLTYPE_FLOAT2;
			VFVFArray[High(VFVFArray)].Method:=D3DDECLMETHOD_DEFAULT;
			VFVFArray[High(VFVFArray)].Usage:=D3DDECLUSAGE_TEXCOORD;
			end;
		AddElVFVF();
		VFVFArray[High(VFVFArray)]:=D3DDECL_END;
		pDevice.CreateVertexDeclaration(@VFVFArray[0],FArBuffers[FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer-1].FVertexDeclaration);
		end;
	
	{if FEnabledClientStateVertex then
		VVMyVertexType:=VVMyVertexType or D3DFVF_XYZ;
	if FEnabledClientStateColor then
		VVMyVertexType:=VVMyVertexType or D3DFVF_DIFFUSE;
	if FEnabledClientStateNormal then
		VVMyVertexType:=VVMyVertexType or D3DFVF_NORMAL;
	if FEnabledClientStateTexVertex then
		VVMyVertexType:=VVMyVertexType or D3DFVF_TEX1;}
	pDevice.BeginScene();
	//Set format of vertex
	//------pDevice.SetFVF(VVMyVertexType);
	pDevice.SetVertexDeclaration(FArBuffers[FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer-1].FVertexDeclaration);
	//Set vertex buffer
	if pDevice.SetStreamSource(0,IDirect3DVertexBuffer9(Pointer(FArBuffers[FVBOData[0]-1].FResourse)),0,FArDataBuffers[SGRDTypeDataBufferVertex].FSizeOfOneVertex)<>D3D_OK then
		SGLog.Sourse('TSGRenderDirectX__DrawElements : SetStreamSource : Failed!!');
	//Set Index buffer
	if pDevice.SetIndices(IDirect3DIndexBuffer9(Pointer(FArBuffers[FVBOData[1]-1].FResourse))) <> D3D_OK then
		SGLog.Sourse('TSGRenderDirectX__DrawElements : SetIndices : Failed!!');
	//Draw
	if pDevice.DrawIndexedPrimitive(FPT(),0,0,
		FArBuffers[FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer-1].FResourseSize div 
		FArDataBuffers[SGRDTypeDataBufferVertex].FSizeOfOneVertex
		,0,GetNumPrimetives())<>D3D_OK then
			begin
			SGLog.Sourse('TSGRenderDirectX__DrawElements : DrawIndexedPrimitive : Draw Failed!! ');
			SGLog.Sourse('<<<<<<<<<<<<<<');
			SGLog.Sourse(['FPT()=',Byte(FPT()),
				';div = ',
					FArBuffers[FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer-1].FResourseSize  div 
					FArDataBuffers[SGRDTypeDataBufferVertex].FSizeOfOneVertex,', ',
					FArBuffers[FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer-1].FResourseSize  ,', ', 
					FArDataBuffers[SGRDTypeDataBufferVertex].FSizeOfOneVertex,
				';GetNumPrimetives()=',GetNumPrimetives()]);
			SGLog.Sourse('>>>>>>>>>>>>>>');
			end;
	pDevice.EndScene();
	end
else
	begin
	
	end;
end;

procedure TSGRenderDirectX.ColorPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 
FArDataBuffers[SGRDTypeDataBufferColor].FQuantityParams:=VQChannels;
FArDataBuffers[SGRDTypeDataBufferColor].FVBOBuffer:=FVBOData[0];
FArDataBuffers[SGRDTypeDataBufferColor].FDataType:=VType;
FArDataBuffers[SGRDTypeDataBufferColor].FSizeOfOneVertex:=VSize;
FArDataBuffers[SGRDTypeDataBufferColor].FShift:=Cardinal(VBuffer);
end;

procedure TSGRenderDirectX.TexCoordPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 
FArDataBuffers[SGRDTypeDataBufferTexVertex].FQuantityParams:=VQChannels;
FArDataBuffers[SGRDTypeDataBufferTexVertex].FVBOBuffer:=FVBOData[0];
FArDataBuffers[SGRDTypeDataBufferTexVertex].FDataType:=VType;
FArDataBuffers[SGRDTypeDataBufferTexVertex].FSizeOfOneVertex:=VSize;
FArDataBuffers[SGRDTypeDataBufferTexVertex].FShift:=Cardinal(VBuffer);
end;

procedure TSGRenderDirectX.NormalPointer(const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 
FArDataBuffers[SGRDTypeDataBufferNormal].FQuantityParams:=3;
FArDataBuffers[SGRDTypeDataBufferNormal].FVBOBuffer:=FVBOData[0];
FArDataBuffers[SGRDTypeDataBufferNormal].FDataType:=VType;
FArDataBuffers[SGRDTypeDataBufferNormal].FSizeOfOneVertex:=VSize;
FArDataBuffers[SGRDTypeDataBufferNormal].FShift:=Cardinal(VBuffer);
end;

procedure TSGRenderDirectX.VertexPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 
FArDataBuffers[SGRDTypeDataBufferVertex].FQuantityParams:=VQChannels;
FArDataBuffers[SGRDTypeDataBufferVertex].FVBOBuffer:=FVBOData[0];
FArDataBuffers[SGRDTypeDataBufferVertex].FDataType:=VType;
FArDataBuffers[SGRDTypeDataBufferVertex].FSizeOfOneVertex:=VSize;
FArDataBuffers[SGRDTypeDataBufferVertex].FShift:=Cardinal(VBuffer);
end;

function TSGRenderDirectX.IsEnabled(const VParam:Cardinal):Boolean; 
begin 

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

//Включаем Z-буфер
pDevice.SetRenderState(D3DRS_ZENABLE, 1);

//������������� ��������
FillChar(Material,SizeOf(Material),0);
Material.Diffuse.r := 1;
Material.Diffuse.g := 1;
Material.Diffuse.b := 1;
Material.Diffuse.a := 1;
Material.Ambient.r := 0;
Material.Ambient.g := 0;
Material.Ambient.b := 0;
Material.Ambient.a := 0;
Material.Specular.r:=0.4;
Material.Specular.g:=0.4;
Material.Specular.b:=0.4;
Material.Specular.a:=1;
Material.Power:=2;
pDevice.SetMaterial(Material);

//������������� ���������
FillChar(FLigth,SizeOf(FLigth),0);
FLigth._Type:=D3DLIGHT_POINT;
FLigth.Diffuse.r := 1 ;
FLigth.Diffuse.g := 1 ;
FLigth.Diffuse.b := 1 ;
FLigth.Range := 1000;// ������ ����������, �� ������� ���������� ���������, ������ �� ������.
{FLigth.Direction.x:=0;
FLigth.Direction.y:=1;
FLigth.Direction.z:=0;}
pDevice.SetLight(0, FLigth);
pDevice.LightEnable(0, True);
pDevice.SetRenderState(D3DRS_LIGHTING,1);
pDevice.SetRenderState(D3DRS_AMBIENT, 0);
//��������� ����
pDevice.SetRenderState(D3DRS_LIGHTING,0);

//========параметры текстур
//Включили вычисление цвета из текстуры RGB каналов
pDevice.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE);
pDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
pDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
//Включение ALPHA прозрачности текстуры(Включили вычисление прозрачности из Alpha канала)
pDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);

//============Прозрачность
pDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, 1);
pDevice.SetRenderState( D3DRS_SRCBLEND, D3DBLEND_SRCALPHA );
pDevice.SetRenderState( D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA );

//===========CULL FACE
//чтобы рисовались все подлигоны, а не только те, у которых
//нормаль направлена в сторону камеры
pDevice.SetRenderState( D3DRS_CULLMODE, D3DCULL_NONE );

//===================СГЛАЖ�?ВАН�?Е 
//pDevice.SetRenderState(D3DRS_MULTISAMPLEANTIALIAS,1); 
//Чето это сильно мутит, линии колбасу напоминают от этого параметра
//pDevice.SetRenderState(D3DRS_ANTIALIASEDLINEENABLE,1); 
pDevice.SetSamplerState( 0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR); 
pDevice.SetSamplerState( 0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR); 
//От MIP фильтора у текстур возникают аномалии
//pDevice.SetSamplerState( 0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR); 
//Настройка режима анизотропной фильтрации (x1, x2 ,x4, x8, x16)
//pDevice.SetSamplerState(0, D3DSAMP_MAXANISOTROPY, 1);
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
end;

destructor TSGRenderDirectX.Destroy();
var
	i:Cardinal;
begin
if FArBuffers<>nil then
	begin
	for i:=0 to High(FArBuffers) do
		if FArBuffers[i].FResourse<>nil then
			FArBuffers[i].FResourse._Release();
	try
	SetLength(FArBuffers,0);
	except
	SGLog.Sourse('TSGRenderDirectX__Destroy : Error : Exception with "SetLength(FArBuffers,0);"');
	end;
	end;
if FArTextures<>nil then
	begin
	for i:=0 to High(FArTextures) do
		if FArTextures[i]<>nil then
			FArTextures[i]._Release;
	SetLength(FArTextures,0);
	end;
if(pD3d<>nil) then
	pD3d._Release();
if (pDevice<>nil)  then
	pDevice._Release();
inherited Destroy();
end;

procedure TSGRenderDirectX.InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht:Real = 120);
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
	D3DXMatrixPerspectiveFovLH(Matrix,            // полученная итоговая матрица проекции
		D3DX_PI/4,                                // поле зрения в направлении оси Y в радианах
		CWidth/CHeight,                           // соотношения сторон экрана Width/Height
		0.0011,                                   // передний план отсечения сцены
		500);                                     // задний план отсечения сцены
	pDevice.SetTransform(D3DTS_PROJECTION, Matrix);
	D3DXMatrixScaling(Matrix,1,1,-1);
	pDevice.SetTransform(D3DTS_WORLD, Matrix);
	end
else
	if Mode=SG_3D_ORTHO then
		begin
		D3DXMatrixOrthoLH(Matrix,D3DX_PI/4*dncht/120,D3DX_PI/4*dncht/120/CWidth*CHeight,0.0011,500);
		pDevice.SetTransform(D3DTS_PROJECTION, Matrix);
		D3DXMatrixScaling(Matrix,1,1,-1);
		pDevice.SetTransform(D3DTS_WORLD, Matrix);
		end
	else if Mode=SG_2D then
		begin
		D3DXMatrixOrthoLH(Matrix,CWidth,-CHeight,-0.001,0.1);
		pDevice.SetTransform(D3DTS_PROJECTION, Matrix);
		
		D3DXMatrixTranslation(Matrix,-CWidth/2,-CHeight/2,0);
		pDevice.SetTransform(D3DTS_WORLD, Matrix);
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
begin
if (pD3D=nil) then
	begin
	pD3D:=Direct3DCreate9( D3D_SDK_VERSION );
	SGLog.Sourse(['TSGRenderDirectX__CreateContext : pD3D="',LongWord(Pointer(pD3D)),'"']);
	if pD3d = nil then
		begin
		Result:=False;
		exit;
		end;
	pD3D.GetAdapterDisplayMode( D3DADAPTER_DEFAULT,d3ddm);

	FillChar(d3dpp,SizeOf(d3dpp),0);

	d3dpp.Windowed := True;
	d3dpp.SwapEffect := D3DSWAPEFFECT_DISCARD;
	d3dpp.BackBufferFormat := d3ddm.Format;
	d3dpp.EnableAutoDepthStencil:= True;
	d3dpp.AutoDepthStencilFormat := D3DFMT_D24X8;
	d3dpp.PresentationInterval   := D3DPRESENT_INTERVAL_IMMEDIATE;

	//У меня на  нетбуке вылетает с этим пораметром
	//d3dpp.MultiSampleType:=D3DMULTISAMPLE_4_SAMPLES;

	if( 0 <> ( pD3d.CreateDevice( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, LongWord(FWindow.Get('WINDOW HANDLE')),
			D3DCREATE_SOFTWARE_VERTEXPROCESSING, @d3dpp, pDevice))) then
		begin
		SGLog.Sourse(['TSGRenderDirectX__CreateContext : pDevice="',LongWord(Pointer(pDevice)),'"']);
		Result:=False;
		exit;
		end;
	SGLog.Sourse(['TSGRenderDirectX__CreateContext : pDevice="',LongWord(Pointer(pDevice)),'"']);
	Result:=True;
	end
else
	begin
	
	end;
end;

procedure TSGRenderDirectX.ReleaseCurrent();
begin

end;

function TSGRenderDirectX.SetPixelFormat():Boolean;overload;
begin
Result:=True;
end;

procedure TSGRenderDirectX.MakeCurrent();
begin

end;

end.
