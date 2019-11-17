//Спецификация форматов ICO и CUR найдены в онлайн-библиотеке Wikipedia (Russian and english languages).

{$INCLUDE SaGe.inc}

//{$DEFINE DEBUGINFO}

unit SaGeImageICO;

interface

uses
	 SaGeBitMap
	,SaGeBase
	,SaGeCursor
	,SaGeCasesOfPrint
	,SaGeBitMapBase
	
	,Classes
	;

type
	TSGIcoFileType = TSGUInt16;
const
	SGIcoFile = 1;
	SGCurFile = 2;

{    Recommended icon sizes for Windows Vista compatibility
     The full set of standard icon sizes which should be provided for full Windows Vista compatibility:
256x256, 32-bit color, PNG compressed
48x48, 32-bit color, uncompressed
48x48, 8-bit color, uncompressed
48x48, 4-bit color, uncompressed
32x32, 32-bit color, uncompressed
32x32, 8-bit color, uncompressed
32x32, 4-bit color, uncompressed
16x16, 32-bit color, uncompressed
16x16, 8-bit color, uncompressed
16x16, 4-bit color, uncompressed }

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
		FWidth : TSGUInt8;    // Width, should be 0 if 256 pixels
		FHeight : TSGUInt8;   // Height, should be 0 if 256 pixels
		FColors : TSGUInt8;   // Specifies number of colors in the color palette. Should be 0 if the image does not use a color palette.
		                      // Color count, should be 0 if more than 256 colors 
		                      // (0 if >=8bpp)
		FReserved : TSGUInt8; // Reserved. Should be 0
		FPlanes : TSGUInt16;  // In ICO format: Specifies color planes. Should be 0 or 1.
							  // In CUR format: Specifies the horizontal coordinates of the hotspot in number of pixels from the left.
		FBpp : TSGUInt16;     // In ICO format: Specifies bits per pixel. 
						      //      16, 24 or 32 bit per pixel
						      //      256, 60 and 2 colors (fixed palette)
						      // In CUR format: Specifies the vertical coordinates of the hotspot in number of pixels from the top.
		FSize : TSGUInt32;    // Specifies the size of the image's data in bytes
		FOffset : TSGUInt32;  // Specifies the offset of BMP or PNG data from the beginning of the ICO/CUR file
		end;
	PSGIcoImageHeader = ^ TSGIcoImageHeader;
	
	TSGIcoBitMapCompression = TSGUInt32;
const
	BI_RGB = 0;            // Pixels data type: two-dimensional array. Most common
	BI_RLE8 = 1;           // BitCount: 8.
	                       // Compression method: RLE 8-bit/pixel. Can be used only with 8-bit/pixel bitmaps
	BI_RLE4 = 2;           // BitCount: 4.
	                       // Compression method: RLE 4-bit/pixel. Can be used only with 4-bit/pixel bitmaps
	BI_BITFIELDS = 3;      // BitCount: 16 and 32.
	                       // Pixels data type: two-dimensional array with bit field masks color channels.
	                       // For .bmp files: BITMAPV2INFOHEADER: RGB bit field masks, BITMAPV3INFOHEADER+: RGBA
	BI_JPEG = 4;           // BitCount: 0.
	                       // Pixels data type: in the embedded .jpg file
	                       // For .bmp files: BITMAPV4INFOHEADER+: JPEG image for printing
	BI_PNG = 5;            // BitCount: 0.
	                       // Pixels data type: in the embedded .png file
	                       // For .bmp files: BITMAPV4INFOHEADER+: PNG image for printing
	BI_ALPHABITFIELDS = 6; // BitCount: 16 and 32.
	                       // Pixels data type: two-dimensional array with bit field masks color and alpha channels.
	                       // Compression method: RGBA bit field masks.
	BI_CMYK = 11;          // For .bmp files. Compression method: none.
	BI_CMYKRLE8 = 12;      // For .bmp files. Compression method: RLE-8.
	BI_CMYKRLE4 = 13;      // For .bmp files. Compression method: RLE-4.
