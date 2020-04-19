//Спецификация форматов ICO и CUR найдены в онлайн-библиотеке Wikipedia (Russian and english languages).

{$INCLUDE Smooth.inc}

//{$DEFINE DEBUGINFO}

unit SmoothImageICO;

interface

uses
	 SmoothBitMap
	,SmoothBase
	,SmoothCursor
	,SmoothCasesOfPrint
	,SmoothBitMapBase
	
	,Classes
	;

type
	TSIcoFileType = TSUInt16;
const
	SIcoFile = 1;
	SCurFile = 2;

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
	TSIcoFileHeader = object
			public
		FReserved : TSUInt16; // Reserved. Must always be 0.
		FType : TSUInt16; // SIcoFile or SCurFile (type TSIcoFileType)
		FCount : TSUInt16; // Specifies number of images in the file.
		end;
	PSIcoFileHeader = ^ TSIcoFileHeader;
	
	TSIcoImageHeader = object // include CUR
			public
		FWidth : TSUInt8;    // Width, should be 0 if 256 pixels
		FHeight : TSUInt8;   // Height, should be 0 if 256 pixels
		FColors : TSUInt8;   // Specifies number of colors in the color palette. Should be 0 if the image does not use a color palette.
		                      // Color count, should be 0 if more than 256 colors 
		                      // (0 if >=8bpp)
		FReserved : TSUInt8; // Reserved. Should be 0
		FPlanes : TSUInt16;  // In ICO format: Specifies color planes. Should be 0 or 1.
							  // In CUR format: Specifies the horizontal coordinates of the hotspot in number of pixels from the left.
		FBpp : TSUInt16;     // In ICO format: Specifies bits per pixel. 
						      //      16, 24 or 32 bit per pixel
						      //      256, 60 and 2 colors (fixed palette)
						      // In CUR format: Specifies the vertical coordinates of the hotspot in number of pixels from the top.
		FSize : TSUInt32;    // Specifies the size of the image's data in bytes
		FOffset : TSUInt32;  // Specifies the offset of BMP or PNG data from the beginning of the ICO/CUR file
		end;
	PSIcoImageHeader = ^ TSIcoImageHeader;
	
	TSIcoBitMapCompression = TSUInt32;
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
	TSIcoBitMapInfoHeader = object
			public
		FSize : TSUInt32;  // Specifies the number of bytes required by the structure. 
		                    // This value does not include the size of the color table or the size of the color masks,
		                    // if they are appended to the end of structure.
		FWidth : TSInt32;  // Specifies the width of the bitmap, in pixels.
		FHeight : TSInt32; // Specifies the height of the bitmap, in pixels.
		                    //      * For uncompressed RGB bitmaps,
		                    //        if FHeight is positive, the bitmap is a bottom-up DIB with the origin at the lower left corner.
		                    //        If FHeight is negative, the bitmap is a top-down DIB with the origin at the upper left corner.
		                    //      * For YUV bitmaps, the bitmap is always top-down, regardless of the sign of FHeight.
		                    //        Decoders should offer YUV formats with postive FHeight, but for backward compatibility
		                    //        they should accept YUV formats with either positive or negative FHeight.
		                    //      * For compressed formats, biHeight must be positive, regardless of image orientation.
		FPlanes : TSUInt16;   // Specifies the number of planes for the target device. This value must be set to 1.
		FBitCount : TSUInt16; // Specifies the number of bits per pixel (bpp).
		                       // For uncompressed formats, this value is the average number of bits per pixel.
		                       // For compressed formats, this value is the implied bit depth of the uncompressed image, after the image has been decoded.
		FCompression : TSIcoBitMapCompression; // For compressed video and YUV formats, this member is a FOURCC code,
		                           // specified as a DWORD in little-endian order.
		                           // For example, YUYV video has the FOURCC 'VYUY' or $56595559.
		                           //      For uncompressed RGB formats, the following values are possible:
		                           //    * BI_RGB       Uncompressed RGB.
		                           //    * BI_BITFIELDS Uncompressed RGB with color masks. Valid for 16-bpp and 32-bpp bitmaps.
		                           //    and others...
		                           // For 16-bpp bitmaps, if biCompression equals BI_RGB, the format is always RGB 555.
		                           // If biCompression equals BI_BITFIELDS, the format is either RGB 555 or RGB 565.
		                           // Use the subtype GUID in the AM_MEDIA_TYPE structure to determine the specific RGB type.
		FSizeImage : TSUInt32;    // Specifies the size, in bytes, of the image. This can be set to 0 for uncompressed RGB bitmaps.
		FXPelsPerMeter : TSInt32; // Specifies the horizontal resolution, in pixels per meter, of the target device for the bitmap.
		FYPelsPerMeter : TSInt32; // Specifies the vertical resolution, in pixels per meter, of the target device for the bitmap.
		FClrUsed : TSUInt32;      // Specifies the number of color indices in the color table that are actually used by the bitmap.
		FClrImportant : TSUInt32; // Specifies the number of color indices that are considered important for displaying the bitmap.
		                           // If this value is zero, all colors are important.
		end;
	// Struct TSIcoBitMapInfoHeader in .ico files:
	//      Only the following members are used: 
	//           FSize, FWidth, FHeight, FPlanes, FBitCount, FSizeImage.
	//      All other members must be 0.
	
	PSIcoBitMapInfoHeader = ^ TSIcoBitMapInfoHeader;
	
	TSIconImageData = object
			public
		FHeader : TSIcoBitMapInfoHeader;
		FColors : PSByte; // array of RGBQUAD
						   // The number of elements in this array is determined by examining the FHeader member.
		FXOR : PSByte;    // The FXOR member contains the DIB bits for the XOR mask of the image.
		                   // The number of bytes in this array is determined by examining the FHeader member.
		                   // The XOR mask is the color portion of the image and is applied to the destination 
		                   //      using the XOR operation after the application of the AND mask.
		FAND : PSByte;    // The FAND member contains the bits for the monochrome AND mask.
		                   // The number of bytes in this array is determined by examining the FHeader member, and assuming 1bpp.
		                   // The dimensions of this bitmap must be the same as the dimensions of the XOR mask.
		                   // The AND mask is applied to the destination using the AND operation, to preserve or
		                   //      remove destination pixels before applying the XOR mask.
		FEmbeddedImageData : TMemoryStream;
			public
		destructor Destroy();
		end;
	
	TSIcoImage = object
			public
		FHeader : TSIcoImageHeader;
		FData : TSIconImageData;
		end;
	PSIcoImage = ^ TSIcoImage;
	
	TSIcoImageList = packed array of TSIcoImage;
	
	TSIcoFile = object
			public
		FHeader : TSIcoFileHeader;
		FImages : TSIcoImageList;
			public
		constructor Create();
		destructor Destroy();
		procedure Load(const _Stream : TStream);
		procedure Save(const _Stream : TStream);
		function MaskDataSize(const _Width, _Height : TSInt32) : TSUInt64;
		end;
	PSIcoFile = ^ TSIcoFile;

