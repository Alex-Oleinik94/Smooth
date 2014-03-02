{$include Includes\SaGe.inc}

unit SaGeContextWinAPI;

interface

uses
	 SaGeBase
	,SaGeBased
	,Windows
	,SaGeContext
	,SaGeCommon
	,SaGeRender
	;
//Где купить пиво? Ответ: в магазине. (Специально для макса)
// Там же можно купить и закусь (Макс без этого просто не может походу пить пиво)


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
		constructor Create();override;
		destructor Destroy();override;
			public
		procedure Initialize();override;
		procedure Run();override;
		procedure Messages();override;
		procedure SwapBuffers();override;
		function  GetCursorPosition():TSGPoint2f;override;
		function  GetWindowRect():TSGPoint2f;override;
		function  GetScreenResolution():TSGPoint2f;override;
			protected
		procedure InitFullscreen(const b:boolean); override;
			public
		procedure ShowCursor(const b:Boolean);override;
		procedure SetCursorPosition(const a:TSGPoint2f);override;
		function  KeysPressed(const  Index : integer ) : Boolean;override;overload;
		// If function need puplic, becourse it calls in WinAPI procedure without whis class
		function WndMessagesProc(const Window: WinAPIHandle; const AMessage:LongWord; const WParam, LParam: WinAPIParam): WinAPIParam;
			protected
		hWindow:HWnd;
		dcWindow:hDc;
		clWindow:LongWord;
		procedure ThrowError(pcErrorMessage : pChar);
		function  WindowRegister(): Boolean;
		function  WindowCreate(): HWnd;
		function  WindowInit(hParent : HWnd): Boolean;
		procedure KillOGLWindow(const KillRC:Boolean = True);
		function  CreateOGLWindow():Boolean;
			public
		function Get(const What:string):Pointer;override;
		end;
	
function SGFullscreenQueschionWinAPIMethod():boolean;
function StandartWndProc(const Window: WinAPIHandle; const AMessage:LongWord; const WParam, LParam: WinAPIParam; var DoExit:Boolean): WinAPIParam;
//procedure GetNativeSystemInfo(var a:SYSTEM_INFO);[stdcall];[external 'kernel32' name 'GetNativeSystemInfo'];

implementation

// А вод это жесткий костыль. 
// Дело в том, что в WinAPI класс нашего hWindow нельзя запихнуть собственную информацию,
// например указатель на контекст, и поэтому процедура отловления сообщений системы
// Ищет по hWindow совй контекст из всех открытых в программе контекстов (SGContexts)
var
	SGContexts:packed array of TSGContextWinAPI = nil;

function TSGContextWinAPI.Get(const What:string):Pointer;
begin
if What='WINDOW HANDLE' then
	Result:=Pointer(hWindow)
else if What='DESCTOP WINDOW HANDLE' then
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
dcWindow:=0;
clWindow:=0;
end;

destructor TSGContextWinAPI.Destroy;
begin
KillOGLWindow();
SetLength(SGContexts,0);
inherited;
end;

procedure TSGContextWinAPI.Initialize();
begin
Active:=CreateOGLWindow();
if Active then
	begin
	if SGScreenLoadProcedure<>nil then
		SGScreenLoadProcedure(Self);
	if FCallInitialize<>nil then
		FCallInitialize(Self);
	end;
end;

procedure TSGContextWinAPI.Run();
var
	FDT:TSGDateTime;
begin
Messages();
FElapsedDateTime.Get();
while FActive and (FNewContextType=nil) do
	begin
	//Calc ElapsedTime
	FDT.Get();
	FElapsedTime:=(FDT-FElapsedDateTime).GetPastMiliSeconds;
	FElapsedDateTime:=FDT;
	
	Render.Clear(SGR_COLOR_BUFFER_BIT OR SGR_DEPTH_BUFFER_BIT);
	Render.InitMatrixMode(SG_3D);
	if FCallDraw<>nil then
		FCallDraw(Self);
	//SGIIdleFunction;
	
	ClearKeys();
	Messages();
	
	if SGScreenPaintProcedure<>nil then
		SGScreenPaintProcedure(Self);
	SwapBuffers();
	end;
end;

function SGFullscreenQueschionWinAPIMethod:boolean;
begin
Result:=MessageBox(0,'Fullscreen Mode?', 'Question!',MB_YESNO OR MB_ICONQUESTION) <> IDNO;
end;

