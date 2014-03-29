{$INCLUDE Includes\SaGe.inc}

unit SaGeMesh;

interface

uses
      Classes
    , SaGeCommon
    , SaGeBase
    , SaGeBased
    , SaGeImages
    , SaGeRender
    , Crt
    , SaGeContext;
const
	SGMeshVersion : TSGQuadWord = 169;
type
	// ��� ��� ���� �������� ������ � ����� ������
	TSGMeshColorType = (TSGMeshColorType3f,TSGMeshColorType4f,TSGMeshColorType3b,TSGMeshColorType4b);
	// ��� ��� ���� �������� ������ � ����� ������
	TSGMeshVertexType = TSGVertexFormat;
const
	// ���� ������
	TSGMeshVertexType2f = SG_VERTEX_2F;
	TSGMeshVertexType3f = SG_VERTEX_3F;
type
	// ���� �������� ������
	TSGFaceType = type TSGWord;//type TSGLongWord;
	TSGArTSGFaceType = packed array of TSGFaceType;
	TSGArTSGArTSGFaceType = packed array of TSGArTSGFaceType;
	
	// ======== ������ ���� ��������� �������� ��p���  ========
	TSGFaceLine = record
		case byte of
		0:  ( p0,p1: TSGFaceType );
		1:  ( p:packed array [0..1] of TSGFaceType );
		end;
	PTSGFaceLine = ^ TSGFaceLine;
	
    TSGFaceTriangle = record
	case byte of
	0: ( p0, p1, p2: TSGFaceType );
	1: ( p:packed array[0..2] of TSGFaceType );
	2: ( v:packed array[0..2] of TSGFaceType );
    end;
    PTSGFaceTriangle = ^ TSGFaceTriangle;
	
	TSGFaceQuad = record
	case byte of
	0: ( p0, p1, p2, p3: TSGFaceType );
	1: ( p : packed array[0..3] of TSGFaceType );
    end;
	PTSGFaceQuad = ^ TSGFaceQuad;
	
	TSGFacePoint = record
	case byte of
	0: ( p0: TSGFaceType );
	1: ( p : packed array[0..0] of TSGFaceType );
    end;
	PTSGFacePoint = ^ TSGFacePoint;

    { TSG3dObject }
    // ���� ��������..
