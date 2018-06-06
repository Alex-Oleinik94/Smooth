{$INCLUDE SaGe.inc}

//{$DEFINE SGWinAPIDebug}

unit SaGeContextWinAPI;

interface

uses
	// Engine
	 SaGeBase
	,SaGeContext
	,SaGeRender
	,SaGeClasses
	,SaGeCommonClasses
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
	TSGContextWinAPI = class(TSGContext)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		procedure Initialize();override;
		procedure Messages();override;
		procedure SwapBuffers();override;
		function  GetWindowArea(): TSGPoint2int32;override;
		function  GetScreenArea(): TSGPoint2int32;override;
		function  ShiftClientArea() : TSGPoint2int32; override;
		procedure Kill();override;
		class function Suppored() : TSGBoolean; override;
		class function ClassName() : TSGString;override;
		function GetDefaultWindowColor():TSGColor3f;override;
		procedure Minimize();override;
		procedure Maximize();override;
		class function UserProfilePath() : TSGString; override;
			public
		procedure ShowCursor(const VVisibility : TSGBoolean);override;
		procedure SetCursorPosition(const VPosition : TSGPoint2int32);override;
		function  KeysPressed(const  Index : integer ) : Boolean;override;overload;
		// If function need puplic, becourse it calls in WinAPI procedure without whis class
		function WndMessagesProc(const AMessage:LongWord; const WParam, LParam: TSGWinAPIParam): TSGWinAPIParam;
			protected
		procedure InitFullscreen(const VFullscreen : TSGBoolean); override;
		function  GetWindow() : TSGPointer; override;
		function  GetDevice() : TSGPointer; override;
		procedure SetCursor(const VCursor : TSGCursor); override;
		procedure SetIcon  (const VIcon   : TSGBitMap); override;
			protected
		hWindow  : Windows.HWnd;
		dcWindow : Windows.HDC;
		clWindow : TSGMaxEnum;
		FWindowClassName : TSGString;
		procedure ThrowError(pcErrorMessage : pChar);
		function  RegisterWindowClass() : TSGBoolean;
		function  WindowCreate(): Windows.HWnd;
		function  WindowInit(hParent : Windows.HWnd): Boolean;
		procedure KillWindow();
		function  CreateWindow():Boolean;
		class function GetClientWindowRect(const VWindow : HWND) : TRect;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function GetWindowRect(const VWindow : HWND) : TRect;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure HandlingSizingFromRect(const PR : PRect = nil);
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
	
	,SysUtils
	;

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

procedure TSGContextWinAPI.Minimize();
var
	wp : WINDOWPLACEMENT;
begin
GetWindowPlacement(hWindow, @wp);
wp.showCmd := SW_SHOWMINIMIZED;
SetWindowPlacement(hWindow, @wp);
end;

procedure TSGContextWinAPI.Maximize();
var
	wp : WINDOWPLACEMENT;
begin
GetWindowPlacement(hWindow, @wp);
wp.showCmd := SW_SHOWMAXIMIZED;
SetWindowPlacement(hWindow, @wp);
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

class function TSGContextWinAPI.Suppored() : TSGBoolean;
begin
Result := True;
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
				begin
				Windows.SetClassLong(hWindow, GCL_HCURSOR, FCursorHandle);
				Windows.SetCursor(FCursorHandle);
				end;
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
			begin
			Windows.SetClassLong(hWindow, GCL_HCURSOR, FCursorHandle);
			Windows.SetCursor(FCursorHandle);
			end;
		end;
	end;
end;

procedure TSGContextWinAPI.SetIcon  (const VIcon   : TSGBitMap);
begin

end;

class function TSGContextWinAPI.GetWindowRect(const VWindow : HWND) : TRect;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Windows.GetWindowRect(VWindow, Result);
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
	WindowShift : Windows.TRect;
	ClientShift : TSGPoint2int32;
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
Windows.ShowCursor(True);
if FShowCursor then
	FCursorHandle := FNormalCursorHandle
else
	FCursorHandle := FGlassyCursorHandle;
