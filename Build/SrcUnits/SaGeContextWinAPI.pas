{$include Includes\SaGe.inc}

unit SaGeContextWinAPI;

interface

uses
	SaGeBase
	,Windows
	,SaGeContext
	,SaGeCommon
	,SaGeRender
	//,SaGe
	//,SaGeImages
	;
//Где купить пиво? Ответ: в магазине. (Специально для макса)
// Там же можно купить и закусь (Макс без этого просто не может походу пить пиво)
{$DEFINE SGWinAPIDebug}
//{$DEFINE SGWinAPIDebugB}

type
	WinAPIParam = 
		{$IFDEF CPU32}
			LongInt
		{$ELSE}
			Int64
			{$ENDIF};
	WinAPIHandle =
		{$IFDEF CPU32}
			LongWord
		{$ELSE}
			QWord
			{$ENDIF};
	
	TSGContextWinAPI=class(TSGContext)
			public
		constructor Create;override;
		destructor Destroy;override;
			public
		procedure Initialize;override;
		procedure Run;override;
		procedure Messages;override;
		procedure SwapBuffers;override;
		function  GetCursorPosition:TSGPoint2f;override;
		function  GetWindowRect:TSGPoint2f;override;
		function  GetScreenResolution:TSGPoint2f;override;
		function  TopShift:LongWord;override;
		function  MouseShift:TSGPoint2f;override;
		procedure InitFullscreen(const b:boolean); override;
		procedure ShowCursor(const b:Boolean);override;
		procedure SetCursorPosition(const a:TSGPoint2f);override;
		function  KeysPressed(const  Index : integer ) : Boolean;override;overload;
			public
		hWindow:HWnd;
		dcWindow:hDc;
		rcWindow:HGLRC;
		clWindow:LongWord;
		procedure ThrowError(pcErrorMessage : pChar);
		function  WindowRegister: Boolean;
		function  WindowCreate: HWnd;
		function  WindowInit(hParent : HWnd): Boolean;
		procedure KillOGLWindow(const KillRC:Boolean = True);
		function  CreateOGLWindow():Boolean;
			public
		function  GetRC:LongWord;override;
		procedure SetRC(const NewRC:LongWord);override;
		function Get(const What:string):Pointer;override;
		end;
	
function SGFullscreenQueschionWinAPIMethod:boolean;
function StandartGLWndProc(const Window: WinAPIHandle; const AMessage:LongWord; const WParam, LParam: WinAPIParam; var DoExit:Boolean): WinAPIParam;
procedure GetNativeSystemInfo(var a:SYSTEM_INFO);[stdcall];[external 'kernel32' name 'GetNativeSystemInfo'];

implementation

var
	SGContexts:packed array of TSGContextWinAPI = nil;
function TSGContextWinAPI.Get(const What:string):Pointer;
begin
if What='WINDOW HANDLE' then
	Result:=Pointer(dcWindow)
else
	Result:=Inherited Get(What);
end;

function TSGContextWinAPI.KeysPressed(const  Index : integer ) : Boolean;overload;
var
	Ar:PByte;
begin
if Index=20 then //Caps Lock
	begin
	GetMem(Ar,256);
	if GetKeyboardState(Ar) then
		begin
		Result:=Boolean(Ar[20]);
		FreeMem(Ar,256);
		end
	else
		Result:=False;
	end
else
	begin
	Result:=inherited;
	end;
end;

procedure TSGContextWinAPI.SetCursorPosition(const a:TSGPoint2f);
var
	b:TSGPoint2f;
begin
b:=GetWindowRect;
Windows.SetCursorPos(b.x+a.x,b.y+a.y);
end;

procedure TSGContextWinAPI.ShowCursor(const b:Boolean);
begin
Windows.ShowCursor(B);
end;

function TSGContextWinAPI.GetRC:LongWord;
begin
Result:=rcWindow;
end;

procedure TSGContextWinAPI.SetRC(const NewRC:LongWord);
begin
rcWindow:=NewRC;
end;

procedure TSGContextWinAPI.InitFullscreen(const b:boolean); 
begin
if hWindow=0 then
	inherited InitFullscreen(b)
