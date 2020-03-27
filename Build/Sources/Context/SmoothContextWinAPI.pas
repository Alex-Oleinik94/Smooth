{$INCLUDE Smooth.inc}

//{$DEFINE SWinAPIDebug}

unit SmoothContextWinAPI;

interface

uses
	// Engine
	 SmoothBase
	,SmoothContext
	,SmoothRender
	,SmoothBaseClasses
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothBitMap
	,SmoothCursor
	,SmoothCommonStructs
	,SmoothContextUtils
	,SmoothWinAPIUtils
	
	// Windows units
	,Windows
	,CommDlg
	,CommCtrl
	,ActiveX
	,jwauserenv
	;
type
	TRectangle = Windows.TRect;
	
	TSContextWinAPI = class(TSContext)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		class function ContextName() : TSString; override;
		procedure Initialize(const _WindowPlacement : TSContextWindowPlacement = SPlacementNormal); override;
		procedure Messages();override;
		procedure SwapBuffers();override;
		function  GetWindowArea(): TSPoint2int32;override;
		function  GetScreenArea(): TSPoint2int32;override;
		function  ShiftClientArea() : TSPoint2int32; override;
		procedure Kill();override;
		class function Supported() : TSBoolean; override;
		class function ClassName() : TSString;override;
		function GetDefaultWindowColor():TSColor3f;override;
		procedure Minimize();override;
		procedure Maximize();override;
		class function UserProfilePath() : TSString; override;
			public
		procedure SetForeground(); override;
		procedure ShowCursor(const VVisibility : TSBoolean);override;
		procedure SetCursorPosition(const VPosition : TSPoint2int32);override;
		function  KeysPressed(const  Index : integer ) : Boolean;override;overload;
		// If function need puplic, becourse it calls in WinAPI procedure without whis class
		function WndMessagesProc(const AMessage:LongWord; const WParam, LParam: TSWinAPIParam): TSWinAPIParam;
			protected
		procedure SetVisible(const _Visible : TSBoolean); override;
		procedure InitFullscreen(const VFullscreen : TSBoolean); override;
		function  GetWindow() : TSPointer; override;
		function  GetDevice() : TSPointer; override;
		procedure SetCursor(const VCursor : TSCursor); override;
		procedure SetIcon  (const VIcon   : TSBitMap); override;
			protected
		FWindowClass : TSMaxEnum;
		FWindowClassName : TSString;
		FWindow  : Windows.HWnd;
		FDeviceContext : Windows.HDC;
			protected
		function  RegisterWindowClass() : TSBoolean;
		function  WindowCreate(const _WindowPlacement : TSContextWindowPlacement = SPlacementNormal): Windows.HWnd;
		function  WindowInit(): TSBoolean;
		procedure KillWindow();
		function  CreateWindow(const _WindowPlacement : TSContextWindowPlacement = SPlacementNormal) : TSBoolean;
		class function GetClientWindowRectangle(const _Window : HWND) : TRectangle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function GetWindowRectangle(const _Window : HWND) : TRectangle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function SetWindowPlacement(const _Placement : TSUInt32) : TSBoolean;
		procedure ThrowError(const ErrorString : TSString);
		procedure HandlingSizingFromRect(const PR : PRect = nil);
		class procedure SetWindowCursor(const _WindowClass : TSMaxEnum; const _Window : Windows.HWnd; const _Cursor : Windows.HCURSOR);
			protected
		FCursorHandle : Windows.HCURSOR;
		FIconHandle   : Windows.HICON;
		FGlassyCursorHandle : Windows.HCURSOR;
		FNormalCursorHandle : Windows.HCURSOR;
			public
		function  GetCursorPosition(): TSPoint2int32; override;
		function  FileOpenDialog(const VTittle: String; const VFilter : String):String;override;
		function  FileSaveDialog(const VTittle: String; const VFilter : String;const extension : String):String;override;
		end;

implementation

uses
	 SmoothScreen
	,SmoothLog
	,SmoothWinAPIIconUtils
	,SmoothStringUtils
	,SmoothFileUtils
	
	,SysUtils
	;

class function TSContextWinAPI.ContextName() : TSString;
begin
Result := 'WinAPI';
end;

