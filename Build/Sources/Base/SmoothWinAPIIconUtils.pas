{$INCLUDE Smooth.inc}

unit SmoothWinAPIIconUtils;

interface

uses
	 SmoothBase
	,SmoothCasesOfPrint
	,SmoothLists
	,SmoothCursor
	
	,ShellAPI
	,Windows
	;

procedure SWinAPIGetMaskBitmaps(const VCursor : TSCursor;const hSourceBitmap : HBITMAP;const  clrTransparent : COLORREF; var hAndMaskBitmap : HBITMAP; var hXorMaskBitmap : HBITMAP);

function SWinAPICreateCursorFromBitmap(const VCursor : TSCursor;const hSourceBitmap : HBITMAP;const clrTransparent : COLORREF;const xHotspot : DWORD;const yHotspot : DWORD) : HCURSOR;
function SWinAPICreateCursor(const VCursor : TSCursor;const clrTransparent : COLORREF):HCURSOR;
function SWinAPICreateGlassyCursor() : Windows.HCURSOR;

function SWinAPIShellAddIconFromResources(const WindowHandle : HWND; const IconIdentifier, IconRecourceIdentifier : TSUInt32; const _CallbackMessage : TSUInt32; const Tip : TSString = '') : TSBoolean;
function SWinAPIShellDeleteIcon(const WindowHandle : HWND; const IconIdentifier : TSUInt32) : TSBoolean;
function SWinAPIShellModifyIconTip(const WindowHandle : HWND; const IconIdentifier : TSUInt32; const _Tip : TSString) : TSBoolean;

implementation

uses
	 SmoothLog
	,SmoothBitMapBase
	;

function SWinAPIShellModifyIconTip(const WindowHandle : HWND; const IconIdentifier : TSUInt32; const _Tip : TSString) : TSBoolean;
var
	IconData : TNotifyIconDataA;
begin
ZeroMemory(@IconData, sizeof(TNotifyIconDataA));
IconData.cbSize := sizeof(TNotifyIconDataA);
IconData.uVersion := NOTIFYICON_VERSION;
IconData.Wnd := WindowHandle;
IconData.uID := IconIdentifier;
IconData.uFlags := NIF_TIP;
IconData.szTip := _Tip;
Result := Shell_NotifyIconA(NIM_MODIFY, @IconData);
end;

function SWinAPIShellDeleteIcon(const WindowHandle : HWND; const IconIdentifier : TSUInt32) : TSBoolean;
var
	IconData : TNotifyIconDataA;
begin
ZeroMemory(@IconData, sizeof(TNotifyIconDataA));
IconData.cbSize := sizeof(TNotifyIconDataA);
IconData.uVersion := NOTIFYICON_VERSION;
IconData.Wnd := WindowHandle;
IconData.uID := IconIdentifier;
Result := Shell_NotifyIconA(NIM_DELETE, @IconData);
end;

function SWinAPIShellAddIconFromResources(const WindowHandle : HWND; const IconIdentifier, IconRecourceIdentifier : TSUInt32; const _CallbackMessage : TSUInt32; const Tip : TSString = '') : TSBoolean;
var
	IconData : TNotifyIconDataA;
begin
ZeroMemory(@IconData, sizeof(TNotifyIconDataA));
IconData.cbSize := sizeof(TNotifyIconDataA);
IconData.uVersion := NOTIFYICON_VERSION;
IconData.Wnd := WindowHandle;
IconData.uID := IconIdentifier;
IconData.uFlags := NIF_ICON;
IconData.hIcon := LoadIcon(GetModuleHandle(nil), MAKEINTRESOURCE(IconRecourceIdentifier));
if (_CallbackMessage <> 0) then
	IconData.uFlags := IconData.uFlags or NIF_MESSAGE;
IconData.uCallbackMessage := _CallbackMessage;
if (Tip <> '') then
	IconData.uFlags := IconData.uFlags or NIF_TIP;
