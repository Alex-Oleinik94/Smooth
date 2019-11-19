{$INCLUDE SaGe.inc}

//{$DEFINE SGDebuging}

unit SaGeImage;

interface

uses
		// Engine
	 SaGeBase
	,SaGeBitMap
	,SaGeContextClasses
	,SaGeContextInterface
	,SaGeCommon
	,SaGeRenderBase
	,SaGeRenderInterface
	,SaGeCommonStructs
	,SaGeImageFormatDeterminer
	,SaGeBitMapBase
		// System
	,Classes
	;
type
	TSGImage = class;
	TSGTextureBlock = class;

	TSGITextureType = (SGITextureTypeTexture, SGITextureTypeBump);

	PSGImage  = ^ TSGImage;
	// Класс изображения и текстуры
	TSGImage = class(TSGContextObject)
			public
		constructor Create(const VFileName : TSGString = '');
		destructor Destroy();override;
		class function ClassName() : TSGString; override;
		procedure DeleteRenderResources();override;
		procedure LoadRenderResources();override;
			public
		// Данные изображения (свойства изображения и последовательность байтов, характеризующих цвета пикселей)
		// В общем "BitMap" ("карта BIT-ов")
		FBitMap : TSGBitMap;
		
		// Идентификатор текстуры
		FTexture : TSGRenderTexture;
		FIsBitsFreeAfterTextureLoad : TSGBoolean;
		// for ActiveTexture
		FTextureNumber : TSGInteger;
		// what it the texture
		FTextureType   : TSGITextureType;
		
		// Возвращает, загружено изображение в оперативную память в виде TSGBitMap, или нет
		FLoadedIntoRAM : TSGBoolean;
		// Путь в файлу
		FFileName           : TSGString;
		
		//Имя изображения или материала
		FName : TSGString;
			public
		property TextureNumber : TSGInteger      read FTextureNumber write FTextureNumber;
		property TextureType   : TSGITextureType read FTextureType   write FTextureType;
			protected
		function HasAlphaChannel() : TSGBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		function Load(const Stream : TStream) : TSGBool;
		function Save(const Stream : TStream) : TSGBool;
		function Load() : TSGBoolean; virtual;
		function Save(const Format : TSGImageFormat = SGImageFormatNull) : TSGBoolean; virtual;
		function Loaded() : TSGBoolean; virtual;
			public
		procedure LoadTexture(); virtual;
		procedure LoadTextureWithBlock(const VTexturesBlock : TSGTextureBlock);
		procedure BindTexture();
		procedure DisableTexture();
		procedure FreeBits();
		procedure FreeTexture();
		procedure FreeAll();
		function TextureLoaded() : TSGBoolean;
		function BitMapHasData() : TSGBoolean;
			public
		property Height             : TSGBitMapUInt    read FBitMap.FHeight;
		property Width              : TSGBitMapUInt    read FBitMap.FWidth;
		property BitMap             : TSGBitMap        read FBitMap;
		property LoadedIntoRAM      : TSGBoolean       read FLoadedIntoRAM write FLoadedIntoRAM;
		property Texture            : TSGRenderTexture read FTexture;
		property IsBitsFreeAfterTextureLoad : TSGBoolean read FIsBitsFreeAfterTextureLoad write FIsBitsFreeAfterTextureLoad;
		property FileName           : TSGString        read FFileName write FFileName;
		property Name               : TSGString        read FName     write FName;
		property HasAlpha           : TSGBool          read HasAlphaChannel;
			public // Render functions:
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
	TSGTextureBlock = class(TSGContextObject)
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

var
	ImageIsBitsFreeAfterTextureLoad : TSGBoolean = True;

procedure SGKill(var _Image : TSGImage); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SGCreateImageFromFile(const _Context : ISGContext; const _FileName : TSGString; const _LoadTexture : TSGBoolean = False) : TSGImage;

implementation

uses
		// System
	 Crt
	,Dos
	,SysUtils
	
		// Engine
	,SaGeResourceManager
	,SaGeFileUtils
	,SaGeStringUtils
	,SaGeStreamUtils
	,SaGeBaseUtils
	,SaGeLog
	,SaGeBitMapUtils
	;

function SGCreateImageFromFile(const _Context : ISGContext; const _FileName : TSGString; const _LoadTexture : TSGBoolean = False) : TSGImage;
begin
Result := TSGImage.Create(_FileName);
Result.Context := _Context;
Result.Load();
if (_LoadTexture) then
	Result.LoadTexture();
end;

procedure SGKill(var _Image : TSGImage); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
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
				Render.DeleteTextures(1, @FTextures[i].FHandle);
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

(****************************)
(*RENDER FUNCTIONS FOR IMAGE*)
(****************************)

procedure TSGImage.LoadTextureWithBlock(const VTexturesBlock : TSGTextureBlock);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (FTexture <> 0) then
	FreeTexture();
FTexture := VTexturesBlock.GetNextUnusebleTexture();
LoadTexture();
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

procedure TSGImage.RePlacVertex(var Vertex1, Vertex2 : TSGVertex2f;const RePlaceY : TSGByte = SG_3D);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Vertex1.x > Vertex2.x then
	Swap(Vertex1.x, Vertex2.x);
case RePlaceY of
SG_2D:
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
if (Self <> nil) then FreeAll() else Self := TSGImage.Create();
FBitMap.Width := Point2.x - Point1.x + 1;
FBitMap.Height := Point2.y - Point1.y + 1;
FBitMap.Channels := 3 + TSGByte(NeedAlpha);
FBitMap.ChannelSize := 8;
FBitMap.ReAllocateMemory();
Render.ReadPixels(
	Point1.x-1,
	Point1.y-1,
	Point2.x-Point1.x+1,
	Point2.y-Point1.y+1,
	SGR_RGBA * TSGByte(NeedAlpha) + SGR_RGB * TSGByte(not NeedAlpha),
	SGR_UNSIGNED_BYTE,
	FBitMap.Data);
