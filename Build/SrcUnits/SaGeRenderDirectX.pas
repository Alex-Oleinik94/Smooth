{$include Includes\SaGe.inc}
unit SaGeRenderDirectX;
interface
uses
	SaGeBase
	,SaGeRender
	,windows
	,DynLibs
	,DXTypes
	,D3DX9
	,Direct3D9
	;
type
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
		
		function SupporedGPUBuffers:Boolean;override;
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
		FClearColor:LongWord;
		FPrimetiveType:LongWord;
		FPrimetivePrt:LongWord;
		FNowColor:LongWord;
		FArPoints:array[0..2]of 
			packed record
				x,y,z:single;
				Color:LongWord;
				end;
		FNumberOfPoints:LongWord;
			private
		procedure AfterVertexProc();inline;
		end;

implementation

procedure TSGRenderDirectX.SwapBuffers();
begin
pDevice.Present(nil, nil, 0, nil);
end;

procedure TSGRenderDirectX.AfterVertexProc();inline;
begin
if (FNumberOfPoints=3) and  ((FPrimetiveType=SGR_QUADS) or (FPrimetiveType=SGR_TRIANGLES) or (FPrimetiveType=SGR_TRIANGLE_STRIP)) then
	begin
	pDevice.SetFVF( D3DFVF_XYZ or D3DFVF_DIFFUSE );
	pDevice.DrawPrimitiveUP( D3DPT_TRIANGLELIST, 1, FArPoints[0], sizeof(FArPoints[0]));
	end
else
	if (FNumberOfPoints=2) and ((FPrimetiveType=SGR_LINES) or (FPrimetiveType=SGR_LINE_LOOP) or (FPrimetiveType=SGR_LINE_STRIP)) then
		begin
		pDevice.SetFVF( D3DFVF_XYZ or D3DFVF_DIFFUSE );
		pDevice.DrawPrimitiveUP( D3DPT_LINELIST, 1, FArPoints[0], sizeof(FArPoints[0]));
		end
	else
		if (FNumberOfPoints=1) and (FPrimetiveType=SGR_POINTS) then
			begin
			pDevice.SetFVF( D3DFVF_XYZ or D3DFVF_DIFFUSE );
			pDevice.DrawPrimitiveUP( D3DPT_POINTLIST, 1, FArPoints[0], sizeof(FArPoints[0]));
			end;
case FPrimetiveType of
SGR_POINTS:
	if (FNumberOfPoints=1) then
		FNumberOfPoints:=0;
SGR_TRIANGLES: 
	if FNumberOfPoints=3 then
		begin
		FNumberOfPoints:=0;
		FArPoints[FNumberOfPoints].Color:=FNowColor;
		end;
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
			FArPoints[0].Color:=FNowColor;
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
		FArPoints[0].Color:=FArPoints[1].Color;
		end;
end;
end;

function TSGRenderDirectX.SupporedGPUBuffers:Boolean;
begin
Result:=False;
end;

procedure TSGRenderDirectX.PointSize(const PS:Single);
begin

end;

procedure TSGRenderDirectX.LineWidth(const VLW:Single);
begin

end;

procedure TSGRenderDirectX.Color3f(const r,g,b:single);
begin
FNowColor:=D3DCOLOR_XRGB(round(255*r),round(255*g),round(255*b));
FArPoints[FNumberOfPoints].Color:=FNowColor;
end;

procedure TSGRenderDirectX.TexCoord2f(const x,y:single); 
begin 

end;

procedure TSGRenderDirectX.Vertex2f(const x,y:single); 
begin
FArPoints[FNumberOfPoints].x:=x;
FArPoints[FNumberOfPoints].y:=y;
FArPoints[FNumberOfPoints].z:=0;
FNumberOfPoints+=1;
AfterVertexProc();
end;

procedure TSGRenderDirectX.Color4f(const r,g,b,a:single); 
begin 
FNowColor:=D3DCOLOR_RGBA(round(255*r),round(255*g),round(255*b),round(255*a));
FArPoints[FNumberOfPoints].Color:=FNowColor;
end;

procedure TSGRenderDirectX.Normal3f(const x,y,z:single); 
begin 

end;

procedure TSGRenderDirectX.Translatef(const x,y,z:single); 
begin 

end;

procedure TSGRenderDirectX.Rotatef(const angle:single;const x,y,z:single); 
begin 

end;

procedure TSGRenderDirectX.Enable(VParam:Cardinal); 
begin

end;

procedure TSGRenderDirectX.Disable(const VParam:Cardinal); 
begin 

end;

procedure TSGRenderDirectX.DeleteTextures(const VQuantity:Cardinal;const VTextures:PSGUInt); 
begin 

end;

procedure TSGRenderDirectX.Lightfv(const VLight,VParam:Cardinal;const VParam2:Pointer); 
begin 

end;

procedure TSGRenderDirectX.GenTextures(const VQuantity:Cardinal;const VTextures:PSGUInt); 
begin 

end;

procedure TSGRenderDirectX.BindTexture(const VParam:Cardinal;const VTexture:Cardinal); 
begin 

end;

procedure TSGRenderDirectX.TexParameteri(const VP1,VP2,VP3:Cardinal); 
begin 

