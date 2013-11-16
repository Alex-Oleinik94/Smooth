{$i Includes\SaGe.inc}

unit SaGeMesh;

interface

uses
      Classes
    , SaGeCommon
    , SaGeBase
    , SaGeBased
    , SaGeUtils
    , SaGeImages
    , SaGeRender
    , Crt
    , SaGeContext;

type
	TSGMeshVertexType=(TSGMeshVertexType3f,TSGMeshVertexType2f);
	TSGMeshColorType=(TSGMeshColorType3f,TSGMeshColorType4f,TSGMeshColorType3b,TSGMeshColorType4b);
	
	TSGFaceType = type word;//type longword;
	TSGArTSGFaceType = packed array of TSGFaceType;
	TSGArTSGArTSGFaceType = packed array of TSGArTSGFaceType;
	TSGFaceLine=record
		case byte of
		0:  ( p0,p1: TSGFaceType );
		1:  ( p:packed array [0..1] of TSGFaceType );
		end;
	PTSGFaceLine = ^TSGFaceLine;
	
    TSGFaceTriangle = record
	case byte of
	0: ( p0, p1, p2: TSGFaceType );
	1: ( p:packed array[0..2] of TSGFaceType );
	2: ( v:packed array[0..2] of TSGFaceType );
    end;
    PTSGFaceTriangle = ^TSGFaceTriangle;
	
	TSGFaceQuad = record
	case byte of
	0: ( p0, p1, p2, p3: TSGFaceType );
	1: ( p:packed array[0..3] of TSGFaceType );
    end;
	PTSGFaceQuad = ^ TSGFaceQuad;
	
	TSGFacePoint = record
	case byte of
	0: ( p0: TSGFaceType );
	1: ( p:packed array[0..0] of TSGFaceType );
    end;
	PTSGFacePoint = ^ TSGFacePoint;
	
	PTSGColor3b = ^TSGColor3b;
	TSGColor3b = record
	case byte of
	0 : (b,g,r:byte);
	1 : (p:packed array[0..2] of byte);
	end;
	
	PTSGColor4b = ^TSGColor4b;
	TSGColor4b = record
	case byte of
	0 : (b,g,r,a:byte);
	1 : (p:packed array[0..3] of byte);
	end;
	
    TSGMaterialInfo = class(TSGGLImage)
        constructor Create;
    public
        strName, strFile: string;
    end;

    PSGMaterialInfo = ^TSGMaterialInfo;

    { TSG3dObject }

    TSG3DObject = class(TSGDrawClass)
    public
        constructor Create(); override;
        destructor Destroy(); override;
        class function ClassName():string;override;
    protected
        FNOfVerts: LongWord;
        FNOfFaces: LongWord;
        
        FHasTexture: Boolean;
        FHasNormals: Boolean;
        FHasColors: Boolean;
    protected
        FQuantityTextures:LongWord;
        FPoligonesType:LongWord;
        FVertexType:TSGMeshVertexType;
        FColorType:TSGMeshColorType;
    private
		procedure SetColorType(const VNewColorType:TSGMeshColorType);
		procedure SetVertexType(const VNewVertexType:TSGMeshVertexType);
		procedure SetHasTesture(const VHasTexture:Boolean);
		function GetSizeOfOneVertex():LongWord;inline;
    public
		property QuantityVertexes:LongWord read FNOfVerts;
		property HasTexture:Boolean read FHasTexture write FHasTexture;
		property HasColors:Boolean read FHasColors write FHasColors;
		property HasNormals:Boolean read FHasNormals write FHasNormals;
		property ColorType:TSGMeshColorType read FColorType write SetColorType;
		property VertexType:TSGMeshVertexType read FVertexType write SetVertexType;
		property PoligonesType:LongWord read FPoligonesType write FPoligonesType;
    private
		ArFaces:packed array of TSGFaceType;
		// array of [Vertexes, Colors, Normals, TexVertexes]
		ArVertex:Pointer;
	public
		function GetArVertexes():Pointer;inline;
		
		function GetVertex3f(const Index:TSGMaxEnum):PTSGVertex3f;inline;
		function GetVertex2f(const Index:TSGMaxEnum):PTSGVertex2f;inline;
		
		property ArVertex3f[Index : TSGMaxEnum]:PTSGVertex3f read GetVertex3f;
		property ArVertex2f[Index : TSGMaxEnum]:PTSGVertex2f read GetVertex2f;
		
		procedure AddVertex(const FQuantityNewVertexes:LongWord = 1);
		procedure AddFace(const FQuantityNewFaces:LongWord = 1);
		
		function GetColor3f(const Index:TSGMaxEnum):PTSGColor3f;inline;
		function GetColor4f(const Index:TSGMaxEnum):PTSGColor4f;inline;
		function GetColor3b(const Index:TSGMaxEnum):PTSGColor3b;inline;
		function GetColor4b(const Index:TSGMaxEnum):PTSGColor4b;inline;
		
		property ArColor3f[Index : TSGMaxEnum]:PTSGColor3f read GetColor3f;
		property ArColor4f[Index : TSGMaxEnum]:PTSGColor4f read GetColor4f;
		property ArColor3b[Index : TSGMaxEnum]:PTSGColor3b read GetColor3b;
		property ArColor4b[Index : TSGMaxEnum]:PTSGColor4b read GetColor4b;
		
		procedure SetColor(const Index:TSGMaxEnum;const r,g,b:Single; const a:Single = 1);inline;
		procedure AutoSetColorType(const VWithAlpha:Boolean = False);inline;
		
		function GetNormal(const Index:TSGMaxEnum):PTSGVertex3f;inline;
		property ArNormal[Index : TSGMaxEnum]:PTSGVertex3f read GetNormal;
		
		procedure SetVertexLength(const NewVertexLength:TSGMaxEnum);inline;
		function GetVertexesSize():TSGMaxEnum;overload;inline;
		
		procedure SetFaceQuad(const Index :TSGMaxEnum; const p0,p1,p2,p3:TSGFaceType);
		function ArFacesLines():PTSGFaceLine;inline;
		function ArFacesQuads():PTSGFaceQuad;inline;
		function ArFacesTriangles():PTSGFaceTriangle;inline;
		function ArFacesPoints():PTSGFacePoint;inline;
		
		procedure SetFaceLength(const NewLength:TSGMaxEnum);inline;
		function GetFaceLength():TSGMaxEnum;overload;inline;
		function GetFaceLength(const FaceLength:TSGMaxEnum):TSGMaxEnum;overload;inline;
		class function GetFaceLength(const FaceLength:TSGMaxEnum; const ThisPoligoneType:LongWord):TSGMaxEnum;overload;inline;
		class function GetPoligoneInt(const ThisPoligoneType:LongWord):Byte;inline;
	public
		property Faces:TSGMaxEnum read GetFaceLength write SetFaceLength;
		property Vertexes:TSGMaxEnum write SetVertexLength;
    public
		FEnableVBO:Boolean;
		
        FVBOVertexes:LongWord;
        FVBOFaces:LongWord;
    public
        FEnableCullFace: Boolean;
        FObjectColor: TSGColor4f;
    public
        procedure Draw(); override;
        procedure BasicDraw(); inline;
        procedure LoadToVBO();
        procedure ClearVBO();
        procedure ClearArrays(const ClearN:Boolean = True);
			public
        procedure SaveToStream(const Stream: TStream);virtual;
        procedure LoadFromStream(const Stream: TStream);virtual;
        procedure AddNormals();virtual;
        procedure CatmulClark();virtual;
		//procedure SaveFromSaGe3DObjFile(const FileWay:string);
		//procedure LoadFromSaGe3DObjFile(const FileWay:string);
		//procedure Stripificate;overload;inline;
		//procedure Stripificate(var VertexesAndTriangles:TSGArTSGArTSGFaceType;var OutputStrip:TSGArTSGFaceType);overload;
		//procedure Im;
		//procedure CalculateDependensies(var VertexesAndTriangles:TSGArTSGArTSGFaceType);
		//procedure Optimization(const SaveColors:Boolean = True;const SaveNormals:Boolean = False);
		procedure WriteInfo(const PredStr:string = '');
		procedure LoadFromFile(const FileWay:string);
		procedure LoadFromOBJ(const FFileName:string);virtual;
	public
		function VertexesSize():Int64;Inline;
		function FacesSize():Int64;inline;
		function Size():Int64;inline;
		function RealSize():Int64;inline;
		function GetSizeOf():int64;inline;
	protected 
		FName:String;
	public
		property Name:string read FName write FName;
    end;

    PSG3dObject = ^TSG3dObject;

    { TSGModel }
    TSGModel = class(TSGDrawClass)
    public
        constructor Create;override;
        destructor Destroy; override;
        class function ClassName:String;override;
    public
        NOfObjects:   word;
        NOfMaterials: word;
	
        ArMaterials: packed array of TSGMaterialInfo;
        ArObjects: packed array of TSG3dObject;
    protected
        procedure AddObjectColor(const ObjColor: TSGColor4f);
    public
        procedure Draw(); override;
        property FObjectColor: TSGColor4f write AddObjectColor;
        property ObjectColor: TSGColor4f write AddObjectColor;
		procedure LoadToVBO();
    public
        //procedure LoadFromSaGe3DObjFile(const FileWay: string);
        //procedure SaveToSaGe3DObjFile(const FileWay: string);
        //procedure LoadWRLFromFile(const FileWay: string);
        //procedure LoadOFFFromFile(const FileWay: string);
		procedure SaveToFile(const FileWay: string);
        class function GetWRLNextIdentity(const Text:PTextFile):string;
        procedure Load3DSFromFile(const FileWay:string);
        procedure Stripificate();
        procedure Optimization(const SaveColors:Boolean = True;const SaveNormals:Boolean = False);
        procedure WriteInfo();
        procedure LoadFromFile(const FileWay:string);
        procedure Clear();virtual;
    public
		function VertexesSize():Int64;
		function FacesSize():Int64;
		function Size():Int64;
		function RealSize():Int64;
    end;
    PSGModel = ^TSGModel;
    
    TSG3DCollisionObject=class(TSG3DObject)
		
		end;

