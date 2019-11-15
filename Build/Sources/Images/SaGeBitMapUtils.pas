{$INCLUDE SaGe.inc}

unit SaGeBitMapUtils;

interface

uses
	 SaGeBase
	,SaGeBitMap
	,SaGeBitMapBase
	,SaGeImageFormatDeterminer
	
	,Classes
	;

function SGDefaultSaveImageFormat() : TSGImageFormat; overload;
function SGDefaultSaveImageFormat(const _Channels : TSGUInt8) : TSGImageFormat; overload;

function SGSaveBitMapToFile(const _Image : TSGBitMap; const _FileName : TSGString; const _Format : TSGImageFormat = SGImageFormatNull) : TSGBoolean;
function SGSaveBitMapToStream(const _Stream : TStream; const _Image : TSGBitMap; const _Format : TSGImageFormat = SGImageFormatNull) : TSGBoolean;
function SGSaveBitMapAsSgiaToStream(const _Stream : TStream; const _Image : TSGBitMap) : TSGBoolean;
procedure SGSaveBitMapAsJpegToStream(const _Stream : TStream; const _Image : TSGBitMap);

function SGLoadBitMapFromFile(const _FileName : TSGString) : TSGBitMap;
function SGLoadBitMapFromStream(const _Stream : TStream; const _FileName : TSGString = '') : TSGBitMap;

procedure SGBGRAToRGBAImage(const _Image : TSGBitMap);

implementation

uses
	 SaGeFileUtils
	,SaGeResourceManager
	,SaGeLog
	,SaGeStringUtils
		// Image formats
	,SaGeImageBmp
	,SaGeImageJpeg
	,SaGeImagePng
	,SaGeImageTga
	,SaGeImageSgia
	,SaGeImageIco
	,SaGeImageMbm
	;

procedure SGBGRAToRGBAImage(const _Image : TSGBitMap);
var
	Index : TSGMaxEnum;
begin
if (_Image.Channels = 4) and (_Image.ChannelSize = 8) then
	for Index := 0 to _Image.Width * _Image.Height - 1 do
		PSGPixel4b(_Image.BitMap)[Index] := SGPixelBGRAToRGBA(PSGPixel4b(_Image.BitMap)[Index]);
end;

function SGLoadBitMapFromStream(const _Stream : TStream; const _FileName : TSGString = '') : TSGBitMap;
var
	ImageFormat : TSGImageFormat = SGImageFormatNull;
begin
_Stream.Position := 0;
ImageFormat := TSGImageFormatDeterminer.DetermineFormat(_Stream);
if (ImageFormat = SGImageFormatNull) and (_FileName <> '') and (SGUpCaseString(SGFileExpansion(_FileName)) = 'TGA') then
	ImageFormat := SGImageFormatTga;
SGLog.Source(['SGLoadBitMapFromStream: Determined format "', TSGImageFormatDeterminer.DetermineExpansionFromFormat(ImageFormat), '" for "', _FileName, '".']);
_Stream.Position := 0;
Result := TSGBitMap.Create();
case ImageFormat of
SGImageFormatTga:
	begin
	SGKill(Result);
	Result := LoadTGA(_Stream);
	end;
SGImageFormatJpeg:
	LoadJPEGToBitMap(_Stream, Result);
SGImageFormatBmp:
	LoadBMP(_Stream, Result);
SGImageFormatSGIA:
	LoadSGIAToBitMap(_Stream, Result);
SGImageFormatIco, SGImageFormatCur:
	SGLoadICO(_Stream, Result);
SGImageFormatMbm:
	Result := SGLoadMBMFromStream(_Stream);
SGImageFormatPng:
	if SGResourceManager.LoadingIsSupported('PNG') and SupportedPNG() then
		begin
		SGKill(Result);
		Result := SGResourceManager.LoadResourceFromStream(_Stream, 'PNG') as TSGBitMap;
		end;
SGImageFormatNull : SGLog.Source(['SGLoadBitMapFromStream: Determining image format for "', _FileName, '" failed!'])
else SGLog.Source(['SGLoadBitMapFromStream: Unknown image format "' + _FileName + '"!'])
end;
end;