procedure TSContextWinAPI.SetVisible(const _Visible : TSBoolean);
begin
if (_Visible <> FVisible) then
	begin
	if (FWindow <> 0) then
		if (_Visible) then
			ShowWindow(FWindow, SW_SHOW)
		else
			ShowWindow(FWindow, SW_HIDE);
	inherited SetVisible(_Visible);
	end;
end;

class function TSContextWinAPI.UserProfilePath() : TSString;
const 
	MaxMem : TSUInt32 = 100;
var
	ProfilePath : LPTSTR = nil;
	Size : TSUInt32;
	hCurrentProcess : Windows.HANDLE;
	hToken : Windows.HANDLE;
begin
Result := inherited UserProfilePath();
GetMem(ProfilePath, MaxMem);
Size := MaxMem;
hCurrentProcess := GetCurrentProcess();
if hCurrentProcess = 0 then
	SLog.Source(['TSContextWinAPI__UserProfilePath : GetCurrentProcess() returned falture handle!'])
else
	if not OpenProcessToken(hCurrentProcess, TOKEN_ALL_ACCESS, hToken) then
		SLog.Source(['TSContextWinAPI__UserProfilePath : OpenProcessToken(..) returned FALSE!']);
	if hToken = 0 then
		SLog.Source(['TSContextWinAPI__UserProfilePath : OpenProcessToken(..) returned falture token!'])
	else
		if not GetUserProfileDirectory(hToken, ProfilePath, Size) then
			SLog.Source(['TSContextWinAPI__UserProfilePath : GetUserProfileDirectory(..) returned FALSE!'])
		else
			Result := SPCharToString(ProfilePath);
if hToken <> 0 then
	CloseHandle(hToken);
FreeMem(ProfilePath);
end;

function TSContextWinAPI.SetWindowPlacement(const _Placement : TSUInt32) : TSBoolean;
var
	wp : WINDOWPLACEMENT;
begin
Result := GetWindowPlacement(FWindow, @wp);
if Result then
	begin
	wp.showCmd := _Placement;
	Result := Windows.SetWindowPlacement(FWindow, @wp);
	end;
end;

procedure TSContextWinAPI.Minimize();
begin
SetWindowPlacement(SW_SHOWMINIMIZED);
end;

procedure TSContextWinAPI.Maximize();
begin
SetWindowPlacement(SW_SHOWMAXIMIZED);
end;

function TSContextWinAPI.GetDefaultWindowColor():TSColor3f;
var
	Colour : TSLongWord;
begin
Colour := GetSysColor(COLOR_WINDOW);
Result.Import(
	PByte(@Colour)[0]/255,
	PByte(@Colour)[1]/255,
	PByte(@Colour)[2]/255);
end;

class function TSContextWinAPI.ClassName() : TSString;
begin
Result := 'TSContextWinAPI';
end;

class function TSContextWinAPI.Supported() : TSBoolean;
begin
Result := True;
end;

class procedure TSContextWinAPI.SetWindowCursor(const _WindowClass : TSMaxEnum; const _Window : Windows.HWnd; const _Cursor : Windows.HCURSOR);
begin
Windows.SetClassLongPtr(_Window, GCL_HCURSOR, _Cursor);
Windows.SetClassLongPtr(_WindowClass, GCL_HCURSOR, _Cursor);
Windows.SetCursor(_Cursor);
end;

procedure TSContextWinAPI.SetCursor(const VCursor : TSCursor);
var
	NewCursor : HCURSOR;
begin
if VCursor.StandartHandle <> SC_NULL then
	begin
	if (not VCursor.HasData()) then
		begin
		NewCursor := LoadCursor(0, MAKEINTRESOURCE(VCursor.StandartHandle));
		if NewCursor <> SC_NULL then
			begin
			inherited;
			FCursorHandle := NewCursor;
			if Active then
				SetWindowCursor(FWindowClass, FWindow, FCursorHandle);
			end;
		end
	else
		begin
		NewCursor := SWinAPICreateCursor(VCursor, RGB(0,0,0));
		if NewCursor <> SC_NULL then
			Windows.SetSystemCursor(NewCursor, VCursor.StandartHandle);
		end;
	end