type
    TSG3DObject = class(TSGDrawClass)
    public
        constructor Create(); override;
        destructor Destroy(); override;
        class function ClassName():string;override;
    protected
        // ���������� ������
        FNOfVerts : TSGQuadWord;
        // ���������� �������� �������� ������
        FNOfFaces : TSGQuadWord;
        
        // ���� �� � �������� ���������
        FHasTexture : TSGBoolean;
        // ���� �� ������� � ��������
        FHasNormals : TSGBoolean;
        // ���� �� � ��� �����
        FHasColors  : TSGBoolean;
        // ������������ �� � ��� ��������������� ���������
        FHasIndexes : TSGBoolean;
    protected
        // ���������� �������, ������� �� ������� � ���� �������� ��������
        FQuantityTextures : TSGLongWord;
        // ��� ��������� � �������� (SGR_QUADS, SGR_TRIANGLES, SGR_LINES, SGR_LINE_LOOP ....)
        FPoligonesType    : TSGLongWord;
        // ��� ������ � ��������
        FVertexType       : TSGMeshVertexType;
        // ��� �������� ������
        FColorType        : TSGMeshColorType;
    private
		procedure SetColorType(const VNewColorType:TSGMeshColorType);
		procedure SetVertexType(const VNewVertexType:TSGMeshVertexType);
		procedure SetHasTesture(const VHasTexture:Boolean);
		function GetSizeOfOneVertex():LongWord;inline;
		function GetVertexLength():QWord;inline;
		procedure SetHasTexture(const VHasTexture:TSGBoolean);inline;
    public
        // ��� �������� ��� ���� ���������������� ���� (�� �� ��� ��� �������� ���������)
		property QuantityVertexes : TSGQuadWord       read FNOfVerts;
		property QuantityFaces    : TSGQuadWord       read FNOfFaces;
		property HasTexture       : Boolean           read FHasTexture    write SetHasTexture;
		property HasIndexes       : Boolean           read FHasIndexes    write FHasIndexes;
		property HasColors        : Boolean           read FHasColors     write FHasColors;
		property HasNormals       : Boolean           read FHasNormals    write FHasNormals;
		property ColorType        : TSGMeshColorType  read FColorType     write SetColorType;
		property VertexType       : TSGMeshVertexType read FVertexType    write SetVertexType;
		property PoligonesType    : LongWord          read FPoligonesType write FPoligonesType;
    protected
        // � ��� � ��� ������ ��������
		ArFaces:packed array of TSGFaceType;
		
		// � ��� � ��� ������ ����� ������. ��� �������� ������� �����. 
		// �� ������ ��� �� ����� �������� (TSGPointer). 
		// �� � ���� �������� ������ ������� �����, �� �������������� �� �������...
		//! B ����� ������� ������������ � ������ ���������� � �������
		(* Vertex = [Vertexes, Colors, Normals, TexVertexes] *)
		//! ��� ������������ �� ���� ���� ������
		(* Array of Vertex *)
		ArVertex:TSGPointer;
	public
		// ���������� ��������� �� ������ ������� ������� ������
		function GetArVertexes():TSGPointer;inline;
		// ���������� ��������� �� ������ ������� ������� ��������
		function GetArFaces():TSGPointer;inline;
		
	private
		function GetVertex3f(const Index : TSGMaxEnum):PTSGVertex3f;inline;
		function GetVertex2f(const Index : TSGMaxEnum):PTSGVertex2f;inline;
		
	public
		// ��� �������� ���������� ��������� �� Index-�� ������� ������� ������ 
		//! ��� ����� ������������ ������ �����, ����� FVertexType = SG_VERTEX_3F, ����� Result = nil
		property ArVertex3f[Index : TSGMaxEnum]:PTSGVertex3f read GetVertex3f;
		//! ��� ����� ������������ ������ �����, ����� FVertexType = SG_VERTEX_2F, ����� Result = nil
		property ArVertex2f[Index : TSGMaxEnum]:PTSGVertex2f read GetVertex2f;
		
		// ��������� ������(��) ������� � ������ ������
		procedure AddVertex(const FQuantityNewVertexes:LongWord = 1);
		// ��������� ��� �������(�) � ������ ��������
		procedure AddFace(const FQuantityNewFaces:LongWord = 1);
	
	private
		function GetColor3f(const Index:TSGMaxEnum):PTSGColor3f;inline;
		function GetColor4f(const Index:TSGMaxEnum):PTSGColor4f;inline;
		function GetColor3b(const Index:TSGMaxEnum):PTSGColor3b;inline;
		function GetColor4b(const Index:TSGMaxEnum):PTSGColor4b;inline;
		
	public
		// ���������� ��������� �� ��������� ������,
		// � ������� �������� ���������� � ����� ������� � �������� Index
		// ������ ������� ����� ������������ ������ ����� ���������� ��������������� ��� ������� ������
		// ����� Result = nil.
		(* ��� ��������� ����� ����� ������������ ��������� SetColor, ��������� ���� *)
		property ArColor3f[Index : TSGMaxEnum]:PTSGColor3f read GetColor3f;
		property ArColor4f[Index : TSGMaxEnum]:PTSGColor4f read GetColor4f;
		property ArColor3b[Index : TSGMaxEnum]:PTSGColor3b read GetColor3b;
		property ArColor4b[Index : TSGMaxEnum]:PTSGColor4b read GetColor4b;
		
		// ��� ��������� ������������� ���� �������. �������� ��� ������ ������� �������� �����.
		procedure SetColor(const Index:TSGMaxEnum;const r,g,b:TSGSingle; const a:TSGSingle = 1);inline;
		// ������������� ���������� ������ ������ �������� ������. (� ����������� �� �������)
		procedure AutoSetColorType(const VWithAlpha:Boolean = False);inline;
	
	private
		function GetNormal(const Index:TSGMaxEnum):PTSGVertex3f;inline;
	
	public
		// �������� ��� �������������� ��������
		property ArNormal[Index : TSGMaxEnum]:PTSGVertex3f read GetNormal;
		
	private
		function GetTexVertex(const Index : TSGMaxEnum): PTSGVertex2f;inline;
		
	public
		property ArTexVertex[Index : TSGMaxEnum] : PTSGVertex2f read GetTexVertex;
		
		// ������������� ���������� ������
		procedure SetVertexLength(const NewVertexLength:TSGQuadWord);inline;
		
		// ���������� ������� � ������ �������� ������ ������
		function GetVertexesSize():TSGMaxEnum;overload;inline;
		
		// ��� ��������� ��� DirectX. ���� � ���, ��� ��� ���� SGR_QUADS. ��� ��� �� ����������� �� 2 ������������.
		procedure SetFaceQuad(const Index :TSGMaxEnum; const p0,p1,p2,p3:TSGFaceType);
		
		// ���������� ������ �� ������ ������� ������� ��������. �� ������ ����������, � ����� ����������.
		// ������ ��� ������� ����� ������������ ��� �������. ��� ��� �� ����� ������ ������������.
		// �� ����� ��������� ��� �������� ��������
		function ArFacesLines()     : PTSGFaceLine;     inline;
		function ArFacesQuads()     : PTSGFaceQuad;     inline;
		function ArFacesTriangles() : PTSGFaceTriangle; inline;
		function ArFacesPoints()    : PTSGFacePoint;    inline;
		
		// ������������� ������ ������� ��������
		procedure SetFaceLength(const NewLength:TSGMaxEnum);inline;
		// ���������� �������������� ������ ������� ��������
		function GetFaceLength():TSGMaxEnum;overload;inline;
		// ���������� �������������� ������ ������� �������� � ����������� �� �� ������, ������� ����������
		function GetFaceLength(const FaceLength:TSGMaxEnum):TSGMaxEnum;overload;inline;
		// ���������� �������������� ������ ������� �������� � ����������� �� �� ������ � �� ����, ������� �����������
		class function GetFaceLength(const FaceLength:TSGMaxEnum; const ThisPoligoneType:LongWord):TSGMaxEnum;overload;inline;
		// ����������, ������� � TSGFaceType*Result ������ �������� ���� ��������� ��������. ����� ���������� �������.
		class function GetPoligoneInt(const ThisPoligoneType:LongWord):Byte;inline;
	public
		// ��������� ��� ��������� � �������������� ����� ��������
		property Faces    :TSGMaxEnum read GetFaceLength   write SetFaceLength;
		property Vertexes :TSGQuadWord read GetVertexLength write SetVertexLength;
    protected
		// ��������� �� VBO
		// VBO - Vertex Buffer Object
		// Vertex Buffer Object - ��� ����� ����������, ��� ������� ����� ��������, 
		//    ����� ��� ������� � ������ ����������, � �� � ����������� ������
		// ���� �� ����� ���������� ���� ���������� (���� ������), �� ������� ����� ������������ � ����������
		FEnableVBO      : TSGBoolean;
		
		// ������������� ������� ������ � ������
        FVBOVertexes    : TSGLongWord;
        // ������������� ������� �������� � ������
        FVBOFaces       : TSGLongWord;
        
		// ������� �� Cull Face
        FEnableCullFace : TSGBoolean;
        // ���� �������
        FObjectColor    : TSGColor4f;
    public
		property EnableVBO      : TSGBoolean read FEnableVBO      write FEnableVBO;
		property ObjectColor    : TSGColor4f read FObjectColor    write FObjectColor;
		property EnableCullFace : TSGBoolean read FEnableCullFace write FEnableCullFace;
    public
        // ��������� � 3� ���
        procedure Draw(); override;
        // ���� � ���, ��� ���� ������� Cull Face, �� Draw ����� ������ 2 ����.
        // ��� ��� ��� ��� �������� Draw, � � Draw ������ �����������, ������� ��� ��  Cull Face, 
        //   � � ����������� �� ����� �� �������� ��� ��������� 1 ��� 2 ����
        procedure BasicDraw(); inline;
        // ��������� �������� � ������ ����������
        procedure LoadToVBO();
        // �������� ������ ���������� �� �������� ����� ������
        procedure ClearVBO();
        // ���������� ������� ����������� ������ �� �������� ����� ������
        procedure ClearArrays(const ClearN:Boolean = True);
			public
		// ��������� �������� � �����
        procedure SaveToStream(const Stream: TStream);virtual;
        // ��������� �������� �� ������
        procedure LoadFromStream(const Stream: TStream);virtual;
        // ��� ���������� ������������� �������� ������ ��� ������� � ��������� ��, ������ �� ������ ������
        procedure AddNormals();virtual;
        // =) Subserf
        procedure CatmulClark();virtual;
        
		procedure SaveToSG3DOFile(const FileWay:TSGString);
		procedure LoadFromSG3DOFile(const FileWay:TSGString);
		
		procedure SaveToSG3DO(const Stream:TStream);
		procedure LoadFromSG3DO(const Stream:TStream);
		
        (* � � ����������� ���� �����. ��� ��, ��� � �� �������. *)
		//procedure Stripificate;overload;inline;
		//procedure Stripificate(var VertexesAndTriangles:TSGArTSGArTSGFaceType;var OutputStrip:TSGArTSGFaceType);overload;
		
		// ������� ������ ���������� � ��������������� ��������
		procedure WriteInfo(const PredStr:string = '');
		// �������� �� �����
		procedure LoadFromFile(const FileWay:string);
		// �������� �� ���������� ������� ������ *.obj
		procedure LoadFromOBJ(const FFileName:string);virtual;
	public
		// ����������, ������� �������� ������ �������
		function VertexesSize():QWord;Inline;
		// ����������, ������� �������� ������ �������
		function FacesSize():QWord;inline;
		// ����������, ������� �������� ������ ������� � �������
		function Size():QWord;inline;
	protected 
		// ��� ��������
		FName : TSGString;
		// ������������� ���������
		FMaterialID : TSGInt64;
	public
		// �������� : ��� ��������
		property Name       : TSGString read FName       write FName;
		// �������� : ������������� ���������
		property MaterialID : TSGInt64  read FMaterialID write FMaterialID;
    end;

    PSG3dObject = ^TSG3dObject;

    { TSGCustomModel }
