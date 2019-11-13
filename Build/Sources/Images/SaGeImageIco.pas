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
						  // In CUR format: Specifies the vertical coordinates of the hotspot in number of pixels from the top.
		FSize : TSGUInt32; // Specifies the size of the image's data in bytes
		FOffset : TSGUInt32; // Specifies the offset of BMP or PNG data from the beginning of the ICO/CUR file
		end;
	
	TSGIcoImageDataType = (SGIcoImageNullData, SGIcoImageBMPData, SGIcoImagePNG);
	
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
function SGLoadICOImage(const _IcoImage : PSGIcoImage; const _Image : TSGBitMap) : TSGBoolean; overload;
function SGIcoImageExpansionFromDataType(const _DataType : TSGIcoImageDataType) : TSGString;
function SGIsICOData(const _Stream : TStream) : TSGBoolean;
procedure SGCopyIcoImageProperties(const _IcoImage : PSGIcoImage; const _Image : TSGBitMap);

implementation

uses
	 SaGeStreamUtils
	,SaGeStringUtils
	,SaGeImageFormatDeterminer
	,SaGeImageBmp // BMP
	,SaGeResourceManager // PNG and others
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
if TSGImageFormatDeterminer.IsPNG(FData) then
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
else Result := '';
end;
end;

//======================================================================
//======================================================================
//======================================================================

function SGLoadICOImage(const _IcoImage : PSGIcoImage; const _Image : TSGBitMap) : TSGBoolean; overload;
var
	ImageDataType : TSGIcoImageDataType;
	FileExpansion : TSGString;
	LoadedImage : TSGBitMap = nil;
begin
ImageDataType := _IcoImage^.DataType();
SGLog.Source(['SGLoadICOImage: Determined format "', SGIcoImageExpansionFromDataType(ImageDataType), '".']);
case ImageDataType of
SGIcoImageBMPData :
	begin
	_Image.CreateTypes();
	_Image.ReAllocateMemory();
	//SGLog.Source(['SGLoadICOImage: BitMap data size = "', _Image.DataSize(), '".']);
	//SGLog.Source(['SGLoadICOImage: ICO image data size = "', _IcoImage^.FData.Size, '".']);
	Move(_IcoImage^.FData.Memory^, _Image.BitMap^, _Image.DataSize()); // may be "Min(TSGUInt64(_IcoImage^.FData.Size), _Image.DataSize())" ?
	SGBGRAToRGBAImage(_Image);
	Result := True;
	end;
else // SGIcoImagePNG
	begin
	_IcoImage^.FData.Position := 0;
	FileExpansion := TSGImageFormatDeterminer.DetermineExpansion(_IcoImage^.FData);
	_IcoImage^.FData.Position := 0;
	if SGResourceManager.LoadingIsSupported(FileExpansion) then
		begin
		LoadedImage := SGResourceManager.LoadResourceFromStream(_IcoImage^.FData, FileExpansion) as TSGBitMap;
		if (LoadedImage <> nil) then
			begin
			_Image.CopyFrom(LoadedImage);
			SGKill(LoadedImage);
			Result := True;
			end;
		end;
	end;
end;
end;

procedure SGCopyIcoImageProperties(const _IcoImage : PSGIcoImage; const _Image : TSGBitMap);
begin
_Image.Width := _IcoImage^.FHeader.FWidth;
_Image.Height := _IcoImage^.FHeader.FHeight;
// DataSize = Width * Height * Channels (if ChannelSize = 8 bit)
// Channels = DataSize / (Width * Height)
_Image.ChannelSize := 8;
_Image.Channels := Trunc(_IcoImage^.FHeader.FSize / (_Image.Width * _Image.Height));
// _IcoImage^.FHeader.FBpp
//      In CUR format: Specifies the vertical coordinates of the hotspot in number of pixels from the top.
//      DataSize = Width * Height * (BitsPerPixel div 8)
//      BitsPerPixel = ChannelSize * Channels
SGLog.Source(['SGCopyIcoImageProperties: Width = "', _Image.Width, '"; Height = "', _Image.Height, '"; Channels = "', _Image.Channels, '"; ChannelSize = "', _Image.ChannelSize, '".']);
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
	SGCopyIcoImageProperties(CursorImage, _Cursor);
	if SGLoadICOImage(CursorImage, _Cursor) then
		begin
		_Cursor.HotPixel := SGVertex2int32Import(CursorImage^.FHeader.FPlanes, CursorImage^.FHeader.FBpp);
		Result := True;
		end;
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
	SGCopyIcoImageProperties(ICOImage, _Image);
	Result := SGLoadICOImage(ICOImage, _Image);
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