type
	TSGIcoBitMapInfoHeader = object
			public
		FSize : TSGUInt32;  // Specifies the number of bytes required by the structure. 
		                    // This value does not include the size of the color table or the size of the color masks,
		                    // if they are appended to the end of structure.
		FWidth : TSGInt32;  // Specifies the width of the bitmap, in pixels.
		FHeight : TSGInt32; // Specifies the height of the bitmap, in pixels.
		                    //      * For uncompressed RGB bitmaps,
		                    //        if FHeight is positive, the bitmap is a bottom-up DIB with the origin at the lower left corner.
		                    //        If FHeight is negative, the bitmap is a top-down DIB with the origin at the upper left corner.
		                    //      * For YUV bitmaps, the bitmap is always top-down, regardless of the sign of FHeight.
		                    //        Decoders should offer YUV formats with postive FHeight, but for backward compatibility
		                    //        they should accept YUV formats with either positive or negative FHeight.
		                    //      * For compressed formats, biHeight must be positive, regardless of image orientation.
		FPlanes : TSGUInt16;   // Specifies the number of planes for the target device. This value must be set to 1.
		FBitCount : TSGUInt16; // Specifies the number of bits per pixel (bpp).
		                       // For uncompressed formats, this value is the average number of bits per pixel.
		                       // For compressed formats, this value is the implied bit depth of the uncompressed image, after the image has been decoded.
		FCompression : TSGIcoBitMapCompression; // For compressed video and YUV formats, this member is a FOURCC code,
		                           // specified as a DWORD in little-endian order.
		                           // For example, YUYV video has the FOURCC 'VYUY' or $56595559.
		                           //      For uncompressed RGB formats, the following values are possible:
		                           //    * BI_RGB       Uncompressed RGB.
		                           //    * BI_BITFIELDS Uncompressed RGB with color masks. Valid for 16-bpp and 32-bpp bitmaps.
		                           //    and others...
		                           // For 16-bpp bitmaps, if biCompression equals BI_RGB, the format is always RGB 555.
		                           // If biCompression equals BI_BITFIELDS, the format is either RGB 555 or RGB 565.
		                           // Use the subtype GUID in the AM_MEDIA_TYPE structure to determine the specific RGB type.
		FSizeImage : TSGUInt32;    // Specifies the size, in bytes, of the image. This can be set to 0 for uncompressed RGB bitmaps.
		FXPelsPerMeter : TSGInt32; // Specifies the horizontal resolution, in pixels per meter, of the target device for the bitmap.
		FYPelsPerMeter : TSGInt32; // Specifies the vertical resolution, in pixels per meter, of the target device for the bitmap.
		FClrUsed : TSGUInt32;      // Specifies the number of color indices in the color table that are actually used by the bitmap.
		FClrImportant : TSGUInt32; // Specifies the number of color indices that are considered important for displaying the bitmap.
		                           // If this value is zero, all colors are important.
		end;
	// Struct TSGIcoBitMapInfoHeader in .ico files:
	//      Only the following members are used: 
	//           FSize, FWidth, FHeight, FPlanes, FBitCount, FSizeImage.
	//      All other members must be 0.
	
	PSGIcoBitMapInfoHeader = ^ TSGIcoBitMapInfoHeader;
	
	TSGIconImageData = object
			public
		FHeader : TSGIcoBitMapInfoHeader;
		FColors : PSGByte; // array of RGBQUAD
						   // The number of elements in this array is determined by examining the FHeader member.
		FXOR : PSGByte;    // The FXOR member contains the DIB bits for the XOR mask of the image.
		                   // The number of bytes in this array is determined by examining the FHeader member.
		                   // The XOR mask is the color portion of the image and is applied to the destination 
		                   //      using the XOR operation after the application of the AND mask.
		FAND : PSGByte;    // The FAND member contains the bits for the monochrome AND mask.
		                   // The number of bytes in this array is determined by examining the FHeader member, and assuming 1bpp.
		                   // The dimensions of this bitmap must be the same as the dimensions of the XOR mask.
		                   // The AND mask is applied to the destination using the AND operation, to preserve or
		                   //      remove destination pixels before applying the XOR mask.
		FEmbeddedImageData : TMemoryStream;
			public
		destructor Destroy();
		end;
	
	TSGIcoImage = object
			public
		FHeader : TSGIcoImageHeader;
		FData : TSGIconImageData;
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
		function MaskDataSize(const _Width, _Height : TSGInt32) : TSGUInt64;
		end;
	PSGIcoFile = ^ TSGIcoFile;

