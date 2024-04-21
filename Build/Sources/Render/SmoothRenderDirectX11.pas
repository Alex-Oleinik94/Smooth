{$INCLUDE Smooth.inc}

//{$DEFINE RENDER_DX11_DEBUG}

unit SmoothRenderDirectX11;

// D3D11 examples with sources
// from https://takinginitiative.net/directx10-tutorials/
// https://www.rastertek.com/tutdx11win10.html
// https://www.rastertek.com/tutindex.html
// https://www.rastertek.com/index.html
//
// https://github.com/AntonAngeloff/DX11_Examples?ysclid=lulmf72mni387948694

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
	,Windows
	,DynLibs
	
	// DirectX unit
	// Include D3D11 and DXGI units
	,DX12.D3D11
	,DX12.D3D11On12
	//,DX12.D2D1//
	,DX12.DXGI
	,DX12.D3DCommon
	//,DX12.DWrite//
	
	,DX12.D3DX11
	//We have to use DX10 unit for the matrix manipulation functions
	,DX12.D3DX10
	,DirectX.Math
	;

type
	TSRenderDirectX11 = class(TSRender)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function RenderName() : TSString; override;
			protected
		{ D3D11 Device and Device Context }
		FDevice: ID3D11Device;
		FDeviceContext: ID3D11DeviceContext;
		FCurrentFeatureLevel: TD3D_FEATURE_LEVEL;
		
		{ Swapchain }
		FSwapchain: IDXGISwapChain;
		FRenderTargetView: ID3D11RenderTargetView;
		
		{ Depth, stencil and raster states }
		FDepthStencilBuffer: ID3D11Texture2D;
		FDepthStencilState: ID3D11DepthStencilState;
		FDepthStencilView: ID3D11DepthStencilView;
		FRasterizerState: ID3D11RasterizerState;
		FViewport: TD3D11_VIEWPORT;
		
		{ Matrices }
		FProjMatrix: TD3DMATRIX;
		
		{ Flag which signalizes that renderer is initialized }
		FReady,
		FEnableVSync: Boolean;
		//цвет, в который окрашивается буфер при очистке
		FClearColor:array[0..3]of Single;

			protected
		Function Initialize(aHWND: HWND; aWidth, aHeight: Integer): HRESULT;
		Function Uninitialize: HRESULT;
			public
		class function Supported() : TSBoolean;override;
		function SetPixelFormat():Boolean;override;overload;
		function CreateContext():Boolean;override;
		function MakeCurrent():Boolean;override;
		procedure ReleaseCurrent();override;
		procedure Init();override;
		procedure Kill();override;//Shutdown
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
		procedure ClearColor(const r,g,b,a : TSFloat);override;
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

uses SmoothLog;

procedure TSRenderDirectX11.ClearColor(const r,g,b,a : TSFloat);
begin
// Setup the color to clear the buffer to.
FClearColor[0] := r;
FClearColor[1] := g;
FClearColor[2] := b;
FClearColor[3] := a;
end;


function TSRenderDirectX11.Initialize(aHWND: HWND; aWidth, aHeight: Integer): HRESULT;
var
  feature_level: Array[0..0] of TD3D_FEATURE_LEVEL;
  pBackbuffer: ID3D11Texture2D;

  swapchain_desc: TDXGI_SWAP_CHAIN_DESC;
  depth_desc: TD3D11_TEXTURE2D_DESC;
  depth_state_desc: TD3D11_DEPTH_STENCIL_DESC;
  depth_view_desc: TD3D11_DEPTH_STENCIL_VIEW_DESC;
  rast_state_desc: TD3D11_RASTERIZER_DESC;
