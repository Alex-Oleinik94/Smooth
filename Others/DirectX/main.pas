{$MODE OBJFPC}
program main;
uses Windows,DXTypes,D3DX9,Direct3D9;
var 
	pD3D:IDirect3D9;
	pDevice:IDirect3DDevice9;
	hWnd:LongWord;
	r:single = 0;
type
	MyVert=record
		x,y,z:single;
		Color:LongWord;
		end;

function Init(var hWnd:LongWord):boolean;
var
	d3dpp:D3DPRESENT_PARAMETERS;
BEGIN
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
if( 0 <> ( pD3d.CreateDevice( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, hWnd,
        D3DCREATE_SOFTWARE_VERTEXPROCESSING, @d3dpp, pDevice))) then
	begin
	Result:=False;
	exit;
	end;
Result:=True;
END;

procedure ReleaseAll;
begin
if (pDevice<>nil)  then
	pDevice._Release;
if(pD3d<>nil) then
	pD3d._Release();
end;

procedure Render;
var
	v:array [0..2] of MyVert;
	dwBlue:LongWord;
	MatrixWorld:D3DMATRIX;
begin
r+=0.001;

fillchar(v,sizeof(v),0);
v[0].x :=-0.5;  
v[0].y :=-0.5;  
v[0].z := 0.5;

v[1].x :=-0.5;  
v[1].y := 0.5;  
v[1].z := 0.5;

v[2].x := 0.5;  
v[2].y := 0.5;  
v[2].z := 0.5;

v[0].Color :=D3DCOLOR_XRGB(255,0,0); // красный
v[1].Color := D3DCOLOR_XRGB(0,255,0); // зеленый
v[2].Color := D3DCOLOR_XRGB(0,0,255); // синий

dwBlue:=D3DCOLOR_XRGB(0,0,0);
pDevice.Clear( 0, nil, D3DCLEAR_TARGET, dwBlue, 1.0, 0 );

//D3DXMatrixIdentity(MatrixWorld);

pDevice.BeginScene();
// Поскольку мы не используем освещение для треугольника,
// отключаем его
pDevice.SetRenderState(D3DRS_LIGHTING,0);
// Просчет объектов всегда между BeginScene и EndScene

pDevice.SetFVF( D3DFVF_XYZ or D3DFVF_DIFFUSE);
pDevice.DrawPrimitiveUP( D3DPT_TRIANGLELIST, 1, v[0], sizeof(MyVert));

pDevice.EndScene();

pDevice.Present(nil, nil, 0, nil);

end;

function MsgProc ( hWnd:LongWord ; msg:UINT; wParam:WPARAM; lParam:LPARAM ):LRESULT;stdcall; export;
begin
case msg of
WM_DESTROY:
	begin
	PostQuitMessage( 0 );
	result:=0;
	exit;
	end;
else
	Result:=DefWindowProc( hWnd, msg, wParam, lParam );
end;
end;



var
  WindowClass: Windows.WNDCLASSEX;
  
     msg:Windows.MSG;
begin

WindowClass.cbSize:=SizeOf(WindowClass);
WindowClass.Style := CS_CLASSDC;
WindowClass.lpfnWndProc := WndProc(@MsgProc);
WindowClass.cbClsExtra := 0;
WindowClass.cbWndExtra := 0;
WindowClass.hInstance := GetModuleHandle(nil);
WindowClass.hIcon := 0;
WindowClass.hCursor := 0;
WindowClass.hbrBackground := 0;
WindowClass.lpszMenuName := nil;
WindowClass.lpszClassName := 'FirstDX_cl';
WindowClass.hIconSm:=0;

RegisterClassEx( WindowClass );

hWnd := CreateWindow( 'FirstDX_cl', 'FirstDX',
                            WS_OVERLAPPEDWINDOW, 100, 100, 500, 500,
                            GetDesktopWindow(), 0, WindowClass.hInstance, nil );
WriteLn('hWnd=',hWnd);

if Init(hWnd) then
	begin
	ShowWindow( hWnd, SW_SHOWDEFAULT );
    UpdateWindow( hWnd );
    fillchar( msg, sizeof(msg) ,0);

    while( msg.message<>WM_QUIT ) do
		begin
		  if( PeekMessage( @msg, 0, 0, 0, PM_REMOVE ) ) then
		  begin
			TranslateMessage( @msg );
			DispatchMessage( @msg );
		  end
		  else
			Render();
		end;
	end;

ReleaseAll();
UnregisterClass( 'FirstDX_cl', WindowClass.hInstance );
end.

