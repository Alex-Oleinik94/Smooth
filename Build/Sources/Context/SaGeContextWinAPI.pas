{$include SaGe.inc}

{$R .\..\..\SaGe.res}

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
	,SaGeCommonClasses
	,SaGeImagesBase
	;

const
	SGCWAPI_ICON = 5;
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
			public
		procedure ShowCursor(const VVisibility : TSGBoolean);override;
		procedure SetCursorPosition(const VPosition : TSGPoint2int32);override;
		function  KeysPressed(const  Index : integer ) : Boolean;override;overload;
		// If function need puplic, becourse it calls in WinAPI procedure without whis class
		function WndMessagesProc(const VWindow: WinAPIHandle; const AMessage:LongWord; const WParam, LParam: WinAPIParam): WinAPIParam;
			protected
		procedure InitFullscreen(const VFullscreen : TSGBoolean); override;
		function  GetWindow() : TSGPointer; override;
		function  GetDevice() : TSGPointer; override;
		procedure SetCursor(const VCursor : TSGCursor); override;
		procedure SetIcon  (const VIcon   : TSGBitMap); override;
			protected
		hWindow  : HWnd;
		dcWindow : hDc;
		clWindow : TSGMaxEnum;
		FWindowClassName : TSGString;
		procedure ThrowError(pcErrorMessage : pChar);
		function  WindowRegister(): Boolean;
		function  WindowCreate(): HWnd;
		function  WindowInit(hParent : HWnd): Boolean;
		procedure KillWindow(const KillRC:Boolean = True);
		function  CreateWindow():Boolean;
		class function GetClientWindowRect(const VWindow : HWND) : TRect;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function GetWindowRect(const VWindow : HWND) : TRect;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class procedure GetMaskBitmaps(const VCursor : TSGCursor;const hSourceBitmap : HBITMAP;const  clrTransparent : COLORREF; var hAndMaskBitmap : HBITMAP; var hXorMaskBitmap : HBITMAP);
		class function CreateCursorFromBitmap(const VCursor : TSGCursor;const hSourceBitmap : HBITMAP;const clrTransparent : COLORREF;const xHotspot : DWORD;const yHotspot : DWORD) : HCURSOR;
		class function CreateCursor(const VCursor : TSGCursor;const clrTransparent : COLORREF):HCURSOR;
		class function CreateGlassyCursor() : HCURSOR;
			protected
		FCursorHandle : Windows.HCURSOR;
		FIconHandle   : Windows.HICON;
		FGlassyCursorHandle : Windows.HCURSOR;
			public
		function  GetCursorPosition(): TSGPoint2int32; override;
		function  FileOpenDialog(const VTittle: String; const VFilter : String):String;override;
		function  FileSaveDialog(const VTittle: String; const VFilter : String;const extension : String):String;override;
		end;

function SGFullscreenQueschionWinAPIMethod():boolean;
function StandartWndProc(const Window: WinAPIHandle; const AMessage:LongWord; const WParam, LParam: WinAPIParam; var DoExit:Boolean): WinAPIParam;
//procedure GetNativeSystemInfo(var a:SYSTEM_INFO);[stdcall];[external 'kernel32' name 'GetNativeSystemInfo'];

implementation

uses
	SaGeScreen
	,SysUtils;

// А вод это жесткий костыль.
// Дело в том, что в WinAPI класс нашего hWindow нельзя запихнуть собственную информацию,
// например указатель на контекст, и поэтому процедура отловления сообщений системы
// Ищет по hWindow совй контекст из всех открытых в программе контекстов (SGContexts)
var
	SGContexts:packed array of TSGContextWinAPI = nil;

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

class function TSGContextWinAPI.CreateGlassyCursor() : HCURSOR;
const
	SGCWAPI_Glassy_Cursor_Width = 32;
	SGCWAPI_Glassy_Cursor_Height = 32;
var
	hBM : HBITMAP;
	bm : PByte = nil;
	i : TSGLongWord;
begin
Result := 0;
hBM := CreateCompatibleBitmap(GetDC(0), SGCWAPI_Glassy_Cursor_Width, SGCWAPI_Glassy_Cursor_Height);