begin
  //If we are already initialized, then call Uninitialize() before proceeding.
  If FReady then Begin
    Result := Uninitialize;
    If Failed(Result) then Exit;
  end;

  //Configure swapchain descriptor
  {$HINTS off}
  FillChar(swapchain_desc, SizeOf(TDXGI_SWAP_CHAIN_DESC), 0);
  {$HINTS on}
  With swapchain_desc do Begin
    BufferCount := 1;

    BufferDesc.Width := aWidth;
    BufferDesc.Height := aHeight;
    BufferDesc.Format := DXGI_FORMAT_R8G8B8A8_UNORM;
    BufferDesc.RefreshRate.Numerator := 0;
    BufferDesc.RefreshRate.Denominator := 1;
    BufferDesc.ScanlineOrdering := DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED;
    BufferDesc.Scaling := DXGI_MODE_SCALING_UNSPECIFIED;

    BufferUsage := DXGI_USAGE_RENDER_TARGET_OUTPUT;
    OutputWindow := aHWND;
    SampleDesc.Count := 1;
    SampleDesc.Quality := 0;
    Windowed := True;

    SwapEffect := DXGI_SWAP_EFFECT_DISCARD;
    Flags := 0;
  End;

  //Decide feature level
  feature_level[0] := D3D_FEATURE_LEVEL_11_0;

  //Create Direct3D 11 device and a swap chain
  Result := D3D11CreateDeviceAndSwapChain(
      nil,
      D3D_DRIVER_TYPE_HARDWARE,
      0,
      0,
      @feature_level[0],
      1,
      D3D11_SDK_VERSION,
      @swapchain_desc,
      FSwapchain,
      FDevice,
      FCurrentFeatureLevel,
      FDeviceContext
  );
  If Failed(Result) then Exit;

  //Get first backbuffer from the chain
  Result := FSwapchain.GetBuffer(0, ID3D11Texture2D, pBackbuffer);
  If Failed(Result) then Exit;

  //Create render target view from backbuffer
  Result := FDevice.CreateRenderTargetView(pBackbuffer, nil, FRenderTargetView);
  If Failed(Result) then Exit;

  //Release backbuffer reference
  pBackbuffer := nil;

  //Setup a depth buffer desc
  {$HINTS off}
  FillChar(depth_desc, SizeOf(depth_desc), 0);
  {$HINTS on}
  With depth_desc do Begin
    Width := aWidth;
    Height := aHeight;
    MipLevels := 1;
    ArraySize := 1;
    Format := DXGI_FORMAT_D24_UNORM_S8_UINT;
    SampleDesc.Count := 1;
    SampleDesc.Quality := 0;
    Usage := D3D11_USAGE_DEFAULT;
    BindFlags := Ord(D3D11_BIND_DEPTH_STENCIL);
    CPUAccessFlags := 0;
    MiscFlags := 0;
  End;

  //Create depth buffer
  Result := FDevice.CreateTexture2D(depth_desc, nil, FDepthStencilBuffer);
  If Failed(Result) then Exit;

  //Setup depth-stencil state desc
  {$HINTS off}
  FillChar(depth_state_desc, SizeOf(depth_state_desc), 0);
  {$HINTS on}
  With depth_state_desc do Begin
    DepthEnable := True;
    DepthWriteMask := D3D11_DEPTH_WRITE_MASK_ALL;
    DepthFunc := D3D11_COMPARISON_LESS;

    StencilEnable := True;
    StencilReadMask := $FF;
    StencilWriteMask := $FF;

    FrontFace.StencilFailOp := D3D11_STENCIL_OP_KEEP;
    FrontFace.StencilDepthFailOp := D3D11_STENCIL_OP_INCR;
    FrontFace.StencilPassOp := D3D11_STENCIL_OP_KEEP;
    FrontFace.StencilFunc := D3D11_COMPARISON_ALWAYS;

    BackFace.StencilFailOp := D3D11_STENCIL_OP_KEEP;
    BackFace.StencilDepthFailOp := D3D11_STENCIL_OP_DECR;
    BackFace.StencilPassOp := D3D11_STENCIL_OP_KEEP;
    BackFace.StencilFunc := D3D11_COMPARISON_ALWAYS;
  End;

  //Create depth-stencil state object
  Result := FDevice.CreateDepthStencilState(depth_state_desc, FDepthStencilState);
  If Failed(Result) then Exit;

  //Set depth-stencil state
  FDeviceContext.OMSetDepthStencilState(FDepthStencilState, 1);

  //Setup depth-stencil view desc
  {$HINTS off}
  FillChar(depth_view_desc, SizeOf(depth_view_desc), 0);
  {$HINTS on}
  With depth_view_desc do Begin
    Format := DXGI_FORMAT_D24_UNORM_S8_UINT;
    ViewDimension := D3D11_DSV_DIMENSION_TEXTURE2D;
    Texture2D.MipSlice := 0;
  End;

  //Create depth-stencil view
  Result := FDevice.CreateDepthStencilView(FDepthStencilBuffer, @depth_view_desc, FDepthStencilView);
  If Failed(Result) then Exit;

  //Bind render target view and depth-stencil view to pipeline
  FDeviceContext.OMSetRenderTargets(1, @FRenderTargetView, FDepthStencilView);

  //Setup rasterizer state desc
  {$HINTS off}
  FillChar(rast_state_desc, SizeOf(rast_state_desc), 0);
  {$HINTS on}
  With rast_state_desc do Begin
    AntialiasedLineEnable := True;
    CullMode := D3D11_CULL_BACK;
    DepthBias := 0;
    DepthBiasClamp := 0;
    DepthClipEnable := True;
    FillMode := D3D11_FILL_SOLID;
    FrontCounterClockwise := False;
    MultisampleEnable := False;
    ScissorEnable := False;
    SlopeScaledDepthBias := 0;
  End;

  //Create rasterizer state object
  Result := FDevice.CreateRasterizerState(rast_state_desc, FRasterizerState);
  If Failed(Result) then Exit;

  //Set rasterizer state to device context
  FDeviceContext.RSSetState(FRasterizerState);

  //Set up viewport
  {$HINTS off}
  FillChar(FViewport, SizeOf(FViewport), 0);
  {$HINTS on}
  With FViewport do Begin
    Width := aWidth;
    Height := aHeight;
    MinDepth := 0;
    MaxDepth := 1;
    TopLeftX := 0;
    TopLeftY := 0;
  End;

  //Set viewport
  FDeviceContext.RSSetViewports(1, @FViewport);

  //Create projection matrix
  D3DXMatrixPerspectiveFovLH(@FProjMatrix, 2*Pi/4, aWidth/aHeight,  TSRenderNear, TSRenderFar);

  //Set ready flag
  FReady := True;