type
    TSGCustomModel = class(TSGDrawClass)
    public
        constructor Create;override;
        destructor Destroy; override;
        class function ClassName:String;override;
    protected
        FQuantityObjects   : TSGQuadWord;
        FQuantityMaterials : TSGQuadWord;
	
        FArMaterials : packed array of TSGImage;
        FArObjects   : packed array of TSG3dObject;
    private
		function GetObject(const Index : TSGMaxEnum):TSG3dObject;inline;
        procedure AddObjectColor(const ObjColor: TSGColor4f);
    public
		property QuantityMaterials : TSGQuadWord read FQuantityMaterials;
		property QuantityObjects   : TSGQuadWord read FQuantityObjects;
		property Objects[Index : TSGMaxEnum]:TSG3dObject read GetObject;
    public
		function AddMaterial():TSGImage;inline;
		function LastMaterial():TSGImage;inline;
		function AddObject():TSG3DObject;inline;
		function LastObject():TSG3DObject;inline;
		function CreateMaterialIDInLastObject(const VMaterialName : TSGString):TSGBoolean;
    public
        procedure Draw(); override;
        property ObjectColor: TSGColor4f write AddObjectColor;
		procedure LoadToVBO();
        procedure WriteInfo();
        procedure Clear();virtual;
    public
		// �������� � ��x�������
		procedure SaveToFile(const FileWay: TSGString);
        procedure LoadFromFile(const FileWay:TSGString);
    public
        procedure LoadFromSG3DMFile(const FileWay: TSGString);
        procedure SaveToSG3DMFile(const FileWay: TSGString);
        procedure LoadFromSG3DM(const Stream : TStream);
        procedure SaveToSG3DM(const Stream : TStream);
        // ��������� ������ 3DS-Max-�
        function Load3DSFromFile(const FileWay:TSGString):TSGBoolean;
        // SGR_TRIANGLES -> SGR_TRIANGLE_STRIP
        procedure Stripificate();
    public
		function VertexesSize():TSGQWord;
		function FacesSize():TSGQWord;
		function Size():TSGQWord;
    end;
    PSGCustomModel = ^TSGCustomModel;
    