//{$DEFINE SGREADINTERFACE}      {$i Includes\SaGeMesh3ds.inc} {$UNDEF SGREADINTERFACE}

implementation

//{$DEFINE SGREADIMPLEMENTATION} {$i Includes\SaGeMesh3ds.inc} {$UNDEF SGREADIMPLEMENTATION}

procedure TSG3DObject.SetFaceQuad(const Index :TSGMaxEnum; const p0,p1,p2,p3:TSGFaceType);
begin
if Render.RenderType=SGRenderDirectX then
	begin
	ArFacesTriangles[Index*2].p[0]:=p0;
	ArFacesTriangles[Index*2].p[1]:=p1;
	ArFacesTriangles[Index*2].p[2]:=p2;
	ArFacesTriangles[Index*2+1].p[0]:=p2;
	ArFacesTriangles[Index*2+1].p[1]:=p3;
	ArFacesTriangles[Index*2+1].p[2]:=p0;
	end
else
	begin
	ArFacesQuads[Index].p[0]:=p0;
	ArFacesQuads[Index].p[1]:=p1;
	ArFacesQuads[Index].p[2]:=p2;
	ArFacesQuads[Index].p[3]:=p3;
	end;
end;

procedure TSG3DObject.CatmulClark();
var
	ArMiddlePointsPol:packed array of TSGVertex3f = nil;
	ii,iii,i:LongWord;
	ArNeighbourPoligons:packed array of array [0..2] of LongWord;

function FindNeighbour(const p1,p2:TSGFaceType; const Pol:LongWord):LongWord;
var
	i,ii,iii:LongWord;
begin
Result:=FNOfFaces;
for i:=0 to FNOfFaces-1 do
	if i<>Pol then
		begin
		iii:=0;
		for ii:=0 to 2 do
			if (ArFacesTriangles[i].p[ii]=p1) or (ArFacesTriangles[i].p[ii]=p2) then
				iii+=1;
		if iii=2 then
			begin
			Result:=i;
			Break;
			end;
		end;
