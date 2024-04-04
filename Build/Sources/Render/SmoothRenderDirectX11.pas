{$INCLUDE Smooth.inc}

//{$DEFINE RENDER_DX11_DEBUG}

unit SmoothRenderDirectX11;

// D3D11 examples with sources
// from https://takinginitiative.net/directx10-tutorials/
// https://www.rastertek.com/tutdx11win10.html
// https://www.rastertek.com/tutindex.html
// https://www.rastertek.com/index.html

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
	,DX12.D3D11
	,DX12.D3D11On12
	//,DX12.D2D1//
	,DX12.DXGI
	,DX12.D3DCommon
	//,DX12.DWrite//
	
	,DX12.D3DX11
	,DirectX.Math
	;

type
	TSRenderDirectX11 = class(TSRender)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function RenderName() : TSString; override;
			protected
		m_vsync_enabled:Boolean;
		m_videoCardMemory:Extended;
		m_videoCardDescription:array[0..127] of Char;
		m_swapChain:^IDXGISwapChain;
		m_device:^ID3D11Device;
		m_deviceContext:^ID3D11DeviceContext;
		m_renderTargetView:PID3D11RenderTargetView;
		m_depthStencilBuffer:^ID3D11Texture2D;
		m_depthStencilState:^ID3D11DepthStencilState;
		m_depthStencilView:^ID3D11DepthStencilView;
		m_rasterState:^ID3D11RasterizerState;
		m_projectionMatrix:TXMMATRIX;
		m_worldMatrix:TXMMATRIX;
		m_orthoMatrix:TXMMATRIX;
		m_viewport:TD3D11_VIEWPORT;
		//цвет, в который окрашивается буфер при очистке
		FClearColor:array[0..3]of Single;

			protected
		function Initialize(screenWidth:LongInt;screenHeight:LongInt; vsync:Boolean; hwnd:HWND;fullscreen:Boolean; screenDepth:Single; screenNear:Single):HRESULT;
		procedure Shutdown();
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


procedure TSRenderDirectX11.ClearColor(const r,g,b,a : TSFloat);
begin
// Setup the color to clear the buffer to.
FClearColor[0] := r;
FClearColor[1] := g;
FClearColor[2] := b;
FClearColor[3] := a;
end;

function TSRenderDirectX11.Initialize(screenWidth:LongInt;screenHeight:LongInt; vsync:Boolean; hwnd:HWND;fullscreen:Boolean; screenDepth:Single; screenNear:Single):HRESULT;
var
	factory:^PIDXGIFactory;
	adapter:^IDXGIAdapter;
	adapterOutput:^IDXGIOutput;
	numModes, i, numerator, denominator:LongWord;
	stringLength:QWord;
	displayModeList:^TDXGI_MODE_DESC = nil;
	adapterDesc:TDXGI_ADAPTER_DESC;
	error:LongInt = 0;
	swapChainDesc:TDXGI_SWAP_CHAIN_DESC;
	featureLevel:TD3D_FEATURE_LEVEL;
	backBufferPtr:^ID3D11Texture2D;
	depthBufferDesc:TD3D11_TEXTURE2D_DESC;
	depthStencilDesc:TD3D11_DEPTH_STENCIL_DESC;
	depthStencilViewDesc:TD3D11_DEPTH_STENCIL_VIEW_DESC;
	rasterDesc:TD3D11_RASTERIZER_DESC;
	fieldOfView, screenAspect:Single;
begin
Result := 1;

WriteLn('=2');
// Store the vsync setting.
m_vsync_enabled := vsync;

// Create a DirectX graphics interface factory.
GetMem(factory, SizeOf(Pointer));
Result := CreateDXGIFactory(IDXGIFactory, factory);
if(FAILED(result))then
	exit;

WriteLn('=4');
// Use the factory to create an adapter for the primary graphics interface (video card).
Result := factory^^.EnumAdapters(0, adapter^);
if(FAILED(result))then
	exit;

WriteLn('=5');
// Enumerate the primary adapter output (monitor).
Result := adapter^.EnumOutputs(0, adapterOutput^);
if(FAILED(result))then
	exit;