{$DEFINE SGREADINTERFACE}      {$INCLUDE Includes\SaGeMesh3ds.inc} {$UNDEF SGREADINTERFACE}

implementation

{$DEFINE SGREADIMPLEMENTATION} {$INCLUDE Includes\SaGeMesh3ds.inc} {$UNDEF SGREADIMPLEMENTATION}

procedure TSG3DObject.SetHasTexture(const VHasTexture:TSGBoolean);inline;
begin
if not VHasTexture then
	FHasTexture:=False
else
	begin
	FHasTexture:=True;
	if FQuantityTextures=0 then
		FQuantityTextures:=1;
	end;
end;

function TSG3DObject.GetVertexLength():QWord;inline;
begin
Result:=FNOfVerts;
end;

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
NowSelectMaterial:=0;
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
	ArColor3b[Index]^.r:=Byte(r>=1)*255+Byte((r<1) and (r>0))*round(255*r);
	ArColor3b[Index]^.g:=Byte(g>=1)*255+Byte((g<1) and (g>0))*round(255*g);
	ArColor3b[Index]^.b:=Byte(b>=1)*255+Byte((b<1) and (b>0))*round(255*b);
	end
else if (FColorType=TSGMeshColorType4b) then
	begin
	ArColor4b[Index]^.r:=Byte(r>=1)*255+Byte((r<1) and (r>0))*round(255*r);
	ArColor4b[Index]^.g:=Byte(g>=1)*255+Byte((g<1) and (g>0))*round(255*g);
	ArColor4b[Index]^.b:=Byte(b>=1)*255+Byte((b<1) and (b>0))*round(255*b);
	ArColor4b[Index]^.a:=Byte(a>=1)*255+Byte((a<1) and (a>0))*round(255*a);
	end;
end;

function TSG3DObject.GetTexVertex(const Index : TSGMaxEnum): PTSGVertex2f;inline;
begin
Result:=PTSGVertex2f(
	TSGMaxEnum(ArVertex)
	+GetSizeOfOneVertex()*Index
	+(2+Byte(FVertexType=TSGMeshVertexType3f))*SizeOf(Single)
	+Byte(FHasColors)*( 
		byte(FColorType=TSGMeshColorType3b)*3+
		byte(FColorType=TSGMeshColorType4b)*4+
		byte(FColorType=TSGMeshColorType4f)*4*SizeOf(Single)+
		byte(FColorType=TSGMeshColorType3f)*3*SizeOf(Single))
	+Byte(FHasNormals)*3*SizeOf(Single));
