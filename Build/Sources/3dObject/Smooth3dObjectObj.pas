{$INCLUDE Smooth.inc}

unit Smooth3dObjectObj;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,Smooth3dObject
	,Smooth3dObjectLoader
	,SmoothCommonStructs
	,SmoothVertexObject
	
	,Classes
	;
type
	TS3dObjectOBJLoader = class(TS3dObjectLoader)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
		function Load() : TSBoolean; override;
		function ImportOBJ(const AModel : TSCustomModel; out Sucsses : TSBoolean) : TS3dObjectOBJLoader;
		function ImportOBJ() : TSBoolean; 
		function SetFileName(const VFileName : TSString) : TS3dObjectOBJLoader;
		function SetModel(const VModel : TSCustomModel) : TS3dObjectOBJLoader;
			protected
		class function ReadComand(var f : TextFile) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function ReadLnString(var f : TextFile) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function ReadSingle(var f : TextFile):TSFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ReadObject(const VObject : TS3DObject; const VFile : PTextFile);
			protected
		function LoadMaterialLibrary(const MaterialFileName : TSString):TSBoolean;
		end;

implementation

uses
	 SmoothCommon
	,SmoothRenderBase
	,SmoothStringUtils
	,SmoothFileUtils
	,SmoothLog
	,SmoothMaterial
	;

function TS3dObjectOBJLoader.Load() : TSBoolean;
begin
Result := ImportOBJ();
end;

function TS3dObjectOBJLoader.LoadMaterialLibrary(const MaterialFileName : TSString) : TSBoolean;
var
	f : TextFile;
	Comand : TSString;
begin
if Model = nil then
	begin
	SLog.Source(['TS3dObjectOBJLoader__LoadMaterialLibrary : Error : Loading materials is not possible!']);
	exit;
	end;
Assign(f, MaterialFileName);
try
	Reset(f);
except
	SLog.Source(['TS3dObjectOBJLoader__LoadMaterialLibrary : Error while opening file "', MaterialFileName, '"!']);
	exit;
end;
repeat
Comand := ReadComand(f);
if Comand = 'newmtl' then
	Model.AddMaterial().Name := ReadLnString(f)
else if Comand = 'Ka' then
	begin
	Model.LastMaterial().SetColorAmbient(ReadSingle(f), ReadSingle(f), ReadSingle(f));
	ReadLn(f);
	end
else if Comand = 'Kd' then
	begin
	Model.LastMaterial().SetColorDiffuse(ReadSingle(f), ReadSingle(f), ReadSingle(f));
	ReadLn(f);
	end
else if Comand = 'Ks' then
	begin
	Model.LastMaterial().SetColorSpecular(ReadSingle(f), ReadSingle(f), ReadSingle(f));
	ReadLn(f);
	end
else if Comand = 'Ns' then
	begin
	Model.LastMaterial().Ns := ReadSingle(f);
	ReadLn(f);
	end
else if Comand = 'map_Kd' then
	begin
	Comand := ReadLnString(f);
	if Comand <> '' then
		Model.LastMaterial().AddDiffuseMap(SFilePath(MaterialFileName) + Comand)
	end
else if Comand = 'map_bump' then
	begin
	ReadLnString(f);
	end
else if Comand = 'bump' then
	begin
	Comand := ReadLnString(f);
	if Comand <> '' then
		Model.LastMaterial().AddBumpMap(SFilePath(MaterialFileName) + Comand)
	end
else if Comand = 'map_opacity' then
	begin
	ReadLnString(f);
	end
else if Comand = 'map_d' then
	begin
	ReadLnString(f);
	end
else if Comand = 'refl' then
	begin
	ReadLn(f);
	end
else if Comand = 'map_kS' then
	begin
	ReadLnString(f);
	end
else if Comand = 'map_kA' then
	begin
	ReadLnString(f);
	end
else if Comand = 'map_Ns' then
	begin
	ReadLnString(f);
	end
else
	ReadLn(f);
until SeekEof(f);
Close(f);
end;

class function TS3dObjectOBJLoader.ReadSingle(var f : TextFile):TSFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Read(f, Result);
end;

class function TS3dObjectOBJLoader.ReadLnString(var f : TextFile) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
ReadLn(f, Result);
end;

class function TS3dObjectOBJLoader.ReadComand(var f : TextFile) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	c : TSChar = ' ';
begin
Result := '';
if SeekEoln(f) then
	Exit;
Read(f, c);
while c = ' ' do
	Read(f, c);
while c <> ' ' do
	begin
	Result += C;
	Read(f, C);
	end;
end;

function TS3dObjectOBJLoader.SetModel(const VModel : TSCustomModel) : TS3dObjectOBJLoader;
begin
FModel := VModel;
Result := Self;
end;