function SGLoadBitMapFromFile(const _FileName : TSGString) : TSGBitMap;
var
	Stream  : TMemoryStream = nil;
begin
Stream := TMemoryStream.Create();
SGResourceFiles.LoadMemoryStreamFromFile(Stream, _FileName);
Stream.Position:=0;
Result := SGLoadBitMapFromStream(Stream, _FileName);
SGKill(Stream);
end;

function SGDefaultSaveImageFormat(const _Channels : TSGUInt8) : TSGImageFormat; overload;
begin
case _Channels of
4 : if SupportedPNG() and SGResourceManager.SaveingIsSupported('PNG') then
		Result := SGImageFormatPNG
	else
		Result := SGImageFormatSGIA;
3 : if SupportedPNG() and SGResourceManager.SaveingIsSupported('PNG') then
		Result := SGImageFormatPNG
	else
		Result := SGImageFormatJpeg;
else Result := SGImageFormatJpeg
end;
end;

function SGSaveBitMapAsSgiaToStream(const _Stream : TStream; const _Image : TSGBitMap) : TSGBoolean;
var
	Image : TSGBitMap;
begin
Result := False;
Image := TSGBitMap.Create();
SaveSGIA(_Stream, Image);
if (Image <> nil) then
	begin
	_Image.CopyFrom(Image);
	SGKill(Image);
	Result := True;
	end;
end;

procedure SGSaveBitMapAsJpegToStream(const _Stream : TStream; const _Image : TSGBitMap);
var
	BmpStream : TMemoryStream = nil;
begin
BmpStream := TMemoryStream.Create();
SaveBMP(_Image, BmpStream);
BmpStream.Position:=0;
SaveJPEG(BmpStream, _Stream);
BmpStream.Destroy();
SGKill(BmpStream);
end;

function SGDefaultSaveImageFormat() : TSGImageFormat; overload;
begin
Result := SGImageFormatSGIA;
end;

function SGSaveBitMapToFile(const _Image : TSGBitMap; const _FileName : TSGString; const _Format : TSGImageFormat = SGImageFormatNull) : TSGBoolean;
var
	Stream : TMemoryStream = nil;
begin
Stream := TMemoryStream.Create();
Result := SGSaveBitMapToStream(Stream, _Image, _Format);
if Result then
	begin
	Stream.Position:=0;
	Stream.SaveToFile(SGSetExpansionToFileName(_FileName, TSGImageFormatDeterminer.DetermineExpansionFromFormat(_Format)));
	SGKill(Stream);
	end;
end;

function SGSaveBitMapToStream(const _Stream : TStream; const _Image : TSGBitMap; const _Format : TSGImageFormat = SGImageFormatNull) : TSGBoolean;
var
	SaveFormat : TSGImageFormat;
begin
SaveFormat := _Format;
if (SaveFormat = SGImageFormatNull) then
	SaveFormat := SGDefaultSaveImageFormat();
Result := False;

case SaveFormat of
SGImageFormatSGIA : Result := SGSaveBitMapAsSgiaToStream(_Stream, _Image);
SGImageFormatPNG :
	if ((not SupportedPNG()) or SGResourceManager.SaveingIsSupported('PNG')) then
		if _Image.Channels = 4 then
			begin
			SaveFormat := SGImageFormatSGIA;
			SGLog.Source('SGSaveBitMapToStream: Save to PNG is impossible. Save format replaced to SGIA.');
			end
		else
			begin
			SaveFormat := SGImageFormatJpeg;
			SGLog.Source('SGSaveBitMapToStream: Save to PNG is impossible. Save format replaced to JPEG.');
			end
	else
		SGResourceManager.SaveResourceToStream(_Stream, 'PNG', _Image);
SGImageFormatIco, SGImageFormatCur:
	Result := SGSaveICO(_Stream, _Image);
SGImageFormatJpeg :
	begin
	SGSaveBitMapAsJpegToStream(_Stream, _Image);
	Result := True;
	end;
SGImageFormatBmp :
	begin
	SaveBMP(_Image, _Stream);
	Result := True;
	end;
end;
end;

end.
