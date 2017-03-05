{$INCLUDE SaGe.inc}

unit SaGeMeshSg3dm;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeMesh
	,SaGeMeshLoader
	,SaGeCommonStructs
	,SaGeMatrix
	
	,Classes
	;
const
	SGMeshVersion : TSGQuadWord = 187;
	SGMeshDefaultLogo = 'SaGe3DObj';
type
	TSGMeshSG3DEnum = TSGUInt64;
	TSGMeshSG3DBool = TSGBoolean;
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
			public
		class procedure LoadObject(var O : TSG3DObject; const Stream : TStream);
		class procedure SaveObject(var O : TSG3DObject; const Stream : TStream);
		class procedure LoadModel(var M : TSGCustomModel; const Stream : TStream);
		class procedure SaveModel(var M : TSGCustomModel; const Stream : TStream);
		class procedure LoadModelFromFile(var M : TSGCustomModel; const VFileName : TSGString);
		class procedure SaveModelToFile(var M : TSGCustomModel; const VFileName : TSGString);
		class procedure LoadObjectFromFile(var O : TSG3DObject; const VFileName : TSGString);
		class procedure SaveObjectToFile(var O : TSG3DObject; const VFileName : TSGString);
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
	,SaGeStringUtils
	,SaGeFileUtils
	,SaGeLog
	,SaGeDateTime
	;

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
var
	ReadedLogo, Logo : TSGMeshSG3DObjectLogo;
begin
Result := True;

Logo := SGMeshDefaultLogo;
Stream.ReadBuffer(ReadedLogo[0], SizeOf(ReadedLogo[0]) * 9);
if ReadedLogo <> Logo then
	begin
	SGLog.Source(['TSGMeshSG3DMLoader__LoadObject : Error : It is not "SaGe3DObj" file!']);
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

class procedure TSGMeshSG3DMLoader.LoadObject(var O : TSG3DObject; const Stream : TStream);
var
	Index, CountFaces : TSGMaxEnum;
begin
if not ReadHead(Stream) then
	begin
	SGLog.Source(['TSGMeshSG3DMLoader__LoadObject : Fatal : Error while reading mesh head!']);
	Exit;
	end;
O.HasTexture := ReadBool(Stream);
O.HasColors  := ReadBool(Stream);
O.HasNormals := ReadBool(Stream);
O.ObjectPoligonesType := ReadEnum(Stream);
O.VertexType := ReadVertexFormat(Stream);
O.ColorType := ReadColorFormat(Stream);
O.ObjectMaterialID := ReadEnum(Stream);
O.EnableCullFace := ReadBool(Stream);
O.Name := SGReadStringFromStream(Stream);
if ReadBool(Stream) then
	O.ObjectMatrix := ReadMatrix(Stream);

O.SetVertexLength(ReadEnum(Stream));
Stream.ReadBuffer(O.GetArVertexes()^, O.VertexesSize());

O.QuantityFaceArrays := ReadEnum(Stream);
if O.QuantityFaceArrays <> 0 then
	for Index := 0 to O.QuantityFaceArrays - 1 do
		with O.ObjectFace[Index]^ do
			begin
			Stream.ReadBuffer(FPoligonesType, SizeOf(FPoligonesType));
			Stream.ReadBuffer(FIndexFormat,   SizeOf(FIndexFormat));
			Stream.ReadBuffer(FNOfFaces,      SizeOf(FNOfFaces));
			Stream.ReadBuffer(FMaterialID,    SizeOf(FMaterialID));
			Stream.ReadBuffer(FArray^,        O.GetFaceLength(Index) * O.GetFaceInt(FIndexFormat));
			end;
end;

class procedure TSGMeshSG3DMLoader.SaveObject(var O : TSG3DObject; const Stream : TStream);
var
	Index : TSGLongWord;
begin
WriteBool(Stream, O.HasTexture);
WriteBool(Stream, O.HasColors);
WriteBool(Stream, O.HasNormals);
WriteEnum(Stream, O.ObjectPoligonesType);
WriteVertexFormat(Stream, O.VertexType);
WriteColorFormat(Stream, O.ColorType);
WriteEnum(Stream, O.ObjectMaterialID);
WriteBool(Stream, O.EnableCullFace);
SGWriteStringToStream(O.Name, Stream);
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
			Stream.WriteBuffer(FMaterialID,    SizeOf(FMaterialID));
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
end;