else
	begin
	NewCursor := SWinAPICreateCursor(VCursor, RGB(0,0,0));
	if NewCursor <> SC_NULL then
		begin
		FCursorHandle := NewCursor;
		inherited;
		if Active then
			SetWindowCursor(FWindowClass, FWindow, FCursorHandle);
		end;
	end;
end;

procedure TSContextWinAPI.SetIcon  (const VIcon   : TSBitMap);
begin

end;

class function TSContextWinAPI.GetWindowRectangle(const _Window : HWND) : TRectangle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Windows.GetWindowRect(_Window, Result);
end;

class function TSContextWinAPI.GetClientWindowRectangle(const _Window : HWND) : TRectangle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Windows.GetClientRect(_Window, Result);
end;

function  TSContextWinAPI.GetWindow() : TSPointer;
begin
Result := TSPointer(FWindow);
end;

function  TSContextWinAPI.GetDevice() : TSPointer;
begin
Result := TSPointer(FDeviceContext);
end;

function  TSContextWinAPI.ShiftClientArea() : TSPoint2int32;
begin
if Fullscreen then
	Result.Import(0,0)
else
	Result.Import(
		GetSystemMetrics(SM_CXSIZEFRAME),
		Height - ClientHeight - GetSystemMetrics(SM_CYSIZEFRAME));
end;

function TSContextWinAPI.FileSaveDialog(const VTittle: String; const VFilter : String;const extension : String):String;
const
	sizeOfResult = 1000;
var
	ofn : LPOPENFILENAME;
begin
New(ofn);
fillchar(ofn^,sizeof(ofn^),0);
ofn^.lStructSize       := sizeof(ofn^);
ofn^.hInstance         := System.MainInstance;
ofn^.hwndOwner         := FWindow;
if (VFilter <> '') then
	ofn^.lpstrFilter   := SStringToPChar(VFilter);
ofn^.lpstrFile         := nil;
ofn^.lpstrFileTitle    := nil;
ofn^.Flags             := OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST or OFN_HIDEREADONLY;
ofn^.nMaxFile          := sizeOfResult;
ofn^.lpstrFile         := GetMem(sizeOfResult);
if (VTittle <> '') then
	ofn^.lpstrTitle    := SStringToPChar(VTittle);
ofn^.nFilterIndex      := 1;
fillchar(ofn^.lpstrFile^,1000,0);
ofn^.lpstrDefExt := SStringToPChar(extension);

if not GetSaveFileName (ofn) then
	begin
	{$IFDEF SDebuging}
		SLog.Source('TSContextWinAPI__FileSaveDlg - GetSaveFileName(...) results with FALSE');
		{$ENDIF}
	end;
Result := SPCharToString(ofn^.lpstrFile);
FreeMem(ofn^.lpstrFile,sizeof(sizeOfResult));
if ofn^.lpstrFilter <> nil then
	FreeMem(ofn^.lpstrFilter,Length(VFilter));
if ofn^.lpstrTitle <> nil then
	FreeMem(ofn^.lpstrTitle,Length(VTittle));
if ofn^.lpstrDefExt <> nil then
	FreeMem(ofn^.lpstrDefExt,Length(extension));
FreeMem(ofn,sizeof(ofn^));
end;

function TSContextWinAPI.FileOpenDialog(const VTittle: String; const VFilter : String):String;
const
	sizeOfResult = 1000;
var
	ofn : LPOPENFILENAME;
begin
New(ofn);
fillchar(ofn^,sizeof(ofn^),0);
ofn^.lStructSize       := sizeof(ofn^);
ofn^.hInstance         := System.MainInstance;
ofn^.hwndOwner         := FWindow;
if (VFilter <> '') then
	ofn^.lpstrFilter   := SStringToPChar(VFilter);
ofn^.lpstrFile         := nil;
ofn^.lpstrFileTitle    := nil;
ofn^.Flags             := OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST or OFN_HIDEREADONLY;
ofn^.nMaxFile          := sizeOfResult;
ofn^.lpstrFile         := GetMem(sizeOfResult);
if (VTittle <> '') then
	ofn^.lpstrTitle    := SStringToPChar(VTittle);
ofn^.nFilterIndex      := 1;
fillchar(ofn^.lpstrFile^,1000,0);

