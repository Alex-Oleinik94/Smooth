{$INCLUDE SaGe.inc}

unit SaGeWinAPIIconUtils;

interface

uses
	 SaGeBase
	,SaGeCasesOfPrint
	,SaGeLists
	,SaGeCursor
	
	,ShellAPI
	,Windows
	;

procedure SGWinAPIGetMaskBitmaps(const VCursor : TSGCursor;const hSourceBitmap : HBITMAP;const  clrTransparent : COLORREF; var hAndMaskBitmap : HBITMAP; var hXorMaskBitmap : HBITMAP);
function SGWinAPICreateCursorFromBitmap(const VCursor : TSGCursor;const hSourceBitmap : HBITMAP;const clrTransparent : COLORREF;const xHotspot : DWORD;const yHotspot : DWORD) : HCURSOR;
function SGWinAPICreateCursor(const VCursor : TSGCursor;const clrTransparent : COLORREF):HCURSOR;
function SGWinAPICreateGlassyCursor() : Windows.HCURSOR;
function SGWinAPIShellAddIconFromResources(const WindowHandle : HWND; const IconIdentifier, IconRecourceIdentifier : TSGUInt32; const _CallbackMessage : TSGUInt32; const Tip : TSGString = '') : TSGBoolean;
function SGWinAPIShellDeleteIcon(const WindowHandle : HWND; const IconIdentifier : TSGUInt32) : TSGBoolean;
function SGWinAPIShellModifyIconTip(const WindowHandle : HWND; const IconIdentifier : TSGUInt32; const _Tip : TSGString) : TSGBoolean;

implementation

uses
	 SaGeLog
	,SaGeBitMapBase
	;

function SGWinAPIShellModifyIconTip(const WindowHandle : HWND; const IconIdentifier : TSGUInt32; const _Tip : TSGString) : TSGBoolean;
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

function SGWinAPIShellDeleteIcon(const WindowHandle : HWND; const IconIdentifier : TSGUInt32) : TSGBoolean;
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

function SGWinAPIShellAddIconFromResources(const WindowHandle : HWND; const IconIdentifier, IconRecourceIdentifier : TSGUInt32; const _CallbackMessage : TSGUInt32; const Tip : TSGString = '') : TSGBoolean;
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

function SGWinAPICreateGlassyCursor() : HCURSOR;
const
	SGCWAPI_Glassy_Cursor_Width = 32;
	SGCWAPI_Glassy_Cursor_Height = 32;
var
	hBM : HBITMAP;
	bm : PByte = nil;
begin
Result := 0;
hBM := CreateCompatibleBitmap(GetDC(0), SGCWAPI_Glassy_Cursor_Width, SGCWAPI_Glassy_Cursor_Height);

bm := GetMem(SGCWAPI_Glassy_Cursor_Width * SGCWAPI_Glassy_Cursor_Height * 3);
fillchar(bm^, SGCWAPI_Glassy_Cursor_Width * SGCWAPI_Glassy_Cursor_Height * 3, 0);
SetBitmapBits(hBM, SGCWAPI_Glassy_Cursor_Width * SGCWAPI_Glassy_Cursor_Height * 3, bm);
FreeMem(bm);

Result := SGWinAPICreateCursorFromBitmap(nil, hBM, RGB(0,0,0), 0, 0);
DeleteObject(hBM);
end;

procedure SGWinAPIGetMaskBitmaps(const VCursor : TSGCursor;const hSourceBitmap : HBITMAP;const clrTransparent : COLORREF{color meaning "glassy"}; var hAndMaskBitmap : HBITMAP; var hXorMaskBitmap : HBITMAP);
var
	hXorMaskDC, hAndMaskDC, hMainDC, hNullDC : HDC;
	bm : BITMAP;
	hOldMainBitmap, hOldAndMaskBitmap, hOldXorMaskBitmap : HBITMAP;
	x, y, alpha: TSGUInt32;
	MainBitPixel : COLORREF;

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
hOldMainBitmap := 0;
hOldAndMaskBitmap := 0;
hOldXorMaskBitmap := 0;

hNullDC				:= GetDC(0);
hMainDC				:= CreateCompatibleDC(hNullDC);
hAndMaskDC			:= CreateCompatibleDC(hNullDC);
hXorMaskDC			:= CreateCompatibleDC(hNullDC);

FillChar(bm, SizeOf(bm), 0);
GetObject(hSourceBitmap, sizeof(BITMAP), @bm);