end;

function TSRenderDirectX11.Uninitialize: HRESULT;
begin
  If not FReady then
     Exit(E_FAIL);

  { Release references to every interface we hold }
  FRasterizerState := nil;
  FDepthStencilState := nil;
  FDepthStencilView := nil;
  FDepthStencilBuffer := nil;

  FRenderTargetView := nil;
  FDeviceContext := nil;
  FDevice := nil;

  FSwapchain := nil;

  { Clear ready flag }
  FReady := False;

  { Success }
  Result := S_OK;
end;

class function TSRenderDirectX11.RenderName() : TSString;
begin
Result := 'DirectX 11';
end;

class function TSRenderDirectX11.ClassName() : TSString; 
begin
Result := 'TSRenderDirectX11';
end;

class function TSRenderDirectX11.Supported() : TSBoolean;
begin
Result := True;
end;

function TSRenderDirectX11.SupportedShaders() : TSBoolean;
begin
Result := False;
end;

{$IFNDEF MOBILE}
procedure TSRenderDirectX11.GetVertexUnderPixel(const px,py : LongWord; out x,y,z : Real);
begin

end;
{$ENDIF}

procedure TSRenderDirectX11.BeginBumpMapping(const Point : Pointer );
begin

end;

procedure TSRenderDirectX11.EndBumpMapping();
begin

end;

procedure TSRenderDirectX11.ActiveTexture(const VTexture : TSLongWord);
begin

end;

procedure TSRenderDirectX11.ActiveTextureDiffuse();
begin

end;

procedure TSRenderDirectX11.ActiveTextureBump();
begin

end;

procedure TSRenderDirectX11.ClientActiveTexture(const VTexture : TSLongWord);
begin

end;

procedure TSRenderDirectX11.ColorMaterial(const r,g,b,a : TSSingle);
begin

end;

