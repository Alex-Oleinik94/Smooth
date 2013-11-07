{$i Includes\SaGe.inc}

unit SaGeMesh;

interface

uses
    classes
    , SaGeCommon
    , SaGeBase
    , SaGeUtils
    , SaGeImages
    , SaGeRender
    , crt
    , SaGeContext;

type
	TSGMeshVertexType=(TSGMeshVertexType3f,TSGMeshVertexType2f);
	TSGMeshColorType=(TSGMeshColorType3f,TSGMeshColorType4f,TSGMeshColorType3b,TSGMeshColorType4b);
	
	TSGFaceType = type longword;
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
    public
        FNOfVerts: int64;
        FNOfFaces: int64;
        
        FHasTexture: boolean;
        FHasNormals: boolean;
        FHasColors: boolean;
     private
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
		
		function GetVertex3f(const Index:Cardinal):PTSGVertex3f;inline;
		function GetVertex2f(const Index:Cardinal):PTSGVertex2f;inline;
		
		property ArVertex3f[Index : Cardinal]:PTSGVertex3f read GetVertex3f;
		property ArVertex2f[Index : Cardinal]:PTSGVertex2f read GetVertex2f;
		
		function GetColor3f(const Index:Cardinal):PTSGColor3f;inline;
		function GetColor4f(const Index:Cardinal):PTSGColor4f;inline;
		function GetColor3b(const Index:Cardinal):PTSGColor3b;inline;
		function GetColor4b(const Index:Cardinal):PTSGColor4b;inline;
		
		property ArColor3f[Index : Cardinal]:PTSGColor3f read GetColor3f;
		property ArColor4f[Index : Cardinal]:PTSGColor4f read GetColor4f;
		property ArColor3b[Index : Cardinal]:PTSGColor3b read GetColor3b;
		property ArColor4b[Index : Cardinal]:PTSGColor4b read GetColor4b;
		
		procedure SetColor(const Index:Cardinal;const r,g,b:Single; const a:Single = 1);inline;
		procedure AutoSetColorType(const VWithAlpha:Boolean = False);inline;
		
		function GetNormal(const Index:Cardinal):PTSGVertex3f;inline;
		property ArNormal[Index : Cardinal]:PTSGVertex3f read GetNormal;
		
		procedure SetVertexLength(const NewVertexLength:int64);inline;
		function GetVertexLength():int64;overload;inline;
		
		function ArFacesLines():PTSGFaceLine;inline;
		function ArFacesQuads():PTSGFaceQuad;inline;
		function ArFacesTriangles():PTSGFaceTriangle;inline;
		function ArFacesPoints():PTSGFacePoint;inline;
		
		procedure SetFaceLength(const NewLength:Int64);inline;
		function GetFaceLength():Int64;overload;inline;
		function GetFaceLength(const FaceLength:Int64):Int64;overload;inline;
		class function GetFaceLength(const FaceLength:Int64; const ThisPoligoneType:LongWord):Int64;overload;inline;
		class function GetPoligoneInt(const ThisPoligoneType:LongWord):Byte;inline;
	public
		property Faces:Int64 read GetFaceLength write SetFaceLength;
		property Vertexes:Int64 read GetVertexLength write SetVertexLength;
    public
		FEnableVBO:Boolean;
		
        FVBOVertexes:Cardinal;
        FVBOFaces:Cardinal;
    public
        FEnableCullFace: boolean;
        FObjectColor: TSGColor4f;
    public
        procedure Draw(); override;
        procedure BasicDraw(); inline;
        procedure LoadToVBO();
        procedure ClearVBO();
        procedure ClearArrays(const ClearN:Boolean = True);
        //procedure SaveToStream(const Stream: TStream);
        //procedure LoadFromStream(const Stream: TStream);
		function GetSizeOf():int64;
		//procedure SaveFromSaGe3DObjFile(const FileWay:string);
		//procedure LoadFromSaGe3DObjFile(const FileWay:string);
		//procedure Stripificate;overload;inline;
		//procedure Stripificate(var VertexesAndTriangles:TSGArTSGArTSGFaceType;var OutputStrip:TSGArTSGFaceType);overload;
		//procedure Im;
		//procedure CalculateDependensies(var VertexesAndTriangles:TSGArTSGArTSGFaceType);
		//procedure Optimization(const SaveColors:Boolean = True;const SaveNormals:Boolean = False);
		procedure WriteInfo(const PredStr:string = '');
		procedure LoadFromFile(const FileWay:string);
	public
		function VertexesSize:Int64;Inline;
		function FacesSize:Int64;inline;
		function Size:Int64;inline;
		function RealSize:Int64;inline;
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
        procedure Draw; override;
        property FObjectColor: TSGColor4f write AddObjectColor;
        property ObjectColor: TSGColor4f write AddObjectColor;
		procedure LoadToVBO;
    public
        //procedure LoadFromSaGe3DObjFile(const FileWay: string);
        //procedure SaveToSaGe3DObjFile(const FileWay: string);
        //procedure LoadWRLFromFile(const FileWay: string);
        //procedure LoadOFFFromFile(const FileWay: string);
		procedure SaveToFile(const FileWay: string);
        class function GetWRLNextIdentity(const Text:PTextFile):string;
        procedure Load3DSFromFile(const FileWay:string);
        procedure Stripificate;
        procedure Optimization(const SaveColors:Boolean = True;const SaveNormals:Boolean = False);
        procedure WriteInfo;
        procedure LoadFromFile(const FileWay:string);
        procedure Clear;virtual;
    public
		function VertexesSize:Int64;
		function FacesSize:Int64;
		function Size:Int64;
		function RealSize:Int64;
    end;
    PSGModel = ^TSGModel;
    
    TSG3DCollisionObject=class(TSG3DObject)
		
		end;