procedure TSGContextWinAPI.SwapBuffers();
begin
Render.SwapBuffers();
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
function TSGContextWinAPI.WndMessagesProc(const Window: WinAPIHandle; const AMessage:LongWord; const WParam, LParam: WinAPIParam): WinAPIParam;
var
	mRect:Windows.TRect;
begin
case AMessage of
wm_create:
	begin
	Active:=True;
	Exit;
	end;
wm_paint:
	begin
	Exit;
	end;
260: //Alt Down
	SetKey(SGDownKey,SG_ALT_KEY);
261: //Alt Up
	SetKey(SGUpKey,SG_ALT_KEY);
262: // Key & Alt
	begin
	SetKey(SGDownKey,WParam);
	FKeysPressed[WParam]:=False;
	end;
wm_keydown:
	SetKey(SGDownKey,WParam);
wm_keyup:
	SetKey(SGUpKey,WParam);
wm_mousewheel:
	begin
	if PByte(@WParam)[3]>128 then
		begin
		FCursorWheel:=SGDownCursorWheel;
		end
	else
		begin
		FCursorWheel:=SGUpCursorWheel;
		end;
	end;
wm_lbuttondown:
	SetCursorKey(SGDownKey,SGLeftCursorButton);
wm_rbuttondown:
	SetCursorKey(SGDownKey,SGRightCursorButton);
wm_mbuttondown:
	SetCursorKey(SGDownKey,SGMiddleCursorButton);
wm_lbuttonup:
	SetCursorKey(SGUpKey,SGLeftCursorButton);
wm_rbuttonup:
	SetCursorKey(SGUpKey,SGRightCursorButton);
wm_mbuttonup:
	SetCursorKey(SGUpKey,SGMiddleCursorButton);
wm_destroy:
	begin 
	SGLog.Sourse('TSGContextWinAPI__Messages : Note : Window is closed for API.');
	Active:=False;
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
 wm_size
,wm_sizing
,wm_move
,wm_moving
,WM_WINDOWPOSCHANGED
,WM_WINDOWPOSCHANGING:
	if Active and (Window<>0) and (hWindow=Window) then
		begin
		Windows.GetWindowRect(Window,mRect);
		Width:=mRect.Right-mRect.Left;
		Height:=mRect.Bottom-mRect.Top;
		Resize();
		end;
else
	begin
	{$IFDEF SGWinAPIDebugB}
		SGLog.Sourse('StandartWndProc : Unknown Message : Window="'+SGSTr(Window)+'" Message="'+SGStr(AMessage)+'" wParam="'+SGStr(wParam)+'" lParam="'+SGStr(lParam)+'"');
		{$ENDIF}
	end;
end;
end;

function StandartWndProc(const Window: WinAPIHandle; const AMessage:LongWord; const WParam, LParam: WinAPIParam; var DoExit:Boolean): WinAPIParam;
var
	SGContext:TSGContextWinAPI;
	i:TSGLongWord;
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
if SGContext<>nil then
	begin
	DoExit:=True;
	Result:=SGContext.WndMessagesProc(Window,AMessage,WParam,LParam);
	DoExit:=False;
	end;
end;

function MyGLWndProc(Window: WinAPIHandle; AMessage:LongWord; WParam,LParam:WinAPIParam):WinAPIParam;  stdcall; export;
var
	DoExit:Boolean;
begin 
//WriteLn(LongWord(LParam));
DoExit:=False;
{$IFDEF SGWinAPIDebugB}
	SGLog.Sourse('MyWndProc(Window='+SGStr(Window)+',AMessage='+SGStr(AMessage)+',WParam='+SGSTr(WParam)+',LParam='+SGStr(LParam)+') : Enter');
	{$ENDIF}
Result:=StandartWndProc(Window,AMessage,WParam,LParam,DoExit);
if DoExit then
	Exit
else
	Result := DefWindowProc(Window, AMessage, WParam, LParam);
{$IFDEF SGWinAPIDebugB}
	SGLog.Sourse('MyWndProc : Exit (Result='+SGStr(Result)+')');
	{$ENDIF}
end;