IconData.szTip := Tip;
Result := Shell_NotifyIconA(NIM_ADD, @IconData);
end;

function SWinAPICreateGlassyCursor() : HCURSOR;
const
	SCWAPI_Glassy_Cursor_Width = 32;
	SCWAPI_Glassy_Cursor_Height = 32;
var
	hBM : HBITMAP;
	bm : PByte = nil;
begin
Result := 0;
hBM := CreateCompatibleBitmap(GetDC(0), SCWAPI_Glassy_Cursor_Width, SCWAPI_Glassy_Cursor_Height);

bm := GetMem(SCWAPI_Glassy_Cursor_Width * SCWAPI_Glassy_Cursor_Height * 3);
fillchar(bm^, SCWAPI_Glassy_Cursor_Width * SCWAPI_Glassy_Cursor_Height * 3, 0);
SetBitmapBits(hBM, SCWAPI_Glassy_Cursor_Width * SCWAPI_Glassy_Cursor_Height * 3, bm);
FreeMem(bm);

Result := SWinAPICreateCursorFromBitmap(nil, hBM, RGB(0,0,0), 0, 0);
DeleteObject(hBM);
end;

procedure SWinAPIGetMaskBitmaps(const VCursor : TSCursor;const hSourceBitmap : HBITMAP;const clrTransparent : COLORREF{color meaning "glassy"}; var hAndMaskBitmap : HBITMAP; var hXorMaskBitmap : HBITMAP);
var
	hXorMaskDC, hAndMaskDC, hMainDC, hNullDC : HDC;
	bm : BITMAP;
	hOldMainBitmap, hOldAndMaskBitmap, hOldXorMaskBitmap : HBITMAP;
	x, y, alpha: TSUInt32;
	Pixel : COLORREF;

procedure SetPixel(const _DC : HDC; const _Color : COLORREF); overload;
begin
SetPixel(_DC, x, bm.bmHeight - 1 - y, _Color);
end;

procedure SetPixels(const _ColorAnd, _ColorXor : COLORREF); overload;
begin
SetPixel(hAndMaskDC, _ColorAnd);
SetPixel(hXorMaskDC, _ColorXor);
end;

begin
hOldMainBitmap    := 0;
hOldAndMaskBitmap := 0;
hOldXorMaskBitmap := 0;

hNullDC    := GetDC(0);
hMainDC    := CreateCompatibleDC(hNullDC);
hAndMaskDC := CreateCompatibleDC(hNullDC);
hXorMaskDC := CreateCompatibleDC(hNullDC);

FillChar(bm, SizeOf(bm), 0);
GetObject(hSourceBitmap, sizeof(BITMAP), @bm);

hAndMaskBitmap := CreateCompatibleBitmap(hNullDC, bm.bmWidth, bm.bmHeight);
hXorMaskBitmap := CreateCompatibleBitmap(hNullDC, bm.bmWidth, bm.bmHeight);

hOldMainBitmap    := HBITMAP(SelectObject(hMainDC,   hSourceBitmap ));
hOldAndMaskBitmap := HBITMAP(SelectObject(hAndMaskDC,hAndMaskBitmap));
hOldXorMaskBitmap := HBITMAP(SelectObject(hXorMaskDC,hXorMaskBitmap));

for x := 0 to bm.bmWidth - 1 do
	for y := 0 to bm.bmHeight - 1 do
		begin
		Pixel := GetPixel(hMainDC, x, y);
		if (VCursor = nil) or (VCursor.Channels = 3) then
			if(Pixel = clrTransparent) then
				SetPixels(RGB(255,255,255){and mask}, RGB(0,0,0){xor mask}) // Transparent("glassy") color
			else
				SetPixels(RGB(0,0,0){and mask}, Pixel{xor mask})
		else if (SPixelRGBA32FromMemory(VCursor.Data, x + y * VCursor.Width).a = 0) then
				SetPixels(RGB(255,255,255){and mask}, RGB(0,0,0){xor mask}) // Transparent("glassy") color
			else
				SetPixels(RGB(0,0,0){and mask}, Pixel{xor mask});
		end;