// Get the number of modes that fit the DXGI_FORMAT_R8G8B8A8_UNORM display format for the adapter output (monitor).
Result := adapterOutput^.GetDisplayModeList(DXGI_FORMAT_R8G8B8A8_UNORM, DXGI_ENUM_MODES_INTERLACED, numModes, nil);
if(FAILED(result))then
	exit;

// Create a list to hold all the possible display modes for this monitor/video card combination.
GetMem(displayModeList, SizeOf(TDXGI_MODE_DESC) * numModes);
if(displayModeList=nil)then
	exit;

// Now fill the display mode list structures.
Result := adapterOutput^.GetDisplayModeList(DXGI_FORMAT_R8G8B8A8_UNORM, DXGI_ENUM_MODES_INTERLACED, numModes, displayModeList);
if(FAILED(result))then
	exit;

// Now go through all the display modes and find the one that matches the screen width and height.
// When a match is found store the numerator and denominator of the refresh rate for that monitor.
for i := 0 to numModes - 1 do
	if(displayModeList[i].Width = screenWidth) and (displayModeList[i].Height = screenHeight)then
		begin
		numerator := displayModeList[i].RefreshRate.Numerator;
		denominator := displayModeList[i].RefreshRate.Denominator;
		end;

// Get the adapter (video card) description.
Result := adapter^.GetDesc(adapterDesc);
if(FAILED(result))then
	exit;

// Store the dedicated video card memory in megabytes.
m_videoCardMemory := adapterDesc.DedicatedVideoMemory / 1024 / 1024;

// Convert the name of the video card to a character array and store it.
for i := 0 to 127 do
	m_videoCardDescription[i] := adapterDesc.Description[i];

// Release the display mode list.
FreeMem(displayModeList);
displayModeList := nil;

// Release the adapter output.
adapterOutput^._Release();
adapterOutput := nil;

// Release the adapter.
adapter^._Release();
adapter := nil;

// Release the factory.
factory^^._Release();
factory := nil;

// Initialize the swap chain description.
FillChar(swapChainDesc, sizeof(swapChainDesc), 0);

// Set to a single back buffer.
swapChainDesc.BufferCount := 1;

// Set the width and height of the back buffer.
swapChainDesc.BufferDesc.Width := screenWidth;
swapChainDesc.BufferDesc.Height := screenHeight;

// Set regular 32-bit surface for the back buffer.
swapChainDesc.BufferDesc.Format := DXGI_FORMAT_R8G8B8A8_UNORM;

// Set the refresh rate of the back buffer.
if(m_vsync_enabled)then
	begin
	swapChainDesc.BufferDesc.RefreshRate.Numerator := numerator;
	swapChainDesc.BufferDesc.RefreshRate.Denominator := denominator;
	end
else
	begin
	swapChainDesc.BufferDesc.RefreshRate.Numerator := 0;
	swapChainDesc.BufferDesc.RefreshRate.Denominator := 1;
	end;

// Set the usage of the back buffer.
swapChainDesc.BufferUsage := DXGI_USAGE_RENDER_TARGET_OUTPUT;

// Set the handle for the window to render to.
swapChainDesc.OutputWindow := hwnd;

// Turn multisampling off.
swapChainDesc.SampleDesc.Count := 1;
swapChainDesc.SampleDesc.Quality := 0;

// Set to full screen or windowed mode.
swapChainDesc.Windowed := not fullscreen;

// Set the scan line ordering and scaling to unspecified.
swapChainDesc.BufferDesc.ScanlineOrdering := DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED;
swapChainDesc.BufferDesc.Scaling := DXGI_MODE_SCALING_UNSPECIFIED;

// Discard the back buffer contents after presenting.
swapChainDesc.SwapEffect := DXGI_SWAP_EFFECT_DISCARD;

// Don't set the advanced flags.
swapChainDesc.Flags := 0;

// Set the feature level to DirectX 11.
featureLevel := D3D_FEATURE_LEVEL_11_0;

// Create the swap chain, Direct3D device, and Direct3D device context.
Result := D3D11CreateDeviceAndSwapChain(nil, D3D_DRIVER_TYPE_HARDWARE, 0, 0, @featureLevel, 1, 
										D3D11_SDK_VERSION, swapChainDesc, m_swapChain^, m_device^, featureLevel, m_deviceContext^);
if(FAILED(result))then
	exit;