if not GetOpenFileName (ofn) then
	begin
	{$IFDEF SDebuging}
		SLog.Source('TSContextWinAPI__FileOpenDlg - GetOpenFileName(...) results with FALSE');
		{$ENDIF}
	end;
Result := SPCharToString(ofn^.lpstrFile);
FreeMem(ofn^.lpstrFile,sizeof(sizeOfResult));
if ofn^.lpstrFilter <> nil then
	FreeMem(ofn^.lpstrFilter,Length(VFilter));
if ofn^.lpstrTitle <> nil then
	FreeMem(ofn^.lpstrTitle,Length(VTittle));
FreeMem(ofn,sizeof(ofn^));
end;

function TSContextWinAPI.KeysPressed(const  Index : integer ) : TSBoolean;overload;
begin
if Index = 20 then //Caps Lock
	Result := SSystemKeyPressed(20)
else
	Result:=inherited;
end;

procedure TSContextWinAPI.SetCursorPosition(const VPosition : TSPoint2int32);
var
	WindowShift : TRectangle;
	ClientShift : TSPoint2int32;
begin
if FFullscreen then
	Windows.SetCursorPos(VPosition.x, VPosition.y)
else
	begin
	WindowShift := GetWindowRectangle(FWindow);
	ClientShift := ShiftClientArea();
	Windows.SetCursorPos(VPosition.x + WindowShift.left + ClientShift.x, VPosition.y + WindowShift.top + ClientShift.y);
	end;
end;

procedure TSContextWinAPI.ShowCursor(const VVisibility : TSBoolean);
begin
inherited;
Windows.ShowCursor(True);
if FShowCursor then
	FCursorHandle := FNormalCursorHandle
else
	FCursorHandle := FGlassyCursorHandle;
SetWindowCursor(FWindowClass, FWindow, FCursorHandle);
Windows.ShowCursor(FShowCursor);
end;

function TSContextWinAPI.GetScreenArea(): TSPoint2int32;
begin
Result.Import(
	Windows.GetDeviceCaps(Windows.GetDC(Windows.GetDesktopWindow()), HORZRES),
	Windows.GetDeviceCaps(Windows.GetDC(Windows.GetDesktopWindow()), VERTRES));
end;

function TSContextWinAPI.GetCursorPosition: TSPoint2int32;
var
	Position : Windows.TPoint;
	Shift : TRectangle;
begin
Windows.GetCursorPos(Position);
if FFullscreen then
	Result.Import(Position.x, Position.y)
else
	begin
	Shift := GetWindowRectangle(FWindow);
	Result.Import(Position.x - Shift.left, Position.y - Shift.top);
	end;
end;

function TSContextWinAPI.GetWindowArea(): TSPoint2int32;
var
	Rectangle : TRectangle;
begin
Rectangle := GetWindowRectangle(FWindow);
Result.x := Rectangle.Left;
Result.y := Rectangle.Top;
end;

constructor TSContextWinAPI.Create;
begin
inherited;
FWindowClassName := '';
FWindow  := 0;
FWindowClass := 0;
FDeviceContext := 0;
FNormalCursorHandle := LoadCursor(0, IDC_ARROW);
FCursorHandle := FNormalCursorHandle;
FIconHandle   := LoadIcon(GetModuleHandle(nil), MAKEINTRESOURCE(SCWAPI_ICON));
FGlassyCursorHandle := SWinAPICreateGlassyCursor();
end;

procedure TSContextWinAPI.Kill();
begin
KillWindow();
inherited;
end;

destructor TSContextWinAPI.Destroy();
begin
inherited;
end;

procedure TSContextWinAPI.Initialize(const _WindowPlacement : TSContextWindowPlacement = SPlacementNormal);

procedure HandlingReSizingFromRect();
var
	WindowRectangle : Windows.TRect;
	ClientWindowRectangle : Windows.TRect;
begin
WindowRectangle := GetWindowRectangle(FWindow);
FWidth  :=  WindowRectangle.Right  - WindowRectangle.Left;
FHeight :=  WindowRectangle.Bottom - WindowRectangle.Top;
FLeft := WindowRectangle.Left;
FTop  := WindowRectangle.Top;
ClientWindowRectangle := GetClientWindowRectangle(FWindow);
FClientHeight := ClientWindowRectangle.bottom - ClientWindowRectangle.top;
FClientWidth  := ClientWindowRectangle.right  - ClientWindowRectangle.left;
Resize();
end;