procedure TSRenderDirectX11.PushMatrix();
begin

end;

procedure TSRenderDirectX11.PopMatrix();
begin

end;

procedure TSRenderDirectX11.SwapBuffers();
begin
// Present the back buffer to the screen since rendering is complete.
if(FEnableVSync)then
    //Enforce vertical sync refresh rate
    FSwapchain.Present(1, 0)
else
    //Present as soon as possible
    FSwapchain.Present(0, 0);
end;

function TSRenderDirectX11.SupportedMemoryBuffers():Boolean;
begin
Result:=False;
end;

function TSRenderDirectX11.SupportedGraphicalBuffers():Boolean;
begin
Result:=False;
end;

procedure TSRenderDirectX11.PointSize(const PS:Single);
begin

end;

procedure TSRenderDirectX11.LineWidth(const VLW:Single);
begin

end;

procedure TSRenderDirectX11.Color3f(const r,g,b:single);
begin
Color4f(r,g,b,1);
end;

procedure TSRenderDirectX11.TexCoord2f(const x,y:single); 
begin 

end;

procedure TSRenderDirectX11.Vertex2f(const x,y:single); 
begin

end;

procedure TSRenderDirectX11.Color4f(const r,g,b,a:single); 
begin

end;

procedure TSRenderDirectX11.LoadMatrixf(const Matrix : PSMatrix4x4);
begin

end;

procedure TSRenderDirectX11.MultMatrixf(const Matrix : PSMatrix4x4);
begin 

end;

procedure TSRenderDirectX11.Translatef(const x,y,z:single);
begin 

end;

procedure TSRenderDirectX11.Rotatef(const angle:single;const x,y,z:single);
begin

end;

procedure TSRenderDirectX11.Enable(VParam:Cardinal); 
begin

end;

procedure TSRenderDirectX11.Disable(const VParam:Cardinal); 
begin 

end;

procedure TSRenderDirectX11.DeleteTextures(const VQuantity:Cardinal;const VTextures:PSRenderTexture); 
begin 

end;

procedure TSRenderDirectX11.Lightfv(const VLight,VParam:Cardinal;const VParam2:Pointer); 
begin 

end;

procedure TSRenderDirectX11.GenTextures(const VQuantity:Cardinal;const VTextures:PSRenderTexture);
begin 

end;

procedure TSRenderDirectX11.BindTexture(const VParam:Cardinal;const VTexture:Cardinal); 
begin 

end;

procedure TSRenderDirectX11.TexParameteri(const VP1,VP2,VP3:Cardinal);
begin 

end;

procedure TSRenderDirectX11.PixelStorei(const VParamName:Cardinal;const VParam:TSInt32); 
begin 

end;

procedure TSRenderDirectX11.TexEnvi(const VP1,VP2,VP3:Cardinal); 
begin 

end;

procedure TSRenderDirectX11.TexImage2D(const VTextureType:Cardinal;const VP1:Cardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:Cardinal;VBitMap:Pointer); 
begin 

end;

procedure TSRenderDirectX11.ReadPixels(const x,y:Integer;const Vwidth,Vheight:Integer;const format, atype: Cardinal;const pixels: Pointer); 
begin 

end;

procedure TSRenderDirectX11.CullFace(const VParam:Cardinal); 
begin 

end;

procedure TSRenderDirectX11.EnableClientState(const VParam:Cardinal); 
begin 

end;

procedure TSRenderDirectX11.DisableClientState(const VParam:Cardinal); 
begin 

end;

procedure TSRenderDirectX11.GenBuffersARB(const VQ:Integer;const PT:PCardinal);
begin 

end;

procedure TSRenderDirectX11.DeleteBuffersARB(const VQuantity:LongWord;VPoint:Pointer);
begin 

end;

procedure TSRenderDirectX11.BindBufferARB(const VParam:Cardinal;const VParam2:Cardinal);
begin 

end;

procedure TSRenderDirectX11.BufferDataARB(
	const VParam:Cardinal;   // SR_ARRAY_BUFFER_ARB or SR_ELEMENT_ARRAY_BUFFER_ARB
	const VSize:int64;       // Размер в байтах
	VBuffer:Pointer;         // Буфер
	const VParam2:Cardinal;
	const VIndexPrimetiveType : TSLongWord = 0);
