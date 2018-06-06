{$INCLUDE SaGe.inc}

unit SaGeSystemTrayIconWinAPI;

interface

uses
	 SaGeBase
	,SaGeSystemTrayIcon
	,SaGeWinAPIIconUtils
	,SaGeWinAPIUtils
	
	,ShellAPI
	,Windows
	;

type
	TSGSystemTrayIconWinAPI = class(TSGSystemTrayIcon)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		procedure Messages(); override;
		procedure Initialize(); override;
		procedure Kill(); override;
		function CallBack(AMessage : TSGUInt32; WParam, LParam : TSGWinAPIParam) : TSGWinAPIParam;
			protected
		FWindowClassName : PSGChar;
		FWindowClass : TSGMaxEnum;
		FWindow : HWND;
		FIconIdentifier : TSGUInt32;
			protected
		function RegisterWindowClass() : TSGBoolean;
		procedure ExecuteCallBacks(const Param : TSGWinAPIParam);
		end;

implementation

uses
	 SaGeLog
	,SaGeStringUtils
	,SaGeContextUtils
	;

procedure TSGSystemTrayIconWinAPI.ExecuteCallBacks(const Param : TSGWinAPIParam);
var
	Button : TSGCursorButton = SGNullCursorButton;
	ButtonType : TSGCursorButtonType = SGNullKey;
begin
if (Param = WM_LBUTTONDBLCLK) or (Param = WM_LBUTTONDOWN) or (Param = WM_LBUTTONUP) then
	Button := SGLeftCursorButton
else if (Param = WM_RBUTTONDBLCLK) or (Param = WM_RBUTTONDOWN) or (Param = WM_RBUTTONUP) then
	Button := SGRightCursorButton
else if (Param = WM_MBUTTONDBLCLK) or (Param = WM_MBUTTONDOWN) or (Param = WM_MBUTTONUP) then
	Button := SGMiddleCursorButton;
if (Param = WM_LBUTTONDBLCLK) or (Param = WM_RBUTTONDBLCLK) or (Param = WM_MBUTTONDBLCLK) then
	ButtonType := SGDoubleClick
else if (Param = WM_LBUTTONDOWN) or (Param = WM_RBUTTONDOWN) or (Param = WM_MBUTTONDOWN) then
	ButtonType := SGDownKey
else if (Param = WM_LBUTTONUP) or (Param = WM_RBUTTONUP) or (Param = WM_MBUTTONUP) then
	ButtonType := SGUpKey;
if (FButtonsCallBack <> nil) then
	FButtonsCallBack.IconMouseCallBack(Button, ButtonType);
end;

const
	SG_CALLBACK = 123232;

function TSGSystemTrayIconWinAPI.CallBack(AMessage : TSGUInt32; WParam, LParam : TSGWinAPIParam) : TSGWinAPIParam;
begin
Result := 0;
case AMessage of
WM_GETMINMAXINFO: {36} ;
WM_NCCREATE: {129} ;
WM_NCCALCSIZE : {131} ;
WM_CREATE: {1} ;
WM_NCDESTROY: {130} ;
WM_DESTROY : {2} ;
VK_NUMLOCK: {144} ;
WM_USER: {1024} ;
799: {?} ;
SG_CALLBACK:
	begin
	case LParam of
	WM_MOUSEMOVE: ;
	WM_LBUTTONDBLCLK, WM_LBUTTONDOWN, WM_LBUTTONUP, WM_RBUTTONDBLCLK, WM_RBUTTONDOWN, WM_RBUTTONUP, WM_MBUTTONDBLCLK, WM_MBUTTONDOWN, WM_MBUTTONUP:
		ExecuteCallBacks(LParam);
	end;
	end;
end;
end;

function WinAPIIconCallBack(Window: TSGWinAPIHandle; AMessage : TSGUInt32; WParam, LParam : TSGWinAPIParam) : TSGWinAPIParam; stdcall; export;
var
	Icon : TSGSystemTrayIconWinAPI;
begin
Icon := TSGSystemTrayIconWinAPI(GetWindowLongPtr(Window, GWLP_USERDATA));
Result := Icon.CallBack(AMessage, WParam, LParam);
if (Result = 0) then
	Result := DefWindowProc(Window, AMessage, WParam, LParam);
end;

function TSGSystemTrayIconWinAPI.RegisterWindowClass() : TSGBoolean;
var
  WindowClass: Windows.WndClassEx;
begin
if (FWindowClassName = nil) then
	FWindowClassName := SGStringToPChar('SaGe Icon Class ' + SGStr(Random(100000)));
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

procedure TSGSystemTrayIconWinAPI.Messages();
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

constructor TSGSystemTrayIconWinAPI.Create();
begin
inherited;
FWindowClassName := nil;
FWindowClass := 0;
FWindow := 0;
FIconIdentifier := 200 + Random(1000);
end;

procedure TSGSystemTrayIconWinAPI.Initialize();
begin
RegisterWindowClass();
FWindow := Windows.CreateWindow(FWindowClassName, nil, 0, 0, 0, 0, 0, 0, 0, System.MainInstance, nil);
if (FWindow <> 0) then
	SetWindowLongPtr(FWindow, GWL_USERDATA, TSGMaxEnum(Self));
SGWinAPIShellAddIconFromResources(FWindow, FIconIdentifier, SGCWAPI_ICON, SG_CALLBACK, FTip);
end;

procedure TSGSystemTrayIconWinAPI.Kill();
begin
if (FIconIdentifier <> 0) then
	begin
	if (FWindow <> 0) then
		SGWinAPIShellDeleteIcon(FWindow, FIconIdentifier);
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

destructor TSGSystemTrayIconWinAPI.Destroy();
begin
Kill();
inherited;
end;

end.
