{$INCLUDE SaGe.inc}

unit SaGeMeshObj;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
	,SaGeMesh
	,SaGeMeshLoader
	,SaGeCommonStructs
	,SaGeVertexObject
	
	,Classes
	;
type
	TSGMeshOBJLoader = class(TSGMeshLoader)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
		function Load() : TSGBoolean; override;
		function ImportOBJ(const AModel : TSGCustomModel; out Sucsses : TSGBoolean) : TSGMeshOBJLoader;
		function ImportOBJ() : TSGBoolean; 
		function SetFileName(const VFileName : TSGString) : TSGMeshOBJLoader;
		function SetModel(const VModel : TSGCustomModel) : TSGMeshOBJLoader;
			protected
		class function ReadComand(var f : TextFile) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function ReadLnString(var f : TextFile) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function ReadSingle(var f : TextFile):TSGFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ReadObject(const VObject : TSG3DObject; const VFile : PTextFile);
			protected
		function LoadMaterialLibrary(const MaterialFileName : TSGString):TSGBoolean;
		end;

implementation

uses
	 SaGeCommon
	,SaGeRenderBase
	,SaGeStringUtils
	,SaGeFileUtils
	,SaGeLog
	,SaGeMaterial
	;

function TSGMeshOBJLoader.Load() : TSGBoolean;
begin
Result := ImportOBJ();
end;

function TSGMeshOBJLoader.LoadMaterialLibrary(const MaterialFileName : TSGString) : TSGBoolean;
var
	f : TextFile;
	Comand : TSGString;
begin
if Model = nil then
	begin
	SGLog.Source(['TSGMeshOBJLoader__LoadMaterialLibrary : Error : Loading materials is not possible!']);
	exit;
	end;
Assign(f, MaterialFileName);
try
	Reset(f);
except
	SGLog.Source(['TSGMeshOBJLoader__LoadMaterialLibrary : Error while opening file "', MaterialFileName, '"!']);
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
		Model.LastMaterial().AddDiffuseMap(SGFilePath(MaterialFileName) + Comand)
	end
else if Comand = 'map_bump' then
	begin
	ReadLnString(f);
	end
else if Comand = 'bump' then
	begin
	Comand := ReadLnString(f);
	if Comand <> '' then
		Model.LastMaterial().AddBumpMap(SGFilePath(MaterialFileName) + Comand)
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

class function TSGMeshOBJLoader.ReadSingle(var f : TextFile):TSGFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Read(f, Result);
end;

class function TSGMeshOBJLoader.ReadLnString(var f : TextFile) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
ReadLn(f, Result);
end;

class function TSGMeshOBJLoader.ReadComand(var f : TextFile) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	c : TSGChar = ' ';
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

function TSGMeshOBJLoader.SetModel(const VModel : TSGCustomModel) : TSGMeshOBJLoader;
begin
FModel := VModel;
Result := Self;
end;

class function TSGMeshOBJLoader.ClassName() : TSGString;
begin
Result := 'TSGMeshOBJLoader';
end;

function TSGMeshOBJLoader.SetFileName(const VFileName : TSGString) : TSGMeshOBJLoader;
begin
FFileName := VFileName;
Result    := Self;
end;

constructor TSGMeshOBJLoader.Create();
begin
inherited Create();
FFileName := '';
FModel := nil;
end;

destructor TSGMeshOBJLoader.Destroy;
begin
inherited Destroy();
end;


function TSGMeshOBJLoader.ImportOBJ() : TSGBoolean;
var
	f :  TextFile;
begin
Result := False;
SGLog.Source(['TSGMeshOBJLoader__ImportOBJ : Loading "',FFileName,'".']);
Assign(f, FFileName);
try
	Reset(f);
except
	SGLog.Source(['TSGMeshOBJLoader__ImportOBJ : Не удалось открыть файл "',FFileName,'".']);
	exit;
end;
ReadObject(FModel.AddObject(), @f);
Close(f);
Result := True;
end;

procedure TSGMeshOBJLoader.ReadObject(const VObject : TSG3DObject; const VFile : PTextFile);
var
	ObjArNormals   : packed array of TSGVertex3f = nil;
	ObjArVertex    : packed array of TSGVertex3f = nil;
	ObjArTexCoord  : packed array of TSGVertex2f = nil;
	ObjArFaces     : packed array of array[0..2,0..2] of TSGLongWord;
	ObjArMaterials : packed array of 
		packed record
			FName      : TSGString;
			FFaceIndex : TSGLongWord;
			end = nil;
	ObjQuantityNormals,ObjQuantityVertexes,ObjQuantityTexCoord,ObjQuantityFaces,ObjQuantityMaterials: TSGLongWord;
	Comand : TSGString;