begin
Active := CreateWindow(_WindowPlacement);
if Active then
	begin
	HandlingReSizingFromRect();
	inherited;
	end;
end;

procedure TSContextWinAPI.SwapBuffers();
begin
Render.SwapBuffers();
end;

procedure TSContextWinAPI.Messages;
var
	msg : Windows.TMSG;
begin
Fillchar(msg, sizeof(msg), 0);
while Windows.PeekMessage(@msg, 0, 0, 0, 0) do
	begin
	Windows.GetMessage(@msg, 0, 0, 0);
	Windows.TranslateMessage(msg);
	Windows.DispatchMessage(msg);
	Fillchar(msg, sizeof(msg), 0);
	end;
inherited;
end;

procedure TSContextWinAPI.ThrowError(const ErrorString : TSString);
var
	ErrorChars : PSChar = nil;
	LastError : TSUInt32;
	FullErrorMessage : TSString;
begin
FullErrorMessage := 'TSContextWinAPI: ' + ErrorString;
LastError := GetLastError();
if (LastError <> 0) then
	FullErrorMessage += ' LastError=' + SStr(LastError) + '.';
TSLog.Source(FullErrorMessage);
ErrorChars := SStringToPChar(FullErrorMessage);
MessageBox(0, ErrorChars, 'WinAPI error!', MB_OK);
FreeMem(ErrorChars);
end;

procedure TSContextWinAPI.HandlingSizingFromRect(const PR : PRect = nil);
var
	WRect : Windows.TRect;
	Shift : TSPoint2int32;
begin
Shift := ShiftClientArea();
if PR = nil then
	begin
	Windows.GetWindowRect(FWindow, WRect);
	FWidth  :=  WRect.Right  - WRect.Left;
	FHeight :=  WRect.Bottom - WRect.Top;
	FLeft := WRect.Left;
	FTop  := WRect.Top;
	end
else
	begin
	FWidth  :=  PR^.Right  - PR^.Left;
	FHeight :=  PR^.Bottom - PR^.Top;
	FLeft := PR^.Left;
	FTop  := PR^.Top;
	end;
FClientWidth  := FWidth - 2 * Shift.x;
FClientHeight := FHeight - Shift.x - Shift.y;
Resize();
end;

function TSContextWinAPI.WndMessagesProc(const AMessage : TSUInt32; const WParam, LParam: TSWinAPIParam): TSWinAPIParam;

procedure HandlingSizingFromParam();
begin
if FFullscreen then
	begin
	FWidth := PSWord(@LParam)[0];
	FHeight := PSWord(@LParam)[1];
	end;
FClientWidth := PSWord(@LParam)[0];
FClientHeight := PSWord(@LParam)[1];
Resize();
end;

procedure HandlingPaint();
begin
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
	if (not(Render = nil)) then //fixed bug: runtime error while opening WinAPI gui
		begin
		FPaintWithHandlingMessages := False;
		Paint();
		FPaintWithHandlingMessages := True;
		end;
260: //Alt Down
	SetKey(SDownKey,S_ALT_KEY);
261: //Alt Up
	SetKey(SUpKey,S_ALT_KEY);
262: // Key & Alt
	begin
	SetKey(SDownKey,WParam);
	FKeysPressed[WParam]:=False;
	end;
wm_keydown:
	SetKey(SDownKey,WParam);
wm_keyup:
	SetKey(SUpKey,WParam);
wm_mousewheel:
	begin
	if PByte(@WParam)[3]>128 then
		begin
		FCursorWheel:=SDownCursorWheel;
		end
	else
		begin
		FCursorWheel:=SUpCursorWheel;
		end;
	end;
wm_lbuttondown:
	SetCursorKey(SDownKey, SLeftCursorButton);
wm_rbuttondown:
	SetCursorKey(SDownKey, SRightCursorButton);
wm_mbuttondown:
	SetCursorKey(SDownKey, SMiddleCursorButton);