function SGSaveICO(const _Stream : TStream; const _Image : TSGBitMap) : TSGBoolean; overload;
function SGSaveCUR(const _Stream : TStream; const _Cursor : TSGCursor) : TSGBoolean; overload;

function SGLoadICO(const _Stream : TStream; var _Image : TSGBitMap; const _ImageNumber : TSGUInt32 = 0) : TSGBoolean; overload;
function SGLoadICO(const _Stream : TStream; const _ImageNumber : TSGUInt32 = 0) : TSGBitMap; overload;
function SGLoadCUR(const _Stream : TStream; var _Cursor : TSGCursor; const _CursorNumber : TSGUInt32 = 0) : TSGBoolean; overload;
function SGLoadCUR(const _Stream : TStream; const _CursorNumber : TSGUInt32 = 0) : TSGCursor; overload;

procedure SGIcoLoad4bitBitMap(const _Image : TSGBitMap; var _ImageData : TSGIconImageData);
function SGLoadICOImage(const _IcoFile : PSGIcoFileHeader; const _IcoImage : PSGIcoImage; const _Image : TSGBitMap) : TSGBoolean; overload;
function SGIcoBitMapDataSize(var _ImageHeader : TSGIcoImageHeader; var _BitMapInfoHeader : TSGIcoBitMapInfoHeader) : TSGUInt64;
function SGCopyIcoImageProperties(const _IcoFile : PSGIcoFileHeader; const _IcoImage : PSGIcoImage; const _Image : TSGBitMap) : TSGBoolean;
function SGIsICOData(const _Stream : TStream) : TSGBoolean;

function SGIcoImageExpansionFromDataType(const _DataType : TSGIcoBitMapCompression) : TSGString;
procedure SGPrintIcoBitMapInfoHeader(const _Name : TSGString; const _Header : TSGIcoBitMapInfoHeader; const _PrintCase : TSGCasesOfPrint = [SGCaseLog]);

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
	,SaGeTextMultiStream
	,SaGeTextStream
	
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

destructor TSGIconImageData.Destroy();
begin
SGKill(FColors);
SGKill(FAND);
SGKill(FXOR);
SGKill(FEmbeddedImageData);
end;

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
	FImages[Index].FData.Destroy();
	FillChar(FImages[Index], SizeOf(FImages[Index]), 0);
	end;
SetLength(FImages, 0);
FImages := nil;
end;

function TSGIcoFile.MaskDataSize(const _Width, _Height : TSGInt32) : TSGUInt64;
begin
if (((_Width * _Height) mod 8) = 0) then
	Result := (_Width * _Height) div 8
else
	Result := ((_Width * _Height) div 8) + 1;
end;

procedure TSGIcoFile.Load(const _Stream : TStream);
var
	Index : TSGMaxEnum;
	MaskSize : TSGUInt64;
	ColorDataSize : TSGUInt64;
	CurrentDataOffset : TSGUInt64;

function VerificationOfHeaderSize(const _Size : TSGUInt64) : TSGBoolean;
begin
Result := not ((_Size = 0) or (_Size > 150));
end;

begin
_Stream.Position := 0;
_Stream.ReadBuffer(FHeader, SizeOf(FHeader));
SetLength(FImages, FHeader.FCount);
FillChar(FImages[0], SizeOf(FImages[0]) * FHeader.FCount, 0);
{$IFDEF DEBUGINFO} SGLog.Source(['TSGIcoFile__Load: Images count = "', FHeader.FCount, '".']); {$ENDIF}
for Index := 0 to FHeader.FCount - 1 do
	begin
	_Stream.ReadBuffer(FImages[Index].FHeader, SizeOf(FImages[Index].FHeader));
	{$IFDEF DEBUGINFO} SGLog.Source(['TSGIcoFile__Load: Image[', Index, '].Size = "', FImages[Index].FHeader.FSize, '" (', SGGetSizeString(FImages[Index].FHeader.FSize, 'EN'), ').']); {$ENDIF}
	{$IFDEF DEBUGINFO} SGLog.Source(['TSGIcoFile__Load: Image[', Index, '].Offset = "', FImages[Index].FHeader.FOffset, '".']); {$ENDIF}
	end;