Windows.SetClassLong(hWindow, GCL_HCURSOR, FCursorHandle);
Windows.SetClassLong(clWindow, GCL_HCURSOR, FCursorHandle);
Windows.SetCursor(FCursorHandle);
Windows.ShowCursor(FShowCursor);
end;

function TSGContextWinAPI.GetScreenArea(): TSGPoint2int32;
begin
Result.Import(
	Windows.GetDeviceCaps(Windows.GetDC(Windows.GetDesktopWindow()),HORZRES),
	Windows.GetDeviceCaps(Windows.GetDC(Windows.GetDesktopWindow()),VERTRES));
end;

function TSGContextWinAPI.GetCursorPosition: TSGPoint2int32;
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

function TSGContextWinAPI.GetWindowArea(): TSGPoint2int32;
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
FWindowClassName := '';
hWindow  := 0;
dcWindow := 0;
clWindow := 0;
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

procedure TSGContextWinAPI.Initialize();

procedure HandlingReSizingFromRect();
var
	WRect : Windows.TRect;
begin
Windows.GetWindowRect(hWindow, WRect);
FWidth  :=  WRect.Right  - WRect.Left;
FHeight :=  WRect.Bottom - WRect.Top;
FLeft := WRect.Left;
FTop  := WRect.Top;
FClientHeight := GetClientWindowRect(hWindow).bottom;
FClientWidth  := GetClientWindowRect(hWindow).right;
Resize();
end;

begin
Active := CreateWindow();
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

procedure TSGContextWinAPI.ThrowError(pcErrorMessage : pChar);
begin
MessageBox(0, pcErrorMessage, 'Error', MB_OK);
Halt(0);
end;

procedure TSGContextWinAPI.HandlingSizingFromRect(const PR : PRect = nil);
var
	WRect : Windows.TRect;
	Shift : TSGPoint2int32;
begin
Shift := ShiftClientArea();
if PR = nil then
	begin
	Windows.GetWindowRect(hWindow, WRect);
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
WM_SETCURSOR:
	begin
	Windows.SetClassLong(hWindow, GCL_HCURSOR, FCursorHandle);
	Windows.SetCursor(FCursorHandle);
	end;
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
wm_move
,wm_moving
,WM_WINDOWPOSCHANGED
,WM_WINDOWPOSCHANGING:
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
if (clWindow = 0) then
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
	
	clWindow := Windows.RegisterClassEx(WindowClass);
	end;
Result := clWindow <> 0;
{$IFDEF SGWinAPIDebug}
	SGLog.Source(['TSGContextWinAPI__WindowRegisterClass : Exit (Result=',Result,')']);
	{$ENDIF}
end;

function TSGContextWinAPI.WindowCreate(): HWnd;
var
  dmScreenSettings : DEVMODE;
begin
{$IFDEF SGWinAPIDebug}
	SGLog.Source('TSGContextWinAPI__WindowCreate : Enter');
	{$ENDIF}
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
	if (FWidth <> GetScreenArea().x) or (FHeight <> GetScreenArea().y) then
		begin
		dmScreenSettings.dmSize := sizeof(dmScreenSettings);
		dmScreenSettings.dmPelsWidth := FWidth;
		dmScreenSettings.dmPelsHeight := FHeight;
		dmScreenSettings.dmBitsPerPel := 32;
		dmScreenSettings.dmFields := DM_BITSPERPEL OR DM_PELSWIDTH OR DM_PELSHEIGHT;
		if ChangeDisplaySettings(@dmScreenSettings,CDS_FULLSCREEN) <> DISP_CHANGE_SUCCESSFUL then
			begin
			ThrowError('Screen resolution is not supported by your gfx card!');
			SGLog.Source('Screen resolution is not supported by your gfx card!');
			WindowCreate := 0;
			Exit;
			end;
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
	ShowWindow(Result, CmdShow);
	UpdateWindow(Result);
	Active:=True;
	end;
{$IFDEF SGWinAPIDebug}
	SGLog.Source(['TSGContextWinAPI__WindowCreate : Exit (Result=',Result,')']);
	{$ENDIF}
end;