function SSaveICO(const _Stream : TStream; const _Image : TSBitMap) : TSBoolean; overload;
function SSaveCUR(const _Stream : TStream; const _Cursor : TSCursor) : TSBoolean; overload;

function SLoadICO(const _Stream : TStream; var _Image : TSBitMap; const _ImageNumber : TSUInt32 = 0) : TSBoolean; overload;
function SLoadICO(const _Stream : TStream; const _ImageNumber : TSUInt32 = 0) : TSBitMap; overload;
function SLoadCUR(const _Stream : TStream; var _Cursor : TSCursor; const _CursorNumber : TSUInt32 = 0) : TSBoolean; overload;
function SLoadCUR(const _Stream : TStream; const _CursorNumber : TSUInt32 = 0) : TSCursor; overload;

procedure SIcoLoad4bitBitMap(const _Image : TSBitMap; var _ImageData : TSIconImageData);
function SLoadICOImage(const _IcoFile : PSIcoFileHeader; const _IcoImage : PSIcoImage; const _Image : TSBitMap) : TSBoolean; overload;
function SIcoBitMapDataSize(var _ImageHeader : TSIcoImageHeader; var _BitMapInfoHeader : TSIcoBitMapInfoHeader) : TSUInt64;
function SCopyIcoImageProperties(const _IcoFile : PSIcoFileHeader; const _IcoImage : PSIcoImage; const _Image : TSBitMap) : TSBoolean;
function SIsICOData(const _Stream : TStream) : TSBoolean;