end;

function TSG3DObject.GetNormal(const Index:TSGMaxEnum):PTSGVertex3f;inline;
begin
Result:=PTSGVertex3f( 
	TSGMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index+
	(2+Byte(FVertexType=TSGMeshVertexType3f))*SizeOf(Single)
	+Byte(FHasColors)*( //�����
	byte(FColorType=TSGMeshColorType3b)*3+
	byte(FColorType=TSGMeshColorType4b)*4+
	byte(FColorType=TSGMeshColorType4f)*4*SizeOf(Single)+
	byte(FColorType=TSGMeshColorType3f)*3*SizeOf(Single))
	);
end;

function TSG3DObject.GetColor4f(const Index:TSGMaxEnum):PTSGColor4f;inline;
begin
Result:=PTSGColor4f( 
	TSGMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index+
	(2+Byte(FVertexType=TSGMeshVertexType3f))*SizeOf(Single)
	);
end;

function TSG3DObject.GetColor3b(const Index:TSGMaxEnum):PTSGColor3b;inline;
begin
Result:=PTSGColor3b( 
	TSGMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index+
	(2+Byte(FVertexType=TSGMeshVertexType3f))*SizeOf(Single)
	);
end;

function TSG3DObject.GetColor4b(const Index:TSGMaxEnum):PTSGColor4b;inline;
begin
Result:=PTSGColor4b(Pointer(
	TSGMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index+
	(2+Byte(FVertexType=TSGMeshVertexType3f))*SizeOf(Single)
	));
end;

function TSG3DObject.GetColor3f(const Index:TSGMaxEnum):PTSGColor3f;inline;
begin
Result:=PTSGColor3f( 
	TSGMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index+
	(2+Byte(FVertexType=TSGMeshVertexType3f))*SizeOf(Single)
	);
end;

function TSG3DObject.GetArFaces():Pointer;inline;
begin
if ArFaces=nil then
	Result:=nil
else
	Result:=@ArFaces[0];
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

procedure TSG3DObject.SetVertexLength(const NewVertexLength:QWord);inline;
begin
FNOfVerts:=NewVertexLength;
GetMem(ArVertex,GetVertexesSize());
end;

function TSG3DObject.GetSizeOfOneVertex():LongWord;
begin
Result:=
(2+Byte(FVertexType=TSGMeshVertexType3f))*SizeOf(Single)//�������
 
+Byte(FHasColors)*( //�����
	byte(FColorType=TSGMeshColorType3b)*3+
	byte(FColorType=TSGMeshColorType4b)*4+
	byte(FColorType=TSGMeshColorType4f)*4*SizeOf(Single)+
	byte(FColorType=TSGMeshColorType3f)*3*SizeOf(Single))

+Byte(FHasNormals)*3*SizeOf(Single)

+Byte(FHasTexture)*2*SizeOf(Single)*FQuantityTextures;
end;

function TSG3DObject.GetVertexesSize():TSGMaxEnum;overload;inline;
begin
Result:=FNOfVerts*GetSizeOfOneVertex();
end;

function TSG3DObject.GetVertex3f(const Index:TSGMaxEnum):PTSGVertex3f;inline;
begin
Result:=PTSGVertex3f(TSGMaxEnum(ArVertex)+Index*(GetSizeOfOneVertex()));
end;

function TSG3DObject.GetVertex2f(const Index:TSGMaxEnum):PTSGVertex2f;inline;
begin
Result:=PTSGVertex2f(TSGMaxEnum(ArVertex)+Index*(GetSizeOfOneVertex()));
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
WriteLn(PredStr,'FMaterialID = ',FMaterialID);
WriteLn(PredStr,'FName = ',FName);
end;

function TSG3DObject.VertexesSize():QWord;Inline;
begin
Result:=GetSizeOfOneVertex()*FNOfVerts;
end;

function TSG3DObject.FacesSize():QWord;inline;
begin
Result:=SizeOf(TSGFaceType)*GetFaceLength();
end;

function TSG3DObject.Size():QWord;inline;
begin
Result:=
	FacesSize()+
	VertexesSize();
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
    FHasIndexes := True;
    FNOfFaces := 0;
    FNOfVerts := 0;
    ArVertex := nil;
    ArFaces := nil;
    FMaterialID := -1;
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

procedure TSG3DObject.SaveToSG3DOFile(const FileWay:TSGString);
var
	Stream:TStream = nil;
begin
Stream:=TFileStream.Create(FileWay,fmCreate);
if Stream<>nil then
	begin
	SaveToSG3DO(Stream);
	Stream.Destroy();
	end;
end;

