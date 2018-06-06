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
//NIM_MODIFY

implementation

uses
	 SaGeLog
	;

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

procedure SGWinAPIGetMaskBitmaps(const VCursor : TSGCursor;const hSourceBitmap : HBITMAP;const clrTransparent : COLORREF; var hAndMaskBitmap : HBITMAP; var hXorMaskBitmap : HBITMAP);
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

function SGWinAPICreateCursorFromBitmap(const VCursor : TSGCursor;const hSourceBitmap : HBITMAP;const clrTransparent : COLORREF;const xHotspot : DWORD;const yHotspot : DWORD) : HCURSOR;
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

SGWinAPIGetMaskBitmaps(VCursor, hSourceBitmap, clrTransparent, hAndMask, hXorMask);
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

function SGWinAPICreateCursor(const VCursor : TSGCursor;const clrTransparent : COLORREF):HCURSOR;
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
Result := SGWinAPICreateCursorFromBitmap(VCursor, 	hBM, clrTransparent, VCursor.HotPixelX, VCursor.HotPixelY);
DeleteObject(hBM);
end;

end.