FLoadedIntoRAM := True;
end;

(****************************)
(*OTHERS FUNCTIONS FOR IMAGE*)
(****************************)

function TSGImage.Load(const Stream : TStream) : TSGBool;
begin
SGKill(FBitMap);
FBitMap := SGLoadBitMapFromStream(Stream, FFileName);
Result := BitMapHasData();
FLoadedIntoRAM := Result;
end;

function TSGImage.Save(const Stream : TStream) : TSGBool;
begin
if (not BitMapHasData()) and (FFileName <> '') and SGFileExists(FFileName) then
	with TMemoryStream.Create() do
		begin
		LoadFromFile(FFileName);
		SaveToStream(Stream);
		Destroy();
		end
else if BitMapHasData() then
	Result := SGSaveBitMapToStream(Stream, FBitMap)
else
	Result := False;
end;

function TSGImage.Load() : TSGBoolean;
begin
SGKill(FBitMap);
FBitMap := SGLoadBitMapFromFile(FFileName);
Result := BitMapHasData();
FLoadedIntoRAM := Result;
end;

function TSGImage.Save(const Format : TSGImageFormat = SGImageFormatNull) : TSGBoolean;
begin
Result := SGSaveBitMapToFile(FBitMap, FFileName, Format);
end;

function TSGImage.BitMapHasData() : TSGBoolean;
begin
Result := (FBitMap <> nil) and FBitMap.HasData();
end;

function TSGImage.HasAlphaChannel() : TSGBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FBitMap.Channels > 3;
end;

procedure TSGImage.LoadRenderResources();
begin
if not (LoadedIntoRAM or (Texture <> 0)) then
	Load();
end;

procedure TSGImage.DeleteRenderResources();
var
	IsHasTexture : TSGBoolean;
begin
IsHasTexture := FTexture <> 0;
FreeTexture();
FLoadedIntoRAM := IsHasTexture and (FBitMap.Data <> nil);
end;

function TSGImage.Loaded() : TSGBoolean;
begin
Result := TextureLoaded();
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
SGKill(FBitMap);
inherited;
end;

procedure TSGImage.FreeAll();
begin
FreeTexture();
if (FBitMap <> nil) then
	FBitMap.Clear();
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
if (FTexture=0) and (FLoadedIntoRAM) then
	begin
	LoadTexture();
	if FIsBitsFreeAfterTextureLoad then
		FreeBits();
	end;
if (FTextureNumber = -1) then
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

procedure TSGImage.FreeBits();
begin
if (FBitMap <> nil) then
	FBitMap.FreeData();
end;

procedure TSGImage.LoadTexture();
var
	FormatType : TSGBitMapUInt;
	DataType   : TSGBitMapUInt;

procedure CreateTypes(const Alpha:TSGBitMapUInt = SG_UNKNOWN;const Grayscale:TSGBitMapUInt = SG_UNKNOWN);
begin
FormatType:=0;
DataType:=0;
case FBitMap.Channels of 
1:
	if (Grayscale = SG_TRUE) then 
		FormatType := SGR_LUMINANCE
	else if (Alpha = SG_TRUE) then
		FormatType := SGR_ALPHA
	else if ((Alpha = SG_FALSE) and (Grayscale = SG_FALSE)) then
		FormatType := SGR_INTENSITY
	else
		FormatType := SGR_RED;
2:
	//if (Grayscale = SG_TRUE) and (Alpha = SG_TRUE) then
		FormatType := SGR_LUMINANCE_ALPHA;
3:
	FormatType := SGR_RGB;
4:
	FormatType := SGR_RGBA;
else
	FormatType := 0;
end;
case FBitMap.ChannelSize of
8:
	DataType := SGR_UNSIGNED_BYTE;
else
	DataType := SGR_BITMAP;
end;
end;

begin
Render.Enable(SGR_TEXTURE_2D);

if (FTexture = 0) then
	Render.GenTextures(1, @FTexture);
if (FTexture = 0) then
	Exit;

CreateTypes();

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
Render.TexImage2D(SGR_TEXTURE_2D, 0, FBitMap.Channels, Width, Height, 0, FormatType, DataType, FBitMap.Data);
{$IFDEF MOBILE}
	Render.GenerateMipmap(SGR_TEXTURE_2D);
	{$ENDIF}
Render.BindTexture(SGR_TEXTURE_2D, 0);
Render.Disable(SGR_TEXTURE_2D);
{$IFDEF SGDebuging}
	SGLog.Source('TSGImage  : Loaded to texture "'+FFileName+'" is "'+SGStr(FTexture<>0)+'"("'+SGStr(FTexture)+'").');
	{$ENDIF}
end;

function TSGImage.TextureLoaded() : TSGBoolean;
begin
Result := FTexture <> 0;
end;

class function TSGImage.ClassName() : TSGString;
begin
Result := 'TSGImage';
end;

constructor TSGImage.Create(const VFileName : TSGString = '');
begin
inherited Create();
FTextureNumber := -1;
FTextureType := SGITextureTypeTexture;
FTexture := 0;
FLoadedIntoRAM := False;
FFileName := VFileName;
FBitMap := TSGBitMap.Create();
FName := '';
FIsBitsFreeAfterTextureLoad := ImageIsBitsFreeAfterTextureLoad;
end;

initialization
begin

end;

end.