for Index := 0 to FHeader.FCount - 1 do
	if (FImages[Index].FHeader.FSize <> 0) then
		begin
		CurrentDataOffset := FImages[Index].FHeader.FOffset;
		_Stream.Position := CurrentDataOffset;
		_Stream.ReadBuffer(FImages[Index].FHeader.FSize, SizeOf(FImages[Index].FHeader.FSize));
		if (not VerificationOfHeaderSize(FImages[Index].FHeader.FSize)) and (Index <> 0) then
			begin
			CurrentDataOffset := FImages[Index - 1].FHeader.FOffset + FImages[Index - 1].FHeader.FSize;
			_Stream.Position := CurrentDataOffset;
			_Stream.ReadBuffer(FImages[Index].FHeader.FSize, SizeOf(FImages[Index].FHeader.FSize));
			SGLog.Source(['TSGIcoFile__Load: FileImages[', Index, ']. Try restore image data offset.']);
			end;
		if VerificationOfHeaderSize(FImages[Index].FHeader.FSize) then
			begin
			_Stream.Position := CurrentDataOffset;
			_Stream.ReadBuffer(FImages[Index].FData.FHeader, FImages[Index].FHeader.FSize);
			{$IFDEF DEBUGINFO} SGPrintIcoBitMapInfoHeader('FileImages[' + SGStr(Index) + ']', FImages[Index].FData.FHeader); {$ENDIF}
			
			if (FImages[Index].FData.FHeader.FCompression in [BI_RGB, BI_BITFIELDS, BI_ALPHABITFIELDS]) then
				begin
				ColorDataSize := SGIcoBitMapDataSize(FImages[Index].FHeader, FImages[Index].FData.FHeader);
				GetMem(FImages[Index].FData.FColors, ColorDataSize);
				_Stream.ReadBuffer(FImages[Index].FData.FColors^, ColorDataSize);
				
				if (FImages[Index].FData.FHeader.FCompression in [BI_BITFIELDS, BI_ALPHABITFIELDS]) then
					begin
					MaskSize := MaskDataSize(FImages[Index].FData.FHeader.FWidth, Abs(FImages[Index].FData.FHeader.FHeight));
					
					GetMem(FImages[Index].FData.FXOR, MaskSize);
					_Stream.ReadBuffer(FImages[Index].FData.FXOR^, MaskSize);
					
					GetMem(FImages[Index].FData.FAND, MaskSize);
					_Stream.ReadBuffer(FImages[Index].FData.FAND^, MaskSize);
					end;
				end
			else if (FImages[Index].FData.FHeader.FCompression in [BI_JPEG, BI_PNG]) then
				begin
				FImages[Index].FData.FEmbeddedImageData := TMemoryStream.Create();
				_Stream.Position := FImages[Index].FHeader.FOffset;
				SGCopyPartStreamToStream(_Stream, FImages[Index].FData.FEmbeddedImageData, FImages[Index].FData.FHeader.FSizeImage);
				end
			else
				SGLog.Source(['TSGIcoFile__Load: Unsuppored data format: "', FImages[Index].FData.FHeader.FCompression, '".']);
			end
		else
			SGLog.Source(['TSGIcoFile__Load: FileImages[', Index, ']. Unsuppored header size "', FImages[Index].FHeader.FSize, '".']);
		end;
end;

procedure TSGIcoFile.Save(const _Stream : TStream);
var
	Index : TSGMaxEnum;
	MaskSize : TSGUInt64;
	ColorDataSize : TSGUInt64;
begin
_Stream.WriteBuffer(FHeader, SizeOf(FHeader));
for Index := 0 to High(FImages) do
	_Stream.WriteBuffer(FImages[Index].FHeader, SizeOf(FImages[Index].FHeader));