else
	begin
	KillOGLWindow(False);
	inherited InitFullscreen(b);
	CreateOGLWindow;
	end;
end;

function TSGContextWinAPI.MouseShift:TSGPoint2f;
begin
Result.Import(-3*Byte(not FFullscreen),3*Byte(not FFullscreen));
end;

function TSGContextWinAPI.TopShift:LongWord;
begin
Result:=28*Byte(not FFullscreen);
end;

function TSGContextWinAPI.GetScreenResolution:TSGPoint2f;
begin
Result.Import(
	GetDeviceCaps(GetDC(GetDesktopWindow),HORZRES),
	GetDeviceCaps(GetDC(GetDesktopWindow),VERTRES));
end;

function TSGContextWinAPI.GetCursorPosition:TSGPoint2f;
var
	p:Tpoint;
begin
GetCursorPos(p);
Result.x:=p.x;
Result.y:=p.y;
end;

function TSGContextWinAPI.GetWindowRect:TSGPoint2f;
var
	Rec:TRect;
begin
Windows.getWindowRect(HWindow,Rec);
Result.x:=Rec.Left;
Result.y:=Rec.Top;
end;

constructor TSGContextWinAPI.Create;
begin
inherited;
hWindow:=0;
rcWindow:=0;
dcWindow:=0;
clWindow:=0;
end;

destructor TSGContextWinAPI.Destroy;
begin
KillOGLWindow;
inherited;
end;

procedure TSGContextWinAPI.Initialize();
var
	Succs:Boolean;
begin
Succs:=CreateOGLWindow;
Active:=Succs;
if Active then
	begin
	if SGCLLoadProcedure<>nil then
		SGCLLoadProcedure(Self);
	if FCallInitialize<>nil then
		FCallInitialize(Self);
	end;
end;

procedure TSGContextWinAPI.Run;
var
	FDT:TSGDateTime;
begin
Messages;
FElapsedDateTime.Get;
while FActive and (FNewContextType=nil) do
	begin
	//Calc ElapsedTime
	FDT.Get;
	FElapsedTime:=(FDT-FElapsedDateTime).GetPastMiliSeconds;
	FElapsedDateTime:=FDT;
	
	Render.Clear(SG_COLOR_BUFFER_BIT OR SG_DEPTH_BUFFER_BIT);
	FRender.InitMatrixMode(SG_3D);
	if FCallDraw<>nil then
		FCallDraw(Self);
	//SGIIdleFunction;
	
	ClearKeys;
	Messages;
	
	if SGCLPaintProcedure<>nil then
		SGCLPaintProcedure(Self);
	SwapBuffers;
	end;
end;

function SGFullscreenQueschionWinAPIMethod:boolean;
begin
Result:=MessageBox(0,'Fullscreen Mode?', 'Question!',MB_YESNO OR MB_ICONQUESTION) <> IDNO;
end;

procedure TSGContextWinAPI.SwapBuffers;
begin
Windows.SwapBuffers(  dcWindow  );
end;

procedure TSGContextWinAPI.Messages;
var
	msg:Windows.TMSG;
begin
Fillchar(msg,sizeof(msg),0);
if Windows.PeekMessage(@msg,0,0,0,0) = true then
	begin
	Windows.GetMessage(@msg,0,0,0);
	Windows.TranslateMessage(msg);
	Windows.DispatchMessage(msg);
	end;
inherited;
end;


procedure TSGContextWinAPI.ThrowError(pcErrorMessage : pChar);
begin
MessageBox(0, pcErrorMessage, 'Error', MB_OK);
Halt(0);
end;

{
	* WM_SETCURSOR = 32
	* WM_MOVE = 3
	* WM_MOVING = 534
	* 
	* 
	* 
	* 
	* 
	* }
function StandartGLWndProc(const Window: WinAPIHandle; const AMessage:LongWord; const WParam, LParam: WinAPIParam; var DoExit:Boolean): WinAPIParam;
var
	mRect:Windows.TRect;
	SGContext:TSGContext;
	i:LongWord;
begin 
SGContext:=nil;
Result:=0;
DoExit:=False;
if SGContexts<>nil then
for i:=0 to High(SGContexts) do
	if SGContexts[i].hWindow = Window then
		begin
		SGContext:=SGContexts[i];
		Break;
		end;
