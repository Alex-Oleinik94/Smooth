{$INCLUDE SaGe.inc}

//{$DEFINE SGWinAPIDebug}

unit SaGeContextWinAPI;

interface

uses
	// Engine
	 SaGeBase
	,SaGeContext
	,SaGeRender
	,SaGeBaseClasses
	,SaGeContextClasses
	,SaGeContextInterface
	,SaGeBitMap
	,SaGeCursor
	,SaGeCommonStructs
	,SaGeContextUtils
	,SaGeWinAPIUtils
	
	// Windows units
	,Windows
	,CommDlg
	,CommCtrl
	,ActiveX
	,jwauserenv
	;
type
	TRectangle = Windows.TRect;
	
	TSGContextWinAPI = class(TSGContext)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		class function ContextName() : TSGString; override;
		procedure Initialize(const _WindowPlacement : TSGContextWindowPlacement = SGPlacementNormal); override;
		procedure Messages();override;
		procedure SwapBuffers();override;
		function  GetWindowArea(): TSGPoint2int32;override;
		function  GetScreenArea(): TSGPoint2int32;override;
		function  ShiftClientArea() : TSGPoint2int32; override;
		procedure Kill();override;
		class function Supported() : TSGBoolean; override;
		class function ClassName() : TSGString;override;
		function GetDefaultWindowColor():TSGColor3f;override;
		procedure Minimize();override;
		procedure Maximize();override;
		class function UserProfilePath() : TSGString; override;
			public
		procedure SetForeground(); override;
		procedure ShowCursor(const VVisibility : TSGBoolean);override;
		procedure SetCursorPosition(const VPosition : TSGPoint2int32);override;
		function  KeysPressed(const  Index : integer ) : Boolean;override;overload;
		// If function need puplic, becourse it calls in WinAPI procedure without whis class
		function WndMessagesProc(const AMessage:LongWord; const WParam, LParam: TSGWinAPIParam): TSGWinAPIParam;
			protected
		procedure SetVisible(const _Visible : TSGBoolean); override;
		procedure InitFullscreen(const VFullscreen : TSGBoolean); override;
		function  GetWindow() : TSGPointer; override;
		function  GetDevice() : TSGPointer; override;
		procedure SetCursor(const VCursor : TSGCursor); override;
		procedure SetIcon  (const VIcon   : TSGBitMap); override;
			protected
		FWindowClass : TSGMaxEnum;
		FWindowClassName : TSGString;
		FWindow  : Windows.HWnd;
		FDeviceContext : Windows.HDC;
			protected
		function  RegisterWindowClass() : TSGBoolean;
		function  WindowCreate(const _WindowPlacement : TSGContextWindowPlacement = SGPlacementNormal): Windows.HWnd;
		function  WindowInit(): TSGBoolean;
		procedure KillWindow();
		function  CreateWindow(const _WindowPlacement : TSGContextWindowPlacement = SGPlacementNormal) : TSGBoolean;
		class function GetClientWindowRectangle(const _Window : HWND) : TRectangle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function GetWindowRectangle(const _Window : HWND) : TRectangle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function SetWindowPlacement(const _Placement : TSGUInt32) : TSGBoolean;
		procedure ThrowError(const ErrorString : TSGString);
		procedure HandlingSizingFromRect(const PR : PRect = nil);
		class procedure SetWindowCursor(const _WindowClass : TSGMaxEnum; const _Window : Windows.HWnd; const _Cursor : Windows.HCURSOR);
			protected
		FCursorHandle : Windows.HCURSOR;
		FIconHandle   : Windows.HICON;
		FGlassyCursorHandle : Windows.HCURSOR;
		FNormalCursorHandle : Windows.HCURSOR;
			public
		function  GetCursorPosition(): TSGPoint2int32; override;
		function  FileOpenDialog(const VTittle: String; const VFilter : String):String;override;
		function  FileSaveDialog(const VTittle: String; const VFilter : String;const extension : String):String;override;
		end;

implementation

uses
	 SaGeScreen
	,SaGeLog
	,SaGeWinAPIIconUtils
	,SaGeStringUtils
	,SaGeFileUtils
	
	,SysUtils
	;

class function TSGContextWinAPI.ContextName() : TSGString;
begin
Result := 'WinAPI';
end;

