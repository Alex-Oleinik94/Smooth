{$INCLUDE SaGe.inc}

unit SaGeBitMapUtils;

interface

uses
	 SaGeBase
	,SaGeBitMap
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
function SGLoadMBMFromStream(const _Stream : TMemoryStream; const Position : TSGUInt32 = 20) : TSGBitMap; overload;
function SGLoadMBMFromStream(const _Stream : TStream) : TSGBitMap; overload;

function SGBGRAToRGBAPixel(const _Pixel : TSGPixel4b) : TSGPixel4b;
procedure SGBGRAToRGBAImage(const _Image : TSGBitMap);

implementation

uses
	 SaGeFileUtils
	,SaGeResourceManager
	,SaGeLog
	,SaGeStringUtils
	,SaGeStreamUtils
		// Image formats
	,SaGeImageBmp
	,SaGeImageJpeg
	,SaGeImagePng
	,SaGeImageTga
	,SaGeImageSgia
	,SaGeImageICO
	;

function SGBGRAToRGBAPixel(const _Pixel : TSGPixel4b) : TSGPixel4b;
begin
Result := _Pixel;
Result.r := _Pixel.b;
Result.b := _Pixel.r;
end;

procedure SGBGRAToRGBAImage(const _Image : TSGBitMap);
var
	Index : TSGMaxEnum;
begin
if (_Image.Channels = 4) and (_Image.ChannelSize = 8) then
	for Index := 0 to _Image.Width * _Image.Height - 1 do
		PSGPixel4b(_Image.BitMap)[Index] := SGBGRAToRGBAPixel(PSGPixel4b(_Image.BitMap)[Index]);
end;

function SGLoadMBMFromStream(const _Stream : TMemoryStream; const Position : TSGUInt32 = 20) : TSGBitMap; overload;
var
	I : TSGUInt32;
	Compression : TSGBoolean = False;
	BitsPerPixel : TSGUInt32;

function GetLongWordBack(const FileBits:PByte;const Position:TSGUInt32):TSGUInt32;
begin
Result:=FileBits[Position+3]+FileBits[Position+2]*256+FileBits[Position+1]*256*256+FileBits[Position]*256*256*256;
end;

function GetLongWord(const FileBits:PByte;const Position:TSGUInt32):TSGUInt32;
begin
Result:=FileBits[Position]+FileBits[Position+1]*256+FileBits[Position+2]*256*256+FileBits[Position+3]*256*256*256;
end;

begin
Result := TSGBitMap.Create();
try
	Result.Width:=GetLongWord(PByte(_Stream.Memory),Position+8);
	Result.Height:=GetLongWord(PByte(_Stream.Memory),Position+12);
	BitsPerPixel := GetLongWord(PByte(_Stream.Memory),Position+24);
	case BitsPerPixel of
	16:
		begin
		Result.ChannelSize:=4;
		Result.Channels:=4;
		end;
	24:
		begin
		Result.Channels:=3;
		Result.ChannelSize:=8;
		end;
	32:
		begin
		Result.Channels:=4;
		Result.ChannelSize:=8;
		end;
	else
		begin
		Result.Channels:=0;
		Result.ChannelSize:=0;
		end;
	end;
	Compression:=(GetLongWord(PByte(_Stream.Memory),Position+36)<>0);
	Result.ReAllocateMemory();
	Result.CreateTypes();
	case BitsPerPixel of
	24:
		begin
		if Compression then
			begin

			end
		else
			begin
			for i:=0 to Result.Width*Result.Height-1 do
				begin
				Result.BitMap[i*3+0]:=PByte(_Stream.Memory)[Position+40+i*3+2];
				Result.BitMap[i*3+1]:=PByte(_Stream.Memory)[Position+40+i*3+1];
				Result.BitMap[i*3+2]:=PByte(_Stream.Memory)[Position+40+i*3+0];
				end;
			end;
		end;
	16:
		begin

		end;
	8:
		begin

		end;
	end;
except
	Result.ClearBitMapBits();
	end;

	{writeln(Width);
	writeln(Height);
	writeln(BitMapBits);}
end;

function SGLoadMBMFromStream(const _Stream : TStream) : TSGBitMap; overload;
var
	Stream : TMemoryStream = nil;
begin
Stream := TMemoryStream.Create();
_Stream.Position := 0;
SGCopyPartStreamToStream(_Stream, Stream, _Stream.Size);
Stream.Position := 0;
Result := SGLoadMBMFromStream(Stream);
SGKill(Stream);
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
