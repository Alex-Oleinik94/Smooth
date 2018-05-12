{$INCLUDE SaGe.inc}

//{$DEFINE SGM3D_DEBUG}
{$IFDEF SGM3D_DEBUG}
	{$DEFINE SGM3D_D_W}
	{$DEFINE SGM3D_D_R}
	{$DEFINE SGM3D_STRING}
	{$DEFINE SGM3D_ENUM}
	{$DEFINE SGM3D_BOOL}
	{$ENDIF}

unit SaGeMeshSg3dm;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeMesh
	,SaGeMeshLoader
	,SaGeCommonStructs
	,SaGeMatrix
	,SaGeVertexObject
	,SaGeMaterial
	,SaGeImage
	
	,Classes
	;
const
	SGMeshVersion : TSGQuadWord = 187;
	SGMeshDefaultLogo = 'SaGe3DObj';
type
	TSGMeshSG3DImageSaveFormat = (SGMeshSG3DNoImage, SGMeshSG3DImagePath, SGMeshSG3DImageSGIA);
	TSGMeshSG3DImageType = (SGMeshSG3DNullImage, SGMeshSG3DImageTexture, SGMeshSG3DImageBump);
	TSGMeshSG3DEnum = TSGUInt64;
	TSGMeshSG3DBool = TSGBool8;
	TSGMeshSG3DMatrix = TSGMatrix4x4;
	TSGMeshSG3DObjectLogo = array[0..8] of TSGChar;
	TSGMeshSG3DMLoader = class(TSGMeshLoader)
			public
		constructor Create(); override; overload;
		constructor Create(const VStream : TStream); virtual; overload;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
		function Load() : TSGBoolean; override;
			protected
		class procedure WriteImageSaveFormat(const Stream : TStream; Format : TSGMeshSG3DImageSaveFormat); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  ReadImageSaveFormat (const Stream : TStream)        : TSGMeshSG3DImageSaveFormat;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class procedure WriteString(const Stream : TStream; Str : TSGString); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  ReadString (const Stream : TStream)      : TSGString;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class procedure WriteEnum(const Stream : TStream; Enum : TSGMeshSG3DEnum); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  ReadEnum (const Stream : TStream)      : TSGMeshSG3DEnum;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class procedure WriteBool(const Stream : TStream; Bool : TSGMeshSG3DBool); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  ReadBool (const Stream : TStream)      : TSGMeshSG3DBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class procedure WriteMatrix(const Stream : TStream; Matrix : TSGMeshSG3DMatrix); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  ReadMatrix (const Stream : TStream)        : TSGMeshSG3DMatrix;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class procedure WriteColorFormat(const Stream : TStream; ColorFormat : TSGMeshColorType); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  ReadColorFormat (const Stream : TStream)             : TSGMeshColorType;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class procedure WriteVertexFormat(const Stream : TStream; VertexFormat : TSGMeshVertexType); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  ReadVertexFormat (const Stream : TStream)              : TSGMeshVertexType;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		
		class procedure WriteHead(const Stream : TStream);              {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  ReadHead (const Stream : TStream) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		
		class function  IdentifyMaterial(const M : TSGCustomModel; const MaterialName : TSGString) : ISGMaterial;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		class function  MaterialName(const Material : ISGMaterial) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		class procedure LoadObject(const M : TSGCustomModel; const O : TSG3DObject; const Stream : TStream);
		class procedure SaveObject(const O : TSG3DObject; const Stream : TStream);
		class procedure LoadModel(const M : TSGCustomModel; const Stream : TStream);
		class procedure SaveModel(const M : TSGCustomModel; const Stream : TStream);
		class procedure LoadMaterial(const Material : TSGMaterial; const Stream : TStream);
		class procedure SaveMaterial(const Material : TSGMaterial; const Stream : TStream);
		class procedure LoadModelFromFile(const M : TSGCustomModel; const VFileName : TSGString);
		class procedure SaveModelToFile  (const M : TSGCustomModel; const VFileName : TSGString);
		class procedure LoadObjectFromFile(const O : TSG3DObject; const VFileName : TSGString);
		class procedure SaveObjectToFile  (const O : TSG3DObject; const VFileName : TSGString);
		class procedure LoadImage(var Image : TSGImage; var ImageType : TSGMeshSG3DImageType; const Stream : TStream);
		class procedure SaveImage(const Image : TSGImage; ImageType : TSGMeshSG3DImageType; const Stream : TStream);
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
	 SaGeCommon
	,SaGeRenderBase
	,SaGeStreamUtils
	,SaGeStringUtils
	,SaGeFileUtils
	,SaGeLog
	,SaGeDateTime
	,SaGeSysUtils
	
	,SysUtils
	;

class procedure TSGMeshSG3DMLoader.WriteImageSaveFormat(const Stream : TStream; Format : TSGMeshSG3DImageSaveFormat); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.WriteBuffer(Format, SizeOf(Format));
end;

class function  TSGMeshSG3DMLoader.ReadImageSaveFormat (const Stream : TStream)        : TSGMeshSG3DImageSaveFormat;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.ReadBuffer(Result, SizeOf(Result));
end;

class procedure TSGMeshSG3DMLoader.WriteString(const Stream : TStream; Str : TSGString); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SGWriteStringToStream(Str, Stream, True);
{$IFDEF SGM3D_STRING}
SGHint(['Writed length = ', Length(Str)]);
{$ENDIF}
end;

class function  TSGMeshSG3DMLoader.ReadString (const Stream : TStream)      : TSGString;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGReadStringFromStream(Stream, [#0]);
{$IFDEF SGM3D_STRING}
SGHint(['Readed length = ', Length(Result), ', Line = "', Result, '"']);
{$ENDIF}
end;

class function  TSGMeshSG3DMLoader.MaterialName(const Material : ISGMaterial) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := '';
if Material <> nil then
	Result := Material.Name;
end;

class function  TSGMeshSG3DMLoader.IdentifyMaterial(const M : TSGCustomModel; const MaterialName : TSGString) : ISGMaterial;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := nil;
if M <> nil then
	Result := M.IdentifyMaterial(MaterialName);
end;

class procedure TSGMeshSG3DMLoader.WriteColorFormat(const Stream : TStream; ColorFormat : TSGMeshColorType); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.WriteBuffer(ColorFormat, SizeOf(ColorFormat));
end;

class function TSGMeshSG3DMLoader.ReadColorFormat(const Stream : TStream) : TSGMeshColorType; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.ReadBuffer(Result, SizeOf(Result));
end;

class procedure TSGMeshSG3DMLoader.WriteVertexFormat(const Stream : TStream; VertexFormat : TSGMeshVertexType); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.WriteBuffer(VertexFormat, SizeOf(VertexFormat));
end;

class function TSGMeshSG3DMLoader.ReadVertexFormat(const Stream : TStream) : TSGMeshVertexType; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.ReadBuffer(Result, SizeOf(Result));
end;

class procedure TSGMeshSG3DMLoader.WriteMatrix(const Stream : TStream; Matrix : TSGMeshSG3DMatrix); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.WriteBuffer(Matrix, SizeOf(Matrix));
end;

class function TSGMeshSG3DMLoader.ReadMatrix(const Stream : TStream) : TSGMeshSG3DMatrix; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.ReadBuffer(Result, SizeOf(Result));
end;

class procedure TSGMeshSG3DMLoader.WriteHead(const Stream : TStream); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Logo : TSGMeshSG3DObjectLogo = SGMeshDefaultLogo;
begin
Stream.WriteBuffer(Logo[0], SizeOf(Logo[0]) * 9);
WriteEnum(Stream, SGMeshVersion);
end;

class function TSGMeshSG3DMLoader.ReadHead(const Stream : TStream) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function LogoToString(const Logo : TSGMeshSG3DObjectLogo) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Index : TSGMaxSignedEnum;
begin
Result := '';
for Index := Low(Logo) to High(Logo) do
	Result += Logo[Index];
end;

var
	ReadedLogo : TSGMeshSG3DObjectLogo;
begin
Result := True;

Stream.ReadBuffer(ReadedLogo[0], SizeOf(ReadedLogo[0]) * 9);
if ReadedLogo <> SGMeshDefaultLogo then
	begin
	WriteLn(LogoToString(ReadedLogo));
	WriteLn(ReadedLogo);
	SGLog.Source(['TSGMeshSG3DMLoader__LoadObject : Error : It is not "', SGMeshDefaultLogo, '" file! Readed logo : "', LogoToString(ReadedLogo), '".']);
	Result := False;
	Exit;
	end;

if ReadEnum(Stream) <> SGMeshVersion then
	begin
	SGLog.Source(['TSGMeshSG3DMLoader__LoadObject : Error : Version error!']);
	Result := False;
	Exit;
	end;
end;

class procedure TSGMeshSG3DMLoader.LoadObject(const M : TSGCustomModel; const O : TSG3DObject; const Stream : TStream);
var
	Index : TSGMaxEnum;
begin
if not ReadHead(Stream) then
	begin
	SGLog.Source(['TSGMeshSG3DMLoader__LoadObject : Fatal : Error while reading mesh head!']);
	Exit;
	end;
//O.Clear();
{$IFDEF SGM3D_D_R}
SGHint(['Position after head=', Stream.Position]);
{$ENDIF}
O.Name := ReadString(Stream);
O.VertexType := ReadVertexFormat(Stream);
O.ColorType := ReadColorFormat(Stream);
O.CountTextureFloatsInVertexArray := ReadEnum(Stream);
O.ObjectMaterial := IdentifyMaterial(M, ReadString(Stream));
O.HasTexture := ReadBool(Stream);
O.HasColors  := ReadBool(Stream);
O.HasNormals := ReadBool(Stream);
O.ObjectPoligonesType := ReadEnum(Stream);
O.EnableCullFace := ReadBool(Stream);
if ReadBool(Stream) then
	O.ObjectMatrix := ReadMatrix(Stream);
{$IFDEF SGM3D_D_R}
O.WriteInfo();
{$ENDIF}

O.SetVertexLength(ReadEnum(Stream));
{$IFDEF SGM3D_D_R}
SGHint(['VertSize=',O.VertexesSize()]);
{$ENDIF}
Stream.ReadBuffer(O.GetArVertexes()^, O.VertexesSize());

O.QuantityFaceArrays := ReadEnum(Stream);
{$IFDEF SGM3D_D_R}
SGHint(['QuantityFaceArrays=',O.QuantityFaceArrays]);
{$ENDIF}
if O.QuantityFaceArrays <> 0 then
	for Index := 0 to O.QuantityFaceArrays - 1 do
		with O.ObjectFace[Index]^ do
			begin
			Stream.ReadBuffer(FPoligonesType, SizeOf(FPoligonesType));
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

class procedure TSGMeshSG3DMLoader.SaveObject(const O : TSG3DObject; const Stream : TStream);
var
	Index : TSGLongWord;
begin
WriteHead(Stream);

{$IFDEF SGM3D_D_W}
SGHint(['Position=',Stream.Position]);
{$ENDIF}
WriteString(Stream, O.Name);
WriteVertexFormat(Stream, O.VertexType);
WriteColorFormat(Stream, O.ColorType);
WriteEnum(Stream, O.CountTextureFloatsInVertexArray);
WriteString(Stream, MaterialName(O.ObjectMaterial));
WriteBool(Stream, O.HasTexture);
WriteBool(Stream, O.HasColors);
WriteBool(Stream, O.HasNormals);
WriteEnum(Stream, O.ObjectPoligonesType);
WriteBool(Stream, O.EnableCullFace);
WriteBool(Stream, O.ObjectMatrixEnabled);
if O.ObjectMatrixEnabled then
	WriteMatrix(Stream, O.ObjectMatrix);

WriteEnum(Stream, O.QuantityVertexes);
Stream.WriteBuffer(O.GetArVertexes()^, O.VertexesSize());

WriteEnum(Stream, O.QuantityFaceArrays);
if O.QuantityFaceArrays <> 0 then
	for Index := 0 to O.QuantityFaceArrays - 1 do
		with O.ObjectFace[Index]^ do
			begin
			Stream.WriteBuffer(FPoligonesType, SizeOf(FPoligonesType));
			Stream.WriteBuffer(FIndexFormat,   SizeOf(FIndexFormat));
			Stream.WriteBuffer(FNOfFaces,      SizeOf(FNOfFaces));
			WriteString(Stream, MaterialName(FMaterial));
			Stream.WriteBuffer(FArray^,        O.GetFaceLength(Index) * O.GetFaceInt(FIndexFormat));
			end;
end;

class procedure TSGMeshSG3DMLoader.WriteBool(const Stream : TStream; Bool : TSGMeshSG3DBool); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.WriteBuffer(Bool, SizeOf(Bool));
end;

class function TSGMeshSG3DMLoader.ReadBool(const Stream : TStream) : TSGMeshSG3DBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.ReadBuffer(Result, SizeOf(Result));
{$IFDEF SGM3D_BOOL}
SGHint([Result]);
{$ENDIF}
end;

class procedure TSGMeshSG3DMLoader.WriteEnum(const Stream : TStream; Enum : TSGMeshSG3DEnum); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.WriteBuffer(Enum, SizeOf(Enum));
end;

class function TSGMeshSG3DMLoader.ReadEnum(const Stream : TStream) : TSGMeshSG3DEnum; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.ReadBuffer(Result, SizeOf(Result));
{$IFDEF SGM3D_ENUM}
SGHint([Result]);
{$ENDIF}
end;

class procedure TSGMeshSG3DMLoader.LoadImage(var Image : TSGImage; var ImageType : TSGMeshSG3DImageType; const Stream : TStream);

procedure LoadSGIA();
var
	MemoryStream : TMemoryStream = nil;
	MemoryStreamSize : TSGMeshSG3DEnum = 0;
begin
MemoryStreamSize  := ReadEnum(Stream);
MemoryStream := TMemoryStream.Create();
SGCopyPartStreamToStream(Stream, MemoryStream, MemoryStreamSize);
MemoryStream.Position := 0;
Image.LoadingFromStream(MemoryStream);
MemoryStream.Destroy();
SGLog.Source(['TSGMeshSG3DMLoader_LoadImage()__LoadSGIA(). Current stream size = ', SGGetSizeString(MemoryStreamSize, 'EN'), '.']);
end;

var
	ImageSaveFormat : TSGMeshSG3DImageSaveFormat;
begin
SGKill(Image);
Stream.ReadBuffer(ImageType, SizeOf(ImageType));
if ImageType <> SGMeshSG3DNullImage then
	begin
	ImageSaveFormat := ReadImageSaveFormat(Stream);
	case ImageSaveFormat of
	SGMeshSG3DImageSGIA :
		begin
		Image := TSGImage.Create();
		LoadSGIA();
		end;
	SGMeshSG3DImagePath :
		begin
		Image := TSGImage.Create();
		Image.FileName := ReadString(Stream);
		Image.Loading();
		end;
	end;
	end;
end;

class procedure TSGMeshSG3DMLoader.SaveImage(const Image : TSGImage; ImageType : TSGMeshSG3DImageType; const Stream : TStream);

procedure SaveSGIA();
var
	MemoryStream : TMemoryStream = nil;
	MemoryStreamSize : TSGMeshSG3DEnum = 0;
begin
MemoryStream := TMemoryStream.Create();
MemoryStream.Position := 0;
Image.SaveingToStream(MemoryStream);
MemoryStream.Position := 0;
MemoryStreamSize := MemoryStream.Size;
WriteEnum(Stream, MemoryStreamSize);
SGCopyPartStreamToStream(MemoryStream, Stream, MemoryStreamSize);
MemoryStream.Destroy();
SGLog.Source(['TSGMeshSG3DMLoader_SaveImage()__SaveSGIA(). Result stream size = ', SGGetSizeString(MemoryStreamSize, 'EN'), '.']);
end;

begin
Stream.WriteBuffer(ImageType, SizeOf(ImageType));
if (Image <> nil) and (Image.Image <> nil) and (Image.Image.BitMap <> nil) then
	begin
	WriteImageSaveFormat(Stream, SGMeshSG3DImageSGIA);
	SaveSGIA();
	end
else if (Image <> nil) and SGFileExists(Image.FileName) then
	begin
	WriteImageSaveFormat(Stream, SGMeshSG3DImagePath);
	WriteString(Stream, Image.FileName);
	end
else
	WriteImageSaveFormat(Stream, SGMeshSG3DNoImage);
end;

class procedure TSGMeshSG3DMLoader.LoadMaterial(const Material : TSGMaterial; const Stream : TStream);

procedure PutImage(var Image : TSGImage; const ImageType : TSGMeshSG3DImageType);
begin
if Image <> nil then
	case ImageType of
	SGMeshSG3DImageTexture :
		begin
		Material.ImageTexture := Image;
		Image := nil;
		end;
	SGMeshSG3DImageBump :
		begin
		Material.ImageBump := Image;
		Image := nil;
		end;
	end;
SGKill(Image);
end;

var
	Image : TSGImage = nil;
	ImageType : TSGMeshSG3DImageType;
begin
Material.Name := ReadString(Stream);
repeat
LoadImage(Image, ImageType, Stream);
PutImage(Image, ImageType);
until ImageType = SGMeshSG3DNullImage;
end;

class procedure TSGMeshSG3DMLoader.SaveMaterial(const Material : TSGMaterial; const Stream : TStream);
var
	ImageType : TSGMeshSG3DImageType;
begin
WriteString(Stream, Material.Name);
SaveImage(Material.ImageTexture, SGMeshSG3DImageTexture, Stream);
SaveImage(Material.ImageBump,    SGMeshSG3DImageBump,    Stream);
ImageType := SGMeshSG3DNullImage;
Stream.WriteBuffer(ImageType, SizeOf(ImageType));
end;

class procedure TSGMeshSG3DMLoader.LoadModel(const M : TSGCustomModel; const Stream : TStream);
var
	Index : TSGMaxEnum;
	QuantityObjects, QuantityMaterials : TSGMeshSG3DEnum;
	O : TSG3DObject = nil;
begin
{$IFDEF SGM3D_D_R}
SGHint(['Beg length = ', Stream.Position]);
{$ENDIF}
M.Clear();
QuantityMaterials := ReadEnum(Stream);
QuantityObjects   := ReadEnum(Stream);
if QuantityMaterials > 0 then
	for Index :=0 to QuantityMaterials - 1 do
		LoadMaterial(M.AddMaterial(), Stream);
{$IFDEF SGM3D_D_R}
SGHint(['Mat length = ', Stream.Position]);
{$ENDIF}
if QuantityObjects > 0 then
	for Index := 0 to QuantityObjects - 1 do
		begin
		O := M.AddObject();
		with M.ModelMesh[M.QuantityObjects - 1]^ do
			begin
			FMatrix := ReadMatrix(Stream);
			Stream.ReadBuffer(FCopired, SizeOf(FCopired));
			if FCopired = -1 then
				LoadObject(M, O, Stream)
			else
				SGKill(FMesh);
			O := nil;
			end;
		end;
end;

class procedure TSGMeshSG3DMLoader.SaveModel(const M : TSGCustomModel; const Stream : TStream);
var
	Index : TSGMaxEnum;
begin
WriteEnum(Stream, M.QuantityMaterials);
WriteEnum(Stream, M.QuantityObjects);
if M.QuantityMaterials > 0 then
	for Index := 0 to M.QuantityMaterials - 1 do
		SaveMaterial(M.Materials[Index], Stream);
if M.QuantityObjects > 0 then
	for Index := 0 to M.QuantityObjects - 1 do
		with M.ModelMesh[Index]^ do
			begin
			WriteMatrix(Stream, FMatrix);
			Stream.WriteBuffer(FCopired, SizeOf(FCopired));
			if FCopired = -1 then
				SaveObject(FMesh, Stream);
			end;
end;

class procedure TSGMeshSG3DMLoader.LoadModelFromFile(const M : TSGCustomModel; const VFileName : TSGString);
var
	LoadStream : TStream = nil;
begin
try
	LoadStream := TFileStream.Create(VFileName, fmOpenRead);
	if LoadStream <> nil then
		begin
		LoadModel(M, LoadStream);
		LoadStream.Destroy();
		end;
except on e : Exception do
	SGLogException('TSGMeshSG3DMLoader__LoadModelFromFile(...). Raised exception', e);
end;
end;

class procedure TSGMeshSG3DMLoader.SaveModelToFile(const M : TSGCustomModel; const VFileName : TSGString);
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
	SGLogException('TSGMeshSG3DMLoader__SaveModelToFile(...). Raised exception', e);
end;
end;

class procedure TSGMeshSG3DMLoader.LoadObjectFromFile(const O : TSG3DObject; const VFileName : TSGString);
var
	LoadStream : TStream = nil;
begin
if SGFileExists(VFileName) then
	begin
	LoadStream := TFileStream.Create(VFileName, fmOpenRead);
	if LoadStream <> nil then
		begin
		LoadObject(nil, O, LoadStream);
		LoadStream.Destroy();
		end;
	end;
end;

class procedure TSGMeshSG3DMLoader.SaveObjectToFile(const O : TSG3DObject; const VFileName : TSGString);
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

procedure TSGMeshSG3DMLoader.DestroyStream();
begin
if FStream <> nil then
	begin
	FStream.Destroy();
	FStream := nil;
	end;
end;

procedure TSGMeshSG3DMLoader.SetStream(const VStream : TStream);
begin
DestroyStream();
FStream := VStream;
end;

constructor TSGMeshSG3DMLoader.Create(); overload;
begin
inherited Create();
FStream := nil;
end;

constructor TSGMeshSG3DMLoader.Create(const VStream : TStream); overload;
begin
Create();
Stream := VStream;
end;

destructor TSGMeshSG3DMLoader.Destroy();
begin
DestroyStream();
inherited;
end;

class function TSGMeshSG3DMLoader.ClassName() : TSGString;
begin
Result := 'TSGMeshSG3DMLoader';
end;

function TSGMeshSG3DMLoader.Load() : TSGBoolean;
begin
LoadModelFromFile(FModel, FFileName);
Result := True;
end;

end.