procedure TSGContextWinAPI.SetVisible(const _Visible : TSGBoolean);
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

class function TSGContextWinAPI.UserProfilePath() : TSGString;
const 
	MaxMem : TSGUInt32 = 100;
var
	ProfilePath : LPTSTR = nil;
	Size : TSGUInt32;
	hCurrentProcess : Windows.HANDLE;
	hToken : Windows.HANDLE;
begin
Result := inherited UserProfilePath();
GetMem(ProfilePath, MaxMem);
Size := MaxMem;
hCurrentProcess := GetCurrentProcess();
if hCurrentProcess = 0 then
	SGLog.Source(['TSGContextWinAPI__UserProfilePath : GetCurrentProcess() returned falture handle!'])
else
	if not OpenProcessToken(hCurrentProcess, TOKEN_ALL_ACCESS, hToken) then
		SGLog.Source(['TSGContextWinAPI__UserProfilePath : OpenProcessToken(..) returned FALSE!']);
	if hToken = 0 then
		SGLog.Source(['TSGContextWinAPI__UserProfilePath : OpenProcessToken(..) returned falture token!'])
	else
		if not GetUserProfileDirectory(hToken, ProfilePath, Size) then
			SGLog.Source(['TSGContextWinAPI__UserProfilePath : GetUserProfileDirectory(..) returned FALSE!'])
		else
			Result := SGPCharToString(ProfilePath);
if hToken <> 0 then
	CloseHandle(hToken);
FreeMem(ProfilePath);
end;

function TSGContextWinAPI.SetWindowPlacement(const _Placement : TSGUInt32) : TSGBoolean;
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

procedure TSGContextWinAPI.Minimize();
begin
SetWindowPlacement(SW_SHOWMINIMIZED);
end;

procedure TSGContextWinAPI.Maximize();
begin
SetWindowPlacement(SW_SHOWMAXIMIZED);
end;

function TSGContextWinAPI.GetDefaultWindowColor():TSGColor3f;
var
	Colour : TSGLongWord;
begin
Colour := GetSysColor(COLOR_WINDOW);
Result.Import(
	PByte(@Colour)[0]/255,
	PByte(@Colour)[1]/255,
	PByte(@Colour)[2]/255);
end;

class function TSGContextWinAPI.ClassName() : TSGString;
begin
Result := 'TSGContextWinAPI';
end;

class function TSGContextWinAPI.Supported() : TSGBoolean;
begin
Result := True;
end;

class procedure TSGContextWinAPI.SetWindowCursor(const _WindowClass : TSGMaxEnum; const _Window : Windows.HWnd; const _Cursor : Windows.HCURSOR);
begin
Windows.SetClassLongPtr(_Window, GCL_HCURSOR, _Cursor);
Windows.SetClassLongPtr(_WindowClass, GCL_HCURSOR, _Cursor);
Windows.SetCursor(_Cursor);
end;

procedure TSGContextWinAPI.SetCursor(const VCursor : TSGCursor);
var
	NewCursor : HCURSOR;
begin
if VCursor.StandartHandle <> SGC_NULL then
	begin
	if VCursor.BitMap = nil then
		begin
		NewCursor := LoadCursor(0, MAKEINTRESOURCE(VCursor.StandartHandle));
		if NewCursor <> SGC_NULL then
			begin
			inherited;
			FCursorHandle := NewCursor;
			if Active then
				SetWindowCursor(FWindowClass, FWindow, FCursorHandle);
			end;
		end
	else
		begin
		NewCursor := SGWinAPICreateCursor(VCursor, RGB(0,0,0));
		if NewCursor <> SGC_NULL then
			Windows.SetSystemCursor(NewCursor, VCursor.StandartHandle);
		end;
	end
else
	begin
	NewCursor := SGWinAPICreateCursor(VCursor, RGB(0,0,0));
	if NewCursor <> SGC_NULL then
		begin
		FCursorHandle := NewCursor;
		inherited;
		if Active then
			SetWindowCursor(FWindowClass, FWindow, FCursorHandle);
		end;
	end;
end;

procedure TSGContextWinAPI.SetIcon  (const VIcon   : TSGBitMap);
begin

end;

class function TSGContextWinAPI.GetWindowRectangle(const _Window : HWND) : TRectangle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Windows.GetWindowRect(_Window, Result);
end;