end;

begin
SetLength(ArMiddlePointsPol,FNOfFaces);
For i:=0 to FNOfFaces-1 do
	begin
	case FPoligonesType of
	SGR_TRIANGLES:
		begin
		ArMiddlePointsPol[i]:=
			(ArVertex3f[ArFacesTriangles[i].p[0]]^+
			ArVertex3f[ArFacesTriangles[i].p[1]]^+
			ArVertex3f[ArFacesTriangles[i].p[2]]^)/3;
		end;
	end;
	end;
SetLength(ArNeighbourPoligons,FNOfFaces);
for i:=0 to FNOfFaces-1 do
	begin
	ArNeighbourPoligons[i][0]:=FindNeighbour(
		ArFacesTriangles[i].p[0],ArFacesTriangles[i].p[1],i);
	ArNeighbourPoligons[i][1]:=FindNeighbour(
		ArFacesTriangles[i].p[2],ArFacesTriangles[i].p[1],i);
	ArNeighbourPoligons[i][2]:=FindNeighbour(
		ArFacesTriangles[i].p[0],ArFacesTriangles[i].p[2],i);
	end;
	
end;

procedure TSG3DObject.AddNormals();
var
	SecondArVertex:Pointer = nil;
	i,ii,iiii,iii:TSGMaxEnum;
	ArPoligonesNormals:packed array of TSGVertex3f = nil;
	Plane:SGPlane;
	Vertex:TSGVertex;
begin
if FHasNormals or (FPoligonesType<>SGR_TRIANGLES) then
	Exit;
ii:=GetSizeOfOneVertex();
iii:=ii+3*SizeOf(Single);
GetMem(SecondArVertex,iii*FNOfVerts);
for i:=0 to FNOfVerts-1 do
	Move(
		PByte(ArVertex)[i*ii],
		PByte(SecondArVertex)[i*iii],
		ii);
FreeMem(ArVertex);
ArVertex:=SecondArVertex;
SecondArVertex:=nil;
FHasNormals:=True;
SetLength(ArPoligonesNormals,FNOfFaces);
for i:=0 to FNOfFaces-1 do
	begin
	Plane:=SGGetPlaneFromThreeVertex(
		ArVertex3f[ArFacesTriangles[i].p[0]]^,
		ArVertex3f[ArFacesTriangles[i].p[1]]^,
		ArVertex3f[ArFacesTriangles[i].p[2]]^);
	ArPoligonesNormals[i].Import(
		Plane.a,Plane.b,Plane.c);
	end;
for i:=0 to FNOfVerts-1 do
	begin
	Vertex.Import(0,0,0);
	for ii:=0 to FNOfFaces-1 do
		begin
		iii:=0;
		for iiii:=0 to 2 do
			if ArFacesTriangles[ii].p[iiii]=i then
				begin
				iii:=1;
				Break;
				end;
		if iii=1 then
			Vertex+=ArPoligonesNormals[ii];
		end;
	Vertex.Normalize();
	ArNormal[i]^:=Vertex;
	end;
SetLength(ArPoligonesNormals,0);
end;

procedure TSG3DObject.LoadFromStream(const Stream: TStream);
begin
Stream.ReadBuffer(FObjectColor,SizeOf(FObjectColor));
Stream.ReadBuffer(FNOfVerts,SizeOf(FNOfVerts));
Stream.ReadBuffer(FNOfFaces,SizeOf(FNOfFaces));
Stream.ReadBuffer(FHasColors,SizeOf(FHasColors));
Stream.ReadBuffer(FHasNormals,SizeOf(FHasNormals));
Stream.ReadBuffer(FHasTexture,SizeOf(FHasTexture));
Stream.ReadBuffer(FQuantityTextures,SizeOf(FQuantityTextures));
Stream.ReadBuffer(FPoligonesType,SizeOf(FPoligonesType));
Stream.ReadBuffer(FVertexType,SizeOf(FVertexType));
Stream.ReadBuffer(FColorType,SizeOf(FColorType));

FName:=SGReadStringFromStream(Stream);

if ArVertex<>nil then
	FreeMem(ArVertex);
GetMem(ArVertex,GetSizeOfOneVertex()*FNOfVerts);
Stream.ReadBuffer(PByte(ArVertex)^,FNOfVerts*GetSizeOfOneVertex());

SetFaceLength(FNOfFaces);
Stream.ReadBuffer(ArFaces[0],Length(ArFaces)*SizeOf(TSGFaceType));
end;

procedure TSG3DObject.SaveToStream(const Stream: TStream);
begin
Stream.WriteBuffer(FObjectColor,SizeOf(FObjectColor));
Stream.WriteBuffer(FNOfVerts,SizeOf(FNOfVerts));
Stream.WriteBuffer(FNOfFaces,SizeOf(FNOfFaces));
Stream.WriteBuffer(FHasColors,SizeOf(FHasColors));
Stream.WriteBuffer(FHasNormals,SizeOf(FHasNormals));
Stream.WriteBuffer(FHasTexture,SizeOf(FHasTexture));
Stream.WriteBuffer(FQuantityTextures,SizeOf(FQuantityTextures));
Stream.WriteBuffer(FPoligonesType,SizeOf(FPoligonesType));
Stream.WriteBuffer(FVertexType,SizeOf(FVertexType));
Stream.WriteBuffer(FColorType,SizeOf(FColorType));
SGWriteStringToStream(FName,Stream);
Stream.WriteBuffer(PByte(ArVertex)^,FNOfVerts*GetSizeOfOneVertex());
Stream.WriteBuffer(ArFaces[0],Length(ArFaces)*SizeOf(TSGFaceType));
end;

procedure TSG3DObject.AddFace(const FQuantityNewFaces:LongWord = 1);
begin
SetFaceLength(FQuantityNewFaces+FNOfFaces);
end;

