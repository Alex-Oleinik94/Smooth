{$INCLUDE Smooth.inc}

//{$DEFINE SDebuging}

unit SmoothImage;

interface

uses
		// Engine
	 SmoothBase
	,SmoothBitMap
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothCommon
	,SmoothRenderBase
	,SmoothRenderInterface
	,SmoothCommonStructs
	,SmoothImageFormatDeterminer
	,SmoothBitMapBase
		// System
	,Classes
	;
type
	TSImage = class;
	TSTextureBlock = class;

	TSITextureType = (SITextureTypeTexture, SITextureTypeBump);

	PSImage  = ^ TSImage;
	// Класс изображения и текстуры
	TSImage = class(TSContextObject)
			public
		constructor Create(const VFileName : TSString = '');
		destructor Destroy();override;
		class function ClassName() : TSString; override;
		procedure DeleteRenderResources();override;
		procedure LoadRenderResources();override;
			public
		// Данные изображения (свойства изображения и последовательность байтов, характеризующих цвета пикселей)
		// В общем "BitMap" ("карта BIT-ов")
		FBitMap : TSBitMap;
		
		// Идентификатор текстуры
		FTexture : TSRenderTexture;
		FIsBitsFreeAfterTextureLoad : TSBoolean;
		// for ActiveTexture
		FTextureNumber : TSInteger;
		// what it the texture
		FTextureType   : TSITextureType;
		
		// Возвращает, загружено изображение в оперативную память в виде TSBitMap, или нет
		FLoadedIntoRAM : TSBoolean;
		// Путь в файлу
		FFileName      : TSString;
		
		//Имя изображения или материала
		FName : TSString;
			public
		property TextureNumber : TSInteger      read FTextureNumber write FTextureNumber;
		property TextureType   : TSITextureType read FTextureType   write FTextureType;
			protected
		function HasAlphaChannel() : TSBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		function Load(const Stream : TStream) : TSBool;
		function Save(const Stream : TStream) : TSBool;
		function Load() : TSBoolean; virtual;
		function Save(const Format : TSImageFormat = SImageFormatNull) : TSBoolean; virtual;
		function Loaded() : TSBoolean; virtual;
			public
		procedure LoadTexture(); virtual;
		procedure LoadTextureWithBlock(const VTexturesBlock : TSTextureBlock);
		procedure BindTexture();
		procedure DisableTexture();
		procedure FreeBits();
		procedure FreeTexture();
		procedure FreeAll();
		function TextureLoaded() : TSBoolean;
		function BitMapHasData() : TSBoolean;
			public
		property Height             : TSBitMapUInt    read FBitMap.FHeight;
		property Width              : TSBitMapUInt    read FBitMap.FWidth;
		property BitMap             : TSBitMap        read FBitMap;
		property LoadedIntoRAM      : TSBoolean       read FLoadedIntoRAM write FLoadedIntoRAM;
		property Texture            : TSRenderTexture read FTexture;
		property IsBitsFreeAfterTextureLoad : TSBoolean read FIsBitsFreeAfterTextureLoad write FIsBitsFreeAfterTextureLoad;
		property FileName           : TSString        read FFileName write FFileName;
		property Name               : TSString        read FName     write FName;
		property HasAlpha           : TSBool          read HasAlphaChannel;
			public // Render functions:
		procedure DrawImageFromTwoVertex2f(Vertex1,Vertex2: TSVertex2f;const RePlace:Boolean = True;const RePlaceY:TSByte = S_3D;const Rotation:Byte = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure DrawImageFromTwoPoint2int32(Vertex1,Vertex2: TSPoint2int32;const RePlace:Boolean = True;const RePlaceY:TSByte = S_3D;const Rotation:Byte = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ImportFromDispley(const Point1,Point2: TSPoint2int32;const NeedAlpha:Boolean = True);
		procedure ImportFromDispley(const NeedAlpha:Boolean = True);
		class function UnProjectShift:TSPoint2int32;
		procedure DrawImageFromTwoVertex2fAsRatio(Vertex1,Vertex2:TSVertex2f;const RePlace:Boolean = True;const Ratio:real = 1);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure DrawImageFromTwoVertex2fWithTexPoint(Vertex1,Vertex2: TSVertex2f;const TexPoint:TSVertex2f;const RePlace:Boolean = True;const RePlaceY:TSByte = S_3D;const Rotation:Byte = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure DrawImageFromTwoVertex2fWith2TexPoint(Vertex1,Vertex2: TSVertex2f;const TexPoint1,TexPoint2:TSVertex2f;const RePlace:Boolean = True;const RePlaceY:TSByte = S_3D;const Rotation:Byte = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure RePlacVertex(var Vertex1,Vertex2: TSVertex2f;const RePlaceY:TSByte = S_3D);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;
	
	TSImageList = packed array of TSImage;

type
	TSTextureBlock = class(TSContextObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
			private
		FTextures : packed array of
			packed record
				FHandle : TSRenderTexture;
				FWasUsed : TSBoolean;
				end;
			private
		procedure SetSize(const VSize : TSLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetSize():TSLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		procedure Generate();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetNextUnusebleTexture():TSRenderTexture;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property Size : TSLongWord read GetSize write SetSize;
		end;

var
	ImageIsBitsFreeAfterTextureLoad : TSBoolean = True;

procedure SKill(var _Image : TSImage); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SCreateImageFromFile(const _Context : ISContext; const _FileName : TSString; const _LoadTexture : TSBoolean = False) : TSImage;

implementation

uses
		// System
	 Crt
	,Dos
	,SysUtils
	
		// Engine
	,SmoothResourceManager
	,SmoothFileUtils
	,SmoothStringUtils
	,SmoothStreamUtils
	,SmoothBaseUtils
	,SmoothLog
	,SmoothBitMapUtils
	;

function SCreateImageFromFile(const _Context : ISContext; const _FileName : TSString; const _LoadTexture : TSBoolean = False) : TSImage;
begin
Result := TSImage.Create(_FileName);
Result.Context := _Context;
Result.Load();
if (_LoadTexture) then
	Result.LoadTexture();
end;

procedure SKill(var _Image : TSImage); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (_Image <> nil) then
	begin
	try
	_Image.Destroy();
	except
	end;
	try
	_Image := nil;
	except
	end;
	end;
end;

(***************)
(*TEXTURE BLOCK*)
(***************)

constructor TSTextureBlock.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FTextures := nil;
end;

destructor TSTextureBlock.Destroy();
var
	i : TSLongWord;
begin
if FTextures <> nil then
	begin
	if Length(FTextures) > 0 then
		for i := 0 to High(FTextures) do
			if (not FTextures[i].FWasUsed) and (FTextures[i].FHandle > 0) then
				Render.DeleteTextures(1, @FTextures[i].FHandle);
	SetLength(FTextures,0);
	end;
inherited;
end;

procedure TSTextureBlock.SetSize(const VSize : TSLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	OldSize, i : TSLongWord;
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

function TSTextureBlock.GetSize():TSLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if FTextures = nil then
	Result := 0
else
	Result := Length(FTextures);
end;

procedure TSTextureBlock.Generate();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
const
	Show = False;
var
	Ar : packed array of TSRenderTexture;
	i : TSLongWord;
begin
if Size > 0 then
	begin
	SetLength(Ar,Size);
	Render.Enable(SR_TEXTURE_2D);
	Render.GenTextures(Size, @Ar[0]);
	Render.Disable(SR_TEXTURE_2D);
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

function TSTextureBlock.GetNextUnusebleTexture():TSRenderTexture;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSLongWord;
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

(****************************)
(*RENDER FUNCTIONS FOR IMAGE*)
(****************************)

procedure TSImage.LoadTextureWithBlock(const VTexturesBlock : TSTextureBlock);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (FTexture <> 0) then
	FreeTexture();
FTexture := VTexturesBlock.GetNextUnusebleTexture();
LoadTexture();
end;

procedure TSImage.DrawImageFromTwoPoint2int32(Vertex1,Vertex2: TSPoint2int32;const RePlace:Boolean = True;const RePlaceY:TSByte = S_3D;const Rotation:Byte = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function PointToVertex(const P : TSPoint2int32):TSVertex2f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(P.x, P.y);
end;
begin
DrawImageFromTwoVertex2f(PointToVertex(Vertex1),PointToVertex(Vertex2),RePlace,RePlaceY,Rotation);
end;

procedure TSImage.DrawImageFromTwoVertex2f(Vertex1,Vertex2: TSVertex2f;const RePlace:Boolean = True;const RePlaceY:TSByte = S_3D;const Rotation:Byte = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
DrawImageFromTwoVertex2fWith2TexPoint(Vertex1,Vertex2,SVertex2fImport(0,0),SVertex2fImport(1,1),RePlace,RePlaceY,Rotation);
end;

procedure TSImage.DrawImageFromTwoVertex2fWith2TexPoint(Vertex1,Vertex2: TSVertex2f;const TexPoint1,TexPoint2:TSVertex2f;const RePlace:Boolean = True;const RePlaceY:TSByte = S_3D;const Rotation:Byte = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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
Render.BeginScene(SR_QUADS);
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

procedure TSImage.DrawImageFromTwoVertex2fWithTexPoint(Vertex1,Vertex2: TSVertex2f;const TexPoint:TSVertex2f;const RePlace:Boolean = True;const RePlaceY:TSByte = S_3D;const Rotation:Byte = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
DrawImageFromTwoVertex2fWith2TexPoint(Vertex1,Vertex2,SVertex2fImport(0,0),TexPoint,RePlace,RePlaceY,Rotation);
end;


procedure TSImage.DrawImageFromTwoVertex2fAsRatio(Vertex1,Vertex2:TSVertex2f;const RePlace:Boolean = True;const Ratio:real = 1);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if RePlace then
	RePlacVertex(Vertex1,Vertex2,S_2D);
DrawImageFromTwoVertex2f(
	SVertex2fImport(
		Vertex1.x+abs(Vertex1.x-Vertex2.x)*((1-Ratio)/2),
		Vertex1.y+abs(Vertex1.y-Vertex2.y)*((1-Ratio)/2)),
	SVertex2fImport(
		Vertex2.x-abs(Vertex1.x-Vertex2.x)*((1-Ratio)/2),
		Vertex2.y-abs(Vertex1.y-Vertex2.y)*((1-Ratio)/2)),
	RePlace,S_2D);
end;

procedure TSImage.RePlacVertex(var Vertex1, Vertex2 : TSVertex2f;const RePlaceY : TSByte = S_3D);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Vertex1.x > Vertex2.x then
	Swap(Vertex1.x, Vertex2.x);
case RePlaceY of
S_2D:
	begin
	if Vertex1.y > Vertex2.y then
		Swap(Vertex1.y, Vertex2.y);
	end;
else
	begin
	if Vertex1.y < Vertex2.y then
		Swap(Vertex1.y, Vertex2.y);
	end;
end;
end;

class function TSImage.UnProjectShift:TSPoint2int32;
begin
//Result:=TSViewportObject.Smezhenie;
	//onu:{$}
	Result.Import();
end;

procedure TSImage.ImportFromDispley(const NeedAlpha:Boolean = True);
begin
ImportFromDispley(
	SVertex2int32Import(1,1),
	SVertex2int32Import(Render.Width,Render.Height),
	NeedAlpha);
end;

procedure TSImage.ImportFromDispley(const Point1,Point2: TSPoint2int32;const NeedAlpha:Boolean = True);
begin
if (Self <> nil) then FreeAll() else Self := TSImage.Create();
FBitMap.Width := Point2.x - Point1.x + 1;
FBitMap.Height := Point2.y - Point1.y + 1;
FBitMap.Channels := 3 + TSByte(NeedAlpha);
FBitMap.ChannelSize := 8;
FBitMap.ReAllocateMemory();
Render.ReadPixels(
	Point1.x-1,
	Point1.y-1,
	Point2.x-Point1.x+1,
	Point2.y-Point1.y+1,
	SR_RGBA * TSByte(NeedAlpha) + SR_RGB * TSByte(not NeedAlpha),
	SR_UNSIGNED_BYTE,
	FBitMap.Data);
FLoadedIntoRAM := True;
end;

(****************************)
(*OTHERS FUNCTIONS FOR IMAGE*)
(****************************)

function TSImage.Load(const Stream : TStream) : TSBool;
begin
SKill(FBitMap);
FBitMap := SLoadBitMapFromStream(Stream, FFileName);
Result := BitMapHasData();
FLoadedIntoRAM := Result;
end;

function TSImage.Save(const Stream : TStream) : TSBool;
begin
if (not BitMapHasData()) and (FFileName <> '') and SFileExists(FFileName) then
	with TMemoryStream.Create() do
		begin
		LoadFromFile(FFileName);
		SaveToStream(Stream);
		Destroy();
		end
else if BitMapHasData() then
	Result := SSaveBitMapToStream(Stream, FBitMap)
else
	Result := False;
end;

function TSImage.Load() : TSBoolean;
begin
SKill(FBitMap);
FBitMap := SLoadBitMapFromFile(FFileName);
Result := BitMapHasData();
FLoadedIntoRAM := Result;
end;

function TSImage.Save(const Format : TSImageFormat = SImageFormatNull) : TSBoolean;
begin
Result := SSaveBitMapToFile(FBitMap, FFileName, Format);
end;

function TSImage.BitMapHasData() : TSBoolean;
begin
Result := (FBitMap <> nil) and FBitMap.HasData();
end;

function TSImage.HasAlphaChannel() : TSBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FBitMap.Channels > 3;
end;

procedure TSImage.LoadRenderResources();
begin
if not (LoadedIntoRAM or (Texture <> 0)) then
	Load();
end;

procedure TSImage.DeleteRenderResources();
var
	IsHasTexture : TSBoolean;
begin
IsHasTexture := FTexture <> 0;
FreeTexture();
FLoadedIntoRAM := IsHasTexture and (FBitMap.Data <> nil);
end;

function TSImage.Loaded() : TSBoolean;
begin
Result := TextureLoaded();
end;

procedure TSImage.FreeTexture();
begin
if RenderAssigned() and (FTexture <> 0) then
	begin
	Render.DeleteTextures(1,@FTexture);
	FTexture := 0;
	end;
end;

destructor TSImage.Destroy();
begin
FreeAll();
SKill(FBitMap);
inherited;
end;

procedure TSImage.FreeAll();
begin
FreeTexture();
if (FBitMap <> nil) then
	FBitMap.Clear();
end;

procedure TSImage.DisableTexture();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if FTextureNumber = -1 then
	begin
	Render.BindTexture(SR_TEXTURE_2D,0);
	Render.Disable(SR_TEXTURE_2D);
	end
else
	begin
	Render.ActiveTexture(FTextureNumber);
	Render.BindTexture(SR_TEXTURE_2D,0);
	Render.Disable(SR_TEXTURE_2D);
	Render.ActiveTexture(0);
	end;
end;

procedure TSImage.BindTexture();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (FTexture=0) and (FLoadedIntoRAM) then
	begin
	LoadTexture();
	if FIsBitsFreeAfterTextureLoad then
		FreeBits();
	end;
if (FTextureNumber = -1) then
	begin
	Render.Enable(SR_TEXTURE_2D);
	Render.BindTexture(SR_TEXTURE_2D,FTexture);
	Render.ActiveTextureDiffuse();
	end
else
	begin
	Render.ActiveTexture(FTextureNumber);
	Render.BindTexture(SR_TEXTURE_2D,FTexture);
	Render.Enable(SR_TEXTURE_2D);
	if FTextureType = SITextureTypeBump then
		Render.ActiveTextureBump()
	else
		Render.ActiveTextureDiffuse();
	Render.ActiveTexture(0);
	end;
end;

procedure TSImage.FreeBits();
begin
if (FBitMap <> nil) then
	FBitMap.FreeData();
end;

procedure TSImage.LoadTexture();
var
	FormatType : TSBitMapUInt;
	DataType   : TSBitMapUInt;

procedure CreateTypes(const Alpha:TSBitMapUInt = S_UNKNOWN;const Grayscale:TSBitMapUInt = S_UNKNOWN);
begin
FormatType:=0;
DataType:=0;
case FBitMap.Channels of 
1:
	if (Grayscale = S_TRUE) then 
		FormatType := SR_LUMINANCE
	else if (Alpha = S_TRUE) then
		FormatType := SR_ALPHA
	else if ((Alpha = S_FALSE) and (Grayscale = S_FALSE)) then
		FormatType := SR_INTENSITY
	else
		FormatType := SR_RED;
2:
	//if (Grayscale = S_TRUE) and (Alpha = S_TRUE) then
		FormatType := SR_LUMINANCE_ALPHA;
3:
	FormatType := SR_RGB;
4:
	FormatType := SR_RGBA;
else
	FormatType := 0;
end;
case FBitMap.ChannelSize of
8:
	DataType := SR_UNSIGNED_BYTE;
else
	DataType := SR_BITMAP;
end;
end;

begin
if FBitMap = nil then
	exit;
Render.Enable(SR_TEXTURE_2D);

if (FTexture = 0) then
	Render.GenTextures(1, @FTexture);
if (FTexture = 0) then
	Exit;

CreateTypes();

Render.BindTexture(SR_TEXTURE_2D, FTexture);
{$IFNDEF MOBILE}
	Render.PixelStorei(SR_UNPACK_ALIGNMENT, 4);
	Render.PixelStorei(SR_UNPACK_ROW_LENGTH, 0);
	Render.PixelStorei(SR_UNPACK_SKIP_ROWS, 0);
	Render.PixelStorei(SR_UNPACK_SKIP_PIXELS, 0);
	{$ENDIF}
Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_MIN_FILTER, SR_LINEAR);
Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_MAG_FILTER, SR_NEAREST);
Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_WRAP_S, SR_REPEAT);
Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_WRAP_T, SR_REPEAT);
Render.TexImage2D(SR_TEXTURE_2D, 0, FBitMap.Channels, Width, Height, 0, FormatType, DataType, FBitMap.Data);
{$IFDEF MOBILE}
	Render.GenerateMipmap(SR_TEXTURE_2D);
	{$ENDIF}
Render.BindTexture(SR_TEXTURE_2D, 0);
Render.Disable(SR_TEXTURE_2D);
{$IFDEF SDebuging}
	SLog.Source('TSImage  : Loaded to texture "'+FFileName+'" is "'+SStr(FTexture<>0)+'"("'+SStr(FTexture)+'").');
	{$ENDIF}
end;

function TSImage.TextureLoaded() : TSBoolean;
begin
Result := FTexture <> 0;
end;

class function TSImage.ClassName() : TSString;
begin
Result := 'TSImage';
end;

constructor TSImage.Create(const VFileName : TSString = '');
begin
inherited Create();
FTextureNumber := -1;
FTextureType := SITextureTypeTexture;
FTexture := 0;
FLoadedIntoRAM := False;
FFileName := VFileName;
FBitMap := TSBitMap.Create();
FName := '';
FIsBitsFreeAfterTextureLoad := ImageIsBitsFreeAfterTextureLoad;
end;

initialization
begin

end;

end.