class function TSGContextWinAPI.GetClientWindowRectangle(const _Window : HWND) : TRectangle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Windows.GetClientRect(_Window, Result);
end;

function  TSGContextWinAPI.GetWindow() : TSGPointer;
begin
Result := TSGPointer(FWindow);
end;

function  TSGContextWinAPI.GetDevice() : TSGPointer;
begin
Result := TSGPointer(FDeviceContext);
end;

function  TSGContextWinAPI.ShiftClientArea() : TSGPoint2int32;
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
ofn^.hwndOwner         := FWindow;
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
		SGLog.Source('TSGContextWinAPI__FileSaveDlg - GetSaveFileName(...) results with FALSE');
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
ofn^.hwndOwner         := FWindow;
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
		SGLog.Source('TSGContextWinAPI__FileOpenDlg - GetOpenFileName(...) results with FALSE');
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

function TSGContextWinAPI.KeysPressed(const  Index : integer ) : TSGBoolean;overload;
begin
if Index = 20 then //Caps Lock
	Result := SGSystemKeyPressed(20)
else
	Result:=inherited;
end;

procedure TSGContextWinAPI.SetCursorPosition(const VPosition : TSGPoint2int32);
var
	WindowShift : TRectangle;
	ClientShift : TSGPoint2int32;
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

procedure TSGContextWinAPI.ShowCursor(const VVisibility : TSGBoolean);
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

function TSGContextWinAPI.GetScreenArea(): TSGPoint2int32;
begin
Result.Import(
	Windows.GetDeviceCaps(Windows.GetDC(Windows.GetDesktopWindow()), HORZRES),
	Windows.GetDeviceCaps(Windows.GetDC(Windows.GetDesktopWindow()), VERTRES));
end;

function TSGContextWinAPI.GetCursorPosition: TSGPoint2int32;
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

function TSGContextWinAPI.GetWindowArea(): TSGPoint2int32;
var
	Rectangle : TRectangle;
begin
Rectangle := GetWindowRectangle(FWindow);
Result.x := Rectangle.Left;
Result.y := Rectangle.Top;
end;

constructor TSGContextWinAPI.Create;
begin
inherited;
FWindowClassName := '';
FWindow  := 0;
FWindowClass := 0;
FDeviceContext := 0;
FNormalCursorHandle := LoadCursor(0, IDC_ARROW);
FCursorHandle := FNormalCursorHandle;
FIconHandle   := LoadIcon(GetModuleHandle(nil), MAKEINTRESOURCE(SGCWAPI_ICON));
FGlassyCursorHandle := SGWinAPICreateGlassyCursor();
end;

procedure TSGContextWinAPI.Kill();
begin
KillWindow();
inherited;
end;

destructor TSGContextWinAPI.Destroy();
begin
inherited;
end;

procedure TSGContextWinAPI.Initialize(const _WindowPlacement : TSGContextWindowPlacement = SGPlacementNormal);

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

procedure TSGContextWinAPI.SwapBuffers();
begin
Render.SwapBuffers();
end;

procedure TSGContextWinAPI.Messages;
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

procedure TSGContextWinAPI.ThrowError(const ErrorString : TSGString);
var
	ErrorChars : PSGChar = nil;
	LastError : TSGUInt32;
	FullErrorMessage : TSGString;
begin
FullErrorMessage := 'TSGContextWinAPI: ' + ErrorString;
LastError := GetLastError();
if (LastError <> 0) then
	FullErrorMessage += ' LastError=' + SGStr(LastError) + '.';
TSGLog.Source(FullErrorMessage);
ErrorChars := SGStringToPChar(FullErrorMessage);
MessageBox(0, ErrorChars, 'WinAPI error!', MB_OK);
FreeMem(ErrorChars);
end;

procedure TSGContextWinAPI.HandlingSizingFromRect(const PR : PRect = nil);
var
	WRect : Windows.TRect;
	Shift : TSGPoint2int32;
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

function TSGContextWinAPI.WndMessagesProc(const AMessage : TSGUInt32; const WParam, LParam: TSGWinAPIParam): TSGWinAPIParam;

procedure HandlingSizingFromParam();
begin
if FFullscreen then
	begin
	FWidth := PSGWord(@LParam)[0];
	FHeight := PSGWord(@LParam)[1];
	end;