procedure TSG3DObject.LoadFromOBJ(const FFileName:string);
var
	f:TextFile;
	C:TSGChar;
	Comand:String = '';
	ArMaterials:packed array of 
		packed record 
		Color:TSGColor3f;
		Name:String;
		end = nil;
	NowMatCOlor:TSGColor3f = (r:1;g:1;b:1);

procedure LoadingMaterials(const FMaterialsFileName:String);
var
	fm:TextFile;
	Comand:string = '';
	NowSelectMaterial:LongWord;
begin
if not SGFileExists(SGGetFileWay(FFileName)+FMaterialsFileName) then
	Exit;
Assign(fm,SGGetFileWay(FFileName)+FMaterialsFileName);
Reset(fm);
while not SeekEof(fm) do
	begin
	c:=#0;
	Comand:='';
	while SeekEoln(fm) do
		begin
		ReadLn(fm);
		end;
	while c<>' ' do
		begin
		Read(fm,C);
		if C<>' ' then
			Comand+=C;
		end;
	if Comand = '#' then
		begin
		ReadLn(fm);
		end
	else if Comand = 'illum' then
		begin
		ReadLn(fm);
		end
	else if Comand = 'd' then
		begin
		ReadLn(fm);
		end
	else if Comand = 'Ks' then
		begin
		ReadLn(fm);
		end
	else if Comand = 'Ka' then
		begin
		ReadLn(fm);
		end
	else if Comand = 'Kd' then
		begin
		ReadLn(fm,
			ArMaterials[NowSelectMaterial].Color.r,
			ArMaterials[NowSelectMaterial].Color.g,
			ArMaterials[NowSelectMaterial].Color.b);
		end
	else if Comand='newmtl' then
		begin
		ReadLn(fm,Comand);
		if ArMaterials=nil then
			SetLength(ArMaterials,1)
		else
			SetLength(ArMaterials,Length(ArMaterials)+1);
		NowSelectMaterial:=High(ArMaterials);
		ArMaterials[NowSelectMaterial].Name:=Comand;
		end
	else
		ReadLn(fm);
	end;
Close(fm);
end;

function FindMaterial(const FMaterialName:String):TSGColor3f;
var
	i,ii:LongWord;
begin
ii:=0;
if ArMaterials<>nil then
for i:=0 to High(ArMaterials) do
	if ArMaterials[i].Name=FMaterialName then
		begin
		Result:=ArMaterials[i].Color;
		ii:=1;
		Break;
		end;
if ii=0 then
	Result.Import(1,1,1);
end;

procedure AddV();
var
	x0,y0,z0:Single;
begin
ReadLn(f,x0,y0,z0);
AddVertex(1);
ArVertex3f[QuantityVertexes-1]^.x:=x0;
ArVertex3f[QuantityVertexes-1]^.y:=y0;
ArVertex3f[QuantityVertexes-1]^.z:=z0;
SetColor(QuantityVertexes-1,NowMatCOlor.r,NowMatCOlor.g,NowMatCOlor.b);
end;

procedure AddF();
var
	a1,a2,a3:LongInt;
begin
ReadLn(f,a1,a2,a3);
AddFace(1);
ArFacesTriangles[FNOfFaces-1].p0:=QuantityVertexes+a1;
ArFacesTriangles[FNOfFaces-1].p1:=QuantityVertexes+a2;
ArFacesTriangles[FNOfFaces-1].p2:=QuantityVertexes+a3;
end;

begin
AutoSetColorType();
SetVertexType(TSGMeshVertexType3f);
PoligonesType:=SGR_TRIANGLES;
NowMatCOlor.Import(1,1,1);

Assign(f,FFileName);
Reset(f);
while not SeekEof(f) do
	begin
	c:=#0;
	Comand:='';
	while SeekEoln(f) do
		begin
		ReadLn(f);
		end;
	while c<>' ' do
		begin
		Read(f,C);
		if C<>' ' then
			Comand+=C;
		end;
	if Comand = '#' then
		begin
		ReadLn(f);
		end
	else if Comand='v' then
		begin
		AddV();
		end
	else if Comand='f' then
		begin
		AddF();
		end
	else if Comand='o' then
		begin
		ReadLn(f);//Name of model
		end
	else if Comand='usemtl' then
		begin
		ReadLn(f,Comand);
		NowMatCOlor:=FindMaterial(Comand);
		end
	else if Comand='mtllib' then
		begin
		ReadLn(f,Comand);
		LoadingMaterials(Comand);
		end
	else if Comand='g' then
		begin
		ReadLn(f);//Name now mesh
		end
	else if Comand='s' then
		begin
		ReadLn(f);
		end
	else
		ReadLn(f);
	end;
Close(f);
end;

procedure TSG3DObject.AddVertex(const FQuantityNewVertexes:LongWord = 1);
begin
FNOfVerts+=FQuantityNewVertexes;
ReAllocMem(ArVertex,GetVertexesSize());
end;

procedure TSG3DObject.AutoSetColorType(const VWithAlpha:Boolean = False);inline;
begin
if Render<>nil then
	begin
	if Render.RenderType=SGRenderOpenGL then
		begin
		if VWithAlpha then
			SetColorType(TSGMeshColorType4f)
		else
			SetColorType(TSGMeshColorType3f);
		end
	else if Render.RenderType=SGRenderDirectX then
		begin
		SetColorType(TSGMeshColorType4b);
		end;
	end;
end;

procedure TSG3DObject.SetColor(const Index:TSGMaxEnum;const r,g,b:Single; const a:Single = 1);inline;
begin
if (FColorType=TSGMeshColorType3f) then
	begin
	ArColor3f[Index]^.r:=r;
	ArColor3f[Index]^.g:=g;
	ArColor3f[Index]^.b:=b;
	end
else if (FColorType=TSGMeshColorType4f) then
	begin
	ArColor4f[Index]^.r:=r;
	ArColor4f[Index]^.g:=g;
	ArColor4f[Index]^.b:=b;
	ArColor4f[Index]^.a:=a;
	end
else if (FColorType=TSGMeshColorType3b) then
	begin
	ArColor3b[Index]^.r:=round(r*255);
	ArColor3b[Index]^.g:=round(g*255);
	ArColor3b[Index]^.b:=round(b*255);
	end