class procedure TSGMeshSG3DMLoader.WriteEnum(const Stream : TStream; Enum : TSGMeshSG3DEnum); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.WriteBuffer(Enum, SizeOf(Enum));
end;

class function TSGMeshSG3DMLoader.ReadEnum(const Stream : TStream) : TSGMeshSG3DEnum; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Stream.ReadBuffer(Result, SizeOf(Result));
end;

class procedure TSGMeshSG3DMLoader.LoadModel(var M : TSGCustomModel; const Stream : TStream);
var
	Index : TSGMaxEnum;
	QuantityObjects, QuantityMaterials : TSGMeshSG3DEnum;
	O : TSG3DObject = nil;
begin
QuantityObjects   := ReadEnum(Stream);
QuantityMaterials := ReadEnum(Stream);
if QuantityObjects > 0 then
	for Index := 0 to QuantityObjects - 1 do
		with M.ModelMesh[M.QuantityObjects - 1]^ do
			begin
			O := M.AddObject();
			Stream.ReadBuffer(FMatrix,  SizeOf(FMatrix));
			Stream.ReadBuffer(FCopired, SizeOf(FCopired));
			if FCopired = -1 then
				LoadObject(O, Stream)
			else
				SGKill(FMesh);
			O := nil;
			end;
if QuantityMaterials > 0 then
	for Index :=0 to QuantityMaterials - 1 do
		begin
		M.AddMaterial().Name := SGReadStringFromStream(Stream);
		M.LastMaterial().AddDiffuseMap(SGReadStringFromStream(Stream));
		end;
end;

class procedure TSGMeshSG3DMLoader.SaveModel(var M : TSGCustomModel; const Stream : TStream);
var
	Index : TSGMaxEnum;
begin
WriteEnum(Stream, M.QuantityObjects);
WriteEnum(Stream, M.QuantityMaterials);
if M.QuantityObjects > 0 then
	for Index := 0 to M.QuantityObjects - 1 do
		with M.ModelMesh[Index]^ do
			begin
			Stream.WriteBuffer(FMatrix,  SizeOf(FMatrix));
			Stream.WriteBuffer(FCopired, SizeOf(FCopired));
			if FCopired = -1 then
				SaveObject(FMesh, Stream);
			end;
if M.QuantityMaterials > 0 then
	for Index := 0 to M.QuantityMaterials - 1 do
		begin
		SGWriteStringToStream(M.Materials[Index].MapDiffuseWay, Stream);
		SGWriteStringToStream(M.Materials[Index].Name, Stream);
		end;
end;

class procedure TSGMeshSG3DMLoader.LoadModelFromFile(var M : TSGCustomModel; const VFileName : TSGString);
var
	LoadStream : TStream = nil;
begin
LoadStream := TFileStream.Create(VFileName, fmOpenRead);
if LoadStream <> nil then
	begin
	LoadModel(M, LoadStream);
	LoadStream.Destroy();
	end;
end;

class procedure TSGMeshSG3DMLoader.SaveModelToFile(var M : TSGCustomModel; const VFileName : TSGString);
var
	SaveStream : TStream = nil;
begin
SaveStream := TFileStream.Create(VFileName, fmCreate);
if SaveStream <> nil then
	begin
	SaveModel(M, SaveStream);
	SaveStream.Destroy();
	end;
end;

class procedure TSGMeshSG3DMLoader.LoadObjectFromFile(var O : TSG3DObject; const VFileName : TSGString);
var
	LoadStream : TStream = nil;
begin
if SGFileExists(VFileName) then
	begin
	LoadStream := TFileStream.Create(VFileName, fmOpenRead);
	if LoadStream <> nil then
		begin
		LoadObject(O, LoadStream);
		LoadStream.Destroy();
		end;
	end;
end;

class procedure TSGMeshSG3DMLoader.SaveObjectToFile(var O : TSG3DObject; const VFileName : TSGString);
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