FClientWidth := PSGWord(@LParam)[0];
FClientHeight := PSGWord(@LParam)[1];
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
	SetCursorKey(SGDownKey, SGLeftCursorButton);
wm_rbuttondown:
	SetCursorKey(SGDownKey, SGRightCursorButton);
wm_mbuttondown:
	SetCursorKey(SGDownKey, SGMiddleCursorButton);
wm_lbuttonup:
	SetCursorKey(SGUpKey, SGLeftCursorButton);
wm_rbuttonup:
	SetCursorKey(SGUpKey, SGRightCursorButton);
wm_mbuttonup:
	SetCursorKey(SGUpKey, SGMiddleCursorButton);
wm_destroy:
	begin
	SGLog.Source('TSGContextWinAPI__Messages : Note : Window is closed from OS.');
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
	Result := 0;
	HandlingSizingFromParam();
	HandlingPaint();
	end;
wm_sizing:
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
	{$IFDEF SGWinAPIDebug}
		SGLog.Source('StandartWndProc : Unknown Message : Window="'+SGSTr(TSGMaxEnum(Window))+'", Message="'+SGStr(AMessage)+'", wParam="'+SGStr(wParam)+'", lParam="'+SGStr(lParam)+'"');
		{$ENDIF}
	end;
end;
end;

function ContextWindowProcedure(Window : TSGWinAPIHandle; AMessage : TSGUInt32; WParam, LParam : TSGWinAPIParam) : TSGWinAPIParam;  stdcall; export;
var
	Context : TSGContextWinAPI = nil;
begin
{$IFDEF SGWinAPIDebug}
	SGLog.Source('Enter export proc(Window='+SGStr(Window)+', Message='+SGStr(AMessage)+', wParam='+SGSTr(WParam)+', lParam='+SGStr(LParam)+')');
	{$ENDIF}
Context := TSGContextWinAPI(GetWindowLongPtr(Window, GWLP_USERDATA));
if (Context <> nil) then
	Result := Context.WndMessagesProc(AMessage, WParam, LParam);
Result := DefWindowProc(Window, AMessage, WParam, LParam);
{$IFDEF SGWinAPIDebug}
	SGLog.Source('Exit export proc(Result='+SGStr(Result)+')');
	{$ENDIF}
end;

function TSGContextWinAPI.RegisterWindowClass(): TSGBoolean;
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
	FWindowClassName := 'SaGe Window Class ' + SGStr(Random(100000));
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
	WindowClass.lpszClassName := SGStringAsPChar(FWindowClassName);
	WindowClass.hIconSm       := WindowClass.hIcon;
	
	FWindowClass := Windows.RegisterClassEx(WindowClass);
	end;
Result := (FWindowClass <> 0);
{$IFDEF SGWinAPIDebug}
	SGLog.Source(['TSGContextWinAPI__WindowRegisterClass : Exit (Result=',Result,')']);
	{$ENDIF}
end;

function TSGContextWinAPI.WindowCreate(const _WindowPlacement : TSGContextWindowPlacement = SGPlacementNormal): HWnd;

function ChangeScreenSettings() : TSGBoolean;
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
{$IFDEF SGWinAPIDebug}
	SGLog.Source('TSGContextWinAPI__WindowCreate : Enter');
	{$ENDIF}