else if (FColorType=TSGMeshColorType4b) then
	begin
	ArColor4b[Index]^.r:=round(r*255);
	ArColor4b[Index]^.g:=round(g*255);
	ArColor4b[Index]^.b:=round(b*255);
	ArColor4b[Index]^.a:=round(a*255);
	end;
end;

function TSG3DObject.GetNormal(const Index:TSGMaxEnum):PTSGVertex3f;inline;
begin
Result:=PTSGVertex3f( 
	LongWord(ArVertex)+
	GetSizeOfOneVertex()*Index+
	
	(2+Byte(FVertexType=TSGMeshVertexType3f))*SizeOf(Single)
	+Byte(FHasColors)*( //Цвета
	byte(FColorType=TSGMeshColorType3b)*3+
	byte(FColorType=TSGMeshColorType4b)*4+
	byte(FColorType=TSGMeshColorType4f)*4*SizeOf(Single)+
	byte(FColorType=TSGMeshColorType3f)*3*SizeOf(Single))
	);
end;

function TSG3DObject.GetColor4f(const Index:TSGMaxEnum):PTSGColor4f;inline;
begin
Result:=PTSGColor4f( 
	LongWord(ArVertex)+
	GetSizeOfOneVertex()*Index+
	(2+Byte(FVertexType=TSGMeshVertexType3f))*SizeOf(Single)
	);
end;

function TSG3DObject.GetColor3b(const Index:TSGMaxEnum):PTSGColor3b;inline;
begin
Result:=PTSGColor3b( 
	LongWord(ArVertex)+
	GetSizeOfOneVertex()*Index+
	(2+Byte(FVertexType=TSGMeshVertexType3f))*SizeOf(Single)
	);
end;

function TSG3DObject.GetColor4b(const Index:TSGMaxEnum):PTSGColor4b;inline;
begin
Result:=PTSGColor4b( 
	LongWord(ArVertex)+
	GetSizeOfOneVertex()*Index+
	(2+Byte(FVertexType=TSGMeshVertexType3f))*SizeOf(Single)
	);
end;

function TSG3DObject.GetColor3f(const Index:TSGMaxEnum):PTSGColor3f;inline;
begin
Result:=PTSGColor3f( 
	LongWord(ArVertex)+
	GetSizeOfOneVertex()*Index+
	(2+Byte(FVertexType=TSGMeshVertexType3f))*SizeOf(Single)
	);
end;

function TSG3DObject.GetArVertexes():Pointer;inline;
begin
Result:=ArVertex;
end;

procedure TSG3DObject.SetVertexType(const VNewVertexType:TSGMeshVertexType);
begin
FVertexType:=VNewVertexType;
end;

procedure TSG3DObject.SetColorType(const VNewColorType:TSGMeshColorType);
begin
FHasColors:=True;
FColorType:=VNewColorType;
end;

procedure TSG3DObject.SetHasTesture(const VHasTexture:Boolean);
begin
if VHasTexture and (FQuantityTextures=0) then
	FQuantityTextures:=1;
FHasTexture:=VHasTexture;
end;

procedure TSG3DObject.SetVertexLength(const NewVertexLength:TSGMaxEnum);inline;
begin
FNOfVerts:=NewVertexLength;
GetMem(ArVertex,GetVertexesSize());
end;

function TSG3DObject.GetSizeOfOneVertex():LongWord;
begin
Result:=
(2+Byte(FVertexType=TSGMeshVertexType3f))*SizeOf(Single)//Вершины
 
+Byte(FHasColors)*( //Цвета
	byte(FColorType=TSGMeshColorType3b)*3+
	byte(FColorType=TSGMeshColorType4b)*4+
	byte(FColorType=TSGMeshColorType4f)*4*SizeOf(Single)+
	byte(FColorType=TSGMeshColorType3f)*3*SizeOf(Single))

+Byte(FHasTexture)*2*SizeOf(Single)*FQuantityTextures

+Byte(FHasNormals)*3*SizeOf(Single);
end;

function TSG3DObject.GetVertexesSize():TSGMaxEnum;overload;inline;
begin
Result:=FNOfVerts*GetSizeOfOneVertex();
end;

function TSG3DObject.GetVertex3f(const Index:TSGMaxEnum):PTSGVertex3f;inline;
begin
Result:=PTSGVertex3f(LongWord(ArVertex)+Index*(GetSizeOfOneVertex()));
end;

function TSG3DObject.GetVertex2f(const Index:TSGMaxEnum):PTSGVertex2f;inline;
begin
Result:=PTSGVertex2f(LongWord(ArVertex)+Index*(GetSizeOfOneVertex()));
end;

procedure TSG3DObject.LoadFromFile(const FileWay:string);
begin
(**)
end;

class function TSG3DObject.GetFaceLength(const FaceLength:TSGMaxEnum; const ThisPoligoneType:LongWord):TSGMaxEnum;overload;inline;
begin
Result:=FaceLength*GetPoligoneInt(ThisPoligoneType);
end;

class function TSG3DObject.ClassName:string;
begin
Result:='TSG3dObject';
end;

procedure TSG3DObject.WriteInfo(const PredStr:string = '');
begin
WriteLn('TSG3DObject__WriteInfo(string)');
WriteLn(PredStr,'FNOfVerts = ',FNOfVerts);
WriteLn(PredStr,'FNOfFaces = ',FNOfFaces,'; RealFaceLength = ',GetFaceLength);
WriteLn(PredStr,'FHasColors = ',FHasColors);
WriteLn(PredStr,'FHasNormals = ',FHasNormals);
WriteLn(PredStr,'FHasTexture = ',FHasTexture);
WriteLn(PredStr,'GetSizeOfOneVertex() = ',GetSizeOfOneVertex());
Write(PredStr,'FVertexFormat = ');
if FVertexType=TSGMeshVertexType2f then
	WriteLn('TSGMeshVertexType2f')
else if FVertexType=TSGMeshVertexType3f then
	WriteLn('TSGMeshVertexType3f');