wm_lbuttonup:
	SetCursorKey(SUpKey, SLeftCursorButton);
wm_rbuttonup:
	SetCursorKey(SUpKey, SRightCursorButton);
wm_mbuttonup:
	SetCursorKey(SUpKey, SMiddleCursorButton);
wm_destroy:
	begin
	SLog.Source('TSContextWinAPI__Messages : Note : Window is closed from OS.');
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
	if (not(Render = nil)) then //fixed bug: runtime error while opening WinAPI gui
		begin
		Result := 0;
		HandlingSizingFromParam();
		HandlingPaint();
		end;
wm_sizing:
	if (not(Render = nil)) then //fixed bug: runtime error while opening WinAPI gui
		begin
		HandlingSizingFromRect(PRect(lParam));
		HandlingPaint();
		Result := 1;
		end;
wm_move ,wm_moving ,WM_WINDOWPOSCHANGED, WM_WINDOWPOSCHANGING:
	begin
	if FActive then
		HandlingSizingFromRect();
	end;
else
	begin
	{$IFDEF SWinAPIDebug}
		SLog.Source('StandartWndProc : Unknown Message : Window="'+SSTr(TSMaxEnum(Window))+'", Message="'+SStr(AMessage)+'", wParam="'+SStr(wParam)+'", lParam="'+SStr(lParam)+'"');
		{$ENDIF}
	end;
end;
end;

function ContextWindowProcedure(Window : TSWinAPIHandle; AMessage : TSUInt32; WParam, LParam : TSWinAPIParam) : TSWinAPIParam;  stdcall; export;
var
	Context : TSContextWinAPI = nil;
begin
{$IFDEF SWinAPIDebug}
	SLog.Source('Enter export proc(Window='+SStr(Window)+', Message='+SStr(AMessage)+', wParam='+SSTr(WParam)+', lParam='+SStr(LParam)+')');
	{$ENDIF}
Context := TSContextWinAPI(GetWindowLongPtr(Window, GWLP_USERDATA));
if (Context <> nil) then
	Result := Context.WndMessagesProc(AMessage, WParam, LParam);
Result := DefWindowProc(Window, AMessage, WParam, LParam);
{$IFDEF SWinAPIDebug}
	SLog.Source('Exit export proc(Result='+SStr(Result)+')');
	{$ENDIF}
end;

function TSContextWinAPI.RegisterWindowClass(): TSBoolean;
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
if (FWindowClassName = '') then
	FWindowClassName := 'Smooth Window Class ' + SStr(Random(100000));
if (FWindowClass = 0) then
	begin
	FillChar(WindowClass, SizeOf(WindowClass), 0);
	WindowClass.cbSize        := SizeOf(Windows.WNDCLASSEX);
	WindowClass.Style         := cs_hRedraw or cs_vRedraw or CS_OWNDC;
	WindowClass.lpfnWndProc   := WndProc(@ContextWindowProcedure);
	WindowClass.cbClsExtra    := 0;
	WindowClass.cbWndExtra    := 0;
	WindowClass.hInstance     := System.MainInstance;
	WindowClass.hIcon         := FIconHandle;
	WindowClass.hCursor       := FCursorHandle;
	WindowClass.hbrBackground := 0;
	WindowClass.lpszMenuName  := nil;
	WindowClass.lpszClassName := SStringAsPChar(FWindowClassName);
	WindowClass.hIconSm       := WindowClass.hIcon;
	
	FWindowClass := Windows.RegisterClassEx(WindowClass);
	end;
Result := (FWindowClass <> 0);
{$IFDEF SWinAPIDebug}
	SLog.Source(['TSContextWinAPI__WindowRegisterClass : Exit (Result=',Result,')']);
	{$ENDIF}
end;

function TSContextWinAPI.WindowCreate(const _WindowPlacement : TSContextWindowPlacement = SPlacementNormal): HWnd;

function ChangeScreenSettings() : TSBoolean;
var
	dmScreenSettings : DEVMODE;