function SIcoImageExtensionFromDataType(const _DataType : TSIcoBitMapCompression) : TSString;
procedure SPrintIcoBitMapInfoHeader(const _Name : TSString; const _Header : TSIcoBitMapInfoHeader; const _PrintCase : TSCasesOfPrint = [SCaseLog]);

implementation

uses
	 SmoothStreamUtils
	,SmoothStringUtils
	,SmoothImageFormatDeterminer
	,SmoothImageBmp // BMP
	,SmoothImageJpeg // Jpeg
	,SmoothResourceManager // PNG and "others"
	,SmoothCommonStructs
	,SmoothLog
	,SmoothMathUtils
	,SmoothBitMapUtils
	,SmoothTextMultiStream
	,SmoothTextStream
	
	,SysUtils
	;

type
	TSResourceManipulatorImagesICO = class(TSResourceManipulator)
			public
		constructor Create();override;
		function LoadResourceFromStream(const VStream : TStream; const VExtension : TSString) : TSResource; override;
		function SaveResourceToStream(const VStream : TStream; const VExtension : TSString; const VResource : TSResource) : TSBoolean; override;
		end;

constructor TSResourceManipulatorImagesICO.Create();
begin
inherited;
AddFileExtension('ICO', True{LoadIsSupported}, False{SaveIsSupported});
AddFileExtension('CUR', True{LoadIsSupported}, False{SaveIsSupported});
end;

function TSResourceManipulatorImagesICO.LoadResourceFromStream(const VStream : TStream; const VExtension : TSString) : TSResource;
var
	ExtensionUpCase : TSString;
begin
ExtensionUpCase := SUpCaseString(VExtension);
if (ExtensionUpCase = 'ICO') then
	Result := SLoadICO(VStream)
else if (ExtensionUpCase = 'CUR') then
	Result := SLoadCUR(VStream)
else
	Result := nil;
end;

function TSResourceManipulatorImagesICO.SaveResourceToStream(const VStream : TStream; const VExtension : TSString; const VResource : TSResource) : TSBoolean;
var
	ExtensionUpCase : TSString;
begin
ExtensionUpCase := SUpCaseString(VExtension);
if (ExtensionUpCase = 'ICO') then
	Result := SSaveICO(VStream, VResource as TSBitMap)
else if (ExtensionUpCase = 'CUR') then
	Result := SSaveCUR(VStream, VResource as TSCursor)
else
	Result := False;
end;

//======================================================================
//======================================================================
//======================================================================

destructor TSIconImageData.Destroy();
begin
SKill(FColors);
SKill(FAND);
SKill(FXOR);
SKill(FEmbeddedImageData);
end;

constructor TSIcoFile.Create();
begin
FillChar(FHeader, SizeOf(FHeader), 0);
FImages := nil;
end;

destructor TSIcoFile.Destroy();
var
	Index : TSMaxEnum;
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

function TSIcoFile.MaskDataSize(const _Width, _Height : TSInt32) : TSUInt64;
begin
if (((_Width * _Height) mod 8) = 0) then
	Result := (_Width * _Height) div 8