bm := GetMem(SGCWAPI_Glassy_Cursor_Width * SGCWAPI_Glassy_Cursor_Height * 3);
fillchar(bm^, SGCWAPI_Glassy_Cursor_Width * SGCWAPI_Glassy_Cursor_Height * 3, 0);
SetBitmapBits(hBM, SGCWAPI_Glassy_Cursor_Width * SGCWAPI_Glassy_Cursor_Height * 3, bm);
FreeMem(bm);

Result := CreateCursorFromBitmap(nil, hBM, RGB(0,0,0), 0, 0);
DeleteObject(hBM);
end;

class procedure TSGContextWinAPI.GetMaskBitmaps(const VCursor : TSGCursor;const hSourceBitmap : HBITMAP;const clrTransparent : COLORREF; var hAndMaskBitmap : HBITMAP; var hXorMaskBitmap : HBITMAP);
var
	hXorMaskDC, hAndMaskDC, hMainDC, hNullDC : HDC;
	bm : BITMAP;
	hOldMainBitmap, hOldAndMaskBitmap, hOldXorMaskBitmap : HBITMAP;
	x, y, alpha: TSGLongWord;
	MainBitPixel : COLORREF;
begin
hNullDC				:= GetDC(0);
hMainDC				:= CreateCompatibleDC(hNullDC);
hAndMaskDC			:= CreateCompatibleDC(hNullDC);
hXorMaskDC			:= CreateCompatibleDC(hNullDC);

GetObject(hSourceBitmap, sizeof(BITMAP), @bm);


hAndMaskBitmap	:= CreateCompatibleBitmap(hNullDC, bm.bmWidth, bm.bmHeight);
hXorMaskBitmap	:= CreateCompatibleBitmap(hNullDC, bm.bmWidth, bm.bmHeight);

hOldMainBitmap      := HBITMAP(SelectObject(hMainDC,   hSourceBitmap ));
hOldAndMaskBitmap	:= HBITMAP(SelectObject(hAndMaskDC,hAndMaskBitmap));
hOldXorMaskBitmap	:= HBITMAP(SelectObject(hXorMaskDC,hXorMaskBitmap));

for x := 0 to bm.bmWidth - 1 do
	begin
	for y := 0 to bm.bmHeight - 1 do
		begin
		MainBitPixel := GetPixel(hMainDC, x, y);
		if (VCursor = nil) or (VCursor.Channels = 3) then
			if(MainBitPixel = clrTransparent) then
				begin
				SetPixel(hAndMaskDC,x,y,RGB(255,255,255));
				SetPixel(hXorMaskDC,x,y,RGB(0,0,0));
				end
			else
				begin
				SetPixel(hAndMaskDC,x,y,RGB(0,0,0));
				SetPixel(hXorMaskDC,x,y,MainBitPixel);
				end
		else
			begin
			alpha := VCursor.BitMap[(x + y * bm.bmWidth) * 4 + 3];
			if alpha < 150 then
				begin
				SetPixel(hAndMaskDC,x,y,RGB(255,255,255));
				SetPixel(hXorMaskDC,x,y,RGB(0,0,0));
				end
			else
				begin
				SetPixel(hAndMaskDC,x,y,RGB(0,0,0));
				SetPixel(hXorMaskDC,x,y,RGB(alpha, alpha, alpha));
				end;
			end;
		end;
	end;

SelectObject(hMainDC,   hOldMainBitmap);
SelectObject(hAndMaskDC,hOldAndMaskBitmap);
SelectObject(hXorMaskDC,hOldXorMaskBitmap);

DeleteDC(hXorMaskDC);
DeleteDC(hAndMaskDC);
DeleteDC(hMainDC);

ReleaseDC(0, hNullDC);
end;

class function TSGContextWinAPI.CreateCursorFromBitmap(const VCursor : TSGCursor;const hSourceBitmap : HBITMAP;const clrTransparent : COLORREF;const xHotspot : DWORD;const yHotspot : DWORD) : HCURSOR;
var
	hAndMask : HBITMAP = 0;
	hXorMask : HBITMAP = 0;
	iconinfo : _ICONINFO;
begin
Result := 0;

if(0 = hSourceBitmap) then
	begin
	Exit;
	end;

GetMaskBitmaps(VCursor, hSourceBitmap, clrTransparent, hAndMask, hXorMask);
if((0 = hAndMask) or (0 = hXorMask)) then
	begin
	Exit;
	end;