if SGContext=nil then
	Exit;
DoExit:=True;
case AMessage of
wm_create:
	begin
	SGContext.Active:=True;
	Exit;
	end;
wm_paint:
	begin
	exit;
	end;
260: //Alt Down
	SGContext.SetKey(SGDownKey,SG_ALT_KEY);
261: //Alt Up
	SGContext.SetKey(SGUpKey,SG_ALT_KEY);
262: // Key & Alt
	begin
	SGContext.SetKey(SGDownKey,WParam);
	SGContext.FKeysPressed[WParam]:=False;
	end;
wm_keydown:
	SGContext.SetKey(SGDownKey,WParam);
wm_keyup:
	SGContext.SetKey(SGUpKey,WParam);
wm_mousewheel:
	begin
	if PByte(@WParam)[3]>128 then
		begin
		SGContext.FCursorWheel:=SGDownCursorWheel;
		end
	else
		begin
		SGContext.FCursorWheel:=SGUpCursorWheel;
		end;
	end;
wm_lbuttondown:
	SGContext.SetCursorKey(SGDownKey,SGLeftCursorButton);
wm_rbuttondown:
	SGContext.SetCursorKey(SGDownKey,SGRightCursorButton);
wm_mbuttondown:
	SGContext.SetCursorKey(SGDownKey,SGMiddleCursorButton);
wm_lbuttonup:
	SGContext.SetCursorKey(SGUpKey,SGLeftCursorButton);
wm_rbuttonup:
	SGContext.SetCursorKey(SGUpKey,SGRightCursorButton);
wm_mbuttonup:
	SGContext.SetCursorKey(SGUpKey,SGMiddleCursorButton);
wm_destroy:
	begin
	SGLog.Sourse('SageWindow is closed for API.');
	SGContext.Active:=False;
	PostQuitMessage(0);
	Exit;
	end;
wm_syscommand:
	begin
	case (wParam) of
	SC_SCREENSAVE : begin
		Result := 0;
		end;
	SC_MONITORPOWER : begin
		Result := 0;
		end;
		end;
	end;
wm_size,wm_sizing
,wm_move,wm_moving,
WM_WINDOWPOSCHANGED,WM_WINDOWPOSCHANGING
: if (SGContext is TSGContextWinAPI) and (SGContext as TSGContextWinAPI).Active
	and (Window<>0) and ((SGContext as TSGContextWinAPI).hWindow=Window) then
	begin
	Windows.GetWindowRect(Window,mRect);
	(SGContext as TSGContextWinAPI).Width:=mRect.Right-mRect.Left;
	(SGContext as TSGContextWinAPI).Height:=mRect.Bottom-mRect.Top;
	(SGContext as TSGContextWinAPI).Resize;
	end;
else
	begin
	{$IFDEF SGWinAPIDebugB}
		SGLog.Sourse('StandartGLWndProc : Unknown Message : Window="'+SGSTr(Window)+'" Message="'+SGStr(AMessage)+'" wParam="'+SGStr(wParam)+'" lParam="'+SGStr(lParam)+'"');
		{$ENDIF}
	end;
end;
DoExit:=False;
end;

function MyGLWndProc(Window: WinAPIHandle; AMessage:LongWord; WParam,LParam:WinAPIParam):WinAPIParam;  stdcall; export;
var
	DoExit:Boolean;
begin 
//WriteLn(LongWord(LParam));
DoExit:=False;
{$IFDEF SGWinAPIDebugB}
	SGLog.Sourse('MyGLWndProc(Window='+SGStr(Window)+',AMessage='+SGStr(AMessage)+',WParam='+SGSTr(WParam)+',LParam='+SGStr(LParam)+') : Enter');
	{$ENDIF}
Result:=StandartGLWndProc(Window,AMessage,WParam,LParam,DoExit);
if DoExit then
	Exit
else
	Result := DefWindowProc(Window, AMessage, WParam, LParam);
{$IFDEF SGWinAPIDebugB}
	SGLog.Sourse('MyGLWndProc : Exit (Result='+SGStr(Result)+')');
	{$ENDIF}
end;