Write(PredStr,'FColorType = ');
case FColorType of
TSGMeshColorType3b:WriteLn('TSGMeshColorType3b');
TSGMeshColorType4b:WriteLn('TSGMeshColorType4b');
TSGMeshColorType3f:WriteLn('TSGMeshColorType3f');
TSGMeshColorType4f:WriteLn('TSGMeshColorType4f');
end;
WriteLn(PredStr,'FQuantityTextures = ',FQuantityTextures);
WriteLn(PredStr,'FEnableVBO = ',FEnableVBO);
end;

function TSG3DObject.RealSize:Int64;inline;
begin
Result:=
	Length(ArFaces)*SizeOf(TSGFaceType)+
	FNOfVerts*GetSizeOfOneVertex();
end;

function TSG3DObject.VertexesSize:Int64;Inline;
begin
Result:=GetSizeOfOneVertex()*FNOfVerts;
end;

function TSG3DObject.FacesSize:Int64;inline;
begin
Result:=SizeOf(TSGFaceType)*GetFaceLength();
end;

function TSG3DObject.Size:Int64;inline;
begin
Result:=
	FacesSize+
	VertexesSize;
end;

class function TSG3DObject.GetPoligoneInt(const ThisPoligoneType:LongWord):Byte;inline;
begin
Result:=
	Byte(
		(ThisPoligoneType=SGR_POINTS) or
		(ThisPoligoneType=SGR_TRIANGLE_STRIP) or
		(ThisPoligoneType=SGR_LINE_LOOP) or
		(ThisPoligoneType=SGR_LINE_STRIP))
	+4*Byte( ThisPoligoneType = SGR_QUADS )
	+3*Byte( ThisPoligoneType = SGR_TRIANGLES )
	+2*Byte( ThisPoligoneType = SGR_LINES );
end;

function TSG3DObject.GetFaceLength(const FaceLength:TSGMaxEnum):TSGMaxEnum;overload;inline;
begin
Result:=GetFaceLength(FaceLength,FPoligonesType);
end;

function TSG3DObject.GetFaceLength:TSGMaxEnum;overload;inline;
begin
Result:=GetFaceLength(FNOfFaces);
end;

procedure TSG3DObject.SetFaceLength(const NewLength:TSGMaxEnum);inline;
begin
FNOfFaces:=NewLength;
SetLength(ArFaces ,GetFaceLength(NewLength));
end;

function TSG3DObject.ArFacesLines:PTSGFaceLine;inline;
begin
if FPoligonesType=SGR_LINES then
	Result:=PTSGFaceLine(Pointer(@ArFaces[0]))
else
	Result:=nil;
end;

function TSG3DObject.ArFacesPoints:PTSGFacePoint;inline;
begin
if (
	(FPoligonesType=SGR_POINTS) or
	(FPoligonesType=SGR_LINE_STRIP) or
	(FPoligonesType=SGR_LINE_LOOP) or
	(FPoligonesType=SGR_TRIANGLE_STRIP)
	)  then
	Result:=PTSGFacePoint(Pointer(@ArFaces[0]))
else
	Result:=nil;
end;

function TSG3DObject.ArFacesQuads:PTSGFaceQuad;inline;
begin
if FPoligonesType=SGR_QUADS then
	Result:=PTSGFaceQuad(Pointer(@ArFaces[0]))
else
	Result:=nil;
end;

function TSG3DObject.ArFacesTriangles:PTSGFaceTriangle;inline;
begin
if FPoligonesType=SGR_TRIANGLES then
	Result:=PTSGFaceTriangle(Pointer(@ArFaces[0]))
else
	Result:=nil;
end;

function TSG3dObject.GetSizeOf:int64;
begin
Result:=
	GetFaceLength*SizeOf(TSGFaceType)+
	FNOfVerts*GetSizeOfOneVertex();
end;

constructor TSG3dObject.Create();
begin
    inherited Create();
    FName:='';
    FQuantityTextures:=0;
    FEnableCullFace := False;
    FObjectColor.Import(1, 1, 1, 1);
    FHasTexture := False;
    FHasNormals := False;
    FHasColors  := False;
    FNOfFaces := 0;
    FNOfVerts := 0;
    ArVertex := nil;
    ArFaces := nil;
    //FMaterialID := -1;
    FPoligonesType:=SGR_TRIANGLES;
    FColorType:=TSGMeshColorType3b;
    FVertexType:=TSGMeshVertexType3f;
    FEnableVBO:=False;
    FVBOFaces:=0;
    FVBOVertexes:=0;
end;

destructor TSG3dObject.Destroy();
begin
ClearArrays();
ClearVBO();
inherited Destroy();
end;

procedure TSG3dObject.Draw(); inline;
begin
{$IFDEF SGMoreDebuging}
	WriteLn('Call "TSG3dObject.Draw" : "'+ClassName+'" is sucsesfull');
	{$ENDIF}
    if FEnableCullFace then
    begin
        Render.Enable(SGR_CULL_FACE);
        Render.CullFace(SGR_BACK);
    end;
    BasicDraw;
    if FEnableCullFace then
    begin
        Render.CullFace(SGR_FRONT);
        BasicDraw();
        Render.Disable(SGR_CULL_FACE);
    end;
end;

procedure TSG3DObject.ClearArrays(const ClearN:boolean = True);
begin
if ArVertex<>nil then
	begin
	FreeMem(ArVertex);
	ArVertex:=nil;
	end;
if ArFaces<>nil then
	begin 
	SetLength(ArFaces,0);
	ArFaces:=nil;
	end;
if ClearN then
	begin
	FNOfFaces:=0;
	FNOfVerts:=0;
	end;
end;

{procedure TSG3dObject.SaveFromSaGe3DObjFile(const FileWay:string);
var
	Stream:TStream = nil;
begin
Stream:=TFileStream.Create(FileWay,fmCreate);
SaveToStream(Stream);
Stream.Destroy;
end;}

