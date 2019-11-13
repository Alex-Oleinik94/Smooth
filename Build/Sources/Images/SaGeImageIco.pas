//Спецификация форматов ICO и CUR найдены в онлайн-библиотеке Wikipedia

{$INCLUDE SaGe.inc}

unit SaGeImageICO;

interface

uses
	 SaGeBitMap
	,SaGeBase
	,SaGeCursor
	
	,Classes
	;

type
	TSGIcoFileType = TSGUInt16;
const
	SGIcoFile = 1;
	SGCurFile = 2;
type
	TSGIcoFileHeader = object
			public
		FReserved : TSGUInt16; // Reserved. Must always be 0.
		FType : TSGUInt16; // SGIcoFile or SGCurFile (type TSGIcoFileType)
		FCount : TSGUInt16; // Specifies number of images in the file.
		end;
	PSGIcoFileHeader = ^ TSGIcoFileHeader;
	
	TSGIcoImageHeader = object // include CUR
			public
		FWidth : TSGUInt8;
		FHeight : TSGUInt8;
		FColors : TSGUInt8; // Specifies number of colors in the color palette. Should be 0 if the image does not use a color palette.
		FReserved : TSGUInt8; // Reserved. Should be 0
		FPlanes : TSGUInt16; // In ICO format: Specifies color planes. Should be 0 or 1.
							 // In CUR format: Specifies the horizontal coordinates of the hotspot in number of pixels from the left.
		FBpp : TSGUInt16; // In ICO format: Specifies bits per pixel. 
						  //      16, 24 or 32 bit per pixel
						  //      256, 60 and 2 colors (fixed palette)
						  // In CUR format: Specifies the vertical coordinates of the hotspot in number of pixels from the top.
		FSize : TSGUInt32; // Specifies the size of the image's data in bytes
		FOffset : TSGUInt32; // Specifies the offset of BMP or PNG data from the beginning of the ICO/CUR file
		end;
	
	TSGIcoImageDataType = (SGIcoImageNullData, SGIcoImageBMPData, SGIcoImagePNG, SGIcoImageJpeg);
	
	TSGIcoImage = object
			public
		FHeader : TSGIcoImageHeader;
		FData : TMemoryStream; // BMP or PNG data
			public
		function DataType() : TSGIcoImageDataType;
		end;
	PSGIcoImage = ^ TSGIcoImage;
	
	TSGIcoImageList = packed array of TSGIcoImage;
	
	TSGIcoFile = object
			public
		FHeader : TSGIcoFileHeader;
		FImages : TSGIcoImageList;
			public
		constructor Create();
		destructor Destroy();
		procedure Load(const _Stream : TStream);
		procedure Save(const _Stream : TStream);
		end;
	PSGIcoFile = ^ TSGIcoFile;

function SGSaveICO(const _Stream : TStream; const _Image : TSGBitMap) : TSGBoolean; overload;
function SGSaveCUR(const _Stream : TStream; const _Cursor : TSGCursor) : TSGBoolean; overload;
function SGLoadICO(const _Stream : TStream; var _Image : TSGBitMap; const _ImageNumber : TSGUInt32 = 0) : TSGBoolean; overload;
function SGLoadICO(const _Stream : TStream; const _ImageNumber : TSGUInt32 = 0) : TSGBitMap; overload;
function SGLoadCUR(const _Stream : TStream; var _Cursor : TSGCursor; const _CursorNumber : TSGUInt32 = 0) : TSGBoolean; overload;
function SGLoadCUR(const _Stream : TStream; const _CursorNumber : TSGUInt32 = 0) : TSGCursor; overload;
function SGLoadICOImage(const _IcoFile : PSGIcoFileHeader; const _IcoImage : PSGIcoImage; const _Image : TSGBitMap) : TSGBoolean; overload;
function SGIcoImageExpansionFromDataType(const _DataType : TSGIcoImageDataType) : TSGString;
function SGIsICOData(const _Stream : TStream) : TSGBoolean;
function SGCopyIcoImageProperties(const _IcoFile : PSGIcoFileHeader; const _IcoImage : PSGIcoImage; const _Image : TSGBitMap) : TSGBoolean;

implementation