else
	Result := ((_Width * _Height) div 8) + 1;
end;

procedure TSIcoFile.Load(const _Stream : TStream);
var
	Index : TSMaxEnum;
	MaskSize : TSUInt64;
	ColorDataSize : TSUInt64;
	CurrentDataOffset : TSUInt64;

function VerificationOfHeaderSize(const _Size : TSUInt64) : TSBoolean;
begin
Result := not ((_Size = 0) or (_Size > 150));
end;

begin
_Stream.Position := 0;
_Stream.ReadBuffer(FHeader, SizeOf(FHeader));
SetLength(FImages, FHeader.FCount);
FillChar(FImages[0], SizeOf(FImages[0]) * FHeader.FCount, 0);
{$IFDEF DEBUGINFO} SLog.Source(['TSIcoFile__Load: Images count = "', FHeader.FCount, '".']); {$ENDIF}
for Index := 0 to FHeader.FCount - 1 do
	begin
	_Stream.ReadBuffer(FImages[Index].FHeader, SizeOf(FImages[Index].FHeader));
	{$IFDEF DEBUGINFO} SLog.Source(['TSIcoFile__Load: Image[', Index, '].Size = "', FImages[Index].FHeader.FSize, '" (', SGetSizeString(FImages[Index].FHeader.FSize, 'EN'), ').']); {$ENDIF}
	{$IFDEF DEBUGINFO} SLog.Source(['TSIcoFile__Load: Image[', Index, '].Offset = "', FImages[Index].FHeader.FOffset, '".']); {$ENDIF}
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
			SLog.Source(['TSIcoFile__Load: FileImages[', Index, ']. Try restore image data offset.']);
			end;
		if VerificationOfHeaderSize(FImages[Index].FHeader.FSize) then
			begin
			_Stream.Position := CurrentDataOffset;
			_Stream.ReadBuffer(FImages[Index].FData.FHeader, FImages[Index].FHeader.FSize);
			{$IFDEF DEBUGINFO} SPrintIcoBitMapInfoHeader('FileImages[' + SStr(Index) + ']', FImages[Index].FData.FHeader); {$ENDIF}
			
			if (FImages[Index].FData.FHeader.FCompression in [BI_RGB, BI_BITFIELDS, BI_ALPHABITFIELDS]) then
				begin
				ColorDataSize := SIcoBitMapDataSize(FImages[Index].FHeader, FImages[Index].FData.FHeader);
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
				SCopyPartStreamToStream(_Stream, FImages[Index].FData.FEmbeddedImageData, FImages[Index].FData.FHeader.FSizeImage);
				end
			else
				SLog.Source(['TSIcoFile__Load: Unsuppored data format: "', FImages[Index].FData.FHeader.FCompression, '".']);
			end
		else
			SLog.Source(['TSIcoFile__Load: FileImages[', Index, ']. Unsuppored header size "', FImages[Index].FHeader.FSize, '".']);
		end;
end;

procedure TSIcoFile.Save(const _Stream : TStream);
var
	Index : TSMaxEnum;
	MaskSize : TSUInt64;
	ColorDataSize : TSUInt64;
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
			ColorDataSize := SIcoBitMapDataSize(FImages[Index].FHeader, FImages[Index].FData.FHeader);
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
			SCopyPartStreamToStream(FImages[Index].FData.FEmbeddedImageData, _Stream, FImages[Index].FData.FEmbeddedImageData.Size);
			end
		else
			SLog.Source(['TSIcoFile__Save: Unsuppored data format: "', FImages[Index].FData.FHeader.FCompression, '".']);
		end;
end;

function SIcoImageExtensionFromDataType(const _DataType : TSIcoBitMapCompression) : TSString;
begin
case _DataType of
BI_RGB, BI_BITFIELDS, BI_ALPHABITFIELDS : Result := 'bmp';
BI_PNG : Result := 'png';
BI_JPEG : Result := 'jpeg';
else Result := '';
end;
end;