end;

procedure TSGRenderDirectX.PixelStorei(const VParamName:Cardinal;const VParam:SGInt); 
begin 

end;

procedure TSGRenderDirectX.TexEnvi(const VP1,VP2,VP3:Cardinal); 
begin 

end;

procedure TSGRenderDirectX.TexImage2D(const VTextureType:Cardinal;const VP1:Cardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:Cardinal;var VBitMap:Pointer); 
begin 

end;

procedure TSGRenderDirectX.ReadPixels(const x,y:Integer;const Vwidth,Vheight:Integer;const format, atype: Cardinal;const pixels: Pointer); 
begin 

end;

procedure TSGRenderDirectX.CullFace(const VParam:Cardinal); 
begin 

end;

procedure TSGRenderDirectX.EnableClientState(const VParam:Cardinal); 
begin 

end;

procedure TSGRenderDirectX.DisableClientState(const VParam:Cardinal); 
begin 

end;

procedure TSGRenderDirectX.GenBuffersARB(const VQ:Integer;const PT:PCardinal); 
begin 

end;

procedure TSGRenderDirectX.DeleteBuffersARB(const VQuantity:LongWord;VPoint:Pointer); 
begin 

end;

procedure TSGRenderDirectX.BindBufferARB(const VParam:Cardinal;const VParam2:Cardinal); 
begin 

end;

procedure TSGRenderDirectX.BufferDataARB(const VParam:Cardinal;const VSize:int64;VBuffer:Pointer;const VParam2:Cardinal); 
begin 

end;

procedure TSGRenderDirectX.DrawElements(const VParam:Cardinal;const VSize:int64;const VParam2:Cardinal;VBuffer:Pointer); 
begin 

end;

procedure TSGRenderDirectX.ColorPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 

end;

procedure TSGRenderDirectX.TexCoordPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 

end;

procedure TSGRenderDirectX.NormalPointer(const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 

end;

procedure TSGRenderDirectX.VertexPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 

end;

function TSGRenderDirectX.IsEnabled(const VParam:Cardinal):Boolean; 
begin 

end;

procedure TSGRenderDirectX.Clear(const VParam:Cardinal); 
begin 
pDevice.Clear( 0, nil, D3DCLEAR_TARGET, FClearColor, 1.0, 0 );
end;

procedure TSGRenderDirectX.BeginScene(const VPrimitiveType:TSGPrimtiveType);
begin
pDevice.BeginScene();
FPrimetiveType:=VPrimitiveType;
FPrimetivePrt:=0;
FNumberOfPoints:=0;
FArPoints[0].Color:=FNowColor;
pDevice.SetRenderState(D3DRS_LIGHTING,0);
end;

procedure TSGRenderDirectX.EndScene();
begin
if FPrimetiveType=SGR_LINE_LOOP then
	begin
	pDevice.SetFVF( D3DFVF_XYZ or D3DFVF_DIFFUSE );
	pDevice.DrawPrimitiveUP( D3DPT_LINELIST, 1, FArPoints[1], sizeof(FArPoints[0]));
	end;
pDevice.EndScene();
end;

procedure TSGRenderDirectX.Init;
begin
FNowColor:=D3DCOLOR_XRGB(1,1,1);
FClearColor:=D3DCOLOR_XRGB(0,0,0);
end;

constructor TSGRenderDirectX.Create;
begin
inherited Create;
end;

destructor TSGRenderDirectX.Destroy;
begin
if(pD3d<>nil) then
	pD3d._Release();
if (pDevice<>nil)  then
	pDevice._Release;
inherited;
end;

procedure TSGRenderDirectX.InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht:Real = 120);
begin

end;

procedure TSGRenderDirectX.Viewport(const a,b,c,d:LongWord);
begin

end;

procedure TSGRenderDirectX.LoadIdentity();
begin

end;

procedure TSGRenderDirectX.Vertex3f(const x,y,z:single);
begin
//WriteLn(FNumberOfPoints,' ',FPrimetiveType);
FArPoints[FNumberOfPoints].x:=x;
FArPoints[FNumberOfPoints].y:=y;
FArPoints[FNumberOfPoints].z:=z;
FNumberOfPoints+=1;
AfterVertexProc();
end;

function TSGRenderDirectX.CreateContext():Boolean;
begin
pD3D:=Direct3DCreate9( D3D_SDK_VERSION );
if pD3d = nil then
	begin
	Result:=False;
	exit;
	end;
FillChar(d3dpp,SizeOf(d3dpp),0);
d3dpp.Windowed := TRUE;
d3dpp.SwapEffect := D3DSWAPEFFECT_DISCARD;
d3dpp.BackBufferFormat := D3DFMT_UNKNOWN;
//d3dpp.EnableAutoDepthStencil:= True;
//d3dpp.AutoDepthStencilFormat = D3DFMT_D16;
if( 0 <> ( pD3d.CreateDevice( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, LongWord(FWindow.Get('WINDOW HANDLE')),
        D3DCREATE_SOFTWARE_VERTEXPROCESSING, @d3dpp, pDevice))) then
	begin
	Result:=False;
	exit;
	end;
Result:=True;
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