for Index := 0 to High(FImages) do
	if (FImages[Index].FHeader.FSize <> 0) then
		begin
		_Stream.WriteBuffer(FImages[Index].FData.FHeader, SizeOf(FImages[Index].FData.FHeader));
		if (FImages[Index].FData.FHeader.FCompression in [BI_RGB, BI_BITFIELDS, BI_ALPHABITFIELDS]) then
			begin
			ColorDataSize := SGIcoBitMapDataSize(FImages[Index].FHeader, FImages[Index].FData.FHeader);
			_Stream.WriteBuffer(FImages[Index].FData.FColors^, ColorDataSize);
			if (FImages[Index].FData.FHeader.FCompression in [BI_BITFIELDS, BI_ALPHABITFIELDS]) then
				begin
				MaskSize := MaskDataSize(FImages[Index].FData.FHeader.FWidth, Abs(FImages[Index].FData.FHeader.FHeight));
				_Stream.WriteBuffer(FImages[Index].FData.FXOR^, MaskSize);
				_Stream.WriteBuffer(FImages[Index].FData.FAND^, MaskSize);
				end;
			end
		else if (FImages[Index].FData.FHeader.FCompression in [BI_JPEG, BI_PNG]) then
			begin
			FImages[Index].FData.FEmbeddedImageData.Position := 0;
			SGCopyPartStreamToStream(FImages[Index].FData.FEmbeddedImageData, _Stream, FImages[Index].FData.FEmbeddedImageData.Size);
			end
		else
			SGLog.Source(['TSGIcoFile__Save: Unsuppored data format: "', FImages[Index].FData.FHeader.FCompression, '".']);
		end;
end;

function SGIcoImageExpansionFromDataType(const _DataType : TSGIcoBitMapCompression) : TSGString;
begin
case _DataType of
BI_RGB, BI_BITFIELDS, BI_ALPHABITFIELDS : Result := 'bmp';
BI_PNG : Result := 'png';
BI_JPEG : Result := 'jpeg';
else Result := '';
end;
end;

procedure SGPrintIcoBitMapInfoHeader(const _Name : TSGString; const _Header : TSGIcoBitMapInfoHeader; const _PrintCase : TSGCasesOfPrint = [SGCaseLog]);
var
	TextStream : TSGTextStream = nil;
begin
TextStream := TSGTextMultiStream.Create(_PrintCase);
TextStream.WriteLn(['     TSGIcoBitMapInfoHeader(', _Name, '):']);
TextStream.WriteLn([' Size = ', _Header.FSize]);
TextStream.WriteLn([' Width = ', _Header.FWidth]);
TextStream.WriteLn([' Height = ', _Header.FHeight]);
TextStream.WriteLn([' Planes = ', _Header.FPlanes]);
TextStream.WriteLn([' BitCount = ', _Header.FBitCount]);
TextStream.WriteLn([' Compression = ', _Header.FCompression]);
TextStream.WriteLn([' SizeImage = ', _Header.FSizeImage]);
TextStream.WriteLn([' XPelsPerMeter = ', _Header.FXPelsPerMeter]);
TextStream.WriteLn([' YPelsPerMeter = ', _Header.FYPelsPerMeter]);
TextStream.WriteLn([' ClrUsed = ', _Header.FClrUsed]);
TextStream.WriteLn([' ClrImportant = ', _Header.FClrImportant]);
SGKill(TextStream);
end;

function SGIcoBitMapDataSize(var _ImageHeader : TSGIcoImageHeader; var _BitMapInfoHeader : TSGIcoBitMapInfoHeader) : TSGUInt64;
var
	PixelSize : TSGMaxEnum;
	Width, Height : TSGMaxEnum;
	TempDataSize : TSGUInt64;
begin
if (_BitMapInfoHeader.FSizeImage <> 0) then
	begin
	Result := _BitMapInfoHeader.FSizeImage;
	end