procedure SPrintIcoBitMapInfoHeader(const _Name : TSString; const _Header : TSIcoBitMapInfoHeader; const _PrintCase : TSCasesOfPrint = [SCaseLog]);
var
	TextStream : TSTextStream = nil;
begin
TextStream := TSTextMultiStream.Create(_PrintCase);
TextStream.WriteLn(['     TSIcoBitMapInfoHeader(', _Name, '):']);
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
SKill(TextStream);
end;

function SIcoBitMapDataSize(var _ImageHeader : TSIcoImageHeader; var _BitMapInfoHeader : TSIcoBitMapInfoHeader) : TSUInt64;
var
	PixelSize : TSMaxEnum;
	Width, Height : TSMaxEnum;
	TempDataSize : TSUInt64;
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
	{$IFDEF DEBUGINFO} if (_BitMapInfoHeader.FWidth <> Width) then SLog.Source(['SIcoBitMapDataSize: ImageHeader.Width(', Width, ') <>  BitMapInfoHeader.Width(', _BitMapInfoHeader.FWidth, ').']); {$ENDIF}
	{$IFDEF DEBUGINFO} if (_BitMapInfoHeader.FHeight <> Height) then SLog.Source(['SIcoBitMapDataSize: ImageHeader.Height(', Height, ') <>  BitMapInfoHeader.Height(', _BitMapInfoHeader.FHeight, ').']); {$ENDIF}
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
{$IFDEF DEBUGINFO} SLog.Source(['SIcoBitMapDataSize(', Result, ').']); {$ENDIF}
end;

//======================================================================
//======================================================================
//======================================================================

procedure SIcoLoad4bitBitMap(const _Image : TSBitMap; var _ImageData : TSIconImageData);
var
	TempIndex, Index, W, H, ColorIndex : TSMaxEnum;
	ImageBitMap : PSPixel3b;
	ColorArray : PSPixel3b;
	IcoImageBitMap : PSUInt8;
begin
ImageBitMap := PSPixel3b(_Image.Data);
ColorArray := PSPixel3b(_ImageData.FColors);
IcoImageBitMap := PSUInt8(TSMaxEnum(ColorArray) + 16{colors} * 4{24 bpp + 8});
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
		ImageBitMap[TempIndex] := ColorArray[ColorIndex]; // SPixelR8G7B9ToRGB24 ?
		end;
ImageBitMap := nil;
ColorArray := nil;
IcoImageBitMap := nil;
end;

function SLoadICOImage(const _IcoFile : PSIcoFileHeader; const _IcoImage : PSIcoImage; const _Image : TSBitMap) : TSBoolean; overload;
var
	ImageDataType : TSIcoBitMapCompression;
	FileExtension : TSString;
	LoadedImage : TSBitMap = nil;
	HaveAdditionalProperties : TSBoolean = False; // is ".ico" (not ".cur")
var
	// fixed palette: 256, 60 or 2 (number colors); may be 16 colors?
	ColorPlanes : TSUInt16 = 0; // Should be 0 or 1 (or 255(icon encoder built into .NET (System.Drawing.Icon.Save)))
	BitsPerPixel : TSUInt16 = 0; // Should be 16, 24 or 32 (bit per pixel)