{{$DEFINE SGREADINTERFACE}
{$i Includes\SaGeMesh3ds.inc}
{$UNDEF SGREADINTERFACE}}

implementation

{{$DEFINE SGREADIMPLEMENTATION}
{$i Includes\SaGeMesh3ds.inc}
{$UNDEF SGREADIMPLEMENTATION}}

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

procedure TSG3DObject.SetColor(const Index:Cardinal;const r,g,b:Single; const a:Single = 1);inline;
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

function TSG3DObject.GetNormal(const Index:Cardinal):PTSGVertex3f;inline;
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

function TSG3DObject.GetColor4f(const Index:Cardinal):PTSGColor4f;inline;
begin
Result:=PTSGColor4f( 
	LongWord(ArVertex)+
	GetSizeOfOneVertex()*Index+
	(2+Byte(FVertexType=TSGMeshVertexType3f))*SizeOf(Single)
	);
end;

function TSG3DObject.GetColor3b(const Index:Cardinal):PTSGColor3b;inline;
begin
Result:=PTSGColor3b( 
	LongWord(ArVertex)+
	GetSizeOfOneVertex()*Index+
	(2+Byte(FVertexType=TSGMeshVertexType3f))*SizeOf(Single)
	);
end;

function TSG3DObject.GetColor4b(const Index:Cardinal):PTSGColor4b;inline;
begin
Result:=PTSGColor4b( 
	LongWord(ArVertex)+
	GetSizeOfOneVertex()*Index+
	(2+Byte(FVertexType=TSGMeshVertexType3f))*SizeOf(Single)
	);
end;

function TSG3DObject.GetColor3f(const Index:Cardinal):PTSGColor3f;inline;
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

procedure TSG3DObject.SetVertexLength(const NewVertexLength:int64);inline;
begin
FNOfVerts:=NewVertexLength;
GetMem(ArVertex,GetVertexLength());
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

function TSG3DObject.GetVertexLength():int64;overload;inline;
begin
Result:=FNOfVerts*GetSizeOfOneVertex();
end;

function TSG3DObject.GetVertex3f(const Index:Cardinal):PTSGVertex3f;inline;
begin
Result:=PTSGVertex3f(LongWord(ArVertex)+Index*(GetSizeOfOneVertex()));
end;

function TSG3DObject.GetVertex2f(const Index:Cardinal):PTSGVertex2f;inline;
begin
Result:=PTSGVertex2f(LongWord(ArVertex)+Index*(GetSizeOfOneVertex()));
end;

procedure TSG3DObject.LoadFromFile(const FileWay:string);
begin
(**)
end;

class function TSG3DObject.GetFaceLength(const FaceLength:Int64; const ThisPoligoneType:LongWord):Int64;overload;inline;
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

function TSG3DObject.GetFaceLength(const FaceLength:Int64):Int64;overload;inline;
begin
Result:=GetFaceLength(FaceLength,FPoligonesType);
end;

