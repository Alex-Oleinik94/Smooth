{$include Includes\SaGe.inc}

//{$DEFINE SGWinAPIDebug}

unit SaGeContextWinAPI;

interface

uses
	 SaGeBase
	,SaGeBased
	,Windows
	,SaGeContext
	,SaGeCommon
	,SaGeRender
	,commdlg
	,SaGeClasses
	;

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
		function  GetWindowArea():TSGPoint2f;override;
		function  GetScreenArea():TSGPoint2f;override;
		function  ShiftClientArea() : TSGPoint2f; override;
			public
		procedure ShowCursor(const VVisibility : TSGBoolean);override;
		procedure SetCursorPosition(const VPosition : TSGPoint2f);override;
		function  KeysPressed(const  Index : integer ) : Boolean;override;overload;
		// If function need puplic, becourse it calls in WinAPI procedure without whis class
		function WndMessagesProc(const VWindow: WinAPIHandle; const AMessage:LongWord; const WParam, LParam: WinAPIParam): WinAPIParam;
			protected
		procedure InitFullscreen(const VFullscreen : TSGBoolean); override;
		function  GetWindow() : TSGPointer; override;
		function  GetDevice() : TSGPointer; override;
			protected
		hWindow  : HWnd;
		dcWindow : hDc;
		clWindow : LongWord;
		procedure ThrowError(pcErrorMessage : pChar);
		function  WindowRegister(): Boolean;
		function  WindowCreate(): HWnd;
		function  WindowInit(hParent : HWnd): Boolean;
		procedure KillWindow(const KillRC:Boolean = True);
		function  CreateWindow():Boolean;
		class function GetClientWindowRect(const VWindow : HWND) : TRect;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function GetWindowRect(const VWindow : HWND) : TRect;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function  GetClientWidth() : TSGLongWord;override;
		function  GetClientHeight() : TSGLongWord;override;
			protected
		FNormalCursor,
			FNullCursor : TSGLongWord;
			public
		function  GetCursorPosition():TSGPoint2f;override;
		function FileOpenDialog(const VTittle: String; const VFilter : String):String;override;
		function FileSaveDialog(const VTittle: String; const VFilter : String;const extension : String):String;override;
		end;
	
function SGFullscreenQueschionWinAPIMethod():boolean;
function StandartWndProc(const Window: WinAPIHandle; const AMessage:LongWord; const WParam, LParam: WinAPIParam; var DoExit:Boolean): WinAPIParam;
//procedure GetNativeSystemInfo(var a:SYSTEM_INFO);[stdcall];[external 'kernel32' name 'GetNativeSystemInfo'];

implementation

uses
	SaGeScreen
	,SysUtils
	,SaGeCommonClasses;

// � ��� ��� ������� �������. 
// ���� � ���, ��� � WinAPI ����� ������ hWindow ������ ��������� ����������� ����������,
// �������� ��������� �� ��������, � ������� ��������� ���������� ��������� �������
// ���� �� hWindow ���� �������� �� ���� �������� � ��������� ���������� (SGContexts)
var
	SGContexts:packed array of TSGContextWinAPI = nil;

class function TSGContextWinAPI.GetWindowRect(const VWindow : HWND) : TRect;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Windows.GetWindowRect(VWindow, Result);
end;

function  TSGContextWinAPI.GetClientWidth() : TSGLongWord;
begin
Result := GetClientWindowRect(hWindow).right;
end;

function  TSGContextWinAPI.GetClientHeight() : TSGLongWord;
begin
Result := GetClientWindowRect(hWindow).bottom;
end;

class function TSGContextWinAPI.GetClientWindowRect(const VWindow : HWND) : TRect;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Windows.GetClientRect(VWindow, Result);
end;

function  TSGContextWinAPI.GetWindow() : TSGPointer;
begin
Result := TSGPointer(hWindow);
end;

function  TSGContextWinAPI.GetDevice() : TSGPointer; 
begin
Result := TSGPointer(dcWindow);
end;