else
	begin
	PixelSize := _BitMapInfoHeader.FBitCount div 8;
	Width := _ImageHeader.FWidth;
	if (Width = 0) then
		Width := 256;
	Height := _ImageHeader.FHeight;
	if (Height = 0) then
		Height := 256;
	{$IFDEF DEBUGINFO} if (_BitMapInfoHeader.FWidth <> Width) then SGLog.Source(['SGIcoBitMapDataSize: ImageHeader.Width(', Width, ') <>  BitMapInfoHeader.Width(', _BitMapInfoHeader.FWidth, ').']); {$ENDIF}
	{$IFDEF DEBUGINFO} if (_BitMapInfoHeader.FHeight <> Height) then SGLog.Source(['SGIcoBitMapDataSize: ImageHeader.Height(', Height, ') <>  BitMapInfoHeader.Height(', _BitMapInfoHeader.FHeight, ').']); {$ENDIF}
	if (_BitMapInfoHeader.FBitCount = 4) then
		begin
		TempDataSize := Width * Height;
		Result := TempDataSize div 2;
		if (TempDataSize mod 2 <> 0) then
			Result += 1;
		if (_BitMapInfoHeader.FClrUsed > 0) then // FClrUsed = 2 ** FBitCount
			Result += _BitMapInfoHeader.FClrUsed{16 colors} * 4{24 bpp + 8};
		end
	else
		Result := Width * Height * PixelSize;
	end;
{$IFDEF DEBUGINFO} SGLog.Source(['SGIcoBitMapDataSize(', Result, ').']); {$ENDIF}
end;

//======================================================================
//======================================================================
//======================================================================

procedure SGIcoLoad4bitBitMap(const _Image : TSGBitMap; var _ImageData : TSGIconImageData);
var
	TempIndex, Index, W, H, ColorIndex : TSGMaxEnum;
	ImageBitMap : PSGPixel3b;
	ColorArray : PSGPixel3b;
	IcoImageBitMap : PSGUInt8;
begin
ImageBitMap := PSGPixel3b(_Image.BitMap);
ColorArray := PSGPixel3b(_ImageData.FColors);
IcoImageBitMap := PSGUInt8(TSGMaxEnum(ColorArray) + 16{colors} * 4{24 bpp + 8});
for H := 0 to _Image.Height - 1 do
	for W := 0 to _Image.Width - 1 do
		begin
		TempIndex := H * _Image.Width + W;
		Index := TempIndex div 2;
		ColorIndex := IcoImageBitMap[Index];
		if (TempIndex mod 2 = 0) then
			ColorIndex := ColorIndex and $0F
		else
			ColorIndex := (ColorIndex and $F0) shr 4;
		TempIndex := H * _Image.Width + (_Image.Width - 1 - W); // should ?
		ImageBitMap[TempIndex] := ColorArray[ColorIndex]; // SGPixelR8G7B9ToRGB24 ?
		end;
ImageBitMap := nil;
ColorArray := nil;
IcoImageBitMap := nil;
end;

function SGLoadICOImage(const _IcoFile : PSGIcoFileHeader; const _IcoImage : PSGIcoImage; const _Image : TSGBitMap) : TSGBoolean; overload;
var
	ImageDataType : TSGIcoBitMapCompression;
	FileExpansion : TSGString;
	LoadedImage : TSGBitMap = nil;
	HaveAdditionalProperties : TSGBoolean = False; // is ".ico" (not ".cur")
var
	// fixed palette: 256, 60 or 2 (number colors); may be 16 colors?
	ColorPlanes : TSGUInt16 = 0; // Should be 0 or 1 (or 255(icon encoder built into .NET (System.Drawing.Icon.Save)))
	BitsPerPixel : TSGUInt16 = 0; // Should be 16, 24 or 32 (bit per pixel)
begin
ImageDataType := _IcoImage^.FData.FHeader.FCompression;
{$IFDEF DEBUGINFO} SGLog.Source(['SGLoadICOImage: Determined format "', SGIcoImageExpansionFromDataType(ImageDataType), '".']); {$ENDIF}
case ImageDataType of
BI_RGB, BI_BITFIELDS, BI_ALPHABITFIELDS:
	begin
	HaveAdditionalProperties := (_IcoFile <> nil) and (_IcoFile^.FType = SGIcoFile);
	if (not HaveAdditionalProperties) or (_Image.Channels * _Image.ChannelSize <> 0) then
		begin
		_Image.CreateTypes();
		_Image.ReAllocateMemory();
		{$IFDEF DEBUGINFO} SGLog.Source(['SGLoadICOImage: BitMap data size = "', _Image.DataSize(), '".']); {$ENDIF}
		{$IFDEF DEBUGINFO} SGLog.Source(['SGLoadICOImage: Data.Header.SizeImage = "', _IcoImage^.FData.FHeader.FSizeImage, '".']); {$ENDIF}
		{$IFDEF DEBUGINFO} SGLog.Source(['SGLoadICOImage: Header.Size = "', _IcoImage^.FHeader.FSize, '".']); {$ENDIF}
		Move(_IcoImage^.FData.FColors^, _Image.BitMap^, _Image.DataSize());
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
			SGIcoLoad4bitBitMap(_Image, _IcoImage^.FData);
			end;
		end
	else SGLog.Source(['SGLoadICOImage: Couldn''t load BMP data from ICO container.']);
	end;