class function TS3dObjectOBJLoader.ClassName() : TSString;
begin
Result := 'TS3dObjectOBJLoader';
end;

function TS3dObjectOBJLoader.SetFileName(const VFileName : TSString) : TS3dObjectOBJLoader;
begin
FFileName := VFileName;
Result    := Self;
end;

constructor TS3dObjectOBJLoader.Create();
begin
inherited Create();
FFileName := '';
FModel := nil;
end;

destructor TS3dObjectOBJLoader.Destroy;
begin
inherited Destroy();
end;


function TS3dObjectOBJLoader.ImportOBJ() : TSBoolean;
var
	f :  TextFile;
begin
Result := False;
SLog.Source(['TS3dObjectOBJLoader__ImportOBJ : Loading "',FFileName,'".']);
Assign(f, FFileName);
try
	Reset(f);
except
	SLog.Source(['TS3dObjectOBJLoader__ImportOBJ : Не удалось открыть файл "',FFileName,'".']);
	exit;
end;
ReadObject(FModel.AddObject(), @f);
Close(f);
Result := True;
end;

procedure TS3dObjectOBJLoader.ReadObject(const VObject : TS3DObject; const VFile : PTextFile);
var
	ObjArNormals   : packed array of TSVertex3f = nil;
	ObjArVertex    : packed array of TSVertex3f = nil;
	ObjArTexCoord  : packed array of TSVertex2f = nil;
	ObjArFaces     : packed array of array[0..2,0..2] of TSLongWord;
	ObjArMaterials : packed array of 
		packed record
			FName      : TSString;
			FFaceIndex : TSLongWord;
			end = nil;
	ObjQuantityNormals,ObjQuantityVertices,ObjQuantityTexCoord,ObjQuantityFaces,ObjQuantityMaterials: TSLongWord;
	Comand : TSString;

procedure Calculate3DObject();
var
	ObjArAllVertices : packed array of array[0..2] of TSLongWord = nil;
	ObjQuantityAllVertices : TSLongWord;
	ObjArNormalFaces : packed array of array[0..2] of TSLongWord = nil;
	//ObjQuantityNormalFaces : TSLongWord;

function ExistsVertex(const f1, f2, f3 : TSLongWord):TSInt64;register;
var
	ei : TSLongWord;
begin
Result:=-1;
if ObjQuantityAllVertices <> 0 then
	for ei:= 0 to ObjQuantityAllVertices - 1 do
		if  (f1 = ObjArAllVertices[ei][0]) and
			(f2 = ObjArAllVertices[ei][1]) and 
			(f3 = ObjArAllVertices[ei][2]) then
				begin
				Result:=ei;
				Break;
				end;
end;

var
	i64r : TSInt64;
	ib : TSByte;
	i, ii, iii : TSLongWord;
begin
ObjQuantityAllVertices:=0;
//ObjQuantityNormalFaces:=0;
SetLength(ObjArNormalFaces,ObjQuantityFaces);
for i := 0 to ObjQuantityFaces-1 do
	for ib := 0 to 2 do 
		begin
		i64r := ExistsVertex(ObjArFaces[i][ib][0],ObjArFaces[i][ib][1],ObjArFaces[i][ib][2]);
		if i64r = -1 then
			begin
			ObjQuantityAllVertices+=1;
			SetLength(ObjArAllVertices,ObjQuantityAllVertices);
			ObjArAllVertices[ObjQuantityAllVertices-1][0]:=ObjArFaces[i][ib][0];
			ObjArAllVertices[ObjQuantityAllVertices-1][1]:=ObjArFaces[i][ib][1];
			ObjArAllVertices[ObjQuantityAllVertices-1][2]:=ObjArFaces[i][ib][2];
			ObjArNormalFaces[i][ib] := ObjQuantityAllVertices-1;
			end
		else
			begin
			ObjArNormalFaces[i][ib] := i64r;
			end;
		end;
with VObject do
	begin
	HasNormals := True;
	HasTexture := True;
	VertexType := S3dObjectVertexType3f;
	Vertices := ObjQuantityAllVertices;
	//if Render.CanBumpMapping then
		BumpFormat := SBumpFormatCopyTexture2f;
	for i:= 0 to ObjQuantityAllVertices-1 do
		begin
		ArVertex3f [i]^ := ObjArVertex  [ObjArAllVertices[i][0] - 1];
		ArTexVertex[i]^ := ObjArTexCoord[ObjArAllVertices[i][1] - 1];
		ArNormal   [i]^ := ObjArNormals [ObjArAllVertices[i][2] - 1];
		end;
	i64r := ObjQuantityFaces - 1;
	for i := ObjQuantityMaterials -1 downto 0 do
		begin
		AddFaceArray();
		AutoSetIndexFormat(QuantityFaceArrays-1,ObjQuantityAllVertices);
		PolygonsType[QuantityFaceArrays-1] := SR_TRIANGLES;
		Faces[QuantityFaceArrays-1] := i64r - ObjArMaterials[i].FFaceIndex + 1;
		Model.IdentifyLastObjectMaterial(ObjArMaterials[i].FName);
		iii := 0;
		for ii := ObjArMaterials[i].FFaceIndex to i64r do
			begin
			SetFaceTriangle(QuantityFaceArrays-1,iii,ObjArNormalFaces[ii][0],ObjArNormalFaces[ii][1],ObjArNormalFaces[ii][2]);
			iii += 1;
			end;
		i64r := ObjArMaterials[i].FFaceIndex - 1;
		end;
	end;