fillchar(iconinfo, sizeof(iconinfo), 0);
iconinfo.fIcon		:= False;
iconinfo.xHotspot	:= xHotspot;
iconinfo.yHotspot	:= yHotspot;
iconinfo.hbmMask	:= hAndMask;
iconinfo.hbmColor	:= hXorMask;

Result := CreateIconIndirect(@iconinfo);
end;

class function TSGContextWinAPI.CreateCursor(const VCursor : TSGCursor;const clrTransparent : COLORREF):HCURSOR;
var
	hBM : HBITMAP;
	bm : PByte = nil;
	i : TSGLongWord;
begin
Result := 0;
hBM := CreateCompatibleBitmap(GetDC(0), VCursor.Width, VCursor.Height);
if VCursor.Channels = 4 then
	begin
	bm := GetMem(VCursor.Width * VCursor.Height * 3);
	for i := 0 to VCursor.Width * VCursor.Height - 1 do
		begin
		bm[i * 3 + 0] := VCursor.BitMap[i * 4 + 0];
		bm[i * 3 + 1] := VCursor.BitMap[i * 4 + 1];
		bm[i * 3 + 2] := VCursor.BitMap[i * 4 + 2];
		end;
	SetBitmapBits(hBM, VCursor.Width * VCursor.Height * 3, bm);
	FreeMem(bm);
	end
else
	SetBitmapBits(hBM, VCursor.Width * VCursor.Height * VCursor.Channels, VCursor.BitMap);
Result := CreateCursorFromBitmap(VCursor,hBM, clrTransparent, VCursor.HotPixelX, VCursor.HotPixelY);
DeleteObject(hBM);
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
		NewCursor := CreateCursor(VCursor,RGB(0,0,0));
		if NewCursor <> SGC_NULL then
			Windows.SetSystemCursor(NewCursor, VCursor.StandartHandle);
		end;
	end
else
	begin
	NewCursor := CreateCursor(VCursor,RGB(0,0,0));
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
	begin
	Windows.SetClassLong(hWindow, GCL_HCURSOR, FCursorHandle);
	Windows.SetCursor(FCursorHandle);
	end
else
	begin
	Windows.SetClassLong(hWindow, GCL_HCURSOR, FGlassyCursorHandle);
	Windows.SetCursor(FGlassyCursorHandle);
	end;
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
FCursorHandle := LoadCursor(0, IDC_ARROW);
FIconHandle   := LoadIcon(GetModuleHandle(nil), MAKEINTRESOURCE(SGCWAPI_ICON));
FGlassyCursorHandle := CreateGlassyCursor();
end;

procedure TSGContextWinAPI.Kill();
begin
inherited;
KillWindow();
SetLength(SGContexts, 0);
end;

destructor TSGContextWinAPI.Destroy;
begin
inherited;
end;

procedure TSGContextWinAPI.Initialize();

procedure HandlingSizingFromRect();
var
	WRect, WCRect : Windows.TRect;
begin
Windows.GetWindowRect(hWindow, WRect);
FWidth  :=  WRect.Right  - WRect.Left;
FHeight :=  WRect.Bottom - WRect.Top;
FLeft := WRect.Left;
FTop  := WRect.Top;
WCRect  := GetClientWindowRect(dcWindow);
FClientHeight := GetClientWindowRect(hWindow).bottom;
FClientWidth  := GetClientWindowRect(hWindow).right;
Resize();
end;

begin
Active := CreateWindow();
if Active then
	begin
	HandlingSizingFromRect();
	inherited;
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
while Windows.PeekMessage(@msg,0,0,0,0) do
	begin
	Windows.GetMessage(@msg,0,0,0);
	Windows.TranslateMessage(msg);
	Windows.DispatchMessage(msg);
	Fillchar(msg,sizeof(msg),0);
	end;
inherited;
end;

procedure TSGContextWinAPI.ThrowError(pcErrorMessage : pChar);
begin
MessageBox(0, pcErrorMessage, 'Error', MB_OK);
Halt(0);
end;

function TSGContextWinAPI.WndMessagesProc(const VWindow: WinAPIHandle; const AMessage:LongWord; const WParam, LParam: WinAPIParam): WinAPIParam;