BI_JPEG:
	begin
	LoadedImage := TSGBitMap.Create();
	LoadJPEGToBitMap(_IcoImage^.FData.FEmbeddedImageData, LoadedImage);
	Result := LoadedImage.DataSize() <> 0;
	if Result then
		_Image.CopyFrom(LoadedImage);
	SGKill(LoadedImage);
	end;
BI_PNG:
	begin
	_IcoImage^.FData.FEmbeddedImageData.Position := 0;
	FileExpansion := TSGImageFormatDeterminer.DetermineExpansion(_IcoImage^.FData.FEmbeddedImageData);
	_IcoImage^.FData.FEmbeddedImageData.Position := 0;
	if SGResourceManager.LoadingIsSupported(FileExpansion) then
		begin
		LoadedImage := SGResourceManager.LoadResourceFromStream(_IcoImage^.FData.FEmbeddedImageData, FileExpansion) as TSGBitMap;
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
	HaveAdditionalProperties : TSGBoolean = False; // is ".ico" (not ".cur")
var
	// fixed palette: 256, 60 or 2 (number colors); may be 16 colors?
	ColorPlanes : TSGUInt16 = 0; // Should be 0 or 1 (or 255(icon encoder built into .NET (System.Drawing.Icon.Save)))
	BitsPerPixel : TSGUInt16 = 0; // Should be 16, 24 or 32 (bit per pixel)
begin
Result := False;
HaveAdditionalProperties := (_IcoFile <> nil) and (_IcoFile^.FType = SGIcoFile);
if HaveAdditionalProperties then
	begin
	BitsPerPixel := _IcoImage^.FHeader.FBpp;
	ColorPlanes := _IcoImage^.FHeader.FPlanes;
	{$IFDEF DEBUGINFO} SGLog.Source(['SGCopyIcoImageProperties: AdditionalProperties: BitsPerPixel = "', BitsPerPixel, '"; ColorPlanes = "', ColorPlanes, '".']); {$ENDIF}
	end;

_Image.Width := _IcoImage^.FHeader.FWidth;
_Image.Height := _IcoImage^.FHeader.FHeight;
if (_Image.Width = 0) then
	_Image.Width := 256;
if (_Image.Height = 0) then
	_Image.Height := 256;
_Image.ChannelSize := 0;
_Image.Channels := 0;

if (_IcoImage^.FData.FHeader.FBitCount = 24) then
	begin
	_Image.ChannelSize := 8;
	_Image.Channels := 3;
	end
else if (_IcoImage^.FData.FHeader.FBitCount = 32) then
	begin
	_Image.ChannelSize := 8;
	_Image.Channels := 4;
	end
else if HaveAdditionalProperties and ((ColorPlanes = 1) or (ColorPlanes = 0)) then
	begin
	_Image.ChannelSize := BitsPerPixel;
	_Image.Channels := 0;
	end
else
	SGLog.Source(['SGCopyIcoImageProperties: Unsupported IcoImage__Data__Header__BitCount.']);

Result := (_Image.Width * _Image.Height) <> 0;
{$IFDEF DEBUGINFO} SGLog.Source(['SGCopyIcoImageProperties(Result=', Result, '): Width = "', _Image.Width, '"; Height = "', _Image.Height, '"; Channels = "', _Image.Channels, '"; ChannelSize = "', _Image.ChannelSize, '".']); {$ENDIF}
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