begin
ImageDataType := _IcoImage^.FData.FHeader.FCompression;
{$IFDEF DEBUGINFO} SLog.Source(['SLoadICOImage: Determined format "', SIcoImageExtensionFromDataType(ImageDataType), '".']); {$ENDIF}
case ImageDataType of
BI_RGB, BI_BITFIELDS, BI_ALPHABITFIELDS:
	begin
	HaveAdditionalProperties := (_IcoFile <> nil) and (_IcoFile^.FType = SIcoFile);
	if (not HaveAdditionalProperties) or (_Image.Channels * _Image.ChannelSize <> 0) then
		begin
		_Image.ReAllocateMemory();
		{$IFDEF DEBUGINFO} SLog.Source(['SLoadICOImage: BitMap data size = "', _Image.DataSize(), '".']); {$ENDIF}
		{$IFDEF DEBUGINFO} SLog.Source(['SLoadICOImage: Data.Header.SizeImage = "', _IcoImage^.FData.FHeader.FSizeImage, '".']); {$ENDIF}
		{$IFDEF DEBUGINFO} SLog.Source(['SLoadICOImage: Header.Size = "', _IcoImage^.FHeader.FSize, '".']); {$ENDIF}
		Move(_IcoImage^.FData.FColors^, _Image.Data^, _Image.DataSize());
		SBitMapBGRAToRGBA(_Image);
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
			_Image.ReAllocateMemory();
			SIcoLoad4bitBitMap(_Image, _IcoImage^.FData);
			end;
		end
	else SLog.Source(['SLoadICOImage: Couldn''t load BMP data from ICO container.']);
	end;
BI_JPEG:
	begin
	LoadedImage := TSBitMap.Create();
	SLoadBitMapAsJpegToStream(_IcoImage^.FData.FEmbeddedImageData, LoadedImage);
	Result := LoadedImage.DataSize() <> 0;
	if Result then
		_Image.CopyFrom(LoadedImage);
	SKill(LoadedImage);
	end;
BI_PNG:
	begin
	_IcoImage^.FData.FEmbeddedImageData.Position := 0;
	FileExtension := TSImageFormatDeterminer.DetermineFileExtension(_IcoImage^.FData.FEmbeddedImageData);
	_IcoImage^.FData.FEmbeddedImageData.Position := 0;
	if SResourceManager.LoadingIsSupported(FileExtension) then
		begin
		LoadedImage := SResourceManager.LoadResourceFromStream(_IcoImage^.FData.FEmbeddedImageData, FileExtension) as TSBitMap;
		Result := (LoadedImage <> nil) and (LoadedImage.DataSize() <> 0);
		if Result then
			_Image.CopyFrom(LoadedImage);
		SKill(LoadedImage);
		end;
	end;
else
	SLog.Source(['SLoadICOImage: Unknown image data format.']);
end;
end;

function SCopyIcoImageProperties(const _IcoFile : PSIcoFileHeader; const _IcoImage : PSIcoImage; const _Image : TSBitMap) : TSBoolean;
var
	HaveAdditionalProperties : TSBoolean = False; // is ".ico" (not ".cur")
var
	// fixed palette: 256, 60 or 2 (number colors); may be 16 colors?
	ColorPlanes : TSUInt16 = 0; // Should be 0 or 1 (or 255(icon encoder built into .NET (System.Drawing.Icon.Save)))
	BitsPerPixel : TSUInt16 = 0; // Should be 16, 24 or 32 (bit per pixel)
begin
Result := False;
HaveAdditionalProperties := (_IcoFile <> nil) and (_IcoFile^.FType = SIcoFile);
if HaveAdditionalProperties then
	begin
	BitsPerPixel := _IcoImage^.FHeader.FBpp;
	ColorPlanes := _IcoImage^.FHeader.FPlanes;
	{$IFDEF DEBUGINFO} SLog.Source(['SCopyIcoImageProperties: AdditionalProperties: BitsPerPixel = "', BitsPerPixel, '"; ColorPlanes = "', ColorPlanes, '".']); {$ENDIF}
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
	SLog.Source(['SCopyIcoImageProperties: Unsupported IcoImage__Data__Header__BitCount.']);

Result := (_Image.Width * _Image.Height) <> 0;
{$IFDEF DEBUGINFO} SLog.Source(['SCopyIcoImageProperties(Result=', Result, '): Width = "', _Image.Width, '"; Height = "', _Image.Height, '"; Channels = "', _Image.Channels, '"; ChannelSize = "', _Image.ChannelSize, '".']); {$ENDIF}
end;