uses
	 SaGeStreamUtils
	,SaGeStringUtils
	,SaGeImageFormatDeterminer
	,SaGeImageBmp // BMP
	,SaGeImageJpeg // Jpeg
	,SaGeResourceManager // PNG and "others"
	,SaGeCommonStructs
	,SaGeLog
	,SaGeMathUtils
	,SaGeBitMapUtils
	
	,SysUtils
	;

type
	TSGResourceManipulatorImagesICO = class(TSGResourceManipulator)
			public
		constructor Create();override;
		function LoadResourceFromStream(const VStream : TStream; const VExpansion : TSGString) : TSGResource; override;
		function SaveResourceToStream(const VStream : TStream; const VExpansion : TSGString; const VResource : TSGResource) : TSGBoolean; override;
		end;

constructor TSGResourceManipulatorImagesICO.Create();
begin
inherited;
AddExpansion('ICO', True{LoadIsSupported}, False{SaveIsSupported});
AddExpansion('CUR', True{LoadIsSupported}, False{SaveIsSupported});
end;

function TSGResourceManipulatorImagesICO.LoadResourceFromStream(const VStream : TStream; const VExpansion : TSGString) : TSGResource;
var
	ExpansionUpCase : TSGString;
begin
ExpansionUpCase := SGUpCaseString(VExpansion);
if (ExpansionUpCase = 'ICO') then
	Result := SGLoadICO(VStream)
else if (ExpansionUpCase = 'CUR') then
	Result := SGLoadCUR(VStream)
else
	Result := nil;
end;

function TSGResourceManipulatorImagesICO.SaveResourceToStream(const VStream : TStream; const VExpansion : TSGString; const VResource : TSGResource) : TSGBoolean;
var
	ExpansionUpCase : TSGString;
begin
ExpansionUpCase := SGUpCaseString(VExpansion);
if (ExpansionUpCase = 'ICO') then
	Result := SGSaveICO(VStream, VResource as TSGBitMap)
else if (ExpansionUpCase = 'CUR') then
	Result := SGSaveCUR(VStream, VResource as TSGCursor)
else
	Result := False;
end;

//======================================================================
//======================================================================
//======================================================================

constructor TSGIcoFile.Create();
begin
FillChar(FHeader, SizeOf(FHeader), 0);
FImages := nil;
end;

destructor TSGIcoFile.Destroy();
var
	Index : TSGMaxEnum;
begin
FillChar(FHeader, SizeOf(FHeader), 0);
for Index := 0 to High(FImages) do
	begin
	if (FImages[Index].FData <> nil) then
		FImages[Index].FData.Destroy();
	FillChar(FImages[Index], SizeOf(FImages[Index]), 0);
	end;
SetLength(FImages, 0);
FImages := nil;
end;

procedure TSGIcoFile.Load(const _Stream : TStream);
var
	Index : TSGMaxEnum;
begin
_Stream.Position := 0;
_Stream.ReadBuffer(FHeader, SizeOf(FHeader));
SetLength(FImages, FHeader.FCount);
FillChar(FImages[0], SizeOf(FImages[0]) * FHeader.FCount, 0);
SGLog.Source(['TSGIcoFile__Load: Images count = "', FHeader.FCount, '".']);
for Index := 0 to FHeader.FCount - 1 do
	begin
	_Stream.ReadBuffer(FImages[Index].FHeader, SizeOf(FImages[Index].FHeader));
	SGLog.Source(['TSGIcoFile__Load: Image[', Index, '].Size = "', FImages[Index].FHeader.FSize, '" (', SGGetSizeString(FImages[Index].FHeader.FSize, 'EN'), ').']);
	SGLog.Source(['TSGIcoFile__Load: Image[', Index, '].Offset = "', FImages[Index].FHeader.FOffset, '".']);
	end;
for Index := 0 to FHeader.FCount - 1 do
	begin
	if (FImages[Index].FHeader.FSize <> 0) then
		begin
		FImages[Index].FData := TMemoryStream.Create();
		_Stream.Position := FImages[Index].FHeader.FOffset;
		SGCopyPartStreamToStream(_Stream, FImages[Index].FData, FImages[Index].FHeader.FSize);
		end;
	end;
end;

procedure TSGIcoFile.Save(const _Stream : TStream);
var
	Index : TSGMaxEnum;