function  TSGContextWinAPI.ShiftClientArea() : TSGPoint2f;
begin
if Fullscreen then
	Result.Import(0,0)
else
	Result.Import(
		GetSystemMetrics(SM_CXSIZEFRAME),
		Height - ClientHeight - GetSystemMetrics(SM_CYSIZEFRAME));
end;

function TSGContextWinAPI.FileSaveDialog(const VTittle: String; const VFilter : String;const extension : String):String;
const
	sizeOfResult = 1000;
var
	ofn : LPOPENFILENAME;
begin
New(ofn);
fillchar(ofn^,sizeof(ofn^),0);
ofn^.lStructSize       := sizeof(ofn^);
ofn^.hInstance         := System.MainInstance;
ofn^.hwndOwner         := hWindow;
if (VFilter <> '') then
	ofn^.lpstrFilter   := SGStringToPChar(VFilter);
ofn^.lpstrFile         := nil;
ofn^.lpstrFileTitle    := nil;
ofn^.Flags             := OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST or OFN_HIDEREADONLY;
ofn^.nMaxFile          := sizeOfResult;
ofn^.lpstrFile         := GetMem(sizeOfResult);
if (VTittle <> '') then
	ofn^.lpstrTitle    := SGStringToPChar(VTittle);
ofn^.nFilterIndex      := 1;
fillchar(ofn^.lpstrFile^,1000,0);
ofn^.lpstrDefExt := SGStringToPChar(extension);

if not GetSaveFileName (ofn) then
	begin
	{$IFDEF SGDebuging}
		SGLog.Sourse('TSGContextWinAPI.FileSaveDlg - GetSaveFileName(...) results with FALSE');
		{$ENDIF}
	end;
Result := SGPCharToString(ofn^.lpstrFile);
FreeMem(ofn^.lpstrFile,sizeof(sizeOfResult));
if ofn^.lpstrFilter <> nil then
	FreeMem(ofn^.lpstrFilter,Length(VFilter));
if ofn^.lpstrTitle <> nil then
	FreeMem(ofn^.lpstrTitle,Length(VTittle));
if ofn^.lpstrDefExt <> nil then
	FreeMem(ofn^.lpstrDefExt,Length(extension));
FreeMem(ofn,sizeof(ofn^));
end;

function TSGContextWinAPI.FileOpenDialog(const VTittle: String; const VFilter : String):String;
const
	sizeOfResult = 1000;
var
	ofn : LPOPENFILENAME;
begin
New(ofn);
fillchar(ofn^,sizeof(ofn^),0);
ofn^.lStructSize       := sizeof(ofn^);
ofn^.hInstance         := System.MainInstance;
ofn^.hwndOwner         := hWindow;
if (VFilter <> '') then
	ofn^.lpstrFilter   := SGStringToPChar(VFilter);
ofn^.lpstrFile         := nil;
ofn^.lpstrFileTitle    := nil;
ofn^.Flags             := OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST or OFN_HIDEREADONLY;
ofn^.nMaxFile          := sizeOfResult;
ofn^.lpstrFile         := GetMem(sizeOfResult);
if (VTittle <> '') then
	ofn^.lpstrTitle    := SGStringToPChar(VTittle);
ofn^.nFilterIndex      := 1;
fillchar(ofn^.lpstrFile^,1000,0);

if not GetOpenFileName (ofn) then
	begin
	{$IFDEF SGDebuging}
		SGLog.Sourse('TSGContextWinAPI.FileOpenDlg - GetOpenFileName(...) results with FALSE');
		{$ENDIF}
	end;
Result := SGPCharToString(ofn^.lpstrFile);
FreeMem(ofn^.lpstrFile,sizeof(sizeOfResult));
if ofn^.lpstrFilter <> nil then
	FreeMem(ofn^.lpstrFilter,Length(VFilter));
if ofn^.lpstrTitle <> nil then
	FreeMem(ofn^.lpstrTitle,Length(VTittle));