function TSGContextWinAPI.WindowRegister: Boolean;
var
  WindowClass: Windows.WndClassEx;

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
WindowClass.cbSize := sizeof(WNDCLASSEX);
WindowClass.Style := cs_hRedraw and cs_vRedraw;
WindowClass.lpfnWndProc := WndProc(@MyGLWndProc);
WindowClass.cbClsExtra := 0;
WindowClass.cbWndExtra := 0;
WindowClass.hInstance :=system.MainInstance;
WindowClass.hIcon := LoadIcon(GetModuleHandle(nil),PCHAR(FIconIdentifier));
WindowClass.hCursor := LoadCursor(GetModuleHandle(nil),PCHAR(FCursorIdenifier));
WindowClass.hbrBackground := GetStockObject(WHITE_BRUSH);
WindowClass.lpszMenuName := nil;
WindowClass.lpszClassName := 'SaGe Window Class';
WindowClass.hIconSm:=LoadIcon(GetModuleHandle(nil),PCHAR(FIconIdentifier));
clWindow:=Windows.RegisterClassEx(WindowClass);
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
{$IFDEF SGWinAPIDebug}
	SGLog.Sourse('TSGContextWinAPI__WindowCreate : Enter');
	{$ENDIF}
if not FFullscreen then 
	begin	
	hWindow2 := CreateWindow('SaGe Window Class',
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
			SGLog.Sourse('Screen resolution is not supported by your gfx card!');
			WindowCreate := 0;
			Exit;
			end;
		end;
	hWindow2 := CreateWindowEx(WS_EX_APPWINDOW,
		'SaGe Window Class',
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
	Active:=True;
	end;
Result := hWindow2;
{$IFDEF SGWinAPIDebug}
	SGLog.Sourse(['TSGContextWinAPI__WindowCreate : Exit (Result=',Result,')']);
	{$ENDIF}
end;

function TSGContextWinAPI.WindowInit(hParent : HWnd): Boolean;
begin
{$IFDEF SGWinAPIDebug}
	SGLog.Sourse(['TSGContextWinAPI__WindowInit(hParent=',hParent,') : Enter']);
	{$ENDIF}
dcWindow := GetDC( hParent );
if FRender=nil then
	begin
	{$IFDEF SGWinAPIDebug}
		SGLog.Sourse('TSGContextWinAPI__WindowInit(HWnd) : Createing render');
		{$ENDIF}
	FRender:=FRenderClass.Create();
	FRender.Window:=Self;
	Result:=FRender.CreateContext();
	if Result then 
		FRender.Init();
	{$IFDEF SGWinAPIDebug}
		SGLog.Sourse('TSGContextWinAPI__WindowInit(HWnd) : Created render (Render='+SGStr(LongWord(Pointer(FRender)))+')');
		{$ENDIF}
	end
else
	begin
	{$IFDEF SGWinAPIDebug}
		SGLog.Sourse('TSGContextWinAPI__WindowInit(HWnd) : Formating render (Render='+SGStr(LongWord(Pointer(FRender)))+')');
		{$ENDIF}
	FRender.Window:=Self;
	Result:=FRender.SetPixelFormat();
	if Result then
		Render.MakeCurrent();
	end;
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
		ThrowError('Could not register the Application Window!');
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

if longint(hWindow) = 0 then 
	begin
	ThrowError('Could not create Application Window!');
	SGLog.Sourse('Could not create Application Window!');
	Result := false;
	Exit;
	end;
if not WindowInit(hWindow) then 
	begin
	ThrowError('Could not initialise Application Window!');
	SGLog.Sourse('Could not initialise Application Window!');
	Result := false;
	Exit;
	end;
Result := true;
{$IFDEF SGWinAPIDebug}
	SGLog.Sourse(['TSGContextWinAPI__CreateOGLWindow : Exit (Result=',Result,')']);
	{$ENDIF}
end;

procedure TSGContextWinAPI.KillOGLWindow(const KillRC:Boolean = True);
begin
if (FRender<>nil) and (KillRC) then
	begin
	FRender.Destroy();
	FRender:=nil;
	end
else
	if (FRender<>nil) and (not KillRC) then
		begin
		FRender.ReleaseCurrent();
		FRender.Window:=nil;
		end;
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
UnregisterClass('SaGe Window Class', System.MainInstance);
end;

procedure TSGContextWinAPI.InitFullscreen(const b:boolean); 
begin
if hWindow=0 then
	inherited InitFullscreen(b)
else if Fullscreen<> b then
	begin
	KillOGLWindow(False);
	inherited InitFullscreen(b);
	Active:=CreateOGLWindow();
	end;
end;

end.