{procedure TSG3dObject.LoadFromSaGe3DObjFile(const FileWay:string);
var
	Stream:TStream = nil;
begin
if SGFileExists(FileWay) then
	begin
	Stream:=TFileStream.Create(FileWay,fmOpenRead);
	LoadFromStream(Stream);
	Stream.Destroy;
	end;
end;}

procedure TSG3dObject.BasicDraw(); inline;
const
	FaceFormat = SGR_UNSIGNED_SHORT; 
// GL_UNSIGNED_INT - LongWord - 4
// GL_UNSIGNED_SHORT - Word - 2
// GL_UNSIGNED_BYTE - Byte - 1
begin

FObjectColor.Color(Render);


Render.EnableClientState(SGR_VERTEX_ARRAY);
if FHasNormals then
	Render.EnableClientState(SGR_NORMAL_ARRAY);
if FHasTexture then
	Render.EnableClientState(SGR_TEXTURE_COORD_ARRAY);
if FHasColors then
	Render.EnableClientState(SGR_COLOR_ARRAY);

if FEnableVBO then
	begin
	Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,FVBOVertexes);
	Render.VertexPointer(2+Byte(FVertexType=TSGMeshVertexType3f),SGR_FLOAT,GetSizeOfOneVertex(),nil);
	
	if FHasColors then
		begin
		Render.ColorPointer(
			3+Byte((FColorType=TSGMeshColorType4b) or (FColorType=TSGMeshColorType4f)),
			SGR_FLOAT*Byte((FColorType=TSGMeshColorType3f) or (FColorType=TSGMeshColorType4f))+
				SGR_UNSIGNED_BYTE*Byte((FColorType=TSGMeshColorType4b) or (FColorType=TSGMeshColorType3b)),
			GetSizeOfOneVertex(),
			Pointer(SizeOf(Single)*(2+Byte(FVertexType=TSGMeshVertexType3f))));
		end;
	
	if FHasNormals then
		begin
		Render.NormalPointer(
			SGR_FLOAT,
			GetSizeOfOneVertex(),
			Pointer(
				SizeOf(Single)*(2+Byte(FVertexType=TSGMeshVertexType3f))+
				Byte(FHasColors)*(
					byte(FColorType=TSGMeshColorType3b)*3+
					byte(FColorType=TSGMeshColorType4b)*4+
					byte(FColorType=TSGMeshColorType4f)*4*SizeOf(Single)+
					byte(FColorType=TSGMeshColorType3f)*3*SizeOf(Single))
				));
		end;
	
	if FHasTexture then
		begin
		Render.TexCoordPointer(2, SGR_FLOAT, GetSizeOfOneVertex(),
			Pointer(
				SizeOf(Single)*(2+Byte(FVertexType=TSGMeshVertexType3f))+
				Byte(FHasColors)*(
					byte(FColorType=TSGMeshColorType3b)*3+
					byte(FColorType=TSGMeshColorType4b)*4+
					byte(FColorType=TSGMeshColorType4f)*4*SizeOf(Single)+
					byte(FColorType=TSGMeshColorType3f)*3*SizeOf(Single))+
				Byte(FHasNormals)*(SizeOf(Single)*3)
				));
		end;
	
	Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB ,FVBOFaces);
	Render.DrawElements(FPoligonesType, GetFaceLength() ,FaceFormat,nil);
	
	Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,0);
	Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB,0);
	end
else
	begin
    Render.VertexPointer(
		2+Byte(FVertexType=TSGMeshVertexType3f),
		SGR_FLOAT, 
		GetSizeOfOneVertex(), 
		ArVertex);
    if FHasColors then
		Render.ColorPointer(
			3+Byte((FColorType=TSGMeshColorType4b) or (FColorType=TSGMeshColorType4f)),
			SGR_FLOAT*Byte((FColorType=TSGMeshColorType3f) or (FColorType=TSGMeshColorType4f))+
				SGR_UNSIGNED_BYTE*Byte((FColorType=TSGMeshColorType4b) or (FColorType=TSGMeshColorType3b)),
			GetSizeOfOneVertex(),
			Pointer(
				LongWord(ArVertex)+
				SizeOf(Single)*(2+Byte(FVertexType=TSGMeshVertexType3f))));
	if FHasNormals then
		Render.NormalPointer(
			SGR_FLOAT, 
			GetSizeOfOneVertex(), 
			Pointer(
				LongWord(ArVertex)+
				SizeOf(Single)*(2+Byte(FVertexType=TSGMeshVertexType3f))+
				Byte(FHasColors)*(
					byte(FColorType=TSGMeshColorType3b)*3+
					byte(FColorType=TSGMeshColorType4b)*4+
					byte(FColorType=TSGMeshColorType4f)*4*SizeOf(Single)+
					byte(FColorType=TSGMeshColorType3f)*3*SizeOf(Single))));
    if FHasTexture then
        Render.TexCoordPointer(
			2, 
			SGR_FLOAT, 
			GetSizeOfOneVertex(), 
			Pointer(
				LongWord(ArVertex)+
				SizeOf(Single)*(2+Byte(FVertexType=TSGMeshVertexType3f))+
				Byte(FHasColors)*(
					byte(FColorType = TSGMeshColorType3b)*3+
					byte(FColorType = TSGMeshColorType4b)*4+
					byte(FColorType = TSGMeshColorType4f)*4*SizeOf(Single)+
					byte(FColorType = TSGMeshColorType3f)*3*SizeOf(Single))+
				Byte(FHasNormals)*(SizeOf(Single)*3)));
    Render.DrawElements(FPoligonesType, GetFaceLength() , FaceFormat, @ArFaces[0]);
    end;
Render.DisableClientState(SGR_VERTEX_ARRAY);
if FHasNormals then
	Render.DisableClientState(SGR_NORMAL_ARRAY);
if FHasTexture then
	Render.DisableClientState(SGR_TEXTURE_COORD_ARRAY);
if FHasColors then
	Render.DisableClientState(SGR_COLOR_ARRAY);
end;