begin
_Stream.WriteBuffer(FHeader, SizeOf(FHeader));
for Index := 0 to High(FImages) do
	begin
	_Stream.WriteBuffer(FImages[Index].FHeader, SizeOf(FImages[Index].FHeader));
	if (FImages[Index].FHeader.FSize <> 0) then
		begin
		FImages[Index].FData.Position := 0;
		SGCopyPartStreamToStream(FImages[Index].FData, _Stream, FImages[Index].FHeader.FSize);
		end;
	end;
end;

function TSGIcoImage.DataType() : TSGIcoImageDataType;
begin
FData.Position := 0;
if TSGImageFormatDeterminer.IsJpeg(FData) then
	Result := SGIcoImageJpeg
else if TSGImageFormatDeterminer.IsPNG(FData) then
	Result := SGIcoImagePNG
else // BMP image data without header
	Result := SGIcoImageBMPData;
FData.Position := 0;
end;

function SGIcoImageExpansionFromDataType(const _DataType : TSGIcoImageDataType) : TSGString;
begin
case _DataType of
SGIcoImageBMPData : Result := 'bmp';
SGIcoImagePNG : Result := 'png';
SGIcoImageJpeg : Result := 'jpeg';
else Result := '';
end;
end;

//======================================================================
//======================================================================
//======================================================================

function SGLoadICOImage(const _IcoFile : PSGIcoFileHeader; const _IcoImage : PSGIcoImage; const _Image : TSGBitMap) : TSGBoolean; overload;
var
	ImageDataType : TSGIcoImageDataType;
	FileExpansion : TSGString;
	LoadedImage : TSGBitMap = nil;
	// fixed palette: 256, 60 or 2 (number colors); may be 16 colors?
	ColorPlanes : TSGUInt16 = 0; // Should be 0 or 1 (or 255(icon encoder built into .NET (System.Drawing.Icon.Save)))
	BitsPerPixel : TSGUInt16 = 0; // Should be 16, 24 or 32 (bit per pixel)
	HaveAdditionalProperties : TSGBoolean = False; // is ".ico" (not ".cur")
	Index : TSGMaxEnum;
	B : TSGUInt8;

function IcoGetColor16(const _ColorNumber : TSGUInt8) : TSGPixel3b;
begin
case _ColorNumber of
00: Result.Import(0, 0, 0);       // black
01: Result.Import(0, 0, 127);     // blue
02: Result.Import(0, 127, 0);     // green
03: Result.Import(127, 127, 0);   // yellow(+)
04: Result.Import(127, 0, 0);     // red
05: Result.Import(127, 0, 127);   // magenta
06: Result.Import(0, 127, 127);   // azure
07: Result.Import(127, 127, 127); // gray
08: Result.Import(64, 64, 64);    // taupe
09: Result.Import(0, 0, 255);     // bright blue
10: Result.Import(0, 255, 0);     // bright green
11: Result.Import(255, 255, 0);   // bright yellow(+)
12: Result.Import(255, 0, 0);     // bright red
13: Result.Import(255, 0, 255);   // bright magenta
14: Result.Import(0, 255, 255);   // bright azure
15: Result.Import(255, 255, 255); // white
else Result.Import(0, 0, 0);
end;
end;

begin
ImageDataType := _IcoImage^.DataType();
SGLog.Source(['SGLoadICOImage: Determined format "', SGIcoImageExpansionFromDataType(ImageDataType), '".']);
case ImageDataType of
SGIcoImageBMPData :
	begin
	HaveAdditionalProperties := (_IcoFile <> nil) and (_IcoFile^.FType = SGIcoFile);
	if (not HaveAdditionalProperties) or (_Image.Channels * _Image.ChannelSize <> 0) then
		begin
		_Image.CreateTypes();
		_Image.ReAllocateMemory();
		//SGLog.Source(['SGLoadICOImage: BitMap data size = "', _Image.DataSize(), '".']);
		//SGLog.Source(['SGLoadICOImage: ICO image data size = "', _IcoImage^.FData.Size, '".']);
		Move(_IcoImage^.FData.Memory^, _Image.BitMap^, _Image.DataSize()); // may be "Min(TSGUInt64(_IcoImage^.FData.Size), _Image.DataSize())" ?
		SGBGRAToRGBAImage(_Image);
		Result := True;
		end
	else if HaveAdditionalProperties then
		begin
		BitsPerPixel := _IcoImage^.FHeader.FBpp;
		ColorPlanes := _IcoImage^.FHeader.FPlanes;
		if (BitsPerPixel = 4) and (ColorPlanes = 1) then
			begin
			_Image.Channels := 3;
			_Image.ChannelSize := 8;
			_Image.CreateTypes();
			_Image.ReAllocateMemory();
			_IcoImage^.FData.Position := 0;
			for Index := 0 to ((_Image.Width * _Image.Height) div 2) - 1 do
				begin
				_IcoImage^.FData.ReadBuffer(B, 1);
				PSGPixel3b(_Image.BitMap)[Index * 2 + 0] := IcoGetColor16(B and $0F);
				PSGPixel3b(_Image.BitMap)[Index * 2 + 1] := IcoGetColor16((B and $F0) shr 4)
				end;
			end;
		end
	else SGLog.Source(['SGLoadICOImage: Couldn''t load BMP data from ICO container.']);
	end;