function TSGContextWinAPI.WindowRegister: Boolean;
var
  WindowClass: Windows.WndClass;

(*Porzhat*) //return GetFileAttributes("c:\ProgramFiles (x86)")==-1?32:64;  
{function GetProcessorArchitecture:Byte;
var
	Si,SI1:Windows.SYSTEM_INFO;
	i:LongWord;
begin
Result:=32;

FillChar(Si,SizeOf(Si),0);
GetSystemInfo(Si);

FillChar(Si1,SizeOf(Si1),0);
GetNativeSystemInfo(Si1);

for i:=0 to SizeOf(Si)-1 do
	if PByte(@SI)[i]<>PByte(@SI1)[i] then
		Result:=64;
end;}

begin
WindowClass.Style := cs_hRedraw and cs_vRedraw;
WindowClass.lpfnWndProc := WndProc(@MyGLWndProc);
WindowClass.cbClsExtra := 0;
WindowClass.cbWndExtra := 0;
WindowClass.hInstance :=system.MainInstance;
WindowClass.hIcon := LoadIcon(GetModuleHandle(nil),PCHAR(FIconIdentifier));
WindowClass.hCursor := LoadCursor(GetModuleHandle(nil),PCHAR(FCursorIdenifier));
WindowClass.hbrBackground := GetStockObject(WHITE_BRUSH);
WindowClass.lpszMenuName := nil;
WindowClass.lpszClassName := 'SaGe Window';
clWindow:=Windows.RegisterClass(WindowClass);
Result := clWindow <> 0;
{$IFDEF SGWinAPIDebug}
	SGLog.Sourse(['TSGContextWinAPI__WindowRegister : Exit (Result=',Result,')']);
	{$ENDIF}
end;

function TSGContextWinAPI.WindowCreate: HWnd;
var
  hWindow2: HWnd;
  dmScreenSettings : DEVMODE;
begin
//WriteLn(LongWord(Self));
{$IFDEF SGWinAPIDebug}
	SGLog.Sourse('TSGContextWinAPI__WindowCreate : Enter');
	{$ENDIF}
if not FFullscreen then 
	begin	
	hWindow2 := CreateWindow('SaGe Window',
			  SGStringToPChar(FTittle),
			  WS_CAPTION OR 
			  WS_POPUPWINDOW OR
			   WS_TILEDWINDOW OR 
			   WS_VISIBLE OR 
			   WS_CLIPSIBLINGS OR 
			   WS_CLIPCHILDREN,
			  cw_UseDefault,
			  cw_UseDefault,
			  FWidth,
			  FHeight,
			  0, 0,
			  system.MainInstance,
			  nil);
			  
	end 
else
	begin
	///WriteLn(FWidth,' ',FHeight);
	if (FWidth<>GetScreenResolution.x) or (FHeight<>GetScreenResolution.y) then
		begin
		dmScreenSettings.dmSize := sizeof(dmScreenSettings);
		dmScreenSettings.dmPelsWidth := FWidth;
		dmScreenSettings.dmPelsHeight := FHeight;
		dmScreenSettings.dmBitsPerPel := 32;
		dmScreenSettings.dmFields := DM_BITSPERPEL OR DM_PELSWIDTH OR DM_PELSHEIGHT;
		if ChangeDisplaySettings(@dmScreenSettings,CDS_FULLSCREEN) <> DISP_CHANGE_SUCCESSFUL then 
			begin
			ThrowError('Screen resolution is not supported by your gfx card!');
			WindowCreate := 0;
			Exit;
			end;
		end;
	hWindow2 := CreateWindowEx(WS_EX_APPWINDOW,
		'SaGe Window',
		SGStringToPChar(FTittle),
		WS_POPUP OR WS_VISIBLE OR WS_CLIPSIBLINGS OR WS_CLIPCHILDREN,
		0, 0,
		FWidth,
		FHeight,
		0, 0,
		system.MainInstance,
		nil );
	ShowCursor(true);
	end;
if hWindow2 <> 0 then 
	begin
	ShowWindow(hWindow2, CmdShow);
	UpdateWindow(hWindow2);
	end;