procedure Calculate3DObject();
var
	ObjArAllVertexes : packed array of array[0..2] of TSGLongWord = nil;
	ObjQuantityAllVertexes : TSGLongWord;
	ObjArNormalFaces : packed array of array[0..2] of TSGLongWord = nil;
	//ObjQuantityNormalFaces : TSGLongWord;

function ExistsVertex(const f1, f2, f3 : TSGLongWord):TSGInt64;register;
var
	ei : TSGLongWord;
begin
Result:=-1;
if ObjQuantityAllVertexes <> 0 then
	for ei:= 0 to ObjQuantityAllVertexes - 1 do
		if  (f1 = ObjArAllVertexes[ei][0]) and
			(f2 = ObjArAllVertexes[ei][1]) and 
			(f3 = ObjArAllVertexes[ei][2]) then
				begin
				Result:=ei;
				Break;
				end;
end;

var
	i64r : TSGInt64;
	ib : TSGByte;
	i, ii, iii : TSGLongWord;
begin
ObjQuantityAllVertexes:=0;
//ObjQuantityNormalFaces:=0;
SetLength(ObjArNormalFaces,ObjQuantityFaces);
for i := 0 to ObjQuantityFaces-1 do
	for ib := 0 to 2 do 
		begin
		i64r := ExistsVertex(ObjArFaces[i][ib][0],ObjArFaces[i][ib][1],ObjArFaces[i][ib][2]);
		if i64r = -1 then
			begin
			ObjQuantityAllVertexes+=1;
			SetLength(ObjArAllVertexes,ObjQuantityAllVertexes);
			ObjArAllVertexes[ObjQuantityAllVertexes-1][0]:=ObjArFaces[i][ib][0];
			ObjArAllVertexes[ObjQuantityAllVertexes-1][1]:=ObjArFaces[i][ib][1];
			ObjArAllVertexes[ObjQuantityAllVertexes-1][2]:=ObjArFaces[i][ib][2];
			ObjArNormalFaces[i][ib] := ObjQuantityAllVertexes-1;
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
	VertexType := SGMeshVertexType3f;
	Vertexes := ObjQuantityAllVertexes;
	//if Render.CanBumpMapping then
		BumpFormat := SGBumpFormatCopyTexture2f;
	for i:= 0 to ObjQuantityAllVertexes-1 do
		begin
		ArVertex3f [i]^ := ObjArVertex  [ObjArAllVertexes[i][0] - 1];
		ArTexVertex[i]^ := ObjArTexCoord[ObjArAllVertexes[i][1] - 1];
		ArNormal   [i]^ := ObjArNormals [ObjArAllVertexes[i][2] - 1];
		end;
	i64r := ObjQuantityFaces - 1;
	for i := ObjQuantityMaterials -1 downto 0 do
		begin
		AddFaceArray();
		AutoSetIndexFormat(QuantityFaceArrays-1,ObjQuantityAllVertexes);
		PoligonesType[QuantityFaceArrays-1] := SGR_TRIANGLES;
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
if ObjArAllVertexes<>nil then
	SetLength(ObjArAllVertexes,0);
end;

procedure ObjAddVertex();
begin
ObjQuantityVertexes+=1;
SetLength(ObjArVertex,ObjQuantityVertexes);
ReadLn(VFile^,
	ObjArVertex[ObjQuantityVertexes-1].x,
	ObjArVertex[ObjQuantityVertexes-1].y,
	ObjArVertex[ObjQuantityVertexes-1].z);
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
	i, ii, iii : TSGByte;
	S,s2 : TSGString;
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
ObjQuantityVertexes:=0;
ObjQuantityTexCoord:=0;
ObjQuantityFaces:=0;
ObjQuantityMaterials:=0;

repeat
Comand := ReadComand(VFile^);
if Comand = 'mtllib' then
	LoadMaterialLibrary(SGFilePath(FFileName) + ReadLnString(VFile^))
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

function TSGMeshOBJLoader.ImportOBJ(const AModel : TSGCustomModel; out Sucsses : TSGBoolean): TSGMeshOBJLoader;
begin
Result := Self;
Sucsses := False;
SetModel(AModel);
Sucsses := ImportOBJ();
end;

end.