SelectObject(hMainDC,    hOldMainBitmap);
SelectObject(hAndMaskDC, hOldAndMaskBitmap);
SelectObject(hXorMaskDC, hOldXorMaskBitmap);

if (bm.bmBits <> nil) then
	FreeMem(bm.bmBits);
FillChar(bm, SizeOf(bm), 0);

DeleteDC(hXorMaskDC);
DeleteDC(hAndMaskDC);
DeleteDC(hMainDC);

ReleaseDC(0, hNullDC);
end;

function SWinAPICreateCursorFromBitmap(const VCursor : TSCursor;const hSourceBitmap : HBITMAP;const clrTransparent : COLORREF;const xHotspot : DWORD;const yHotspot : DWORD) : HCURSOR;
var
	hAndMask : HBITMAP = 0;
	hXorMask : HBITMAP = 0;
	iconinfo : _ICONINFO;
begin
Result := 0;

if(0 = hSourceBitmap) then
	Exit;

SWinAPIGetMaskBitmaps(VCursor, hSourceBitmap, clrTransparent, hAndMask, hXorMask);
if((0 = hAndMask) or (0 = hXorMask)) then
	Exit;

//     typedef struct _ICONINFO {
//       BOOL    fIcon;
//       DWORD   xHotspot;
//       DWORD   yHotspot;
//       HBITMAP hbmMask;
//       HBITMAP hbmColor;
//     } ICONINFO;
//  ==> fIcon; Type: BOOL
//      Specifies whether this structure defines an icon or a cursor.
// A value of TRUE specifies an icon; FALSE specifies a cursor.
//  ==> hbmMask; Type: HBITMAP
//      The icon bitmask bitmap. If this structure defines a black and white icon,
// this bitmask is formatted so that the upper half is the icon AND bitmask
// and the lower half is the icon XOR bitmask. Under this condition, the height
// should be an even multiple of two. If this structure defines a color icon,
// this mask only defines the AND bitmask of the icon.
//  ==> hbmColor; Type: HBITMAP
//      A handle to the icon color bitmap. This member can be optional if
// this structure defines a black and white icon. The AND bitmask of hbmMask
// is applied with the SRCAND flag to the destination; subsequently, the
// color bitmap is applied (using XOR) to the destination by using the SRCINVERT flag.

fillchar(iconinfo, sizeof(iconinfo), 0);
iconinfo.fIcon      := False; // is cursor
iconinfo.xHotspot   := xHotspot;
iconinfo.yHotspot   := yHotspot;
iconinfo.hbmMask    := hAndMask;
iconinfo.hbmColor   := hXorMask;

Result := CreateIconIndirect(@iconinfo);
end;

function SWinAPICreateCursor(const VCursor : TSCursor;const clrTransparent : COLORREF):HCURSOR;
var
	hBM : HBITMAP;
	bm : PByte = nil;
	w, h, Index : TSMaxEnum;
begin
Result := 0;
hBM := CreateCompatibleBitmap(GetDC(0), VCursor.Width, VCursor.Height);
bm := GetMem(VCursor.Width * VCursor.Height * VCursor.Channels);
for h := 0 to VCursor.Height - 1 do
	for w := 0 to VCursor.Width - 1 do
		begin
		Index := h * VCursor.Width + w;
		if (VCursor.Channels = 4) then
			PSPixel3b(bm)[Index] := SPixelRGB24FromMemory(VCursor.Data, Index)
		else
			PSPixel3b(bm)[Index] := SPixelRGBA32FromMemory(VCursor.Data, Index);
		end;
SetBitmapBits(hBM, VCursor.Width * VCursor.Height * VCursor.Channels, bm);
FreeMem(bm);
Result := SWinAPICreateCursorFromBitmap(VCursor, hBM, clrTransparent, VCursor.HotPixelX, VCursor.HotPixelY);
DeleteObject(hBM);
end;

end.