// Get the pointer to the back buffer.
Result := m_swapChain^.GetBuffer(0, ID3D11Texture2D, backBufferPtr);
if(FAILED(result))then
	exit;

// Create the render target view with the back buffer pointer.
Result := m_device^.CreateRenderTargetView(backBufferPtr^, nil, m_renderTargetView^);
if(FAILED(result))then
	exit;

// Release pointer to the back buffer as we no longer need it.
backBufferPtr^._Release();
backBufferPtr := nil;

// Initialize the description of the depth buffer.
FillChar(depthBufferDesc, SizeOf(depthBufferDesc), 0);

// Set up the description of the depth buffer.
depthBufferDesc.Width := screenWidth;
depthBufferDesc.Height := screenHeight;
depthBufferDesc.MipLevels := 1;
depthBufferDesc.ArraySize := 1;
depthBufferDesc.Format := DXGI_FORMAT_D24_UNORM_S8_UINT;
depthBufferDesc.SampleDesc.Count := 1;
depthBufferDesc.SampleDesc.Quality := 0;
depthBufferDesc.Usage := D3D11_USAGE_DEFAULT;
depthBufferDesc.BindFlags := LongWord(D3D11_BIND_DEPTH_STENCIL);
depthBufferDesc.CPUAccessFlags := 0;
depthBufferDesc.MiscFlags := 0;

// Create the texture for the depth buffer using the filled out description.
Result := m_device^.CreateTexture2D(depthBufferDesc, nil, m_depthStencilBuffer^);
if(FAILED(result))then
	exit;

// Initialize the description of the stencil state.
FillChar(depthStencilDesc, SizeOf(depthStencilDesc), 0);

// Set up the description of the stencil state.
depthStencilDesc.DepthEnable := True;
depthStencilDesc.DepthWriteMask := D3D11_DEPTH_WRITE_MASK_ALL;
depthStencilDesc.DepthFunc := D3D11_COMPARISON_LESS;

depthStencilDesc.StencilEnable := True;
depthStencilDesc.StencilReadMask := $FF;
depthStencilDesc.StencilWriteMask := $FF;

// Stencil operations if pixel is front-facing.
depthStencilDesc.FrontFace.StencilFailOp := D3D11_STENCIL_OP_KEEP;
depthStencilDesc.FrontFace.StencilDepthFailOp := D3D11_STENCIL_OP_INCR;
depthStencilDesc.FrontFace.StencilPassOp := D3D11_STENCIL_OP_KEEP;
depthStencilDesc.FrontFace.StencilFunc := D3D11_COMPARISON_ALWAYS;

// Stencil operations if pixel is back-facing.
depthStencilDesc.BackFace.StencilFailOp := D3D11_STENCIL_OP_KEEP;
depthStencilDesc.BackFace.StencilDepthFailOp := D3D11_STENCIL_OP_DECR;
depthStencilDesc.BackFace.StencilPassOp := D3D11_STENCIL_OP_KEEP;
depthStencilDesc.BackFace.StencilFunc := D3D11_COMPARISON_ALWAYS;

// Create the depth stencil state.
Result := m_device^.CreateDepthStencilState(depthStencilDesc, m_depthStencilState^);
if(FAILED(result))then
	exit;

// Set the depth stencil state.
m_deviceContext^.OMSetDepthStencilState(m_depthStencilState^, 1);

// Initialize the depth stencil view.
FillChar(depthStencilViewDesc, SizeOf(depthStencilViewDesc), 0);

// Set up the depth stencil view description.
depthStencilViewDesc.Format := DXGI_FORMAT_D24_UNORM_S8_UINT;
depthStencilViewDesc.ViewDimension := D3D11_DSV_DIMENSION_TEXTURE2D;
depthStencilViewDesc.Texture2D.MipSlice := 0;

// Create the depth stencil view.
Result := m_device^.CreateDepthStencilView(m_depthStencilBuffer^, @depthStencilViewDesc, m_depthStencilView^);
if(FAILED(result))then
	exit;

// Bind the render target view and depth stencil buffer to the output render pipeline.
m_deviceContext^.OMSetRenderTargets(1, m_renderTargetView, m_depthStencilView^);

