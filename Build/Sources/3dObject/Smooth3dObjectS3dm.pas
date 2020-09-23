{$INCLUDE Smooth.inc}

//{$DEFINE SM3D_DEBUG}
{$IFDEF SM3D_DEBUG}
	{$DEFINE SM3D_D_W}
	{$DEFINE SM3D_D_R}
	{$DEFINE SM3D_STRING}
	{$DEFINE SM3D_ENUM}
	{$DEFINE SM3D_BOOL}
	{$ENDIF}

unit Smooth3dObjectS3dm;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,Smooth3dObject
	,Smooth3dObjectLoader
	,SmoothCommonStructs
	,SmoothMatrix
	,SmoothVertexObject
	,SmoothMaterial
	,SmoothImage
	
	,Classes
	;
const
	S3dObjectVersion : TSQuadWord = 187;
	S3dObjectDefaultLogo = 'Smooth3DObj';
type
	TS3dObjectS3DImageSaveFormat = (S3dObjectS3DNoImage, S3dObjectS3DImagePath, S3dObjectS3DImageSIA);
	TS3dObjectS3DImageType = (S3dObjectS3DNullImage, S3dObjectS3DImageTexture, S3dObjectS3DImageBump);
	TS3dObjectS3DEnum = TSUInt64;
	TS3dObjectS3DBool = TSBool8;
	TS3dObjectS3DMatrix = TSMatrix4x4;
	TS3dObjectS3DObjectLogo = packed array[0..10] of TSChar;
	TS3dObjectS3DMLoader = class(TS3dObjectLoader)
			public
		constructor Create(); override; overload;
		constructor Create(const VStream : TStream); virtual; overload;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
		function Load() : TSBoolean; override;
			protected
		class procedure WriteImageSaveFormat(const Stream : TStream; Format : TS3dObjectS3DImageSaveFormat); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  ReadImageSaveFormat (const Stream : TStream)        : TS3dObjectS3DImageSaveFormat;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class procedure WriteString(const Stream : TStream; Str : TSString); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  ReadString (const Stream : TStream)      : TSString;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class procedure WriteEnum(const Stream : TStream; Enum : TS3dObjectS3DEnum); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  ReadEnum (const Stream : TStream)      : TS3dObjectS3DEnum;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class procedure WriteBool(const Stream : TStream; Bool : TS3dObjectS3DBool); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  ReadBool (const Stream : TStream)      : TS3dObjectS3DBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class procedure WriteMatrix(const Stream : TStream; Matrix : TS3dObjectS3DMatrix); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  ReadMatrix (const Stream : TStream)        : TS3dObjectS3DMatrix;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class procedure WriteColorFormat(const Stream : TStream; ColorFormat : TS3dObjectColorType); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  ReadColorFormat (const Stream : TStream)             : TS3dObjectColorType;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class procedure WriteVertexFormat(const Stream : TStream; VertexFormat : TS3dObjectVertexType); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  ReadVertexFormat (const Stream : TStream)              : TS3dObjectVertexType;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		
		class procedure WriteHead(const Stream : TStream);              {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  ReadHead (const Stream : TStream) : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		
		class function  IdentifyMaterial(const M : TSCustomModel; const MaterialName : TSString) : ISMaterial;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		class function  MaterialName(const Material : ISMaterial) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		class procedure LoadObject(const M : TSCustomModel; const O : TS3DObject; const Stream : TStream);
		class procedure SaveObject(const O : TS3DObject; const Stream : TStream);
		class procedure LoadModel(const M : TSCustomModel; const Stream : TStream);
		class procedure SaveModel(const M : TSCustomModel; const Stream : TStream);
		class procedure LoadMaterial(const Material : TSMaterial; const Stream : TStream);
		class procedure SaveMaterial(const Material : TSMaterial; const Stream : TStream);
		class procedure LoadModelFromFile(const M : TSCustomModel; const VFileName : TSString);
		class procedure SaveModelToFile  (const M : TSCustomModel; const VFileName : TSString);
		class procedure LoadObjectFromFile(const O : TS3DObject; const VFileName : TSString);
		class procedure SaveObjectToFile  (const O : TS3DObject; const VFileName : TSString);
		class procedure LoadImage(var Image : TSImage; var ImageType : TS3dObjectS3DImageType; const Stream : TStream);
		class procedure SaveImage(const Image : TSImage; ImageType : TS3dObjectS3DImageType; const Stream : TStream);
			public
		procedure SetStream(const VStream : TStream);
			private
		FStream : TStream;
			protected
		procedure DestroyStream();
			public
		property Stream : TStream read FStream write SetStream;
		end;

implementation

uses
	 SmoothCommon
	,SmoothRenderBase
	,SmoothStreamUtils
	,SmoothStringUtils
	,SmoothFileUtils
	,SmoothLog
	,SmoothDateTime
	,SmoothSysUtils
	
	,SysUtils
	;

class procedure TS3dObjectS3DMLoader.WriteImageSaveFormat(const Stream : TStream; Format : TS3dObjectS3DImageSaveFormat); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.WriteBuffer(Format, SizeOf(Format));
end;

class function  TS3dObjectS3DMLoader.ReadImageSaveFormat (const Stream : TStream)        : TS3dObjectS3DImageSaveFormat;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.ReadBuffer(Result, SizeOf(Result));
end;

class procedure TS3dObjectS3DMLoader.WriteString(const Stream : TStream; Str : TSString); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SWriteStringToStream(Str, Stream, True);
{$IFDEF SM3D_STRING}
SHint(['Writed length = ', Length(Str)]);
{$ENDIF}
end;

class function  TS3dObjectS3DMLoader.ReadString (const Stream : TStream)      : TSString;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SReadStringFromStream(Stream, [#0]);
{$IFDEF SM3D_STRING}
SHint(['Readed length = ', Length(Result), ', Line = "', Result, '"']);
{$ENDIF}
end;

class function  TS3dObjectS3DMLoader.MaterialName(const Material : ISMaterial) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := '';
if Material <> nil then
	Result := Material.Name;
end;

class function  TS3dObjectS3DMLoader.IdentifyMaterial(const M : TSCustomModel; const MaterialName : TSString) : ISMaterial;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := nil;
if M <> nil then
	Result := M.IdentifyMaterial(MaterialName);
end;

class procedure TS3dObjectS3DMLoader.WriteColorFormat(const Stream : TStream; ColorFormat : TS3dObjectColorType); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.WriteBuffer(ColorFormat, SizeOf(ColorFormat));
end;

class function TS3dObjectS3DMLoader.ReadColorFormat(const Stream : TStream) : TS3dObjectColorType; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.ReadBuffer(Result, SizeOf(Result));
end;

class procedure TS3dObjectS3DMLoader.WriteVertexFormat(const Stream : TStream; VertexFormat : TS3dObjectVertexType); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.WriteBuffer(VertexFormat, SizeOf(VertexFormat));
end;

class function TS3dObjectS3DMLoader.ReadVertexFormat(const Stream : TStream) : TS3dObjectVertexType; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.ReadBuffer(Result, SizeOf(Result));
end;

class procedure TS3dObjectS3DMLoader.WriteMatrix(const Stream : TStream; Matrix : TS3dObjectS3DMatrix); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.WriteBuffer(Matrix, SizeOf(Matrix));
end;

class function TS3dObjectS3DMLoader.ReadMatrix(const Stream : TStream) : TS3dObjectS3DMatrix; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.ReadBuffer(Result, SizeOf(Result));
end;

class procedure TS3dObjectS3DMLoader.WriteHead(const Stream : TStream); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Logo : TS3dObjectS3DObjectLogo = S3dObjectDefaultLogo;
begin
Stream.WriteBuffer(Logo[0], SizeOf(Logo[0]) * Length(TS3dObjectS3DObjectLogo));
WriteEnum(Stream, S3dObjectVersion);
end;

class function TS3dObjectS3DMLoader.ReadHead(const Stream : TStream) : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function LogoToString(const Logo : TS3dObjectS3DObjectLogo) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Index : TSMaxSignedEnum;
begin
Result := '';
for Index := Low(Logo) to High(Logo) do
	Result += Logo[Index];
end;

var
	ReadedLogo : TS3dObjectS3DObjectLogo;
begin
Result := True;

Stream.ReadBuffer(ReadedLogo[0], SizeOf(ReadedLogo[0]) * Length(TS3dObjectS3DObjectLogo));
if ReadedLogo <> S3dObjectDefaultLogo then
	begin
	WriteLn(LogoToString(ReadedLogo));
	WriteLn(ReadedLogo);
	SLog.Source(['TS3dObjectS3DMLoader__LoadObject : Error : It is not "', S3dObjectDefaultLogo, '" file! Readed logo : "', LogoToString(ReadedLogo), '".']);
	Result := False;
	Exit;
	end;

if ReadEnum(Stream) <> S3dObjectVersion then
	begin
	SLog.Source(['TS3dObjectS3DMLoader__LoadObject : Error : Version error!']);
	Result := False;
	Exit;
	end;
end;

class procedure TS3dObjectS3DMLoader.LoadObject(const M : TSCustomModel; const O : TS3DObject; const Stream : TStream);
var
	Index : TSMaxEnum;
begin
if not ReadHead(Stream) then
	begin
	SLog.Source(['TS3dObjectS3DMLoader__LoadObject : Fatal : Error while reading 3dObject head!']);
	Exit;
	end;
//O.Clear();
{$IFDEF SM3D_D_R}
SHint(['Position after head=', Stream.Position]);
{$ENDIF}
O.Name := ReadString(Stream);
O.VertexType := ReadVertexFormat(Stream);
O.ColorType := ReadColorFormat(Stream);
O.CountTextureFloatsInVertexArray := ReadEnum(Stream);
O.ObjectMaterial := IdentifyMaterial(M, ReadString(Stream));
O.HasTexture := ReadBool(Stream);
O.HasColors  := ReadBool(Stream);
O.HasNormals := ReadBool(Stream);
O.ObjectPolygonsType := ReadEnum(Stream);
O.EnableCullFace := ReadBool(Stream);
if ReadBool(Stream) then
	O.ObjectMatrix := ReadMatrix(Stream);
{$IFDEF SM3D_D_R}
O.WriteInfo();
{$ENDIF}

O.SetVertexLength(ReadEnum(Stream));
{$IFDEF SM3D_D_R}
SHint(['VertSize=',O.VerticesSize()]);
{$ENDIF}
Stream.ReadBuffer(O.GetArVertices()^, O.VerticesSize());

O.QuantityFaceArrays := ReadEnum(Stream);
{$IFDEF SM3D_D_R}
SHint(['QuantityFaceArrays=',O.QuantityFaceArrays]);
{$ENDIF}
if O.QuantityFaceArrays <> 0 then
	for Index := 0 to O.QuantityFaceArrays - 1 do
		with O.ObjectFace[Index]^ do
			begin
			Stream.ReadBuffer(FPolygonsType, SizeOf(FPolygonsType));
			Stream.ReadBuffer(FIndexFormat,   SizeOf(FIndexFormat));
			Stream.ReadBuffer(FNOfFaces,      SizeOf(FNOfFaces));
			FMaterial := IdentifyMaterial(M, ReadString(Stream));
			if FArray = nil then
				GetMem(FArray, O.GetFaceLength(Index) * O.GetFaceInt(FIndexFormat))
			else
				ReAllocMem(FArray, O.GetFaceLength(Index) * O.GetFaceInt(FIndexFormat));
			Stream.ReadBuffer(FArray^,        O.GetFaceLength(Index) * O.GetFaceInt(FIndexFormat));
			end;
end;

class procedure TS3dObjectS3DMLoader.SaveObject(const O : TS3DObject; const Stream : TStream);
var
	Index : TSLongWord;
begin
WriteHead(Stream);

{$IFDEF SM3D_D_W}
SHint(['Position=',Stream.Position]);
{$ENDIF}
WriteString(Stream, O.Name);
WriteVertexFormat(Stream, O.VertexType);
WriteColorFormat(Stream, O.ColorType);
WriteEnum(Stream, O.CountTextureFloatsInVertexArray);
WriteString(Stream, MaterialName(O.ObjectMaterial));
WriteBool(Stream, O.HasTexture);
WriteBool(Stream, O.HasColors);
WriteBool(Stream, O.HasNormals);
WriteEnum(Stream, O.ObjectPolygonsType);
WriteBool(Stream, O.EnableCullFace);
WriteBool(Stream, O.ObjectMatrixEnabled);
if O.ObjectMatrixEnabled then
	WriteMatrix(Stream, O.ObjectMatrix);

WriteEnum(Stream, O.QuantityVertices);
Stream.WriteBuffer(O.GetArVertices()^, O.VerticesSize());

WriteEnum(Stream, O.QuantityFaceArrays);
if O.QuantityFaceArrays <> 0 then
	for Index := 0 to O.QuantityFaceArrays - 1 do
		with O.ObjectFace[Index]^ do
			begin
			Stream.WriteBuffer(FPolygonsType, SizeOf(FPolygonsType));
			Stream.WriteBuffer(FIndexFormat,   SizeOf(FIndexFormat));
			Stream.WriteBuffer(FNOfFaces,      SizeOf(FNOfFaces));
			WriteString(Stream, MaterialName(FMaterial));
			Stream.WriteBuffer(FArray^,        O.GetFaceLength(Index) * O.GetFaceInt(FIndexFormat));
			end;
end;

class procedure TS3dObjectS3DMLoader.WriteBool(const Stream : TStream; Bool : TS3dObjectS3DBool); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.WriteBuffer(Bool, SizeOf(Bool));
end;

class function TS3dObjectS3DMLoader.ReadBool(const Stream : TStream) : TS3dObjectS3DBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.ReadBuffer(Result, SizeOf(Result));
{$IFDEF SM3D_BOOL}
SHint([Result]);
{$ENDIF}
end;

class procedure TS3dObjectS3DMLoader.WriteEnum(const Stream : TStream; Enum : TS3dObjectS3DEnum); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.WriteBuffer(Enum, SizeOf(Enum));
end;

class function TS3dObjectS3DMLoader.ReadEnum(const Stream : TStream) : TS3dObjectS3DEnum; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.ReadBuffer(Result, SizeOf(Result));
{$IFDEF SM3D_ENUM}
SHint([Result]);
{$ENDIF}
end;

class procedure TS3dObjectS3DMLoader.LoadImage(var Image : TSImage; var ImageType : TS3dObjectS3DImageType; const Stream : TStream);

procedure LoadSIA();
var
	MemoryStream : TMemoryStream = nil;
	MemoryStreamSize : TS3dObjectS3DEnum = 0;
begin
MemoryStreamSize  := ReadEnum(Stream);
MemoryStream := TMemoryStream.Create();
SCopyPartStreamToStream(Stream, MemoryStream, MemoryStreamSize);
MemoryStream.Position := 0;
Image.Load(MemoryStream);
MemoryStream.Destroy();
SLog.Source(['TS3dObjectS3DMLoader_LoadImage()__LoadSIA(). Current stream size = ', SMemorySizeToString(MemoryStreamSize, 'EN'), '.']);
end;

var
	ImageSaveFormat : TS3dObjectS3DImageSaveFormat;
begin
SKill(Image);
Stream.ReadBuffer(ImageType, SizeOf(ImageType));
if ImageType <> S3dObjectS3DNullImage then
	begin
	ImageSaveFormat := ReadImageSaveFormat(Stream);
	case ImageSaveFormat of
	S3dObjectS3DImageSIA :
		begin
		Image := TSImage.Create();
		LoadSIA();
		end;
	S3dObjectS3DImagePath :
		Image := SCreateImageFromFile(nil, ReadString(Stream));
	end;
	end;
end;

class procedure TS3dObjectS3DMLoader.SaveImage(const Image : TSImage; ImageType : TS3dObjectS3DImageType; const Stream : TStream);

procedure SaveSIA();
var
	MemoryStream : TMemoryStream = nil;
	MemoryStreamSize : TS3dObjectS3DEnum = 0;
begin
MemoryStream := TMemoryStream.Create();
MemoryStream.Position := 0;
Image.Save(MemoryStream);
MemoryStream.Position := 0;
MemoryStreamSize := MemoryStream.Size;
WriteEnum(Stream, MemoryStreamSize);
SCopyPartStreamToStream(MemoryStream, Stream, MemoryStreamSize);
MemoryStream.Destroy();
SLog.Source(['TS3dObjectS3DMLoader_SaveImage()__SaveSIA(). Result stream size = ', SMemorySizeToString(MemoryStreamSize, 'EN'), '.']);
end;

begin
Stream.WriteBuffer(ImageType, SizeOf(ImageType));
if (Image <> nil) and (Image.BitMap <> nil) and (Image.BitMap.Data <> nil) then
	begin
	WriteImageSaveFormat(Stream, S3dObjectS3DImageSIA);
	SaveSIA();
	end
else if (Image <> nil) and SFileExists(Image.FileName) then
	begin
	WriteImageSaveFormat(Stream, S3dObjectS3DImagePath);
	WriteString(Stream, Image.FileName);
	end
else
	WriteImageSaveFormat(Stream, S3dObjectS3DNoImage);
end;

class procedure TS3dObjectS3DMLoader.LoadMaterial(const Material : TSMaterial; const Stream : TStream);

procedure PutImage(var Image : TSImage; const ImageType : TS3dObjectS3DImageType);
begin
if Image <> nil then
	case ImageType of
	S3dObjectS3DImageTexture :
		begin
		Material.ImageTexture := Image;
		Image := nil;
		end;
	S3dObjectS3DImageBump :
		begin
		Material.ImageBump := Image;
		Image := nil;
		end;
	end;
SKill(Image);
end;

var
	Image : TSImage = nil;
	ImageType : TS3dObjectS3DImageType;
begin
Material.Name := ReadString(Stream);
repeat
LoadImage(Image, ImageType, Stream);
PutImage(Image, ImageType);
until ImageType = S3dObjectS3DNullImage;
end;

class procedure TS3dObjectS3DMLoader.SaveMaterial(const Material : TSMaterial; const Stream : TStream);
var
	ImageType : TS3dObjectS3DImageType;
begin
WriteString(Stream, Material.Name);
SaveImage(Material.ImageTexture, S3dObjectS3DImageTexture, Stream);
SaveImage(Material.ImageBump,    S3dObjectS3DImageBump,    Stream);
ImageType := S3dObjectS3DNullImage;
Stream.WriteBuffer(ImageType, SizeOf(ImageType));
end;

class procedure TS3dObjectS3DMLoader.LoadModel(const M : TSCustomModel; const Stream : TStream);
var
	Index : TSMaxEnum;
	QuantityObjects, QuantityMaterials : TS3dObjectS3DEnum;
	O : TS3DObject = nil;
begin
{$IFDEF SM3D_D_R}
SHint(['Beg length = ', Stream.Position]);
{$ENDIF}
M.Clear();
QuantityMaterials := ReadEnum(Stream);
QuantityObjects   := ReadEnum(Stream);
if QuantityMaterials > 0 then
	for Index :=0 to QuantityMaterials - 1 do
		LoadMaterial(M.AddMaterial(), Stream);
{$IFDEF SM3D_D_R}
SHint(['Mat length = ', Stream.Position]);
{$ENDIF}
if QuantityObjects > 0 then
	for Index := 0 to QuantityObjects - 1 do
		begin
		O := M.AddObject();
		with M.ExtObjects[M.QuantityObjects - 1]^ do
			begin
			FMatrix := ReadMatrix(Stream);
			Stream.ReadBuffer(FCopired, SizeOf(FCopired));
			if FCopired = -1 then
				LoadObject(M, O, Stream)
			else
				SKill(F3dObject);
			O := nil;
			end;
		end;
end;

class procedure TS3dObjectS3DMLoader.SaveModel(const M : TSCustomModel; const Stream : TStream);
var
	Index : TSMaxEnum;
begin
WriteEnum(Stream, M.QuantityMaterials);
WriteEnum(Stream, M.QuantityObjects);
if M.QuantityMaterials > 0 then
	for Index := 0 to M.QuantityMaterials - 1 do
		SaveMaterial(M.Materials[Index], Stream);
if M.QuantityObjects > 0 then
	for Index := 0 to M.QuantityObjects - 1 do
		with M.ExtObjects[Index]^ do
			begin
			WriteMatrix(Stream, FMatrix);
			Stream.WriteBuffer(FCopired, SizeOf(FCopired));
			if FCopired = -1 then
				SaveObject(F3dObject, Stream);
			end;
end;

class procedure TS3dObjectS3DMLoader.LoadModelFromFile(const M : TSCustomModel; const VFileName : TSString);
var
	LoadStream : TStream = nil;
begin
try
	LoadStream := TFileStream.Create(VFileName, fmOpenRead);
	if LoadStream <> nil then
		begin
		LoadModel(M, LoadStream);
		SKill(LoadStream);
		end;
except on e : Exception do
	SLogException('TS3dObjectS3DMLoader__LoadModelFromFile(...). Raised exception', e);
end;
end;

class procedure TS3dObjectS3DMLoader.SaveModelToFile(const M : TSCustomModel; const VFileName : TSString);
var
	SaveStream : TStream = nil;
begin
try
	SaveStream := TFileStream.Create(VFileName, fmCreate);
	if SaveStream <> nil then
		begin
		SaveModel(M, SaveStream);
		SaveStream.Destroy();
		end;
except on e : Exception do
	SLogException('TS3dObjectS3DMLoader__SaveModelToFile(...). Raised exception', e);
end;
end;

class procedure TS3dObjectS3DMLoader.LoadObjectFromFile(const O : TS3DObject; const VFileName : TSString);
var
	LoadStream : TStream = nil;
begin
if SFileExists(VFileName) then
	begin
	LoadStream := TFileStream.Create(VFileName, fmOpenRead);
	if LoadStream <> nil then
		begin
		LoadObject(nil, O, LoadStream);
		LoadStream.Destroy();
		end;
	end;
end;

class procedure TS3dObjectS3DMLoader.SaveObjectToFile(const O : TS3DObject; const VFileName : TSString);
var
	SaveStream : TStream = nil;
begin
SaveStream := TFileStream.Create(VFileName, fmCreate);
if SaveStream <> nil then
	begin
	SaveObject(O, SaveStream);
	SaveStream.Destroy();
	end;
end;

procedure TS3dObjectS3DMLoader.DestroyStream();
begin
SKill(FStream);
end;

procedure TS3dObjectS3DMLoader.SetStream(const VStream : TStream);
begin
DestroyStream();
FStream := VStream;
end;

constructor TS3dObjectS3DMLoader.Create(); overload;
begin
inherited Create();
FStream := nil;
end;

constructor TS3dObjectS3DMLoader.Create(const VStream : TStream); overload;
begin
Create();
Stream := VStream;
end;

destructor TS3dObjectS3DMLoader.Destroy();
begin
DestroyStream();
inherited;
end;

class function TS3dObjectS3DMLoader.ClassName() : TSString;
begin
Result := 'TS3dObjectS3DMLoader';
end;

function TS3dObjectS3DMLoader.Load() : TSBoolean;
begin
LoadModelFromFile(FModel, FFileName);
Result := True;
end;

end.