procedure HandlingSizingFromRect(const PR : PRect = nil);
var
	WRect, WCRect : Windows.TRect;
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

procedure HandlingSizingFromParam();
var
	mRect : Windows.TRect;
	Shift : TSGPoint2int32;
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
	SGLog.Sourse('TSGContextWinAPI__Messages : Note : Window is closed from OS.');
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
	HandlingSizingFromRect();
	end;
else
	begin
	{$IFDEF SGWinAPIDebug}
		SGLog.Sourse('StandartWndProc : Unknown Message : Window="'+SGSTr(TSGMaxEnum(Window))+'" Message="'+SGStr(AMessage)+'" wParam="'+SGStr(wParam)+'" lParam="'+SGStr(lParam)+'"');
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
{$IFDEF SGWinAPIDebug}
	SGLog.Sourse('MyWndProc(Window='+SGStr(Window)+',AMessage='+SGStr(AMessage)+',WParam='+SGSTr(WParam)+',LParam='+SGStr(LParam)+') : Enter');
	{$ENDIF}
Result:=StandartWndProc(Window,AMessage,WParam,LParam,DoExit);
if DoExit then
	Exit
else
	Result := DefWindowProc(Window, AMessage, WParam, LParam);
{$IFDEF SGWinAPIDebug}
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
FWindowClassName := 'SaGe Window Class ' + SGStr(Random(100000));
WindowClass.cbSize        := SizeOf(WNDCLASSEX);
WindowClass.Style         := cs_hRedraw or cs_vRedraw or CS_OWNDC;
WindowClass.lpfnWndProc   := WndProc(@MyGLWndProc);
WindowClass.cbClsExtra    := 0;
WindowClass.cbWndExtra    := 0;
WindowClass.hInstance     := System.MainInstance;
WindowClass.hIcon         := FIconHandle;
WindowClass.hCursor       := FCursorHandle;
WindowClass.hbrBackground := 0;
WindowClass.lpszMenuName  := nil;
WindowClass.lpszClassName := SGStringAsPChar(FWindowClassName);
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
	hWindow2 := Windows.CreateWindow(SGStringAsPChar(FWindowClassName),
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
	FTop := 0;
	FLeft := 0;
	hWindow2 := CreateWindowEx(WS_EX_APPWINDOW,
		SGStringAsPChar(FWindowClassName),
		SGStringToPChar(FTitle),
		WS_EX_TOPMOST OR WS_POPUP OR WS_VISIBLE OR WS_CLIPSIBLINGS OR WS_CLIPCHILDREN,
		0,
		0,
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
	SGLog.Sourse(['TSGContextWinAPI__WindowInit(hParent='+SGStr(hParent)+') : Enter']);
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
	{$IFDEF SGWinAPIDebug}
		SGLog.Sourse(['TSGContextWinAPI__WindowInit(HWnd) : Create render context (Result=',Result,')']);
		{$ENDIF}
	if Result then
		FRender.Init();
	{$IFDEF SGWinAPIDebug}
		SGLog.Sourse('TSGContextWinAPI__WindowInit(HWnd) : Created render (Render='+SGAddrStr(FRender)+')');
		{$ENDIF}
	end
else
	begin
	{$IFDEF SGWinAPIDebug}
		SGLog.Sourse('TSGContextWinAPI__WindowInit(HWnd) : Formating render (Render='+SGAddrStr(FRender)+')');
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
if (hWindow<>0) and (dcWindow<>0) then
	ReleaseDC( hWindow, dcWindow );
if (dcWindow<>0) then
	begin
	CloseHandle(dcWindow);
	dcWindow:=0;
	end;
if hWindow<>0 then
	begin
	DestroyWindow( hWindow );
	hWindow:=0;
	end;
if hWindow<>0 then
	begin
	CloseHandle( hWindow);
	hWindow:=0;
	end;
UnregisterWindowClass();
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
		KillWindow(False);
		Messages();
		inherited InitFullscreen(VFullscreen);
		if VFullscreen then
			begin
			FWidth := GetScreenArea().x;
			FHeight:= GetScreenArea().y;
			end;
		Active := CreateWindow();
		if (FRender <> nil) and Active then
			FRender.UnLockResources();
		Resize();
		end;
end;

end.