// Setup the raster description which will determine how and what polygons will be drawn.
rasterDesc.AntialiasedLineEnable := false;
rasterDesc.CullMode := D3D11_CULL_BACK;
rasterDesc.DepthBias := 0;
rasterDesc.DepthBiasClamp := 0.0;
rasterDesc.DepthClipEnable := true;
rasterDesc.FillMode := D3D11_FILL_SOLID;
rasterDesc.FrontCounterClockwise := false;
rasterDesc.MultisampleEnable := false;
rasterDesc.ScissorEnable := false;
rasterDesc.SlopeScaledDepthBias := 0.0;

// Create the rasterizer state from the description we just filled out.
Result := m_device^.CreateRasterizerState(rasterDesc, m_rasterState^);
if(FAILED(result))then
	exit;

// Now set the rasterizer state.
m_deviceContext^.RSSetState(m_rasterState^);

// Setup the viewport for rendering.
m_viewport.Width := screenWidth;
m_viewport.Height := screenHeight;
m_viewport.MinDepth := 0.0;
m_viewport.MaxDepth := 1.0;
m_viewport.TopLeftX := 0.0;
m_viewport.TopLeftY := 0.0;

// Create the viewport.
m_deviceContext^.RSSetViewports(1, @m_viewport);

// Setup the projection matrix.
fieldOfView := 3.141592654 / 4.0;
screenAspect := screenWidth / screenHeight;

// Create the projection matrix for 3D rendering.
m_projectionMatrix := XMMatrixPerspectiveFovLH(fieldOfView, screenAspect, screenNear, screenDepth);

// Initialize the world matrix to the identity matrix.
m_worldMatrix := XMMatrixIdentity();

// Create an orthographic projection matrix for 2D rendering.
m_orthoMatrix := XMMatrixOrthographicLH(screenWidth, screenHeight, screenNear, screenDepth);

Result := 0;
end;

procedure TSRenderDirectX11.Shutdown();
begin
// Before shutting down set to windowed mode or when you release the swap chain it will throw an exception.
if(m_swapChain<>nil)then
	m_swapChain^.SetFullscreenState(false, nil);


if(m_rasterState<>nil)then
	begin
	m_rasterState^._Release();
	m_rasterState := nil;
	end;

if(m_depthStencilView<>nil)then
	begin
	m_depthStencilView^._Release();
	m_depthStencilView := nil;
	end;

if(m_depthStencilState<>nil)then
	begin
	m_depthStencilState^._Release();
	m_depthStencilState := nil;
	end;

if(m_depthStencilBuffer<>nil)then
	begin
	m_depthStencilBuffer^._Release();
	m_depthStencilBuffer := nil;
	end;

if(m_renderTargetView<>nil)then
	begin
	m_renderTargetView^._Release();
	m_renderTargetView := nil;
	end;

if(m_deviceContext<>nil)then
	begin
	m_deviceContext^._Release();
	m_deviceContext := nil;
	end;

if(m_device<>nil)then
	begin
	m_device^._Release();
	m_device := nil;
	end;

if(m_swapChain<>nil)then
	begin
	m_swapChain^._Release();
	m_swapChain := nil;
	end
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
if(m_vsync_enabled)then
	// Lock to screen refresh rate.
	m_swapChain^.Present(1, 0)
else
	// Present as fast as possible.
	m_swapChain^.Present(0, 0);
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
	// Clear the back buffer.
	m_deviceContext^.ClearRenderTargetView(m_renderTargetView^, FClearColor);
if (SR_DEPTH_BUFFER_BIT and VParam > 0)then
	// Clear the depth buffer.
	m_deviceContext^.ClearDepthStencilView(m_depthStencilView^, LongWord(D3D11_CLEAR_DEPTH), 1.0, 0);
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
m_swapChain := nil;
m_device := nil;
m_deviceContext := nil;
m_renderTargetView := nil;
m_depthStencilBuffer := nil;
m_depthStencilState := nil;
m_depthStencilView := nil;
m_rasterState := nil;
FClearColor[0]:=1;
FClearColor[1]:=0;
FClearColor[2]:=0;
FClearColor[3]:=0;
end;

procedure TSRenderDirectX11.Kill();
begin
Shutdown();
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
	Result := Initialize(Context.Width, Context.Height, True, TSMaxEnum(Context.Window), Context.Fullscreen, TSRenderFar, TSRenderNear) = 0
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