FreeMem(ofn,sizeof(ofn^));
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

procedure TSGContextWinAPI.SetCursorPosition(const VPosition : TSGPoint2f);
var
	WindowShift : Windows.TRect;
	ClientShift : TSGPoint2f;
begin
if FFullscreen then
	Windows.SetCursorPos(VPosition.x, VPosition.y)
else
	begin
	WindowShift := TSGContextWinAPI.GetWindowRect(hWindow);
	ClientShift := ShiftClientArea();
	Windows.SetCursorPos(VPosition.x + WindowShift.left + ClientShift.x, VPosition.y + WindowShift.top + ClientShift.y);
	end;
end;

procedure TSGContextWinAPI.ShowCursor(const VVisibility : TSGBoolean);
begin
inherited;
Windows.ShowCursor(FShowCursor);
end;

function TSGContextWinAPI.GetScreenArea():TSGPoint2f;
begin
Result.Import(
	Windows.GetDeviceCaps(Windows.GetDC(Windows.GetDesktopWindow()),HORZRES),
	Windows.GetDeviceCaps(Windows.GetDC(Windows.GetDesktopWindow()),VERTRES));
end;

function TSGContextWinAPI.GetCursorPosition:TSGPoint2f;
var
	Position : Windows.TPoint;
	Shift : Windows.TRect;
begin
Windows.GetCursorPos(Position);
if FFullscreen then
	Result.Import(Position.x, Position.y)
else
	begin
	Shift := TSGContextWinAPI.GetWindowRect(hWindow);
	Result.Import(Position.x - Shift.left, Position.y - Shift.top);
	end;
end;

function TSGContextWinAPI.GetWindowArea():TSGPoint2f;
var
	Rec:TRect;
begin
Windows.GetWindowRect(hWindow,Rec);
Result.x:=Rec.Left;
Result.y:=Rec.Top;
end;

constructor TSGContextWinAPI.Create;
begin
inherited;
hWindow  := 0;
dcWindow := 0;
clWindow := 0;
FNormalCursor := LoadCursor(GetModuleHandle(nil), MAKEINTRESOURCE(5));
FNullCursor := LoadCursor(GetModuleHandle(nil), MAKEINTRESOURCE(5));
end;

destructor TSGContextWinAPI.Destroy;
begin
KillWindow();
SetLength(SGContexts,0);
inherited;
end;

procedure TSGContextWinAPI.Initialize();
begin
Active := CreateWindow();
if Active then
	begin
	SGScreen.Load(Self);
	inherited;
	end;
SetClassLong(hWindow, GCL_HCURSOR, FNullCursor);
end;

procedure TSGContextWinAPI.Run();
begin
Messages();
StartComputeTimer();
while Active and (FNewContextType = nil) do
	begin
	Paint();
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
function TSGContextWinAPI.WndMessagesProc(const VWindow: WinAPIHandle; const AMessage:LongWord; const WParam, LParam: WinAPIParam): WinAPIParam;

procedure HandlingSizing();
var
	mRect:Windows.TRect;
begin
Windows.GetWindowRect(hWindow, mRect);
Width:=mRect.Right-mRect.Left;
Height:=mRect.Bottom-mRect.Top;
Resize();
end;

procedure HandlingSizingWithPaint();
begin
HandlingSizing();
FPaintWithHandlingMessages := False;
Paint();
FPaintWithHandlingMessages := True;
end;

procedure HandlingMinMaxInfo();
type
	MinMaxInfo = ^ Windows.MINMAXINFO;
var
	pInfo : MinMaxInfo;
begin
pInfo := MinMaxInfo(lParam);
pInfo^.ptMinTrackSize.x := 320;
pInfo^.ptMinTrackSize.y := 240;
pInfo^.ptMaxTrackSize.x := 1000000;
pInfo^.ptMaxTrackSize.y := 1000000;
end;

begin
case AMessage of
WM_GETMINMAXINFO:
	begin
	HandlingMinMaxInfo();
	end;