procedure TSG3dObject.LoadToVBO;
begin
	Render.GenBuffersARB(1, @FVBOVertexes);
	Render.GenBuffersARB(1, @FVBOFaces);

	Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,FVBOVertexes);
	Render.BufferDataARB (SGR_ARRAY_BUFFER_ARB,FNOfVerts*GetSizeOfOneVertex(),ArVertex, SGR_STATIC_DRAW_ARB);
	//WriteInfo('  ');
	Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB,FVBOFaces);
	Render.BufferDataARB (SGR_ELEMENT_ARRAY_BUFFER_ARB,GetFaceLength()*SizeOf(TSGFaceType),@ArFaces[0], SGR_STATIC_DRAW_ARB);

	Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,0);
	Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB,0);
	
	ClearArrays(False);
	FEnableVBO:=True;
	//WriteLn(123);
end;

procedure TSG3DObject.ClearVBO();inline;
begin
if FEnableVBO and (Render<>nil) then
	begin
	if FVBOFaces <> 0 then
		Render.DeleteBuffersARB(1,@FVBOFaces);
	FVBOFaces:=0;
	if FVBOVertexes<>0 then
		Render.DeleteBuffersARB(1,@FVBOVertexes);
	FVBOVertexes:=0;
	FEnableVBO:=False;
	end;
end;

(************************************************************************************)
(************************************){TSGModel}(************************************)
(************************************************************************************)

procedure TSGModel.SaveToFile(const FileWay: string);
begin
;//SaveToSaGe3DObjFile(FileWay);
end;

procedure TSGModel.Clear;
var
	i:LongWord;
begin
if NOfObjects>0 then
	begin
	for i:=0 to NOfObjects-1 do
		ArObjects[i].Destroy;
	SetLength(ArObjects,0);
	NOfObjects:=0;
	end;
if NOfMaterials>0 then
	begin
	for i:=0 to NOfMaterials-1 do
		ArMaterials[i].Destroy;
	SetLength(ArMaterials,0);
	NOfMaterials:=0;
	end;
end;

procedure TSGModel.LoadToVBO;
var	
	i:LongInt;
begin
for i:=0 to NOfObjects-1 do
	begin
	ArObjects[i].LoadToVBO;
	end;
end;

class function TSGModel.GetWRLNextIdentity(const Text:PTextFile):string;
begin
Result:='';
(**)
end;

procedure TSGModel.LoadFromFile(const FileWay:string);
begin
if SGFileExists(FileWay) then
	begin
	if SGUpCaseString(SGGetFileExpansion(FileWay))='WRL' then
		begin
		;//LoadWRLFromFile(FileWay);
		end
	else
		if SGUpCaseString(SGGetFileExpansion(FileWay))='3DS' then
			begin
			Load3DSFromFile(FileWay);
			end
		else
			if SGUpCaseString(SGGetFileExpansion(FileWay))='OFF' then
				begin
				;//LoadOFFFromFile(FileWay);
				end
			else
				begin
				;//LoadFromSaGe3DObjFile(FileWay);
				end;
	end;
end;

class function TSGModel.ClassName():String;
begin
Result:='TSGModel';
end;

procedure TSGModel.WriteInfo();
var
	i:LongWord;
begin
WriteLn('TSGModel.WriteInfo');
WriteLn('  NOfObjects = ',NOfObjects);
WriteLn('  NOfMaterials = ',NOfMaterials);
for i:=0 to NOfObjects-1 do
	ArObjects[i].WriteInfo('   '+SGStr(i+1)+') ');
end;

procedure TSGModel.Optimization(const SaveColors:Boolean = True;const SaveNormals:Boolean = False);
var
	i:LongWord;
begin
for i:=0 to NOfObjects-1 do
	;//ArObjects[i].Optimization(SaveColors,SaveNormals);
end;

function TSGModel.RealSize():Int64;
var
	i:LongWord;
begin
Result:=0;
for i:=0 to NOfObjects-1 do
	Result+=ArObjects[i].RealSize;
end;

procedure TSGModel.Stripificate;
var
	i:LongWord;
begin
for i:=0 to NOfObjects-1 do
	;//ArObjects[i].Stripificate;
end;

function TSGModel.VertexesSize:Int64;Inline;
var
	i:LongWord;
begin
Result:=0;
for i:=0 to NOfObjects-1 do
	Result+=ArObjects[i].VertexesSize();
end;

function TSGModel.FacesSize:Int64;inline;
var
	i:LongWord;
begin
Result:=0;
for i:=0 to NOfObjects-1 do
	Result+=ArObjects[i].FacesSize;
end;

function TSGModel.Size:Int64;inline;
var
	i:LongWord;
begin
Result:=0;
for i:=0 to NOfObjects-1 do
	Result+=ArObjects[i].Size;
end;

constructor TSGMaterialInfo.Create;
begin
    inherited Create;
    strFile:='';
    strName:='';
end;
procedure TSGModel.AddObjectColor(const ObjColor: TSGColor4f);
var
    i: longint;
begin
    for i := 0 to High(ArObjects) do
        ArObjects[i].FObjectColor := ObjColor;
end;

procedure TSGModel.Load3DSFromFile(const FileWay:string);
begin
{with TSGLoad3DS.Create do
	begin
	//Import3DS(@Self,FileWay);
	Destroy;
	end;}
end;

constructor TSGModel.Create;
begin
    inherited;
    NOfObjects := 0;
    NOfMaterials := 0;
    ArMaterials := nil;
    ArObjects := nil;
end;

destructor TSGModel.Destroy;
var
    i: longint;
begin
    for i := 0 to High(ArObjects) do
        ArObjects[i].Destroy;
    for i := 0 to High(ArMaterials) do
        ArMaterials[i].Destroy;
    inherited;
end;

procedure TSGModel.Draw;
var
    i: longword;
begin
for i := 0 to NOfObjects - 1 do
	begin
	{if ArObjects[i].FHasTexture then
		ArMaterials[ArObjects[i].FMaterialID].BindTexture;}
	ArObjects[i].Draw;
	{if ArObjects[i].FHasTexture and ArMaterials[ArObjects[i].FMaterialID].Ready then
		ArMaterials[ArObjects[i].FMaterialID].DisableTexture;}
	end;
end;


end.