begin 

end;

procedure TSRenderDirectX11.DrawElements(
	const VParam:Cardinal;
	const VSize:int64;// не в байтах а в 4*байт
	const VParam2:Cardinal;
	VBuffer:Pointer);
begin 

end;

procedure TSRenderDirectX11.DrawArrays(const VParam:TSCardinal;const VFirst,VCount:TSLongWord);
begin

end;

procedure TSRenderDirectX11.ColorPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 

end;

procedure TSRenderDirectX11.TexCoordPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 

end;

procedure TSRenderDirectX11.NormalPointer(const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 

end;

procedure TSRenderDirectX11.VertexPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 

end;

function TSRenderDirectX11.IsEnabled(const VParam:Cardinal):Boolean; 
begin 
Result:=False;
end;

procedure TSRenderDirectX11.Clear(const VParam:Cardinal); 
begin 
if (SR_COLOR_BUFFER_BIT and VParam > 0)then
  //Clear the render target view (frame buffer)
  FDeviceContext.ClearRenderTargetView(FRenderTargetView, FClearColor);
if (SR_DEPTH_BUFFER_BIT and VParam > 0)then
  //Clear depth buffer
  FDeviceContext.ClearDepthStencilView(FDepthStencilView, Ord(D3D11_CLEAR_DEPTH), 1, 0);
end;

procedure TSRenderDirectX11.BeginScene(const VPrimitiveType:TSPrimtiveType);
begin

end;

procedure TSRenderDirectX11.EndScene();
begin

end;

procedure TSRenderDirectX11.Init();
begin
//Initialize();
end;

constructor TSRenderDirectX11.Create();
begin
inherited Create();
FClearColor[0]:=1;
FClearColor[1]:=0;
FClearColor[2]:=0;
FClearColor[3]:=0;
end;

procedure TSRenderDirectX11.Kill();
begin

end;

destructor TSRenderDirectX11.Destroy();
begin
inherited Destroy();
{$IFDEF RENDER_DX11_DEBUG}
	WriteLn('TSRenderDirectX11.Destroy(): End');
	{$ENDIF}
end;

procedure TSRenderDirectX11.InitOrtho2d(const x0,y0,x1,y1:TSSingle);
begin

end;

procedure TSRenderDirectX11.MatrixMode(const Par:TSLongWord);
begin

end;

procedure TSRenderDirectX11.InitMatrixMode(const Mode:TSMatrixMode = S_3D; const dncht : TSFloat = 1);
begin

end;

procedure TSRenderDirectX11.Viewport(const a,b,c,d:TSAreaInt);
begin

end;

procedure TSRenderDirectX11.LoadIdentity();
begin

end;

procedure TSRenderDirectX11.Vertex3fv(const Variable : TSPointer);
begin

end;

procedure TSRenderDirectX11.Normal3f(const x,y,z:single); 
begin 

end;

procedure TSRenderDirectX11.Normal3fv(const Variable : TSPointer);
begin

end;

procedure TSRenderDirectX11.Vertex3f(const x,y,z:single);
begin

end;


function TSRenderDirectX11.CreateContext():Boolean;
begin
WriteLn('=');
if Context <> nil then
	//Result := Initialize(Context.Width, Context.Height, True, TSMaxEnum(Context.Window), Context.Fullscreen, TSRenderFar, TSRenderNear) = 0
	Result := Initialize(TSMaxEnum(Context.Window), Context.Width, Context.Height) = 0
else
	Result := False;
end;

procedure TSRenderDirectX11.ReleaseCurrent();
begin

end;

function TSRenderDirectX11.SetPixelFormat():Boolean;overload;
begin
Result:=True;
end;

function TSRenderDirectX11.MakeCurrent():Boolean;
begin
Result := True;
end;

procedure TSRenderDirectX11.LockResources();
begin

end;

procedure TSRenderDirectX11.UnLockResources();
begin

end;

end.