procedure TSG3DObject.LoadFromSG3DOFile(const FileWay:TSGString);
var
	Stream:TStream = nil;
begin
if SGFileExists(FileWay) then
	begin
	Stream:=TFileStream.Create(FileWay,fmOpenRead);
	if Stream<>nil then
		begin
		LoadFromSG3DO(Stream);
		Stream.Destroy();
		end;
	end;
end;

procedure TSG3DObject.SaveToSG3DO(const Stream:TStream);
var
	S:array[0..8] of TSGChar = 'SaGe3DObj';
begin
Stream.WriteBuffer(S[0],SizeOf(S[0])*9);
Stream.WriteBuffer(SGMeshVersion,SizeOf(SGMeshVersion));

Stream.WriteBuffer(FHasTexture,SizeOf(FHasTexture));
Stream.WriteBuffer(FHasColors,SizeOf(FHasColors));
Stream.WriteBuffer(FHasNormals,SizeOf(FHasNormals));
Stream.WriteBuffer(FQuantityTextures,SizeOf(FQuantityTextures));
Stream.WriteBuffer(FPoligonesType,SizeOf(FPoligonesType));
Stream.WriteBuffer(FVertexType,SizeOf(FVertexType));
Stream.WriteBuffer(FColorType,SizeOf(FColorType));
Stream.WriteBuffer(FMaterialID,SizeOf(FMaterialID));
Stream.WriteBuffer(FEnableCullFace,SizeOf(FEnableCullFace));
SGWriteStringToStream(FName,Stream);

Stream.WriteBuffer(FNOfVerts,SizeOf(FNOfVerts));
Stream.WriteBuffer(FNOfFaces,SizeOf(FNOfFaces));

Stream.WriteBuffer(ArFaces[0],FacesSize());
Stream.WriteBuffer(ArVertex^,VertexesSize());
end;

procedure TSG3DObject.LoadFromSG3DO(const Stream:TStream);
var
	S,S2:array[0..8] of TSGChar;
	Version : TSGQuadWord = 0;
begin
S2:='SaGe3DObj';
Stream.ReadBuffer(S[0],SizeOf(S[0])*9);
if S<>S2 then
	begin
	SGLog.Sourse(['TSG3DObject.LoadFromSG3DO : Fatal : It is not "SaGe3DObj" file!']);
	Exit;
	end;
Stream.ReadBuffer(Version,SizeOf(Version));
if Version <> SGMeshVersion then
	begin
	SGLog.Sourse(['TSG3DObject.LoadFromSG3DO : Fatal : (Program.MeshVersion!=Mesh.MeshVersion)!']);
	Exit;
	end;
Stream.ReadBuffer(FHasTexture,SizeOf(FHasTexture));
Stream.ReadBuffer(FHasColors,SizeOf(FHasColors));
Stream.ReadBuffer(FHasNormals,SizeOf(FHasNormals));
Stream.ReadBuffer(FQuantityTextures,SizeOf(FQuantityTextures));
Stream.ReadBuffer(FPoligonesType,SizeOf(FPoligonesType));
Stream.ReadBuffer(FVertexType,SizeOf(FVertexType));
Stream.ReadBuffer(FColorType,SizeOf(FColorType));
Stream.ReadBuffer(FMaterialID,SizeOf(FMaterialID));
Stream.ReadBuffer(FEnableCullFace,SizeOf(FEnableCullFace));
FName := SGReadStringFromStream(Stream);

Stream.ReadBuffer(FNOfVerts,SizeOf(FNOfVerts));
Stream.ReadBuffer(FNOfFaces,SizeOf(FNOfFaces));

SetVertexLength(FNOfVerts);
SetFaceLength(FNOfFaces);

Stream.ReadBuffer(ArFaces[0],FacesSize());
Stream.ReadBuffer(ArVertex^,VertexesSize());
end;

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
	
	if FHasIndexes then
		begin
		Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB ,FVBOFaces);
		Render.DrawElements(FPoligonesType, GetFaceLength() ,FaceFormat,nil);
		end
	else
		Render.DrawArrays(FPoligonesType,0,FNOfVerts);
	
	Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,0);
	if FHasIndexes then
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
				TSGMaxEnum(ArVertex)+
				SizeOf(Single)*(2+Byte(FVertexType=TSGMeshVertexType3f))));
	if FHasNormals then
		Render.NormalPointer(
			SGR_FLOAT, 
			GetSizeOfOneVertex(), 
			Pointer(
				TSGMaxEnum(ArVertex)+
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
				TSGMaxEnum(ArVertex)+
				SizeOf(Single)*(2+Byte(FVertexType=TSGMeshVertexType3f))+
				Byte(FHasColors)*(
					byte(FColorType = TSGMeshColorType3b)*3+
					byte(FColorType = TSGMeshColorType4b)*4+
					byte(FColorType = TSGMeshColorType4f)*4*SizeOf(Single)+
					byte(FColorType = TSGMeshColorType3f)*3*SizeOf(Single))+
				Byte(FHasNormals)*(SizeOf(Single)*3)));
	if FHasIndexes then
		Render.DrawElements(FPoligonesType, GetFaceLength() , FaceFormat, @ArFaces[0])
	else
		Render.DrawArrays(FPoligonesType,0,FNOfVerts);
    end;