begin
Result := True;
if (FWidth <> GetScreenArea().x) or (FHeight <> GetScreenArea().y) then
	begin
	dmScreenSettings.dmSize := sizeof(dmScreenSettings);
	dmScreenSettings.dmPelsWidth := FWidth;
	dmScreenSettings.dmPelsHeight := FHeight;
	dmScreenSettings.dmBitsPerPel := 32;
	dmScreenSettings.dmFields := DM_BITSPERPEL OR DM_PELSWIDTH OR DM_PELSHEIGHT;
	if ChangeDisplaySettings(@dmScreenSettings, CDS_FULLSCREEN) <> DISP_CHANGE_SUCCESSFUL then
		Result := False;
	end;
end;

begin
{$IFDEF SWinAPIDebug}
	SLog.Source('TSContextWinAPI__WindowCreate : Enter');
	{$ENDIF}
Result := 0;
if not FFullscreen then
	begin
	Result := Windows.CreateWindow(SStringAsPChar(FWindowClassName),
			  SStringToPChar(FTitle),
				WS_CAPTION OR
				WS_POPUPWINDOW OR
				WS_TILEDWINDOW OR
				WS_VISIBLE OR
				WS_CLIPSIBLINGS OR
				WS_CLIPCHILDREN,
			  FLeft,
			  FTop,
			  FWidth,
			  FHeight,
			  0, 0,
			  System.MainInstance,
			  nil);
	end
else
	begin
	if (not ChangeScreenSettings()) then
		begin
		ThrowError('Screen resolution is not supported by your gfx card!');
		exit;
		end;
	FTop := 0;
	FLeft := 0;
	Result := CreateWindowEx(WS_EX_APPWINDOW,
		SStringAsPChar(FWindowClassName),
		SStringToPChar(FTitle),
		WS_EX_TOPMOST OR WS_POPUP OR WS_VISIBLE OR WS_CLIPSIBLINGS OR WS_CLIPCHILDREN,
		0,
		0,
		FWidth,
		FHeight,
		0, 0,
		System.MainInstance,
		nil );
	ShowCursor(FShowCursor);
	end;
if (Result <> 0) then
	begin
	SetWindowLongPtr(Result, GWL_USERDATA, TSMaxEnum(Self));
	if FVisible then
		begin
		case _WindowPlacement of
		SPlacementNormal    : ShowWindow(Result, SW_SHOW);
		SPlacementMaximized : ShowWindow(Result, SW_SHOWMAXIMIZED);
		SPlacementMinimized : ShowWindow(Result, SW_SHOWMINIMIZED);
		end;
		SetFocus(Result);
		SetForegroundWindow(Result);
		end;
	UpdateWindow(Result);
	Active := True;
	end;
{$IFDEF SWinAPIDebug}
	SLog.Source(['TSContextWinAPI__WindowCreate : Exit (Result=',Result,')']);
	{$ENDIF}
end;

procedure TSContextWinAPI.SetForeground();
begin
SetFocus(FWindow);
SetForegroundWindow(FWindow);
end;

function TSContextWinAPI.WindowInit(): TSBoolean;

function CreateRender() : TSBoolean;
begin
Result := False;
{$IFDEF SWinAPIDebug}
	SLog.Source('TSContextWinAPI__WindowInit: Createing render');
	{$ENDIF}
if FRender <> nil then
	KillRender();
FRender := FRenderClass.Create();
FRender.Context := Self as ISContext;
Result := FRender.CreateContext();
{$IFDEF SWinAPIDebug}
	SLog.Source(['TSContextWinAPI__WindowInit: Create render context (Result=',Result,')']);
	{$ENDIF}
if Result then
	FRender.Init()
else
	begin
	SLog.Source('TSContextWinAPI__WindowInit. Failed creating render "' + FRenderClass.ClassName() + '".');
	KillRender();
	end;
{$IFDEF SWinAPIDebug}
	SLog.Source('TSContextWinAPI__WindowInit: Created render (Render='+SAddrStr(FRender)+')');
	{$ENDIF}
end;

begin
{$IFDEF SWinAPIDebug}
	SLog.Source(['TSContextWinAPI__WindowInit: Enter']);
	{$ENDIF}
Result := False;
FDeviceContext :=
	GetDC(FWindow);
	//GetDCEx(FWindow, 0, 0);