function TSG3DObject.GetFaceLength:Int64;overload;inline;
begin
Result:=GetFaceLength(FNOfFaces);
end;

procedure TSG3DObject.SetFaceLength(const NewLength:Int64);inline;
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
    //FName := '';
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
ClearArrays;
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
        BasicDraw;
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
begin
FObjectColor.Color(Render);

{if FEnableVBO then
	Render.Enable(SGR_ARRAY_BUFFER_ARB);}

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
	Render.DrawElements(FPoligonesType, GetFaceLength() ,SGR_UNSIGNED_INT,nil);
	
	Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,0);
	end
else
	begin
    Render.VertexPointer(
		2+Byte(FVertexType=TSGMeshVertexType3f),
		SGR_FLOAT, 
		GetSizeOfOneVertex(), 
		ArVertex);
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
					byte(FColorType=TSGMeshColorType3b)*3+
					byte(FColorType=TSGMeshColorType4b)*4+
					byte(FColorType=TSGMeshColorType4f)*4*SizeOf(Single)+
					byte(FColorType=TSGMeshColorType3f)*3*SizeOf(Single))+
				Byte(FHasNormals)*(SizeOf(Single)*3)));
    if FHasColors then
		Render.ColorPointer(
			3+Byte((FColorType=TSGMeshColorType4b) or (FColorType=TSGMeshColorType4f)),
			SGR_FLOAT*Byte((FColorType=TSGMeshColorType3f) or (FColorType=TSGMeshColorType4f))+
				SGR_UNSIGNED_BYTE*Byte((FColorType=TSGMeshColorType4b) or (FColorType=TSGMeshColorType3b)),
			GetSizeOfOneVertex(),
			Pointer(LongWord(ArVertex)+SizeOf(Single)*(2+Byte(FVertexType=TSGMeshVertexType3f))));
    Render.DrawElements(FPoligonesType, GetFaceLength() , SGR_UNSIGNED_INT, @ArFaces[0]);
    end;

Render.DisableClientState(SGR_VERTEX_ARRAY);
if FHasNormals then
	Render.DisableClientState(SGR_NORMAL_ARRAY);
if FHasTexture then
	Render.DisableClientState(SGR_TEXTURE_COORD_ARRAY);
if FHasColors then
	Render.DisableClientState(SGR_COLOR_ARRAY);

{if FEnableVBO then
	Render.Disable(SGR_ARRAY_BUFFER_ARB);}
end;

procedure TSG3dObject.LoadToVBO;
begin
	//Render.Enable(SGR_ARRAY_BUFFER_ARB);
	
	Render.GenBuffersARB(1, @FVBOVertexes);
	Render.GenBuffersARB(1, @FVBOFaces);

	Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,FVBOVertexes);
	Render.BufferDataARB (SGR_ARRAY_BUFFER_ARB,FNOfVerts*GetSizeOfOneVertex(),ArVertex, SGR_STATIC_DRAW_ARB);

	Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB,FVBOFaces);
	Render.BufferDataARB (SGR_ELEMENT_ARRAY_BUFFER_ARB,GetFaceLength()*SizeOf(TSGFaceType),@ArFaces[0], SGR_STATIC_DRAW_ARB);

	Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,0);
	
	//Render.Disable(SGR_ARRAY_BUFFER_ARB);
	
//	Delay(100);
	ClearArrays(False);
	FEnableVBO:=True;
end;

procedure TSG3DObject.ClearVBO();inline;
begin
if FEnableVBO then
	begin
	Render.DeleteBuffersARB(1,@FVBOFaces);
	FVBOFaces:=0;
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
	{if (i<=High(ArObjects)) and ((not ArObjects[i].FHasTexture) or (ArObjects[i].FHasTexture and (ArObjects[i].FMaterialID<=High(ArMaterials)) and (ArObjects[i].FMaterialID>=0))) then
		begin    
		if ArObjects[i].FHasTexture then
			ArMaterials[ArObjects[i].FMaterialID].BindTexture;
		ArObjects[i].Draw;
		if ArObjects[i].FHasTexture and ArMaterials[ArObjects[i].FMaterialID].Ready then
			ArMaterials[ArObjects[i].FMaterialID].DisableTexture;
		end;}
	end;
end;


end.

