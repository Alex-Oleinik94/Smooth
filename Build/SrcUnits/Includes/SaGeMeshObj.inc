procedure TSG3DObject.LoadFromOBJ(const FFileName:string);

function ObjReadComand(var pf:TextFile):TSGString;inline;
var
	c: TSGChar = ' ';
begin
Result:='';
while (((Result='') and (c=' ')) or (c<>' ')) and (not SeekEoln(pf)) do
	begin
	if c <> ' ' then
		Result+=c;
	Read(pf, c);
	end;
end;

function ObjReadLnString(var pf : TextFile):TSGString;inline;
begin
ReadLn(pf,Result);
end;

procedure LoadMaterialLibrary(const MaterialFileName : TSGString);
var
	f : TextFile;
	Comand : TSGString;
begin
Assign(f,MaterialFileName);
Reset(f);
repeat
Comand := ObjReadComand(f);
if Comand = 'newmtl' then
	begin
	
	end
else if Comand = 'Ka' then
	begin
	
	end
else if Comand = 'Kd' then
	begin
	
	end
else if Comand = 'Ks' then
	begin
	
	end
else if Comand = 'Ns' then
	begin
	
	end
else if Comand = 'map_Kd' then
	begin
	
	end
else if Comand = 'map_bump' then
	begin
	
	end
else if Comand = 'bump' then
	begin
	
	end
else if Comand = 'map_opacity' then
	begin
	
	end
else if Comand = 'map_d' then
	begin
	
	end
else if Comand = 'refl' then
	begin
	
	end
else if Comand = 'map_kS' then
	begin
	
	end
else if Comand = 'map_kA' then
	begin
	
	end
else if Comand = 'map_Ns' then
	begin
	
	end
else if Comand = 'bump' then
	begin
	
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
	ObjQuantityNormals,ObjQuantityVertexes,ObjQuantityTexCoord,ObjQuantityFaces,ObjQuantityMaterials : TSGLongWord;
	Comand : TSGString;

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
	c : TSGChar;
begin
ObjQuantityFaces+=1;
SetLength(ObjArFaces,ObjQuantityFaces);
ReadLn(f,
	ObjArFaces[ObjQuantityFaces-1][0][0],c,
	ObjArFaces[ObjQuantityFaces-1][0][1],c,
	ObjArFaces[ObjQuantityFaces-1][0][2],
	ObjArFaces[ObjQuantityFaces-1][1][0],c,
	ObjArFaces[ObjQuantityFaces-1][1][1],c,
	ObjArFaces[ObjQuantityFaces-1][1][2],
	ObjArFaces[ObjQuantityFaces-1][2][0],c,
	ObjArFaces[ObjQuantityFaces-1][2][1],c,
	ObjArFaces[ObjQuantityFaces-1][2][2]);
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
if Comand = '#' then
	ReadLn(f)
else if Comand = 'mtllib' then
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
end;