SGIcoImageJpeg :
	begin
	LoadedImage := TSGBitMap.Create();
	LoadJPEGToBitMap(_IcoImage^.FData, LoadedImage);
	Result := LoadedImage.DataSize() <> 0;
	if Result then
		_Image.CopyFrom(LoadedImage);
	SGKill(LoadedImage);
	end;
SGIcoImagePNG :
	begin
	_IcoImage^.FData.Position := 0;
	FileExpansion := TSGImageFormatDeterminer.DetermineExpansion(_IcoImage^.FData);
	_IcoImage^.FData.Position := 0;
	if SGResourceManager.LoadingIsSupported(FileExpansion) then
		begin
		LoadedImage := SGResourceManager.LoadResourceFromStream(_IcoImage^.FData, FileExpansion) as TSGBitMap;
		Result := (LoadedImage <> nil) and (LoadedImage.DataSize() <> 0);
		if Result then
			_Image.CopyFrom(LoadedImage);
		SGKill(LoadedImage);
		end;
	end;
else
	SGLog.Source(['SGLoadICOImage: Unknown image data format.']);
end;
end;

function SGCopyIcoImageProperties(const _IcoFile : PSGIcoFileHeader; const _IcoImage : PSGIcoImage; const _Image : TSGBitMap) : TSGBoolean;
var
	// fixed palette: 256, 60 or 2 (number colors); may be 16 colors?
	ColorPlanes : TSGUInt16 = 0; // Should be 0 or 1 (or 255(icon encoder built into .NET (System.Drawing.Icon.Save)))
	BitsPerPixel : TSGUInt16 = 0; // Should be 16, 24 or 32 (bit per pixel)
	HaveAdditionalProperties : TSGBoolean = False; // is ".ico" (not ".cur")
begin
Result := False;
HaveAdditionalProperties := (_IcoFile <> nil) and (_IcoFile^.FType = SGIcoFile);
if HaveAdditionalProperties then
	begin
	BitsPerPixel := _IcoImage^.FHeader.FBpp;
	ColorPlanes := _IcoImage^.FHeader.FPlanes;
	SGLog.Source(['SGCopyIcoImageProperties: BitsPerPixel = "', BitsPerPixel, '"; ColorPlanes = "', ColorPlanes, '".']);
	end;

_Image.Width := _IcoImage^.FHeader.FWidth;
_Image.Height := _IcoImage^.FHeader.FHeight;
_Image.ChannelSize := 0;
_Image.Channels := 0;
if (not HaveAdditionalProperties) then
	begin
	// DataSize = Width * Height * Channels (if ChannelSize = 8 bit)
	// Channels = DataSize / (Width * Height)
	_Image.ChannelSize := 8;
	_Image.Channels := Trunc(_IcoImage^.FHeader.FSize / (_Image.Width * _Image.Height));
	// _IcoImage^.FHeader.FBpp
	//      In CUR format: Specifies the vertical coordinates of the hotspot in number of pixels from the top.
	//      In ICO (may be)
	//           DataSize = Width * Height * (BitsPerPixel div 8)
	//           BitsPerPixel = ChannelSize * Channels
	end
else
	begin
	if (BitsPerPixel = 24) then
		begin
		_Image.ChannelSize := 8;
		_Image.Channels := 3;
		end
	else if (BitsPerPixel = 32) then
		begin
		_Image.ChannelSize := 8;
		_Image.Channels := 4;
		end
	else if ((ColorPlanes = 1) or (ColorPlanes = 0)) then
		begin
		_Image.ChannelSize := BitsPerPixel;
		_Image.Channels := 0;
		end;
	end;
