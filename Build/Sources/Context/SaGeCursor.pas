{$INCLUDE SaGe.inc}

unit SaGeCursor;

interface

uses
	 SaGeBase
	,SaGeBitMap
	,SaGeCommon
	,SaGeCommonStructs
	;

type
	TSGCursorHandle = type TSGUInt32;

const
	SGC_NULL = 0;
	SGC_APPSTARTING = 32650;
	SGC_NORMAL = 32512;
	SGC_CROSS = 32515;
	SGC_HAND = 32649;
	SGC_HELP = 32651;
	SGC_IBEAM = 32513;
	SGC_NO = 32648;
	SGC_SIZEALL = 32646;
	SGC_SIZENESW = 32643;
	SGC_SIZENS = 32645;
	SGC_SIZENWSE = 32642;
	SGC_SIZEWE = 32644;
	SGC_UP = 32516;
	SGC_WAIT = 32514;
	SGC_GLASSY = 20000;

type
	TSGHotPixelType = TSGPoint2int32;
	TSGHotPixelValueType = TSGInt32;
	
	TSGCursor = class(TSGBitMap)
			public
		constructor Create(); override;
		constructor Create(const VStandartCursor : TSGCursorHandle); virtual;
		function LoadFrom(const VFileName : TSGString; const HotX : TSGFloat = 0; const HotY : TSGFloat = 0) : TSGCursor; virtual;
		class function Copy(const VCursor : TSGCursor) : TSGCursor;
		procedure CopyFrom(const VCursor : TSGCursor);
		procedure Clear(); override;
			private
		FHotPixel : TSGHotPixelType;
		FStandartCursor : TSGCursorHandle;
			public
		property HotPixelX : TSGHotPixelValueType read FHotPixel.x write FHotPixel.x;
		property HotPixelY : TSGHotPixelValueType read FHotPixel.y write FHotPixel.y;
		property HotPixel : TSGHotPixelType read FHotPixel write FHotPixel;
		property StandartHandle : TSGCursorHandle read FStandartCursor;
		end;

procedure SGKill(var _Cursor : TSGCursor); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SaGeBitMapUtils
	;

procedure SGKill(var _Cursor : TSGCursor); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (_Cursor <> nil) then
	begin
	_Cursor.Destroy();
	_Cursor := nil;
	end;
end;

procedure TSGCursor.CopyFrom(const VCursor : TSGCursor);
begin
(Self as TSGBitMap).CopyFrom(VCursor as TSGBitMap);
FHotPixel       := VCursor.FHotPixel;
FStandartCursor := VCursor.FStandartCursor;
end;

class function TSGCursor.Copy(const VCursor : TSGCursor):TSGCursor;
begin
Result := TSGCursor.Create();
Result.CopyFrom(VCursor);
end;

function TSGCursor.LoadFrom(const VFileName : TSGString; const HotX : TSGFloat = 0; const HotY : TSGFloat = 0) : TSGCursor;
var
	Image : TSGBitMap;
begin
Image := SGLoadBitMapFromFile(VFileName);

(Self as TSGBitMap).CopyFrom(Image);
HotPixelX := Trunc(HotX * Width );
HotPixelY := Trunc(HotY * Height);

SGKill(Image);

Result := Self;
end;

constructor TSGCursor.Create();
begin
inherited Create();
//Clear(); allready in TSGBitMap
end;

constructor TSGCursor.Create(const VStandartCursor : TSGCursorHandle);
begin
Create();
FStandartCursor := VStandartCursor;
end;

procedure TSGCursor.Clear();
begin
inherited;
FHotPixel.Import(0, 0);
FStandartCursor := SGC_NULL;
end;

end.