Result := hWindow2;
{$IFDEF SGWinAPIDebug}
	SGLog.Sourse(['TSGContextWinAPI__WindowCreate : Exit (Result=',Result,')']);
	{$ENDIF}
end;

function TSGContextWinAPI.WindowInit(hParent : HWnd): Boolean;
{var
	FunctionError : integer;
	pfd : PIXELFORMATDESCRIPTOR;
	iFormat : integer;}
begin
{$IFDEF SGWinAPIDebug}
	SGLog.Sourse(['TSGContextWinAPI__WindowInit(hParent=',hParent,') : Enter']);
	{$ENDIF}
//FunctionError := 0;
dcWindow := GetDC( hParent );
//writeln('dcWindow=',dcWindow);
{FillChar(pfd, sizeof(pfd), 0);
pfd.nSize         := sizeof(pfd);
pfd.nVersion      := 1;
pfd.dwFlags       := PFD_SUPPORT_OPENGL OR PFD_DRAW_TO_WINDOW OR PFD_DOUBLEBUFFER;
pfd.iPixelType    := PFD_TYPE_RGBA;
pfd.cColorBits    := 32;
pfd.cDepthBits    := 24;
pfd.iLayerType    := PFD_MAIN_PLANE;
iFormat := ChoosePixelFormat( dcWindow, @pfd );
if (iFormat = 0) then 
	FunctionError := 1;
SetPixelFormat( dcWindow, iFormat, @pfd );
if rcWindow=0 then
	begin
	rcWindow := wglCreateContext( dcWindow );
	if (rcWindow = 0) then 
		FunctionError := 2;
	end;
wglMakeCurrent( dcWindow, rcWindow );
if FunctionError = 0 then 
	Result := true 
else 
	Result := false;}
FRender:=FRenderClass.Create();
FRender.Window:=Self;
Result:=FRender.CreateContext();
//WriteLn(Result);
if Result then 
	FRender.Init();
{$IFDEF SGWinAPIDebug}
	SGLog.Sourse(['TSGContextWinAPI__WindowInit : Exit (Result=',Result,')']);
	{$ENDIF}
end;

function TSGContextWinAPI.CreateOGLWindow():Boolean;
begin 
{$IFDEF SGWinAPIDebug}
	SGLog.Sourse('TSGContextWinAPI__CreateOGLWindow : Enter');
	{$ENDIF}
if not WindowRegister then
		begin
		//ThrowError('Could not register the Application Window!');
		SGLog.Sourse('Could not register the Application Window!');
		CreateOGLWindow := false;
		Exit;
		end;
hWindow := WindowCreate;

if SGContexts=nil then
	SetLength(SGContexts,1)
else
	SetLength(SGContexts,Length(SGContexts)+1);
SGContexts[High(SGContexts)]:=Self;

if longint(hWindow) = 0 then begin
	//ThrowError('Could not create Application Window!');
	SGLog.Sourse('Could not create Application Window!');
	CreateOGLWindow := false;
	Exit;
	end;
if not WindowInit(hWindow) then begin
	//ThrowError('Could not initialise Application Window!');
	SGLog.Sourse('Could not initialise Application Window!');
	CreateOGLWindow := false;
	Exit;
	end;
Result := true;
{$IFDEF SGWinAPIDebug}
	SGLog.Sourse(['TSGContextWinAPI__CreateOGLWindow : Exit (Result=',Result,')']);
	{$ENDIF}
end;

procedure TSGContextWinAPI.KillOGLWindow(const KillRC:Boolean = True);
begin
{if dcWindow<>0 then
	wglMakeCurrent( dcWindow, 0 );}
{if KillRC and (rcWindow<>0) then
	begin
	wglDeleteContext( rcWindow );
	CloseHandle(rcWindow);
	rcWindow:=0;
	end;}
FRender.Destroy;
if (hWindow<>0) and (dcWindow<>0) then
	ReleaseDC( hWindow, dcWindow );
if (dcWindow<>0) then
	begin
	CloseHandle(dcWindow);
	dcWindow:=0;
	end;
if hWindow<>0 then
	DestroyWindow( hWindow );
if hWindow<>0 then
	begin
	CloseHandle( hWindow);
	hWindow:=0;
	end;
end;

end.

