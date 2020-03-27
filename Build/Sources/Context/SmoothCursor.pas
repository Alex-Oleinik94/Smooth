{$INCLUDE Smooth.inc}

unit SmoothCursor;

interface

uses
		// Engine
	 SmoothBase
	,SmoothBitMap
	,SmoothCommon
	,SmoothCommonStructs
		// System
	,Classes
	;

type
	TSCursorHandle = type TSUInt32;

const
	SC_NULL = 0;
	SC_APPSTARTING = 32650;
	SC_NORMAL = 32512;
	SC_CROSS = 32515;
	SC_HAND = 32649;
	SC_HELP = 32651;
	SC_IBEAM = 32513;
	SC_NO = 32648;
	SC_SIZEALL = 32646;
	SC_SIZENESW = 32643;
	SC_SIZENS = 32645;
	SC_SIZENWSE = 32642;
	SC_SIZEWE = 32644;
	SC_UP = 32516;
	SC_WAIT = 32514;
	SC_GLASSY = 20000;

type
	TSHotPixelType = TSPoint2int32;
	TSHotPixelValueType = TSInt32;
	
	TSCursor = class(TSBitMap)
			public
		constructor Create(); override;
		constructor Create(const VStandartCursor : TSCursorHandle); virtual;
		function LoadFrom(const VFileName : TSString; const HotX : TSFloat = 0; const HotY : TSFloat = 0) : TSCursor; virtual;
		class function Copy(const VCursor : TSCursor) : TSCursor;
		procedure CopyFrom(const VCursor : TSCursor);
		procedure Clear(); override;
			private
		FHotPixel : TSHotPixelType;
		FStandartCursor : TSCursorHandle;
			public
		property HotPixelX : TSHotPixelValueType read FHotPixel.x write FHotPixel.x;
		property HotPixelY : TSHotPixelValueType read FHotPixel.y write FHotPixel.y;
		property HotPixel : TSHotPixelType read FHotPixel write FHotPixel;
		property StandartHandle : TSCursorHandle read FStandartCursor;
		end;

procedure SKill(var _Cursor : TSCursor); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SCreateCursorFromFile(const _FileName : TSString) : TSCursor;
function SLoadCursorFromStream(const _Stream : TStream; const _FileName : TSString = '') : TSCursor;

implementation

uses
		// Engine
	 SmoothBitMapUtils
	,SmoothLog
	,SmoothResourceManager
		// Cursor file formats
	,SmoothImageICO // .cur
	;

function SLoadCursorFromStream(const _Stream : TStream; const _FileName : TSString = '') : TSCursor;
begin
_Stream.Position := 0;
if SIsICOData(_Stream) then
	begin
	SLog.Source(['SLoadCursorFromStream: Determined format "cur" for "', _FileName, '".']);
	Result := SLoadCUR(_Stream);
	end
else
	SLog.Source(['SLoadCursorFromStream: Unsupported cursor file format "', _FileName, '".']);
end;

function SCreateCursorFromFile(const _FileName : TSString) : TSCursor;
var
	Stream : TMemoryStream;
begin
Stream := TMemoryStream.Create();
if SResourceFiles.LoadMemoryStreamFromFile(Stream, _FileName) then
	Result := SLoadCursorFromStream(Stream, _FileName)
else
	SLog.Source(['SCreateCursorFromFile: Can''t load data from "', _FileName, '".']);
SKill(Stream);
end;

procedure SKill(var _Cursor : TSCursor); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (_Cursor <> nil) then
	begin
	_Cursor.Destroy();
	_Cursor := nil;
	end;
end;

procedure TSCursor.CopyFrom(const VCursor : TSCursor);
begin
(Self as TSBitMap).CopyFrom(VCursor as TSBitMap);
FHotPixel       := VCursor.FHotPixel;
FStandartCursor := VCursor.FStandartCursor;
end;

class function TSCursor.Copy(const VCursor : TSCursor):TSCursor;
begin
Result := TSCursor.Create();
Result.CopyFrom(VCursor);
end;

function TSCursor.LoadFrom(const VFileName : TSString; const HotX : TSFloat = 0; const HotY : TSFloat = 0) : TSCursor;
var
	Image : TSBitMap;
begin
Image := SLoadBitMapFromFile(VFileName);

(Self as TSBitMap).CopyFrom(Image);
HotPixelX := Trunc(HotX * Width );
HotPixelY := Trunc(HotY * Height);

SKill(Image);

Result := Self;
end;

constructor TSCursor.Create();
begin
inherited Create();
//Clear(); allready in TSBitMap
end;

constructor TSCursor.Create(const VStandartCursor : TSCursorHandle);
begin
Create();
FStandartCursor := VStandartCursor;
end;

procedure TSCursor.Clear();
begin
inherited;
FHotPixel.Import(0, 0);
FStandartCursor := SC_NULL;
end;

end.