if ObjArNormalFaces<>nil then
	SetLength(ObjArNormalFaces,0);
if ObjArAllVertices<>nil then
	SetLength(ObjArAllVertices,0);
end;

procedure ObjAddVertex();
begin
ObjQuantityVertices+=1;
SetLength(ObjArVertex,ObjQuantityVertices);
ReadLn(VFile^,
	ObjArVertex[ObjQuantityVertices-1].x,
	ObjArVertex[ObjQuantityVertices-1].y,
	ObjArVertex[ObjQuantityVertices-1].z);
end;

procedure ObjAddNormal();
begin
ObjQuantityNormals+=1;
SetLength(ObjArNormals,ObjQuantityNormals);
ReadLn(VFile^,
	ObjArNormals[ObjQuantityNormals-1].x,
	ObjArNormals[ObjQuantityNormals-1].y,
	ObjArNormals[ObjQuantityNormals-1].z);
end;

procedure ObjAddTexCoord();
begin
ObjQuantityTexCoord+=1;
SetLength(ObjArTexCoord, ObjQuantityTexCoord);
ReadLn(VFile^,
	ObjArTexCoord[ObjQuantityTexCoord-1].x,
	ObjArTexCoord[ObjQuantityTexCoord-1].y);
end;

procedure ObjAddFace();
var
	i, ii, iii : TSByte;
	S,s2 : TSString;
begin
ObjQuantityFaces+=1;
SetLength(ObjArFaces, ObjQuantityFaces);
ReadLn(VFile^, S);
S2 := '';
ii := 0;
iii:=0;
for i:=1 to Length(S) do
	case S[i] of
	' ','/':if s2<>'' then
		begin
		Val(s2,ObjArFaces[ObjQuantityFaces-1][ii][iii]);
		s2 := '';iii += 1;ii += iii div 3; iii := iii mod 3;
		end;
	else
		s2 += S[i];
	end;
Val(s2,ObjArFaces[ObjQuantityFaces-1][ii][iii]);
end;

procedure ObjAddMaterial();
begin
ObjQuantityMaterials+=1;
SetLength(ObjArMaterials,ObjQuantityMaterials);
ObjArMaterials[ObjQuantityMaterials-1].FName := ReadLnString(VFile^);
ObjArMaterials[ObjQuantityMaterials-1].FFaceIndex := ObjQuantityFaces;
end;

begin
ObjQuantityNormals:=0;
ObjQuantityVertices:=0;
ObjQuantityTexCoord:=0;
ObjQuantityFaces:=0;
ObjQuantityMaterials:=0;

repeat
Comand := ReadComand(VFile^);
if Comand = 'mtllib' then
	LoadMaterialLibrary(SFilePath(FFileName) + ReadLnString(VFile^))
else if Comand = 'v' then
	ObjAddVertex()
else if Comand = 'vn' then
	ObjAddNormal()
else if (Comand = 'g') or (Comand='o') then
	begin
	Comand := ReadLnString(VFile^);
	if VObject.Name = '' then
		VObject.Name := Comand
	else
		begin
		FModel.AddObject().Name := Comand;
		ReadObject(FModel.LastObject(), VFile)
		end;
	end
else if Comand = 'vt' then
	ObjAddTexCoord()
else if Comand = 'usemtl' then
	ObjAddMaterial()
else if Comand = 'f' then
	ObjAddFace()
else
	ReadLn(VFile^);
until SeekEof(VFile^);

Calculate3DObject();
if ObjArNormals<>nil then
	SetLength(ObjArNormals,0);
if ObjArVertex <> nil then
	SetLength(ObjArVertex,0);
if ObjArTexCoord<>nil then
	SetLength(ObjArTexCoord,0);
if ObjArFaces<>nil then
	SetLength(ObjArFaces,0);
if ObjArMaterials<>nil then
	SetLength(ObjArMaterials,0);
end;

function TS3dObjectOBJLoader.ImportOBJ(const AModel : TSCustomModel; out Sucsses : TSBoolean): TS3dObjectOBJLoader;
begin
Result := Self;
Sucsses := False;
SetModel(AModel);
Sucsses := ImportOBJ();
end;

end.