Render.DisableClientState(SGR_VERTEX_ARRAY);
if FHasNormals then
	Render.DisableClientState(SGR_NORMAL_ARRAY);
if FHasTexture then
	Render.DisableClientState(SGR_TEXTURE_COORD_ARRAY);
if FHasColors then
	Render.DisableClientState(SGR_COLOR_ARRAY);
end;

procedure TSG3dObject.LoadToVBO();
begin
if FEnableVBO then
	begin
	SGLog.Sourse('TSG3dObject__LoadToVBO : It is not possible to do this several times!');
	Exit;
	end;
Render.GenBuffersARB(1, @FVBOVertexes);
if FHasIndexes then
	Render.GenBuffersARB(1, @FVBOFaces);

Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,FVBOVertexes);
Render.BufferDataARB(SGR_ARRAY_BUFFER_ARB,FNOfVerts*GetSizeOfOneVertex(),ArVertex, SGR_STATIC_DRAW_ARB);

if FHasIndexes then
	begin
	Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB,FVBOFaces);
	Render.BufferDataARB(SGR_ELEMENT_ARRAY_BUFFER_ARB,GetFaceLength()*SizeOf(TSGFaceType),@ArFaces[0], SGR_STATIC_DRAW_ARB);
	end;

Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,0);
if FHasIndexes then
	Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB,0);

ClearArrays(False);
FEnableVBO:=True;
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

procedure TSGCustomModel.LoadFromSG3DMFile(const FileWay: TSGString);
var
	Stream : TStream = nil;
begin
Stream := TFileStream.Create(FileWay,fmOpenRead);
if Stream<>nil then
	begin
	LoadFromSG3DM(Stream);
	Stream.Destroy();
	end;
end;

procedure TSGCustomModel.SaveToSG3DMFile(const FileWay: TSGString);
var
	Stream : TStream = nil;
begin
Stream := TFileStream.Create(FileWay,fmCreate);
if Stream<>nil then
	begin
	SaveToSG3DM(Stream);
	Stream.Destroy();
	end;
end;

procedure TSGCustomModel.LoadFromSG3DM(const Stream : TStream);
var
	i : TSGLongWord;
	QuantityO,QuantityM : TSGQuadWord;
begin
Stream.ReadBuffer(QuantityO,SizeOf(QuantityO));
Stream.ReadBuffer(QuantityM,SizeOf(QuantityM));
for i:=0 to QuantityO-1 do
	begin
	AddObject().LoadFromSG3DO(Stream);
	end;
for i:=0 to QuantityM-1 do
	begin
	AddMaterial().Way:=SGReadStringFromStream(Stream);
	LastMaterial().Name:=SGReadStringFromStream(Stream);
	if SGFileExists(LastMaterial().Way) then
		begin
		LastMaterial().Loading();
		end;
	end;
end;

procedure TSGCustomModel.SaveToSG3DM(const Stream : TStream);
var
	i : TSGLongWord;
begin
Stream.WriteBuffer(FQuantityObjects,SizeOf(FQuantityObjects));
Stream.WriteBuffer(FQuantityMaterials,SizeOf(FQuantityMaterials));
for i:=0 to FQuantityObjects-1 do
	Objects[i].SaveToSG3DO(Stream);
for i:=0 to FQuantityMaterials-1 do
	begin
	SGWriteStringToStream(FArMaterials[i].Way,Stream);
	SGWriteStringToStream(FArMaterials[i].Name,Stream);
	end;
end;

procedure TSGCustomModel.SaveToFile(const FileWay: string);
begin
SaveToSG3DMFile(FileWay);
end;

procedure TSGCustomModel.Clear;
var
	i : TSGLongWord;
begin
if FQuantityObjects>0 then
	begin
	for i:=0 to FQuantityObjects-1 do
		FArObjects[i].Destroy();
	SetLength(FArObjects,0);
	FQuantityObjects:=0;
	end;
FArObjects:=nil;
if FQuantityMaterials>0 then
	begin
	for i:=0 to FQuantityMaterials-1 do
		FArMaterials[i].Destroy;
	SetLength(FArMaterials,0);
	FQuantityMaterials:=0;
	end;
FArMaterials:=nil;
end;

procedure TSGCustomModel.LoadToVBO();
var	
	i : TSGLongWord;