Result := 0;
if not FFullscreen then
	begin
	Result := Windows.CreateWindow(SGStringAsPChar(FWindowClassName),
			  SGStringToPChar(FTitle),
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
		SGStringAsPChar(FWindowClassName),
		SGStringToPChar(FTitle),
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
	SetWindowLongPtr(Result, GWL_USERDATA, TSGMaxEnum(Self));
	if FVisible then
		begin
		case _WindowPlacement of
		SGPlacementNormal    : ShowWindow(Result, SW_SHOW);
		SGPlacementMaximized : ShowWindow(Result, SW_SHOWMAXIMIZED);
		SGPlacementMinimized : ShowWindow(Result, SW_SHOWMINIMIZED);
		end;
		SetFocus(Result);
		SetForegroundWindow(Result);
		end;
	UpdateWindow(Result);
	Active := True;
	end;
{$IFDEF SGWinAPIDebug}
	SGLog.Source(['TSGContextWinAPI__WindowCreate : Exit (Result=',Result,')']);
	{$ENDIF}
end;

procedure TSGContextWinAPI.SetForeground();
begin
SetFocus(FWindow);
SetForegroundWindow(FWindow);
end;

function TSGContextWinAPI.WindowInit(): TSGBoolean;

function CreateRender() : TSGBoolean;
begin
Result := False;
{$IFDEF SGWinAPIDebug}
	SGLog.Source('TSGContextWinAPI__WindowInit: Createing render');
	{$ENDIF}
if FRender <> nil then
	KillRender();
FRender := FRenderClass.Create();
FRender.Context := Self as ISGContext;
Result := FRender.CreateContext();
{$IFDEF SGWinAPIDebug}
	SGLog.Source(['TSGContextWinAPI__WindowInit: Create render context (Result=',Result,')']);
	{$ENDIF}
if Result then
	FRender.Init()
else
	begin
	SGLog.Source('TSGContextWinAPI__WindowInit. Failed creating render "' + FRenderClass.ClassName() + '".');
	KillRender();
	end;
{$IFDEF SGWinAPIDebug}
	SGLog.Source('TSGContextWinAPI__WindowInit: Created render (Render='+SGAddrStr(FRender)+')');
	{$ENDIF}
end;

begin
{$IFDEF SGWinAPIDebug}
	SGLog.Source(['TSGContextWinAPI__WindowInit: Enter']);
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
		if (TSGCompatibleRender <> nil) and (not (FRender is TSGCompatibleRender)) then
			begin
			KillRender();
			FRenderClass := TSGCompatibleRender;
			Result := CreateRender();
			end
		else
			KillRender();
		end;
	end
else if (FRender = nil) and (FRenderClass = nil) then
	begin
	FRenderClass := TSGCompatibleRender;
	if FRenderClass <> nil then
		Result := CreateRender();
	end
else if (FRender <> nil) then
	begin
	{$IFDEF SGWinAPIDebug}
		SGLog.Source('TSGContextWinAPI__WindowInit: Formating render (Render='+SGAddrStr(FRender)+')');
		{$ENDIF}
	FRender.Context := Self as ISGContext;
	Result := FRender.SetPixelFormat();
	if Result then
		Render.MakeCurrent();
	end;
{$IFDEF SGWinAPIDebug}
	SGLog.Source(['TSGContextWinAPI__WindowInit: Exit (Result=',Result,')']);
	{$ENDIF}
end;

function TSGContextWinAPI.CreateWindow(const _WindowPlacement : TSGContextWindowPlacement = SGPlacementNormal) : TSGBoolean;
begin
{$IFDEF SGWinAPIDebug}
	SGLog.Source('TSGContextWinAPI__CreateWindow : Enter');
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
{$IFDEF SGWinAPIDebug}
	SGLog.Source(['TSGContextWinAPI__CreateWindow : Exit (Result=',Result,')']);
	{$ENDIF}
end;

procedure TSGContextWinAPI.KillWindow();

procedure UnregisterWindowClass();
var
	WindowClassName : PChar;
begin
if (FWindowClassName <> '') then
	begin
	WindowClassName := SGStringToPChar(FWindowClassName);
	UnregisterClass(WindowClassName, System.MainInstance);
	FreeMem(WindowClassName);
	FWindowClassName := '';
	FWindowClass := 0;
	end;
end;

begin
{$IFDEF SGWinAPIDebug}
	SGLog.Source(['TSGContextWinAPI__KillWindow(). Release DC.']);
	{$ENDIF}
if (FWindow <> 0) and (FDeviceContext <> 0) then
	begin
	ReleaseDC(FWindow, FDeviceContext);
	FDeviceContext := 0;
	end;
{$IFDEF SGWinAPIDebug}
	SGLog.Source(['TSGContextWinAPI__KillWindow(). Destroying window.']);
	{$ENDIF}
if FWindow <> 0 then
	begin
	DestroyWindow(FWindow);
	FWindow := 0;
	end;
{$IFDEF SGWinAPIDebug}
	SGLog.Source(['TSGContextWinAPI__KillWindow(). Unregister window class.']);
	{$ENDIF}
UnregisterWindowClass();
{$IFDEF SGWinAPIDebug}
	SGLog.Source(['TSGContextWinAPI__KillWindow().']);
	{$ENDIF}
end;

procedure TSGContextWinAPI.InitFullscreen(const VFullscreen : TSGBoolean);
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

