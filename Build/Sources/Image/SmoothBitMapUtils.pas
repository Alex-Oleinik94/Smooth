{$INCLUDE Smooth.inc}

unit SmoothBitMapUtils;

interface

uses
	 SmoothBase
	,SmoothBitMap
	,SmoothBitMapBase
	,SmoothImageFormatDeterminer
	
	,Classes
	;

function SDefaultSaveImageFormat() : TSImageFormat; overload;
function SDefaultSaveImageFormat(const _Channels : TSUInt8) : TSImageFormat; overload;

function SSaveBitMapToFile(const _Image : TSBitMap; const _FileName : TSString; const _Format : TSImageFormat = SImageFormatNull) : TSBoolean;
function SSaveBitMapToStream(const _Stream : TStream; const _Image : TSBitMap; const _Format : TSImageFormat = SImageFormatNull) : TSBoolean;
function SSaveBitMapAsSiaToStream(const _Stream : TStream; const _Image : TSBitMap) : TSBoolean;

function SLoadBitMapFromFile(const _FileName : TSString) : TSBitMap;
function SLoadBitMapFromStream(const _Stream : TStream; const _FileName : TSString = '') : TSBitMap;

procedure SBitMapBGRAToRGBA(const _BitMap : TSBitMap);

implementation

uses
	 SmoothFileUtils
	,SmoothResourceManager
	,SmoothLog
	,SmoothStringUtils
		// Image formats
	,SmoothImageBmp
	,SmoothImageJpeg
	,SmoothImagePng
	,SmoothImageTga
	,SmoothImageSia
	,SmoothImageIco
	,SmoothImageMbm
	;

procedure SBitMapBGRAToRGBA(const _BitMap : TSBitMap);
var
	Index : TSMaxEnum;
begin
if (_BitMap.Channels = 4) and (_BitMap.ChannelSize = 8) then
	for Index := 0 to _BitMap.Width * _BitMap.Height - 1 do
		PSPixel4b(_BitMap.Data)[Index] := SPixelBGRAToRGBA(PSPixel4b(_BitMap.Data)[Index]);
end;

function SLoadBitMapFromStream(const _Stream : TStream; const _FileName : TSString = '') : TSBitMap;
var
	ImageFormat : TSImageFormat = SImageFormatNull;
begin
_Stream.Position := 0;
ImageFormat := TSImageFormatDeterminer.DetermineFormat(_Stream);
if (ImageFormat = SImageFormatNull) and (_FileName <> '') and (SFileExtension(_FileName, True) = 'TGA') then
	ImageFormat := SImageFormatTga;
SLog.Source(['SLoadBitMapFromStream: Determined format "', TSImageFormatDeterminer.DetermineFileExtensionFromFormat(ImageFormat), '" for "', _FileName, '".']);
_Stream.Position := 0;
Result := TSBitMap.Create();
case ImageFormat of
SImageFormatTga:
	begin
	SKill(Result);
	Result := LoadTGA(_Stream);
	end;
SImageFormatJpeg:
	SLoadBitMapAsJpegToStream(_Stream, Result);
SImageFormatBmp:
	LoadBMP(_Stream, Result);
SImageFormatSIA:
	LoadSIAToBitMap(_Stream, Result);
SImageFormatIco, SImageFormatCur:
	SLoadICO(_Stream, Result);
SImageFormatMbm:
	Result := SLoadMBMFromStream(_Stream);
SImageFormatPng:
	if SResourceManager.LoadingIsSupported('PNG') and SupportedPNG() then
		begin
		SKill(Result);
		Result := SResourceManager.LoadResourceFromStream(_Stream, 'PNG') as TSBitMap;
		end;
SImageFormatNull : SLog.Source(['SLoadBitMapFromStream: Determining image format for "', _FileName, '" failed!'])
else SLog.Source(['SLoadBitMapFromStream: Unknown image format "' + _FileName + '"!'])
end;
end;

function SLoadBitMapFromFile(const _FileName : TSString) : TSBitMap;
var
	Stream  : TMemoryStream = nil;
begin
Result := nil;
Stream := TMemoryStream.Create();
SResourceFiles.LoadMemoryStreamFromFile(Stream, _FileName);
if (Stream.Size > 0) then
	begin
	Stream.Position:=0;
	Result := SLoadBitMapFromStream(Stream, _FileName);
	end;
SKill(Stream);
end;

function SDefaultSaveImageFormat(const _Channels : TSUInt8) : TSImageFormat; overload;
begin
case _Channels of
4 : if SupportedPNG() and SResourceManager.SaveingIsSupported('PNG') then
		Result := SImageFormatPNG
	else
		Result := SImageFormatSIA;
3 : if SupportedPNG() and SResourceManager.SaveingIsSupported('PNG') then
		Result := SImageFormatPNG
	else
		Result := SImageFormatJpeg;
else Result := SImageFormatJpeg
end;
end;

function SSaveBitMapAsSiaToStream(const _Stream : TStream; const _Image : TSBitMap) : TSBoolean;
var
	Image : TSBitMap;
begin
Result := False;
Image := TSBitMap.Create();
SaveSIA(_Stream, Image);
if (Image <> nil) then
	begin
	_Image.CopyFrom(Image);
	SKill(Image);
	Result := True;
	end;
end;

function SDefaultSaveImageFormat() : TSImageFormat; overload;
begin
Result := SImageFormatSIA;
end;

function SSaveBitMapToFile(const _Image : TSBitMap; const _FileName : TSString; const _Format : TSImageFormat = SImageFormatNull) : TSBoolean;
var
	Stream : TMemoryStream = nil;
begin
Stream := TMemoryStream.Create();
Result := SSaveBitMapToStream(Stream, _Image, _Format);
if Result then
	begin
	Stream.Position:=0;
	Stream.SaveToFile(SSetExtensionToFileName(_FileName, TSImageFormatDeterminer.DetermineFileExtensionFromFormat(_Format)));
	SKill(Stream);
	end;
end;

function SSaveBitMapToStream(const _Stream : TStream; const _Image : TSBitMap; const _Format : TSImageFormat = SImageFormatNull) : TSBoolean;
var
	SaveFormat : TSImageFormat;
begin
SaveFormat := _Format;
if (SaveFormat = SImageFormatNull) then
	SaveFormat := SDefaultSaveImageFormat();
Result := False;

case SaveFormat of
SImageFormatSIA : Result := SSaveBitMapAsSiaToStream(_Stream, _Image);
SImageFormatPNG :
	if SResourceManager.SaveingIsSupported('PNG') then
		Result := SResourceManager.SaveResourceToStream(_Stream, 'PNG', _Image)
	else if _Image.Channels = 4 then
		begin
		SaveFormat := SImageFormatSIA;
		SLog.Source('SSaveBitMapToStream: Save to PNG is impossible. Save format replaced to SIA.');
		end
	else
		begin
		SaveFormat := SImageFormatJpeg;
		SLog.Source('SSaveBitMapToStream: Save to PNG is impossible. Save format replaced to JPEG.');
		end;
SImageFormatIco, SImageFormatCur:
	Result := SSaveICO(_Stream, _Image);
SImageFormatJpeg :
	begin
	SSaveBitMapAsJpegToStream(_Stream, _Image);
	Result := True;
	end;
SImageFormatBmp :
	begin
	SaveBMP(_Image, _Stream);
	Result := True;
	end;
end;
end;

end.
