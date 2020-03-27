{$INCLUDE Smooth.inc}

unit SmoothSystemTrayIconWinAPI;

interface

uses
	 SmoothBase
	,SmoothSystemTrayIcon
	,SmoothWinAPIIconUtils
	,SmoothWinAPIUtils
	
	,ShellAPI
	,Windows
	;

type
	TSSystemTrayIconWinAPI = class(TSSystemTrayIcon)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		procedure Messages(); override;
		procedure Initialize(); override;
		procedure Kill(); override;
		function CallBack(AMesSmooth : TSUInt32; WParam, LParam : TSWinAPIParam) : TSWinAPIParam;
			protected
		FWindowClassName : PSChar;
		FWindowClass : TSMaxEnum;
		FWindow : HWND;
		FIconIdentifier : TSUInt32;
			protected
		procedure SetTip(const _Tip : TSString); override;
			protected
		function RegisterWindowClass() : TSBoolean;
		procedure ExecuteCallBacks(const Param : TSWinAPIParam);
		end;

implementation

uses
	 SmoothLog
	,SmoothStringUtils
	,SmoothContextUtils
	;

procedure TSSystemTrayIconWinAPI.SetTip(const _Tip : TSString);
begin
if (FInitialized and (_Tip <> FTip)) then
	SWinAPIShellModifyIconTip(FWindow, FIconIdentifier, _Tip);
inherited SetTip(_Tip);
end;

procedure TSSystemTrayIconWinAPI.ExecuteCallBacks(const Param : TSWinAPIParam);
var
	Button : TSCursorButton = SNullCursorButton;
	ButtonType : TSCursorButtonType = SNullKey;
begin
if (Param = WM_LBUTTONDBLCLK) or (Param = WM_LBUTTONDOWN) or (Param = WM_LBUTTONUP) then
	Button := SLeftCursorButton
else if (Param = WM_RBUTTONDBLCLK) or (Param = WM_RBUTTONDOWN) or (Param = WM_RBUTTONUP) then
	Button := SRightCursorButton
else if (Param = WM_MBUTTONDBLCLK) or (Param = WM_MBUTTONDOWN) or (Param = WM_MBUTTONUP) then
	Button := SMiddleCursorButton;
if (Param = WM_LBUTTONDBLCLK) or (Param = WM_RBUTTONDBLCLK) or (Param = WM_MBUTTONDBLCLK) then
	ButtonType := SDoubleClick
else if (Param = WM_LBUTTONDOWN) or (Param = WM_RBUTTONDOWN) or (Param = WM_MBUTTONDOWN) then
	ButtonType := SDownKey
else if (Param = WM_LBUTTONUP) or (Param = WM_RBUTTONUP) or (Param = WM_MBUTTONUP) then
	ButtonType := SUpKey;
if (FButtonsCallBack <> nil) then
	FButtonsCallBack.IconMouseCallBack(Button, ButtonType);
end;

const
	S_CALLBACK = 123232;

function TSSystemTrayIconWinAPI.CallBack(AMesSmooth : TSUInt32; WParam, LParam : TSWinAPIParam) : TSWinAPIParam;
begin
Result := 0;
case AMesSmooth of
WM_GETMINMAXINFO: {36} ;
WM_NCCREATE: {129} ;
WM_NCCALCSIZE : {131} ;
WM_CREATE: {1} ;
WM_NCDESTROY: {130} ;
WM_DESTROY : {2} ;
VK_NUMLOCK: {144} ;
WM_USER: {1024} ;
799: {?} ;
S_CALLBACK:
	begin
	case LParam of
	WM_MOUSEMOVE: ;
	WM_LBUTTONDBLCLK, WM_LBUTTONDOWN, WM_LBUTTONUP, WM_RBUTTONDBLCLK, WM_RBUTTONDOWN, WM_RBUTTONUP, WM_MBUTTONDBLCLK, WM_MBUTTONDOWN, WM_MBUTTONUP:
		ExecuteCallBacks(LParam);
	end;
	end;
end;
end;

function WinAPIIconCallBack(Window: TSWinAPIHandle; AMesSmooth : TSUInt32; WParam, LParam : TSWinAPIParam) : TSWinAPIParam; stdcall; export;
var
	Icon : TSSystemTrayIconWinAPI;
begin
Icon := TSSystemTrayIconWinAPI(GetWindowLongPtr(Window, GWLP_USERDATA));
Result := Icon.CallBack(AMesSmooth, WParam, LParam);
if (Result = 0) then
	Result := DefWindowProc(Window, AMesSmooth, WParam, LParam);
end;

function TSSystemTrayIconWinAPI.RegisterWindowClass() : TSBoolean;
var
  WindowClass: Windows.WndClassEx;
begin
if (FWindowClassName = nil) then
	FWindowClassName := SStringToPChar('Smooth Icon Class ' + SStr(Random(100000)));
if (FWindowClass = 0) then
	begin
	FillChar(WindowClass, SizeOf(WindowClass), 0);
	WindowClass.cbSize        := SizeOf(Windows.WNDCLASSEX);
	WindowClass.Style         := cs_hRedraw or cs_vRedraw or CS_OWNDC;
	WindowClass.lpfnWndProc   := WndProc(@WinAPIIconCallBack);
	WindowClass.cbClsExtra    := 0;
	WindowClass.cbWndExtra    := 0;
	WindowClass.hInstance     := System.MainInstance;
	WindowClass.hIcon         := 0;
	WindowClass.hCursor       := 0;
	WindowClass.hbrBackground := 0;
	WindowClass.lpszMenuName  := nil;
	WindowClass.lpszClassName := FWindowClassName;
	WindowClass.hIconSm       := WindowClass.hIcon;
	
	FWindowClass := Windows.RegisterClassEx(WindowClass);
	end;
Result := (FWindowClass <> 0);
end;

procedure TSSystemTrayIconWinAPI.Messages();
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
end;

constructor TSSystemTrayIconWinAPI.Create();
begin
inherited;
FWindowClassName := nil;
FWindowClass := 0;
FWindow := 0;
FIconIdentifier := 200 + Random(1000);
end;

procedure TSSystemTrayIconWinAPI.Initialize();
begin
RegisterWindowClass();
FWindow := Windows.CreateWindow(FWindowClassName, nil, 0, 0, 0, 0, 0, 0, 0, System.MainInstance, nil);
if (FWindow <> 0) then
	SetWindowLongPtr(FWindow, GWL_USERDATA, TSMaxEnum(Self));
SWinAPIShellAddIconFromResources(FWindow, FIconIdentifier, SCWAPI_ICON, S_CALLBACK, FTip);
inherited Initialize();
end;

procedure TSSystemTrayIconWinAPI.Kill();
begin
if (FIconIdentifier <> 0) then
	begin
	if (FWindow <> 0) then
		SWinAPIShellDeleteIcon(FWindow, FIconIdentifier);
	FIconIdentifier := 0;
	end;
if (FWindow <> 0) then
	begin
	DestroyWindow(FWindow);
	FWindow := 0;
	end;
if (FWindowClass <> 0) then
	begin
	UnregisterClass(FWindowClassName, System.MainInstance);
	FreeMem(FWindowClassName);
	FWindowClassName := nil;
	FWindowClass := 0;
	end;
end;

destructor TSSystemTrayIconWinAPI.Destroy();
begin
Kill();
inherited;
end;

end.