begin
for i:=0 to FQuantityObjects-1 do
	begin
	FArObjects[i].LoadToVBO();
	end;
end;

procedure TSGCustomModel.LoadFromFile(const FileWay:string);
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

class function TSGCustomModel.ClassName():String;
begin
Result:='TSGCustomModel';
end;

procedure TSGCustomModel.WriteInfo();
var
	i : TSGLongWord;
begin
WriteLn('TSGModel.WriteInfo');
WriteLn('  QuantityObjects = ',FQuantityObjects);
WriteLn('  QuantityMaterials = ',FQuantityMaterials);
for i:=0 to FQuantityObjects-1 do
	FArObjects[i].WriteInfo('   '+SGStr(i+1)+') ');
end;


procedure TSGCustomModel.Stripificate();
var
	i : TSGLongWord;
begin
for i:=0 to FQuantityObjects-1 do
	;//ArObjects[i].Stripificate;
end;

function TSGCustomModel.VertexesSize():QWord;Inline;
var
	i : TSGLongWord;
begin
Result:=0;
for i:=0 to FQuantityObjects-1 do
	Result+=FArObjects[i].VertexesSize();
end;

function TSGCustomModel.FacesSize():QWord;inline;
var
	i : TSGLongWord;
begin
Result:=0;
for i:=0 to FQuantityObjects-1 do
	Result+=FArObjects[i].FacesSize();
end;

function TSGCustomModel.Size():QWord;inline;
var
	i : TSGLongWord;
begin
Result:=0;
for i:=0 to FQuantityObjects-1 do
	Result+=FArObjects[i].Size();
end;


procedure TSGCustomModel.AddObjectColor(const ObjColor: TSGColor4f);
var
    i: TSGLongWord;
begin
    for i := 0 to High(FArObjects) do
        FArObjects[i].FObjectColor := ObjColor;
end;

function TSGCustomModel.Load3DSFromFile(const FileWay:TSGString):TSGBoolean;
var
	Sucsses : TSGBoolean = False;
begin
TSGLoad3DS.Create().SetFileName(FileWay).Import3DS(Self,Result).Destroy();
end;

constructor TSGCustomModel.Create();
begin
inherited;
FQuantityMaterials := 0;
FQuantityObjects := 0;
FArMaterials := nil;
FArObjects := nil;
end;

destructor TSGCustomModel.Destroy();
var
    i: TSGLongWord;
begin
Clear();
inherited;
end;

procedure TSGCustomModel.Draw();
var
    i: TSGLongWord;
begin
for i := 0 to FQuantityObjects - 1 do
	if (FArObjects[i].HasTexture) and (FArObjects[i].MaterialID <> -1) and 
	((FArMaterials[FArObjects[i].MaterialID].ReadyToGoToTexture)or(FArMaterials[FArObjects[i].MaterialID].Ready)) then
		begin
		FArMaterials[FArObjects[i].MaterialID].BindTexture();
		FArObjects[i].Draw();
		FArMaterials[FArObjects[i].MaterialID].DisableTexture();
		end
	else
		FArObjects[i].Draw();
end;

function TSGCustomModel.AddMaterial():TSGImage;inline;
begin
FQuantityMaterials+=1;
SetLength(FArMaterials,FQuantityMaterials);
FArMaterials[FQuantityMaterials-1]:=TSGImage.Create();
Result:=FArMaterials[FQuantityMaterials-1];
Result.Context := Context;
end;

function TSGCustomModel.LastMaterial():TSGImage;inline;
begin
if (FArMaterials=nil) or (FQuantityMaterials=0) then
	Result:=nil
else
	Result:=FArMaterials[High(FArMaterials)];
end;

function TSGCustomModel.AddObject():TSG3DObject;inline;
begin
FQuantityObjects+=1;
SetLength(FArObjects,FQuantityObjects);
Result:=TSG3DObject.Create();
Result.Context := Context;
FArObjects[FQuantityObjects-1]:=Result;
end;

function TSGCustomModel.LastObject():TSG3DObject;inline;
begin
if (FQuantityObjects=0) or(FArObjects=nil) then
	Result:=nil
else
	Result:=FArObjects[FQuantityObjects-1];
end;

function TSGCustomModel.CreateMaterialIDInLastObject(const VMaterialName : TSGString):TSGBoolean;
var
	i : TSGLongWord;
begin
Result:=False;
for i := 0 to FQuantityMaterials - 1 do
	if FArMaterials[i].Name = VMaterialName then
		begin
		LastObject().MaterialID := i;
		LastObject().HasTexture := True;
		Result:=True;
		Break;
		end;
end;

function TSGCustomModel.GetObject(const Index : TSGMaxEnum):TSG3dObject;inline;
begin
Result:=FArObjects[Index];
end;

end.