hAndMaskBitmap := CreateCompatibleBitmap(hNullDC, bm.bmWidth, bm.bmHeight);
hXorMaskBitmap := CreateCompatibleBitmap(hNullDC, bm.bmWidth, bm.bmHeight);

{hAndMaskBitmap := CreateCompatibleBitmap(hNullDC, VCursor.Width, VCursor.Height);
hXorMaskBitmap := CreateCompatibleBitmap(hNullDC, VCursor.Width, VCursor.Height);}
hOldMainBitmap      := HBITMAP(SelectObject(hMainDC,   hSourceBitmap ));
hOldAndMaskBitmap	:= HBITMAP(SelectObject(hAndMaskDC,hAndMaskBitmap));
hOldXorMaskBitmap	:= HBITMAP(SelectObject(hXorMaskDC,hXorMaskBitmap));

for x := 0 to bm.bmWidth - 1 do // why not VCursor.Width ?
	begin
	for y := 0 to bm.bmHeight - 1 do // why not VCursor.Height ?
		begin
		MainBitPixel := GetPixel(hMainDC, x, y);
		if (VCursor = nil) or (VCursor.Channels = 3) then
			if(MainBitPixel = clrTransparent) then
				SetPixels(RGB(255,255,255){and mask}, RGB(0,0,0){xor mask})
			else
				SetPixels(RGB(0,0,0){and mask}, MainBitPixel{xor mask})
		else
			begin
			alpha := VCursor.BitMap[(x + y * VCursor.Width) * 4 + 3];
			if (alpha < 150) then
				SetPixels(RGB(255,255,255){and mask}, RGB(0,0,0){xor mask})
			else
				SetPixels(RGB(0,0,0){and mask}, RGB(alpha, alpha, alpha){xor mask});
			end;
		end;
	end;

{SelectObject(hMainDC,   hOldMainBitmap);
SelectObject(hAndMaskDC,hOldAndMaskBitmap);
SelectObject(hXorMaskDC,hOldXorMaskBitmap);}
SelectObject(hMainDC,   0);
SelectObject(hAndMaskDC,0);
SelectObject(hXorMaskDC,0);

if (bm.bmBits <> nil) then
	FreeMem(bm.bmBits);
FillChar(bm, SizeOf(bm), 0);

DeleteDC(hXorMaskDC);
DeleteDC(hAndMaskDC);
DeleteDC(hMainDC);

ReleaseDC(0, hNullDC);
end;

function SGWinAPICreateCursorFromBitmap(const VCursor : TSGCursor;const hSourceBitmap : HBITMAP;const clrTransparent : COLORREF;const xHotspot : DWORD;const yHotspot : DWORD) : HCURSOR;
var
	hAndMask : HBITMAP = 0;
	hXorMask : HBITMAP = 0;
	iconinfo : _ICONINFO;
begin
Result := 0;

if(0 = hSourceBitmap) then
	Exit;

SGWinAPIGetMaskBitmaps(VCursor, hSourceBitmap, clrTransparent, hAndMask, hXorMask);
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
iconinfo.fIcon      := False;
iconinfo.xHotspot   := xHotspot;
iconinfo.yHotspot   := yHotspot;
iconinfo.hbmMask    := hAndMask; // hXorMask ?
iconinfo.hbmColor   := hXorMask;
//iconinfo.hbmColor   := hSourceBitmap; // ?

Result := CreateIconIndirect(@iconinfo);
end;

function SGWinAPICreateCursor(const VCursor : TSGCursor;const clrTransparent : COLORREF):HCURSOR;
var
	hBM : HBITMAP;
	bm : PByte = nil;
	w, h, Index : TSGMaxEnum;
begin
Result := 0;
hBM := CreateCompatibleBitmap(GetDC(0), VCursor.Width, VCursor.Height);
bm := GetMem(VCursor.Width * VCursor.Height * VCursor.Channels);
for h := 0 to VCursor.Height - 1 do
	for w := 0 to VCursor.Width - 1 do
		begin
		Index := h * VCursor.Width + w;
		if (VCursor.Channels = 4) then
			PSGPixel3b(bm)[Index] := TSGPixel3b(PSGPixel4b(VCursor.BitMap)[Index])
		else
			PSGPixel3b(bm)[Index] := PSGPixel3b(VCursor.BitMap)[Index];
		end;
SetBitmapBits(hBM, VCursor.Width * VCursor.Height * VCursor.Channels, bm);
FreeMem(bm);
Result := SGWinAPICreateCursorFromBitmap(VCursor, hBM, clrTransparent, VCursor.HotPixelX, VCursor.HotPixelY);
DeleteObject(hBM);
end;

end.