function SLoadCUR(const _Stream : TStream; var _Cursor : TSCursor; const _CursorNumber : TSUInt32 = 0) : TSBoolean; overload;
var
	IcoFile : TSIcoFile;
	CursorImage : PSIcoImage = nil;
begin
if (_Cursor = nil) then
	_Cursor := TSCursor.Create()
else
	_Cursor.Clear();
Result := False;
IcoFile.Create();
IcoFile.Load(_Stream);
CursorImage := @IcoFile.FImages[_CursorNumber];
if (CursorImage <> nil) then
	begin
	Result := SCopyIcoImageProperties(@IcoFile, CursorImage, _Cursor);
	if Result then
		Result := SLoadICOImage(@IcoFile, CursorImage, _Cursor);
	if Result then
		_Cursor.HotPixel := SVertex2int32Import(CursorImage^.FHeader.FPlanes, CursorImage^.FHeader.FBpp);
	CursorImage := nil;
	end;
IcoFile.Destroy();
FillChar(IcoFile, SizeOf(IcoFile), 0);
end;

function SIsICOData(const _Stream : TStream) : TSBoolean;
var
	IcoHeader_Reserved : TSUInt16; // Reserved. Must always be 0.
	IcoHeader_Type : TSUInt16; // SIcoFile(1) or SCurFile(2) (type TSIcoFileType)
begin
Result := False;
if (_Stream <> nil) then
	begin
	_Stream.Position := 0;
	_Stream.ReadBuffer(IcoHeader_Reserved, SizeOf(IcoHeader_Reserved));
	_Stream.ReadBuffer(IcoHeader_Type, SizeOf(IcoHeader_Type));
	Result := (IcoHeader_Reserved = 0) and ((IcoHeader_Type = SIcoFile) or (IcoHeader_Type = SCurFile));
	_Stream.Position := 0;
	end;
end;

function SLoadICO(const _Stream : TStream; var _Image : TSBitMap; const _ImageNumber : TSUInt32 = 0) : TSBoolean; overload;
var
	IcoFile : TSIcoFile;
	ICOImage : PSIcoImage = nil;
begin
if (_Image = nil) then
	_Image := TSBitMap.Create()
else
	_Image.Clear();
Result := False;
IcoFile.Create();
IcoFile.Load(_Stream);
ICOImage :=  @IcoFile.FImages[_ImageNumber];
if (ICOImage <> nil) then
	begin
	Result := SCopyIcoImageProperties(@IcoFile, ICOImage, _Image);
	if Result then
		Result := SLoadICOImage(@IcoFile, ICOImage, _Image);
	ICOImage := nil;
	end;
IcoFile.Destroy();
FillChar(IcoFile, SizeOf(IcoFile), 0);
end;

function SLoadICO(const _Stream : TStream; const _ImageNumber : TSUInt32 = 0) : TSBitMap; overload;
begin
Result := TSBitMap.Create();
if (not SLoadICO(_Stream, Result, _ImageNumber)) then
	SKill(Result);
end;

function SLoadCUR(const _Stream : TStream; const _CursorNumber : TSUInt32 = 0) : TSCursor; overload;
begin
Result := TSCursor.Create();
if (not SLoadCUR(_Stream, Result, _CursorNumber)) then
	SKill(Result);
end;

function SSaveICO(const _Stream : TStream; const _Image : TSBitMap) : TSBoolean; overload;
begin
Result := False;
if (_Image <> nil) then // is necessary
	begin
	//todo
	end;
end;

function SSaveCUR(const _Stream : TStream; const _Cursor : TSCursor) : TSBoolean; overload;
begin
Result := False;
if (_Cursor <> nil) then // is necessary
	begin
	//todo
	end;
end;

initialization
begin
SResourceManager.AddManipulator(TSResourceManipulatorImagesICO);
end;

end.
