//Спецификации формата ICO и CUR найдены в онлайн-библиотеке Wikipedia

{$INCLUDE SaGe.inc}

unit SaGeImageICO;

interface

uses
	 SaGeBitMap
	,SaGeBase
	
	,Classes
	;

const
	ICONTYPE_ICO = 1;
	ICONTYPE_CUR = 2;
type
	TSGIcoFileHeader = object
			public
		FReserved : TSGUInt16; // Reserved. Must always be 0.
		FType : TSGUInt16; // ICONTYPE_ICO or ICONTYPE_CUR
		FCount : TSGUInt16; // Specifies number of images in the file.
		end;
	
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
	
	TSGIcoImage = object
			public
		FHeader : TSGIcoImageHeader;
		FData : TMemoryStream; // BMP or PNG
		end;
	
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

procedure SaveICO(const _Stream : TStream; var _Image : TSGBitMap);
procedure LoadICO(const _Stream : TStream; var _Image : TSGBitMap);
function IsICOData(const _Stream : TStream) : TSGBoolean;

implementation

uses
	 SaGeStreamUtils
	,SaGeImageBmp // BMP
	,SaGeResourceManager // PNG and others
	
	,SysUtils
	;

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
for Index := 0 to High(FImages) do
	FillChar(FImages[Index], SizeOf(FImages[Index]), 0);
for Index := 0 to High(FImages) do
	begin
	_Stream.ReadBuffer(FImages[Index].FHeader, SizeOf(FImages[Index].FHeader));
	if (FImages[Index].FHeader.FSize <> 0) then
		begin
		FImages[Index].FData := TMemoryStream.Create();
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

//======================================================================
//======================================================================
//======================================================================

function IsICOData(const _Stream : TStream) : TSGBoolean;
begin
Result := False;
if (_Stream <> nil) then
	begin
	_Stream.Position := 0;
	//todo
	end;
end;

procedure LoadICO(const _Stream : TStream; var _Image : TSGBitMap);
var
	FFile : TSGIcoFile;
begin
if (_Image = nil) then
	_Image := TSGBitMap.Create()
else
	_Image.Clear();
FFile.Create();
FFile.Load(_Stream);
//todo
FFile.Destroy();
FillChar(FFile, SizeOf(FFile), 0);
end;

procedure SaveICO(const _Stream : TStream; var _Image : TSGBitMap);
begin
//todo
end;

end.
