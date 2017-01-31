{$INCLUDE SaGe.inc}

unit SaGeImages;

interface

uses
		// Engine
	 SaGeBase
	,SaGeImagesBase
	,SaGeCommonClasses
	,SaGeCommon
	,SaGeRenderConstants
		// System
	,Classes
	;
type
	TSGImage = class;
	TSGTextureBlock = class;

	TSGITextureType = (SGITextureTypeTexture, SGITextureTypeBump);

	PSGImage  = ^ TSGImage;
	// Класс изображения и текстуры
	TSGImage = class(TSGDrawable)
			public
		constructor Create(const NewWay : string = '');
		destructor Destroy();override;
		class function ClassName() : TSGString; override;
		procedure DeleteDeviceResources();override;
		procedure LoadDeviceResources();override;
			public
		// А это само изображение ( в оперативной памяти, в виде последовательности байнов, и свойств изобрадения )
		// В общем это BitMap (битовая карта)
		FImage   : TSGBitMap;

		// Поток, в которы подгружается изобрадения, при его загрузке.
		// Сделано MemoryStream чтобы очень быстро грузилось.
		FStream  : TMemoryStream;

		// Идентификатор текстуры
		FTexture : TSGRenderTexture;
		// for ActiveTexture
		FTextureNumber : TSGInteger;
		// what it the texture
		FTextureType   : TSGITextureType;

		// Возвращает, загружено изображение в оперативную память в виде TSGBitMap, или нет
		FReadyToGoToTexture : TSGBoolean;
		//Путь в файлу
		FWay                : TSGString;
		//ФОрмат, в который сохранится изображзение прии его сохранении
		FSaveFormat:TSGIByte;

		//Имя изображения/материала и тп
		FName : TSGString;
			public
		property TextureNumber : TSGInteger      read FTextureNumber write FTextureNumber;
		property TextureType   : TSGITextureType read FTextureType   write FTextureType;
			protected
		procedure LoadMBMToBitMap(const Position:TSGUInt32 = 20);
		procedure LoadToMemory();virtual;
		function LoadToBitMap():TSGBoolean;virtual;
		function GetBitMapBits():TSGBitMapUInt;
		procedure SetBitMapBits(const Value:TSGBitMapUInt);
		class function GetLongWord(const FileBits:PByte;const Position:TSGUInt32):TSGUInt32;
		class function GetLongWordBack(const FileBits:PByte;const Position:TSGUInt32):TSGUInt32;
			public
		procedure Saveing(const Format:TSGByte = SGI_DEFAULT);
		function Loading():TSGBoolean;virtual;
		procedure SaveToStream(const Stream:TStream);
		procedure ToTexture();virtual;
		procedure ToTextureWithBlock(const VTexturesBlock : TSGTextureBlock);
		procedure BindTexture();
		procedure DisableTexture();
		function ReadyTexture():TSGBoolean;
		procedure FreeSream();
		procedure FreeBits();
		procedure FreeSome();
		procedure FreeTexture();
		procedure FreeAll();
		function Ready():TSGBoolean;virtual;
			public
		property FormatType         : TSGBitMapUInt read FImage.FFormatType  write FImage.FFormatType;
		property DataType           : TSGBitMapUInt read FImage.FDataType    write FImage.FDataType;
		property Channels           : TSGBitMapUInt read FImage.FChannels    write FImage.FChannels;
		property BitDepth           : TSGBitMapUInt read FImage.FSizeChannel write FImage.FSizeChannel;
		property Texture            : TSGRenderTexture read FTexture            write FTexture;
		property Height             : TSGBitMapUInt read FImage.FHeight      write FImage.FHeight;
		property Width              : TSGBitMapUInt read FImage.FWidth       write FImage.FWidth;
		property Bits               : TSGBitMapUInt read GetBitMapBits       write SetBitMapBits;
		property BitMap             : PSGByte       read FImage.FBitMap      write FImage.FBitMap;
		property Image              : TSGBitMap   read FImage;
		property Way                : TSGString   read FWay                write FWay;
		property ReadyToGoToTexture : TSGBoolean  read FReadyToGoToTexture write FReadyToGoToTexture;
		property ReadyGoToTexture   : TSGBoolean  read FReadyToGoToTexture write FReadyToGoToTexture;
		property ReadyToTexture     : TSGBoolean  read FReadyToGoToTexture write FReadyToGoToTexture;
		property Name               : TSGString   read FName               write FName;
			public //Render Functions:
		procedure DrawImageFromTwoVertex2f(Vertex1,Vertex2: TSGVertex2f;const RePlace:Boolean = True;const RePlaceY:TSGByte = SG_3D;const Rotation:Byte = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure DrawImageFromTwoPoint2int32(Vertex1,Vertex2: TSGPoint2int32;const RePlace:Boolean = True;const RePlaceY:TSGByte = SG_3D;const Rotation:Byte = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ImportFromDispley(const Point1,Point2: TSGPoint2int32;const NeedAlpha:Boolean = True);
		procedure ImportFromDispley(const NeedAlpha:Boolean = True);
		class function UnProjectShift:TSGPoint2int32;
		procedure DrawImageFromTwoVertex2fAsRatio(Vertex1,Vertex2:TSGVertex2f;const RePlace:Boolean = True;const Ratio:real = 1);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure DrawImageFromTwoVertex2fWithTexPoint(Vertex1,Vertex2: TSGVertex2f;const TexPoint:TSGVertex2f;const RePlace:Boolean = True;const RePlaceY:TSGByte = SG_3D;const Rotation:Byte = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure DrawImageFromTwoVertex2fWith2TexPoint(Vertex1,Vertex2: TSGVertex2f;const TexPoint1,TexPoint2:TSGVertex2f;const RePlace:Boolean = True;const RePlaceY:TSGByte = SG_3D;const Rotation:Byte = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure RePlacVertex(var Vertex1,Vertex2: TSGVertex2f;const RePlaceY:TSGByte = SG_3D);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;
	
	TSGImageList = packed array of TSGImage;

type
	TSGTextureBlock = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
			private
		FTextures : packed array of
			packed record
				FHandle : TSGRenderTexture;
				FWasUsed : TSGBoolean;
				end;
			private
		procedure SetSize(const VSize : TSGLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetSize():TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		procedure Generate();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetNextUnusebleTexture():TSGRenderTexture;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property Size : TSGLongWord read GetSize write SetSize;
		end;

procedure SGConvertToSGIA(const InFile, OutFile : TSGString);
procedure SGKillImage(var Image : TSGImage);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
		// Image formats
	 SaGeImagesBmp
	,SaGeImagesJpeg
	{$IFDEF WITHLIBPNG}
		,SaGeImagesPng
		{$ENDIF}
	,SaGeImagesTga
	,SaGeImagesSgia
	,SaGeImageFormatDeterminer
	,SaGeLog
	
		// System
	,Crt
	,Dos
	,SysUtils
	
		// Engine
	,SaGeResourceManager
	,SaGeFileUtils
	,SaGeStringUtils
	;

procedure SGKillImage(var Image : TSGImage);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
try
Image.Destroy();
except
end;
try
Image := nil;
except
end;
end;

procedure TSGImage.LoadDeviceResources();
begin
if not (ReadyGoToTexture or (Texture <> 0)) then
	Loading();
end;

procedure TSGImage.DeleteDeviceResources();
var
	IsHasTexture : TSGBoolean;
begin
IsHasTexture := FTexture <> 0;
FreeTexture();
FReadyToGoToTexture := IsHasTexture and (FImage.BitMap <> nil);
end;

constructor TSGTextureBlock.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FTextures := nil;
end;

destructor TSGTextureBlock.Destroy();
var
	i : TSGLongWord;
begin
if FTextures <> nil then
	begin
	if Length(FTextures) > 0 then
		for i := 0 to High(FTextures) do
			if (not FTextures[i].FWasUsed) and (FTextures[i].FHandle > 0) then
				Render.DeleteTextures(1,@FTextures[i].FHandle);
	SetLength(FTextures,0);
	end;
inherited;
end;

procedure TSGTextureBlock.SetSize(const VSize : TSGLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	OldSize, i : TSGLongWord;
begin
OldSize := Size;
if VSize > OldSize then
	begin
	SetLength(FTextures,VSize);
	for i := OldSize to Size - 1 do
		begin
		FTextures[i].FHandle := 0;
		FTextures[i].FWasUsed := False;
		end;
	end;
end;

function TSGTextureBlock.GetSize():TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if FTextures = nil then
	Result := 0
else
	Result := Length(FTextures);
end;

procedure TSGTextureBlock.Generate();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
const
	Show = False;
var
	Ar : packed array of TSGRenderTexture;
	i : TSGLongWord;
begin
if Size > 0 then
	begin
	SetLength(Ar,Size);
	Render.Enable(SGR_TEXTURE_2D);
	Render.GenTextures(Size, @Ar[0]);
	Render.Disable(SGR_TEXTURE_2D);
	for i := 0 to Size - 1 do
		begin
		FTextures[i].FWasUsed := False;
		FTextures[i].FHandle := Ar[i];
		if Show then
			Write(Ar[i],' ');
		end;
	if Show then
		WriteLn();
	SetLength(Ar,0);
	end;
end;

function TSGTextureBlock.GetNextUnusebleTexture():TSGRenderTexture;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
begin
Result := 0;
if (FTextures <> nil) then
	if (Length(FTextures) > 0) then
		for i := 0 to Size - 1 do
			if (not FTextures[i].FWasUsed) and (FTextures[i].FHandle > 0) then
				begin
				Result := FTextures[i].FHandle;
				FTextures[i].FWasUsed := True;
				break;
				end;
end;

procedure SGConvertToSGIA(const InFile,OutFile:TSGString);
var
	Image: TSGImage = nil;
begin
Image:=TSGImage.Create();
Image.Way := InFile;
Image.Loading();
Image.Way := OutFile;
Image.Saveing(SGI_SGIA);
Image.Destroy();
end;

(****************************)
(*RENDER FUNCTIONS FOR IMAGE*)
(****************************)

procedure TSGImage.ToTextureWithBlock(const VTexturesBlock : TSGTextureBlock);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if FTexture <> 0 then
	FreeTexture();
FTexture := VTexturesBlock.GetNextUnusebleTexture();
ToTexture();
end;

procedure TSGImage.DrawImageFromTwoPoint2int32(Vertex1,Vertex2: TSGPoint2int32;const RePlace:Boolean = True;const RePlaceY:TSGByte = SG_3D;const Rotation:Byte = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function PointToVertex(const P : TSGPoint2int32):TSGVertex2f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(P.x, P.y);
end;
begin
DrawImageFromTwoVertex2f(PointToVertex(Vertex1),PointToVertex(Vertex2),RePlace,RePlaceY,Rotation);
end;

procedure TSGImage.DrawImageFromTwoVertex2f(Vertex1,Vertex2: TSGVertex2f;const RePlace:Boolean = True;const RePlaceY:TSGByte = SG_3D;const Rotation:Byte = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
DrawImageFromTwoVertex2fWith2TexPoint(Vertex1,Vertex2,SGVertex2fImport(0,0),SGVertex2fImport(1,1),RePlace,RePlaceY,Rotation);
end;

procedure TSGImage.DrawImageFromTwoVertex2fWith2TexPoint(Vertex1,Vertex2: TSGVertex2f;const TexPoint1,TexPoint2:TSGVertex2f;const RePlace:Boolean = True;const RePlaceY:TSGByte = SG_3D;const Rotation:Byte = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure DoTexCoord(const NowRotation:Byte);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case (NowRotation mod 4) of
0:Render.TexCoord2f(TexPoint1.x,TexPoint2.y);
1:Render.TexCoord2f(TexPoint2.x,TexPoint2.y);
2:Render.TexCoord2f(TexPoint2.x,TexPoint1.y);
3:Render.TexCoord2f(TexPoint1.x,TexPoint1.y);
end;
end;
begin
if RePlace then
	begin
	RePlacVertex(Vertex1,Vertex2,rePlaceY);
	end;
BindTexture();
Render.BeginScene(SGR_QUADS);
DoTexCoord(Rotation);
Render.Vertex(Vertex1);
DoTexCoord(Rotation+1);
Render.Vertex2f(Vertex2.x,Vertex1.y);
DoTexCoord(Rotation+2);
Render.Vertex(Vertex2);
DoTexCoord(Rotation+3);
Render.Vertex2f(Vertex1.x,Vertex2.y);
Render.EndScene();
DisableTexture();
end;

procedure TSGImage.DrawImageFromTwoVertex2fWithTexPoint(Vertex1,Vertex2: TSGVertex2f;const TexPoint:TSGVertex2f;const RePlace:Boolean = True;const RePlaceY:TSGByte = SG_3D;const Rotation:Byte = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
DrawImageFromTwoVertex2fWith2TexPoint(Vertex1,Vertex2,SGVertex2fImport(0,0),TexPoint,RePlace,RePlaceY,Rotation);
end;


procedure TSGImage.DrawImageFromTwoVertex2fAsRatio(Vertex1,Vertex2:TSGVertex2f;const RePlace:Boolean = True;const Ratio:real = 1);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if RePlace then
	RePlacVertex(Vertex1,Vertex2,SG_2D);
DrawImageFromTwoVertex2f(
	SGVertex2fImport(
		Vertex1.x+abs(Vertex1.x-Vertex2.x)*((1-Ratio)/2),
		Vertex1.y+abs(Vertex1.y-Vertex2.y)*((1-Ratio)/2)),
	SGVertex2fImport(
		Vertex2.x-abs(Vertex1.x-Vertex2.x)*((1-Ratio)/2),
		Vertex2.y-abs(Vertex1.y-Vertex2.y)*((1-Ratio)/2)),
	RePlace,SG_2D);
end;

procedure TSGImage.RePlacVertex(var Vertex1,Vertex2: TSGVertex2f;const RePlaceY:TSGByte = SG_3D);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Vertex1.x>Vertex2.x then
	SGQuickRePlaceVertexType(Vertex1.x,Vertex2.x);
case RePlaceY of
SG_2D:
	begin
	if Vertex1.y>Vertex2.y then
		SGQuickRePlaceVertexType(Vertex1.y,Vertex2.y);
	end;
else
	begin
	if Vertex1.y<Vertex2.y then
		SGQuickRePlaceVertexType(Vertex1.y,Vertex2.y);
	end;
end;
end;

class function TSGImage.UnProjectShift:TSGPoint2int32;
begin
//Result:=TSGViewportObject.Smezhenie;
	//onu:{$}
	Result.Import();
end;

procedure TSGImage.ImportFromDispley(const NeedAlpha:Boolean = True);
begin
ImportFromDispley(
	SGVertex2int32Import(1,1),
	SGVertex2int32Import(Render.Width,Render.Height),
	NeedAlpha);
end;

procedure TSGImage.ImportFromDispley(const Point1,Point2: TSGPoint2int32;const NeedAlpha:Boolean = True);
begin
if Self <> nil then
	FreeAll()
else
	Self := TSGImage.Create();
Width := Point2.x - Point1.x + 1;
Height := Point2.y - Point1.y + 1;
Bits := 24 + 8 * TSGByte(NeedAlpha);
Render.ReadPixels(
	Point1.x-1,
	Point1.y-1,
	Point2.x-Point1.x+1,
	Point2.y-Point1.y+1,
	SGR_RGBA * TSGByte(NeedAlpha) + SGR_RGB * TSGByte(not NeedAlpha),
	SGR_UNSIGNED_BYTE,
	FImage.BitMap);
FReadyToGoToTexture := True;
end;

(****************************)
(*OTHERS FUNCTIONS FOR IMAGE*)
(****************************)

procedure TSGImage.SaveToStream(const Stream:TStream);
begin
if (FImage<>nil) and (FImage.BitMap<>nil) then
	begin
	if SGResourceManager.SaveingIsSuppored('PNG') then
		SGResourceManager.SaveResourceToStream(Stream,'PNG',FImage)
	else
		if SGResourceManager.SaveingIsSuppored('BMP') then
			SGResourceManager.SaveResourceToStream(Stream,'BMP',FImage);
	end
else
	if (FWay<>'') and FileExists(FWay) then
		with TMemoryStream.Create() do
			begin
			LoadFromFile(FWay);
			SaveToStream(Stream);
			Destroy();
			end;
end;

procedure TSGImage.Saveing(const Format:TSGByte = SGI_DEFAULT);
var
	SaveFormat : TSGByte;
	Stream:TMemoryStream = nil;

procedure SaveJpg();
var
	BmpStream:TMemoryStream = nil;
begin
BmpStream:=TMemoryStream.Create;
SaveBMP(FImage,BmpStream);
BmpStream.Position:=0;
SaveJPEG(BmpStream,Stream);
BmpStream.Destroy();
end;

function GetDefSaveFormat() : TSGByte;
begin
if Channels=3 then
	begin
	{$IFDEF WITHLIBPNG}
	if SupporedPNG() then
		Result := SGI_PNG
	else
	{$ELSE}
		Result:=SGI_JPEG;
	{$ENDIF}
	end
else if Channels=4 then
	begin
	{$IFDEF WITHLIBPNG}
	if SupporedPNG() then
		Result := SGI_PNG
	else
	{$ELSE}
		Result:=SGI_SGIA;
	{$ENDIF}
	end
else
	Result:=SGI_JPEG
end;

begin
if (FImage=nil) or (FImage.BitMap=nil) then
	Exit;
if Format=SGI_DEFAULT then
	SaveFormat := GetDefSaveFormat()
else
	SaveFormat:=Format;
{$IFDEF WITHLIBPNG}
if (SaveFormat = SGI_PNG) and (not SupporedPNG()) then
	begin
	if Channels = 4 then
		begin
		SaveFormat := SGI_SGIA;
		SGLog.Source('TSGImage.Saveing - Saving to PNG is impossible, save format replaced to SGI_SGIA.');
		end
	else
		begin
		SaveFormat := SGI_JPEG;
		SGLog.Source('TSGImage.Saveing - Saving to PNG is impossible, save format replaced to SGI_JPEG.');
		end;
	end;
{$ENDIF}
Stream:=TMemoryStream.Create();
case SaveFormat of
SGI_SGIA:
	begin
	SaveSGIA(Stream,FImage);
	end;
{$IFDEF WITHLIBPNG}
	SGI_PNG:
		begin
		{$IFDEF SGDebuging}
			SGLog.Source('TSGImage  : Saveing "'+FWay+'" as PNG');
			{$ENDIF}
		if SGResourceManager.SaveingIsSuppored('PNG') then
			SGResourceManager.SaveResourceToStream(Stream,'PNG',FImage);
		end;
	{$ENDIF}
SGI_JPEG:
	begin
	{$IFDEF SGDebuging}
		SGLog.Source('TSGImage  : Saveing "'+FWay+'" as JPEG');
		{$ENDIF}
	SaveJpg();
	end;
SGI_BMP:
	begin
	{$IFDEF SGDebuging}
		SGLog.Source('TSGImage  : Saveing "'+FWay+'" as BMP');
		{$ENDIF}
	SaveBMP(FImage,Stream);
	end;
else
	begin
	Stream.Destroy;
	Stream:=nil;
	end;
end;
if Stream<>nil then
	begin
	Stream.Position:=0;
	Stream.SaveToFile(SGSetExpansionToFileName(Way, TSGImageFormatDeterminer.DetermineExpansionFromFormat(SaveFormat)));
	Stream.Destroy();
	end;
end;

function TSGImage.Loading():TSGBoolean;
begin
{$IFDEF ANDROID}SGLog.Source('Enterind "TSGImage__Loading".');{$ENDIF}

Result:=False;
LoadToMemory();
if (FStream<>nil) and (FStream.Size<>0) then
	LoadToBitMap();
Result:=ReadyToGoToTexture;

{$IFDEF ANDROID}SGLog.Source('Leaving "TSGImage__Loading". Result = "'+SGStr(Result)+'"');{$ENDIF}
end;

procedure TSGImage.SetBitMapBits(const Value : TSGBitMapUInt);
begin
case Value of
16:
	begin
	FImage.SizeChannel:=4;
	FImage.Channels:=4;
	end;
24:
	begin
	FImage.Channels:=3;
	FImage.SizeChannel:=8;
	end;
32:
	begin
	FImage.Channels:=4;
	FImage.SizeChannel:=8;
	end;
else
	begin
	FImage.Channels:=0;
	FImage.SizeChannel:=0;
	end;
end;
FImage.CreateTypes();
end;

function TSGImage.GetBitMapBits() : TSGBitMapUInt;
begin
Result := FImage.SizeChannel * FImage.Channels;
end;

function TSGImage.Ready:Boolean;
begin
Result:=ReadyTexture;
end;

procedure TSGImage.LoadMBMToBitMap(const Position:TSGUInt32 = 20);
var
	I:LongWord;
	Compression:Boolean = False;
begin
try
	FImage.Width:=GetLongWord(PByte(FStream.Memory),Position+8);
	FImage.Height:=GetLongWord(PByte(FStream.Memory),Position+12);
	Bits:=GetLongWord(PByte(FStream.Memory),Position+24);
	Compression:=(GetLongWord(PByte(FStream.Memory),Position+36)<>0);
	FImage.ReAllocateMemory();
	FImage.CreateTypes();
	case Bits of
	24:
		begin
		if Compression then
			begin

			end
		else
			begin
			for i:=0 to Width*Height-1 do
				begin
				FImage.BitMap[i*3+0]:=PByte(FStream.Memory)[Position+40+i*3+2];
				FImage.BitMap[i*3+1]:=PByte(FStream.Memory)[Position+40+i*3+1];
				FImage.BitMap[i*3+2]:=PByte(FStream.Memory)[Position+40+i*3+0];
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
	FreeBits();
	end;

	{writeln(Width);
	writeln(Height);
	writeln(BitMapBits);}
end;

procedure TSGImage.FreeTexture();
begin
if RenderAssigned() and (FTexture <> 0) then
	begin
	Render.DeleteTextures(1,@FTexture);
	FTexture := 0;
	end;
end;

destructor TSGImage.Destroy();
begin
FreeAll();
if FImage <> nil then
	begin
	FImage.Destroy();
	FImage := nil;
	end;
inherited;
end;

procedure TSGImage.FreeSome();
begin
FreeBits();
FreeSream();
end;

procedure TSGImage.FreeAll;
begin
FreeSome;
FreeTexture;
if FImage <> nil then
	FImage.Clear();
end;

procedure TSGImage.DisableTexture();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if FTextureNumber = -1 then
	begin
	Render.BindTexture(SGR_TEXTURE_2D,0);
	Render.Disable(SGR_TEXTURE_2D);
	end
else
	begin
	Render.ActiveTexture(FTextureNumber);
	Render.BindTexture(SGR_TEXTURE_2D,0);
	Render.Disable(SGR_TEXTURE_2D);
	Render.ActiveTexture(0);
	end;
end;

procedure TSGImage.BindTexture();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (FTexture=0) and (FReadyToGoToTexture) then
	begin
	ToTexture();
	FreeBits();
	end;
if FTextureNumber = -1 then
	begin
	Render.Enable(SGR_TEXTURE_2D);
	Render.BindTexture(SGR_TEXTURE_2D,FTexture);
	Render.ActiveTextureDiffuse();
	end
else
	begin
	Render.ActiveTexture(FTextureNumber);
	Render.BindTexture(SGR_TEXTURE_2D,FTexture);
	Render.Enable(SGR_TEXTURE_2D);
	if FTextureType = SGITextureTypeBump then
		Render.ActiveTextureBump()
	else
		Render.ActiveTextureDiffuse();
	Render.ActiveTexture(0);
	end;
end;

class function TSGImage.GetLongWordBack(const FileBits:PByte;const Position:TSGUInt32):TSGUInt32;
begin
Result:=FileBits[Position+3]+FileBits[Position+2]*256+FileBits[Position+1]*256*256+FileBits[Position]*256*256*256;
end;

class function TSGImage.GetLongWord(const FileBits:PByte;const Position:TSGUInt32):TSGUInt32;
begin
Result:=FileBits[Position]+FileBits[Position+1]*256+FileBits[Position+2]*256*256+FileBits[Position+3]*256*256*256;
end;

function TSGImage.LoadToBitMap():TSGBoolean;
var
	ImageFormat : TSGImageFormat = 0;
begin
{$IFDEF ANDROID}SGLog.Source('Enterind "TSGImage__LoadToBitMap".');{$ENDIF}
Result:=False;
FStream.Position:=0;
ImageFormat := TSGImageFormatDeterminer.DetermineFormat(FStream);
if (ImageFormat = 0) and (SGUpCaseString(SGFileExpansion(Way)) = 'TGA') then
	ImageFormat := SGI_TGA;
if ImageFormat = 0 then
	SGLog.Source(['TSGImage.LoadToBitMap() : Determining image format for "' + Way + '" failed!'])
else
	case ImageFormat of
	SGI_TGA :
		begin
		if FImage<>nil then
			FImage.Destroy();
		FImage := LoadTGA(FStream);
		end;
	SGI_JPEG :
		LoadJPEGToBitMap(FStream, FImage);
	SGI_BMP :
		LoadBMP(FStream, FImage);
	SGI_SGIA :
		LoadSGIAToBitMap(FStream, FImage);
	SGI_MBM :
		LoadMBMToBitMap();
	{$IFDEF WITHLIBPNG}
	SGI_PNG :
		if SGResourceManager.LoadingIsSuppored('PNG') then
			begin
			if FImage <> nil then
				FImage.Destroy();
			FImage := SGResourceManager.LoadResourceFromStream(FStream, 'PNG') as TSGBitMap;
			end;
	{$ENDIF}
	else
		SGLog.Source(['TSGImage.LoadToBitMap() : Unknown image format "' + Way + '"!'])
	end;
if FImage = nil then
	FImage := TSGBitMap.Create();
Result:=FImage.BitMap<>nil;
{$IFDEF SGDebuging}
	SGLog.Source('TSGImage  : Loaded "' + FWay + '" as ' + SGUpCaseString(TSGImageFormatDeterminer.DetermineExpansionFromFormat(ImageFormat)) + ' is "'+SGStr(Result)+'"');
	{$ENDIF}
FReadyToGoToTexture:=Result;
{$IFDEF ANDROID}SGLog.Source('Leaving "TSGImage__LoadToBitMap". Result="'+SGStr(Result)+'"');{$ENDIF}
end;

procedure TSGImage.FreeSream();
begin
if FStream<>nil then
	begin
	FStream.Destroy();
	FStream:=nil;
	end;
end;

procedure TSGImage.FreeBits();
begin
if FImage <> nil then
	FImage.ClearBitMapBits();
end;

procedure TSGImage.LoadToMemory();
begin
if FStream=nil then
	FStream:=TMemoryStream.Create()
else
	begin
	FStream.Free();
	FStream:=TMemoryStream.Create();
	end;
SGResourceFiles.LoadMemoryStreamFromFile(FStream,FWay);
FStream.Position:=0;
{$IFDEF ANDROID}SGLog.Source('Leaving "TSGImage__LoadToMemory". Way="'+FWay+'", FStream.Size="'+SGStr(FStream.Size)+'".');{$ENDIF}
end;

procedure TSGImage.ToTexture();
begin
Render.Enable(SGR_TEXTURE_2D);

if FTexture = 0 then
	Render.GenTextures(1, @FTexture);

if FTexture = 0 then
	Exit;

Render.BindTexture(SGR_TEXTURE_2D, FTexture);
{$IFNDEF MOBILE}
	Render.PixelStorei(SGR_UNPACK_ALIGNMENT, 4);
	Render.PixelStorei(SGR_UNPACK_ROW_LENGTH, 0);
	Render.PixelStorei(SGR_UNPACK_SKIP_ROWS, 0);
	Render.PixelStorei(SGR_UNPACK_SKIP_PIXELS, 0);
	{$ENDIF}
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_MIN_FILTER, SGR_LINEAR);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_MAG_FILTER, SGR_NEAREST);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_WRAP_S, SGR_REPEAT);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_WRAP_T, SGR_REPEAT);
Render.TexImage2D(SGR_TEXTURE_2D, 0, Channels, Width, Height, 0, FormatType, DataType, FImage.BitMap);
Render.BindTexture(SGR_TEXTURE_2D, 0);
{$IFDEF MOBILE}
	Render.GenerateMipmap(SGR_TEXTURE_2D);
	{$ENDIF}
Render.Disable(SGR_TEXTURE_2D);
FReadyToGoToTexture:=False;
{$IFDEF SGDebuging}
	SGLog.Source('TSGImage  : Loaded to texture "'+FWay+'" is "'+SGStr(FTexture<>0)+'"("'+SGStr(FTexture)+'").');
	{$ENDIF}
end;


function TSGImage.ReadyTexture:Boolean;
begin
Result:=FTexture<>0;
end;

class function TSGImage.ClassName() : TSGString;
begin
Result := 'TSGImage';
end;

constructor TSGImage.Create(const NewWay:string = '');
begin
inherited Create();
FTextureNumber := -1;
FTextureType := SGITextureTypeTexture;
FTexture:=0;
FReadyToGoToTexture:=False;
Way:=NewWay;
FImage:=TSGBitMap.Create();
FStream:=nil;
FName:='';
end;


initialization
begin

end;

end.