Result := (_Image.Width * _Image.Height) <> 0;
SGLog.Source(['SGCopyIcoImageProperties(Result=', Result, '): Width = "', _Image.Width, '"; Height = "', _Image.Height, '"; Channels = "', _Image.Channels, '"; ChannelSize = "', _Image.ChannelSize, '".']);
end;

function SGLoadCUR(const _Stream : TStream; var _Cursor : TSGCursor; const _CursorNumber : TSGUInt32 = 0) : TSGBoolean; overload;
var
	IcoFile : TSGIcoFile;
	CursorImage : PSGIcoImage = nil;
begin
if (_Cursor = nil) then
	_Cursor := TSGCursor.Create()
else
	_Cursor.Clear();
Result := False;
IcoFile.Create();
IcoFile.Load(_Stream);
CursorImage := @IcoFile.FImages[_CursorNumber];
if (CursorImage <> nil) then
	begin
	Result := SGCopyIcoImageProperties(@IcoFile, CursorImage, _Cursor);
	if Result then
		Result := SGLoadICOImage(@IcoFile, CursorImage, _Cursor);
	if Result then
		_Cursor.HotPixel := SGVertex2int32Import(CursorImage^.FHeader.FPlanes, CursorImage^.FHeader.FBpp);
	CursorImage := nil;
	end;
IcoFile.Destroy();
FillChar(IcoFile, SizeOf(IcoFile), 0);
end;

function SGIsICOData(const _Stream : TStream) : TSGBoolean;
var
	IcoHeader_Reserved : TSGUInt16; // Reserved. Must always be 0.
	IcoHeader_Type : TSGUInt16; // SGIcoFile(1) or SGCurFile(2) (type TSGIcoFileType)
begin
Result := False;
if (_Stream <> nil) then
	begin
	_Stream.Position := 0;
	_Stream.ReadBuffer(IcoHeader_Reserved, SizeOf(IcoHeader_Reserved));
	_Stream.ReadBuffer(IcoHeader_Type, SizeOf(IcoHeader_Type));
	Result := (IcoHeader_Reserved = 0) and ((IcoHeader_Type = SGIcoFile) or (IcoHeader_Type = SGCurFile));
	_Stream.Position := 0;
	end;
end;

function SGLoadICO(const _Stream : TStream; var _Image : TSGBitMap; const _ImageNumber : TSGUInt32 = 0) : TSGBoolean; overload;
var
	IcoFile : TSGIcoFile;
	ICOImage : PSGIcoImage = nil;
begin
if (_Image = nil) then
	_Image := TSGBitMap.Create()
else
	_Image.Clear();
Result := False;
IcoFile.Create();
IcoFile.Load(_Stream);
ICOImage :=  @IcoFile.FImages[_ImageNumber];
if (ICOImage <> nil) then
	begin
	Result := SGCopyIcoImageProperties(@IcoFile, ICOImage, _Image);
	if Result then
		Result := SGLoadICOImage(@IcoFile, ICOImage, _Image);
	ICOImage := nil;
	end;
IcoFile.Destroy();
FillChar(IcoFile, SizeOf(IcoFile), 0);
end;

function SGLoadICO(const _Stream : TStream; const _ImageNumber : TSGUInt32 = 0) : TSGBitMap; overload;
begin
Result := TSGBitMap.Create();
if (not SGLoadICO(_Stream, Result, _ImageNumber)) then
	SGKill(Result);
end;

function SGLoadCUR(const _Stream : TStream; const _CursorNumber : TSGUInt32 = 0) : TSGCursor; overload;
begin
Result := TSGCursor.Create();
if (not SGLoadCUR(_Stream, Result, _CursorNumber)) then
	SGKill(Result);
end;

function SGSaveICO(const _Stream : TStream; const _Image : TSGBitMap) : TSGBoolean; overload;
begin
Result := False;
if (_Image <> nil) then // is necessary
	begin
	//todo
	end;
end;

function SGSaveCUR(const _Stream : TStream; const _Cursor : TSGCursor) : TSGBoolean; overload;
begin
Result := False;
if (_Cursor <> nil) then // is necessary
	begin
	//todo
	end;
end;

initialization
begin
SGResourceManager.AddManipulator(TSGResourceManipulatorImagesICO);
end;

end.