function TSGContextWinAPI.WindowInit(hParent : HWnd): Boolean;

function CreateRender() : TSGBoolean;
begin
Result := False;
{$IFDEF SGWinAPIDebug}
	SGLog.Source('TSGContextWinAPI__WindowInit(hParent='+SGStr(hParent)+') : Createing render');
	{$ENDIF}
if FRender <> nil then
	KillRender();
FRender := FRenderClass.Create();
FRender.Context := Self as ISGContext;
Result := FRender.CreateContext();
{$IFDEF SGWinAPIDebug}
	SGLog.Source(['TSGContextWinAPI__WindowInit(hParent='+SGStr(hParent)+') : Create render context (Result=',Result,')']);
	{$ENDIF}
if Result then
	FRender.Init()
else
	begin
	SGLog.Source('TSGContextWinAPI__WindowInit(...). Failed creating render "' + FRenderClass.ClassName() + '".');
	KillRender();
	end;
{$IFDEF SGWinAPIDebug}
	SGLog.Source('TSGContextWinAPI__WindowInit(hParent='+SGStr(hParent)+') : Created render (Render='+SGAddrStr(FRender)+')');
	{$ENDIF}
end;

begin
{$IFDEF SGWinAPIDebug}
	SGLog.Source(['TSGContextWinAPI__WindowInit(hParent='+SGStr(hParent)+') : Enter']);
	{$ENDIF}
Result := False;
dcWindow := GetDC( hParent );
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
		SGLog.Source('TSGContextWinAPI__WindowInit(hParent='+SGStr(hParent)+') : Formating render (Render='+SGAddrStr(FRender)+')');
		{$ENDIF}
	FRender.Context := Self as ISGContext;
	Result := FRender.SetPixelFormat();
	if Result then
		Render.MakeCurrent();
	end;
{$IFDEF SGWinAPIDebug}
	SGLog.Source(['TSGContextWinAPI__WindowInit(hParent='+SGStr(hParent)+') : Exit (Result=',Result,')']);
	{$ENDIF}
end;

function TSGContextWinAPI.CreateWindow():Boolean;
begin
{$IFDEF SGWinAPIDebug}
	SGLog.Source('TSGContextWinAPI__CreateWindow : Enter');
	{$ENDIF}
if not RegisterWindowClass() then
		begin
		ThrowError('Could not register the Application Window!');
		SGLog.Source('Could not register the Application Window!');
		Result := false;
		Exit;
		end;
hWindow := WindowCreate();
if hWindow = 0 then
	begin
	ThrowError('Could not create Application Window!');
	SGLog.Source('Could not create Application Window!');
	Result := false;
	Exit;
	end;
if not WindowInit(hWindow) then
	begin
	ThrowError('Could not initialise Application Window!');
	SGLog.Source('Could not initialise Application Window!');
	Result := false;
	Exit;
	end;
Result := true;
{$IFDEF SGWinAPIDebug}
	SGLog.Source(['TSGContextWinAPI__CreateWindow : Exit (Result=',Result,')']);
	{$ENDIF}
end;

procedure TSGContextWinAPI.KillWindow();

procedure UnregisterWindowClass();
var
	WindowClassName : PChar;
begin
if FWindowClassName <> '' then
	begin
	WindowClassName := SGStringToPChar(FWindowClassName);
	UnregisterClass(WindowClassName, System.MainInstance);
	FreeMem(WindowClassName);
	FWindowClassName := '';
	end;
end;

begin
{$IFDEF SGWinAPIDebug}
	SGLog.Source(['TSGContextWinAPI__KillWindow(). Release DC.']);
	{$ENDIF}
if (hWindow <> 0) and (dcWindow <> 0) then
	begin
	ReleaseDC(hWindow, dcWindow);
	dcWindow := 0;
	end;
{$IFDEF SGWinAPIDebug}
	SGLog.Source(['TSGContextWinAPI__KillWindow(). Destroying window.']);
	{$ENDIF}
if hWindow <> 0 then
	begin
	DestroyWindow(hWindow);
	hWindow := 0;
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
if hWindow = 0 then
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

