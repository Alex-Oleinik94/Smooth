procedure TSG3DObject.LoadFromOBJ(const FFileName:string);

function ObjReadComand(var pf:TextFile):TSGString;
var
	c: TSGChar = ' ';
begin
Result:='';
if SeekEoln(pf) then
	Exit;
Read(pf, c);
while c=' ' do
	Read(pf, c);
while c<>' ' do
	begin
	Result+=c;
	Read(pf, c);
	end;
end;

function ObjReadLnString(var pf : TextFile):TSGString;inline;
begin
ReadLn(pf,Result);
end;

function ObjReadSingle(var pf : TextFile):TSGSingle;inline;
begin
Read(pf,Result);
end;

procedure LoadMaterialLibrary(const MaterialFileName : TSGString);
var
	f : TextFile;
	Comand : TSGString;

begin
if FParent = nil then
	Exit;
Assign(f,MaterialFileName);
Reset(f);
repeat
Comand := ObjReadComand(f);
if Comand = 'newmtl' then
	FParent.AddMaterial().Name := ObjReadLnString(f)
else if Comand = 'Ka' then
	begin
	FParent.LastMaterial().SetColorAmbient(ObjReadSingle(f),ObjReadSingle(f),ObjReadSingle(f));
	ReadLn(f);
	end
else if Comand = 'Kd' then
	begin
	FParent.LastMaterial().SetColorDiffuse(ObjReadSingle(f),ObjReadSingle(f),ObjReadSingle(f));
	ReadLn(f);
	end
else if Comand = 'Ks' then
	begin
	FParent.LastMaterial().SetColorSpecular(ObjReadSingle(f),ObjReadSingle(f),ObjReadSingle(f));
	ReadLn(f);
	end
else if Comand = 'Ns' then
	begin
	FParent.LastMaterial().Ns := ObjReadSingle(f);
	ReadLn(f);
	end
else if Comand = 'map_Kd' then
	begin
	Comand := ObjReadLnString(f);
	if Comand <> '' then
		FParent.LastMaterial().AddDiffuseMap(SGGetFileWay(MaterialFileName)+Comand)
	end
else if Comand = 'map_bump' then
	begin
	ObjReadLnString(f);
	end
else if Comand = 'bump' then
	begin
	Comand := ObjReadLnString(f);
	if Comand <> '' then
		FParent.LastMaterial().AddBumpMap(SGGetFileWay(MaterialFileName)+Comand)
	end
else if Comand = 'map_opacity' then
	begin
	ObjReadLnString(f);
	end
else if Comand = 'map_d' then
	begin
	ObjReadLnString(f);
	end
else if Comand = 'refl' then
	begin
	ReadLn(f);
	end
else if Comand = 'map_kS' then
	begin
	ObjReadLnString(f);
	end
else if Comand = 'map_kA' then
	begin
	ObjReadLnString(f);
	end
else if Comand = 'map_Ns' then
	begin
	ObjReadLnString(f);
	end
else
	ReadLn(f);
until SeekEof(f);
Close(f);
end;

var
	f : TextFile;
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
	ObjQuantityNormalFaces : TSGLongWord;

function ExistsVertex(const f1,f2,f3:TSGLongWord):TSGInt64;register;
var
	ei : TSGLongWord;
begin
Result:=-1;
if ObjQuantityAllVertexes <> 0 then
	for ei:= 0 to ObjQuantityAllVertexes-1 do
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
ObjQuantityNormalFaces:=0;
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
HasNormals := True;
HasTexture := True;
VertexType := SGMeshVertexType3f;
Vertexes := ObjQuantityAllVertexes;
//if Render.CanBumpMapping then
	BumpFormat := SGMeshBumpTypeCopyTexture2f;
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
	CreateMaterialIDInLastFaceArray(ObjArMaterials[i].FName);
	iii := 0;
	for ii := ObjArMaterials[i].FFaceIndex to i64r do
		begin
		SetFaceTriangle(QuantityFaceArrays-1,iii,ObjArNormalFaces[ii][0],ObjArNormalFaces[ii][1],ObjArNormalFaces[ii][2]);
		iii += 1;
		end;
	i64r := ObjArMaterials[i].FFaceIndex - 1;
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
ReadLn(f,ObjArVertex[ObjQuantityVertexes-1].x,
	ObjArVertex[ObjQuantityVertexes-1].y,
	ObjArVertex[ObjQuantityVertexes-1].z);
end;

procedure ObjAddNormal();
begin
ObjQuantityNormals+=1;
SetLength(ObjArNormals,ObjQuantityNormals);
ReadLn(f,ObjArNormals[ObjQuantityNormals-1].x,
	ObjArNormals[ObjQuantityNormals-1].y,
	ObjArNormals[ObjQuantityNormals-1].z);
end;

procedure ObjAddTexCoord();
begin
ObjQuantityTexCoord+=1;
SetLength(ObjArTexCoord,ObjQuantityTexCoord);
ReadLn(f,ObjArTexCoord[ObjQuantityTexCoord-1].x,
	ObjArTexCoord[ObjQuantityTexCoord-1].y);
end;

procedure ObjAddFace();
var
	i, ii, iii : TSGByte;
	S,s2 : TSGString;
begin
ObjQuantityFaces+=1;
SetLength(ObjArFaces,ObjQuantityFaces);
ReadLn(f,S);
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
ObjArMaterials[ObjQuantityMaterials-1].FName := ObjReadLnString(f);
ObjArMaterials[ObjQuantityMaterials-1].FFaceIndex := ObjQuantityFaces;
end;

begin
ObjQuantityNormals:=0;
ObjQuantityVertexes:=0;
ObjQuantityTexCoord:=0;
ObjQuantityFaces:=0;
ObjQuantityMaterials:=0;

Assign(f,FFileName);
Reset(f);
repeat
Comand := ObjReadComand(f);
if Comand = 'mtllib' then
	LoadMaterialLibrary(SGGetFileWay(FFileName)+ObjReadLnString(f))
else if Comand = 'v' then
	ObjAddVertex()
else if Comand = 'vn' then
	ObjAddNormal()
else if Comand = 'g' then
	Name := ObjReadLnString(f)
else if Comand = 'vt' then
	ObjAddTexCoord()
else if Comand = 'usemtl' then
	ObjAddMaterial()
else if Comand = 'f' then
	ObjAddFace()
else
	ReadLn(f);
until SeekEof(f);
Close(f);
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