wm_create:
	begin
	Active := True;
	Result := 0;
	end;
wm_paint:
	begin
	FPaintWithHandlingMessages := False;
	Paint();
	FPaintWithHandlingMessages := True;
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
wm_size:
	begin
	HandlingSizingWithPaint();
	Result := 0;
	end;
wm_sizing:
	begin
	HandlingSizing();
	Result := 1;
	end;
wm_move
,wm_moving
,WM_WINDOWPOSCHANGED
,WM_WINDOWPOSCHANGING:
	begin
	HandlingSizing();
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
WindowClass.cbSize        := SizeOf(WNDCLASSEX);
WindowClass.Style         := cs_hRedraw or cs_vRedraw or CS_OWNDC;
WindowClass.lpfnWndProc   := WndProc(@MyGLWndProc);
WindowClass.cbClsExtra    := 0;
WindowClass.cbWndExtra    := 0;
WindowClass.hInstance     := System.MainInstance;
WindowClass.hIcon         := LoadIcon(GetModuleHandle(nil),MAKEINTRESOURCE(5));
WindowClass.hCursor       := FNormalCursor;
WindowClass.hbrBackground := 0;
WindowClass.lpszMenuName  := nil;
WindowClass.lpszClassName := 'SaGe Window Class';
WindowClass.hIconSm       := WindowClass.hIcon;

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
	hWindow2 := Windows.CreateWindow('SaGe Window Class',
			  SGStringToPChar(FTitle),
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
	if (FWidth<>GetScreenArea().x) or (FHeight<>GetScreenArea().y) then
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
		SGStringToPChar(FTitle),
		WS_EX_TOPMOST OR WS_POPUP OR WS_VISIBLE OR WS_CLIPSIBLINGS OR WS_CLIPCHILDREN,
		0, 0,
		FWidth,
		FHeight,
		0, 0,
		system.MainInstance,
		nil );
	ShowCursor(FShowCursor);
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
if FRender = nil then
	begin
	{$IFDEF SGWinAPIDebug}
		SGLog.Sourse('TSGContextWinAPI__WindowInit(HWnd) : Createing render');
		{$ENDIF}
	FRender := FRenderClass.Create();
	FRender.Context := Self as ISGContext;
	Result := FRender.CreateContext();
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
	FRender.Context := Self as ISGContext;
	Result := FRender.SetPixelFormat();
	if Result then
		Render.MakeCurrent();
	end;
{$IFDEF SGWinAPIDebug}
	SGLog.Sourse(['TSGContextWinAPI__WindowInit : Exit (Result=',Result,')']);
	{$ENDIF}
end;

function TSGContextWinAPI.CreateWindow():Boolean;
begin 
{$IFDEF SGWinAPIDebug}
	SGLog.Sourse('TSGContextWinAPI__CreateWindow : Enter');
	{$ENDIF}
if not WindowRegister then
		begin
		ThrowError('Could not register the Application Window!');
		SGLog.Sourse('Could not register the Application Window!');
		Result := false;
		Exit;
		end;
hWindow := WindowCreate();

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
	SGLog.Sourse(['TSGContextWinAPI__CreateWindow : Exit (Result=',Result,')']);
	{$ENDIF}
end;

procedure TSGContextWinAPI.KillWindow(const KillRC:Boolean = True);
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
		FRender.Context := nil;
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

procedure TSGContextWinAPI.InitFullscreen(const VFullscreen : TSGBoolean); 
begin
if hWindow = 0 then
	inherited InitFullscreen(VFullscreen)
else 
	if Fullscreen <> VFullscreen then
		begin
		if (FRender<>nil) then
			begin
			FRender.LockResourses();
			FRender.ReleaseCurrent();
			end;
		KillWindow(False);
		inherited InitFullscreen(VFullscreen);
		Active := CreateWindow();
		if (FRender<>nil) and Active then
			FRender.UnLockResourses();
		Resize();
		end;
end;

end.