if (FRender = nil) and (FRenderClass <> nil) then
	begin
	Result := CreateRender();
	if (not Result) then
		begin
		if FRender = nil then
			FRender := FRenderClass.Create();
		if (TSCompatibleRender <> nil) and (not (FRender is TSCompatibleRender)) then
			begin
			KillRender();
			FRenderClass := TSCompatibleRender;
			Result := CreateRender();
			end
		else
			KillRender();
		end;
	end
else if (FRender = nil) and (FRenderClass = nil) then
	begin
	FRenderClass := TSCompatibleRender;
	if FRenderClass <> nil then
		Result := CreateRender();
	end
else if (FRender <> nil) then
	begin
	{$IFDEF SWinAPIDebug}
		SLog.Source('TSContextWinAPI__WindowInit: Formating render (Render='+SAddrStr(FRender)+')');
		{$ENDIF}
	FRender.Context := Self as ISContext;
	Result := FRender.SetPixelFormat();
	if Result then
		Render.MakeCurrent();
	end;
{$IFDEF SWinAPIDebug}
	SLog.Source(['TSContextWinAPI__WindowInit: Exit (Result=',Result,')']);
	{$ENDIF}
end;

function TSContextWinAPI.CreateWindow(const _WindowPlacement : TSContextWindowPlacement = SPlacementNormal) : TSBoolean;
begin
{$IFDEF SWinAPIDebug}
	SLog.Source('TSContextWinAPI__CreateWindow : Enter');
	{$ENDIF}
Result := False;
if not RegisterWindowClass() then
	begin
	ThrowError('Could not register the Application Window!');
	Exit;
	end;
FWindow := WindowCreate(_WindowPlacement);
if (FWindow = 0) then
	begin
	ThrowError('Could not create Application Window!');
	Exit;
	end;
if not WindowInit() then
	begin
	ThrowError('Could not initialise Application Window!');
	Exit;
	end;
Result := True;
{$IFDEF SWinAPIDebug}
	SLog.Source(['TSContextWinAPI__CreateWindow : Exit (Result=',Result,')']);
	{$ENDIF}
end;

procedure TSContextWinAPI.KillWindow();

procedure UnregisterWindowClass();
var
	WindowClassName : PChar;
begin
if (FWindowClassName <> '') then
	begin
	WindowClassName := SStringToPChar(FWindowClassName);
	UnregisterClass(WindowClassName, System.MainInstance);
	FreeMem(WindowClassName);
	FWindowClassName := '';
	FWindowClass := 0;
	end;
end;

begin
{$IFDEF SWinAPIDebug}
	SLog.Source(['TSContextWinAPI__KillWindow(). Release DC.']);
	{$ENDIF}
if (FWindow <> 0) and (FDeviceContext <> 0) then
	begin
	ReleaseDC(FWindow, FDeviceContext);
	FDeviceContext := 0;
	end;
{$IFDEF SWinAPIDebug}
	SLog.Source(['TSContextWinAPI__KillWindow(). Destroying window.']);
	{$ENDIF}
if FWindow <> 0 then
	begin
	DestroyWindow(FWindow);
	FWindow := 0;
	end;
{$IFDEF SWinAPIDebug}
	SLog.Source(['TSContextWinAPI__KillWindow(). Unregister window class.']);
	{$ENDIF}
UnregisterWindowClass();
{$IFDEF SWinAPIDebug}
	SLog.Source(['TSContextWinAPI__KillWindow().']);
	{$ENDIF}
end;

procedure TSContextWinAPI.InitFullscreen(const VFullscreen : TSBoolean);
begin
if FWindow = 0 then
	inherited InitFullscreen(VFullscreen)
else
	if Fullscreen <> VFullscreen then
		begin
		if (FRender<>nil) then
			begin
			FRender.LockResources();
			FRender.ReleaseCurrent();
			end;
		KillWindow();
		Messages();
		inherited InitFullscreen(VFullscreen);
		if VFullscreen then
			begin
			FWidth := GetScreenArea().x;
			FHeight:= GetScreenArea().y;
			end;
		Active := CreateWindow();
		if not Fullscreen then
			Maximize();
		Messages();
		if (FRender <> nil) and Active then
			FRender.UnLockResources();
		HandlingSizingFromRect();
		end;
end;

end.

