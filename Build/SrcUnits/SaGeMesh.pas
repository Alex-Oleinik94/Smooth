{$i Includes\SaGe.inc}

unit SaGeMesh;

interface

uses
    classes
    , SaGeCommon
    , SaGeBase
    , SaGeUtils
    , SaGeImages
    , crt;

type
	TSGMeshVertexType=(TSGMeshVertexType3f,TSGMeshVertexType2f);
	
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
	
    TSGMaterialInfo = class(TSGGLImage)
        constructor Create;
    public
        strName, strFile: string;
    end;

    PSGMaterialInfo = ^TSGMaterialInfo;

    { TSG3dObject }

    TSG3DObject = class(TSGDrawClass)
    public
        constructor Create;override;
        destructor Destroy; override;
        class function ClassName:string;override;
    public
        FNOfVerts: int64;
        FNOfFaces: int64;
        FNOfTexVertex: int64;
        FNOfNormals:int64;
        FNOfColors:int64;
        
        FMaterialID: longint;
        FHasTexture: boolean;
        FName: string;
        
        FHasNormals: boolean;
        
        FPoligonesType:LongWord;
        FVertexType:TSGMeshVertexType;
        
        ArColors:packed array of TSGColor3f;
        ArNormals:packed array of TSGVertex;
        ArTexVertexes:packed array of TSGVertex2f;
    private
		ArFaces:packed array of TSGFaceType;
		ArVertex:packed array of TSGVertexType;
	public
		function ArVertexes:PTSGVertex3f;inline;
		function ArVertex3f:PTSGVertex3f;inline;
		function ArVertex2f:PTSGVertex2f;inline;
		
		procedure SetVertexLength(const NewVertexLength:int64);inline;
		class function GetVertexLength(const VertexLength:int64;const VertexType:TSGMeshVertexType):int64;overload;inline;
		function GetVertexLength:int64;overload;inline;
		
		function ArFacesLines:PTSGFaceLine;inline;
		function ArFacesQuads:PTSGFaceQuad;inline;
		function ArFacesTriangles:PTSGFaceTriangle;inline;
		function ArFacesPoints:PTSGFacePoint;inline;
		
		procedure SetFaceLength(const NewLength:Int64);inline;
		function GetFaceLength:Int64;overload;inline;
		function GetFaceLength(const FaceLength:Int64):Int64;overload;inline;
		class function GetFaceLength(const FaceLength:Int64; const ThisPoligoneType:LongWord):Int64;overload;inline;
		class function GetPoligoneInt(const ThisPoligoneType:LongWord):Byte;inline;
	public
		property Faces:Int64 read GetFaceLength write SetFaceLength;
    public
		FEnableVBO:Boolean;
		
        FVBOVertexes:GluInt;
        FVBOFaces:GluInt;
        FVBONormals:GLUInt;
        FVBOColors:GLUInt;
        FVBOTexVertexes:GLUInt;
    public
        FEnableCullFace: boolean;
        FObjectColor: TSGColor4f;
    public
        procedure Draw; override;
        procedure BasicDraw; inline;
        procedure LoadToVBO;
        procedure ClearVBO;
        procedure ClearArrays(const ClearN:Boolean = True);
        procedure SaveToStream(const Stream: TStream);
        procedure LoadFromStream(const Stream: TStream);
		function GetSizeOf:int64;
		procedure SaveFromSaGe3DObjFile(const FileWay:string);
		procedure LoadFromSaGe3DObjFile(const FileWay:string);
		procedure Stripificate;overload;inline;
		procedure Stripificate(var VertexesAndTriangles:TSGArTSGArTSGFaceType;var OutputStrip:TSGArTSGFaceType);overload;
		procedure Im;
		procedure CalculateDependensies(var VertexesAndTriangles:TSGArTSGArTSGFaceType);
		procedure Optimization(const SaveColors:Boolean = True;const SaveNormals:Boolean = False);
		procedure WriteInfo(const PredStr:string = '');
		procedure LoadFromFile(const FileWay:string);
	public
		function VertexesSize:Int64;Inline;
		function FacesSize:Int64;inline;
		function NormalsSize:Int64;inline;
		function ColorsSize:Int64;inline;
		function TextureVertexesSize:Int64;inline;
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
        procedure LoadFromSaGe3DObjFile(const FileWay: string);
        procedure SaveToSaGe3DObjFile(const FileWay: string);
        procedure LoadWRLFromFile(const FileWay: string);
        procedure LoadOFFFromFile(const FileWay: string);
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
		function NormalsSize:Int64;
		function ColorsSize:Int64;
		function TextureVertexesSize:Int64;
		function Size:Int64;
		function RealSize:Int64;
    end;

    PSGModel = ^TSGModel;
    
    TSG3DCollisionObject=class(TSG3DObject)
		
		end;

{$DEFINE SGREADINTERFACE}
{$i Includes\SaGeMesh3ds.inc}
{$UNDEF SGREADINTERFACE}

implementation

{$DEFINE SGREADIMPLEMENTATION}
{$i Includes\SaGeMesh3ds.inc}
{$UNDEF SGREADIMPLEMENTATION}

procedure TSG3DObject.SetVertexLength(const NewVertexLength:int64);inline;
begin
SetLength(ArVertex,GetVertexLength(NewVertexLength,FVertexType));
end;

class function TSG3DObject.GetVertexLength(const VertexLength:int64;const VertexType:TSGMeshVertexType):int64;overload;inline;
begin
Result:=VertexLength*(2+Byte(VertexType=TSGMeshVertexType3f));
end;

function TSG3DObject.GetVertexLength:int64;overload;inline;
begin
Result:=GetVertexLength(FNOfVerts,FVertexType);
end;


function TSG3DObject.ArVertexes:PTSGVertex3f;inline;
begin
Result:=@ArVertex[0];
end;

function TSG3DObject.ArVertex3f:PTSGVertex3f;inline;
begin
Result:=@ArVertex[0];
end;

function TSG3DObject.ArVertex2f:PTSGVertex2f;inline;
begin
Result:=@ArVertex[0];
end;


procedure TSG3DObject.Im;
var
	ArCV:TSGArTSGVertex = nil;
	i,ii,iii:LongWord;
	ArFV:packed array of TSGFaceType = nil;
	ArFVB:packed array of Boolean = nil;
	ArFV2:packed array of TSGFaceType = nil;
	FP,FP2:TSGFaceType;
	Flag1:Boolean;
begin
SetLength(ArCV,FNOfFaces);
for i:=0 to FNOfFaces-1 do
	ArCV[i]:=
		(ArVertexes[ArFacesTriangles[i].p[0]]+
		 ArVertexes[ArFacesTriangles[i].p[1]]+
		 ArVertexes[ArFacesTriangles[i].p[2]])/3;
for i:=0 to FNOfVerts-1 do
	begin
	for ii:=0 to FNOfFaces-1 do
		begin
		for iii:=0 to 2 do
			if ArFacesTriangles[ii].p[iii]=i then
				begin
				SetLength(ArFV,Length(ArFV)+1);
				ArFV[High(ArFV)]:=ii;
				Break;
				end;
		end;
	SetLength(ArFV2,1);
	ArFV2[0]:=ArFV[0];
	SetLength(ArFVB,Length(ArFV));
	for ii:=0 to High(ArFV) do
		ArFVB[ii]:=False;
	ArFVB[0]:=True;
	while Length(ArFV2)<>Length(ArFV) do
		begin
		if Length(ArFV2)=1 then
			begin
			for ii:=0 to 2 do
				if ArFacesTriangles[ArFV2[0]].p[ii]<>i then
					begin
					FP:=ArFacesTriangles[ArFV2[0]].p[ii];
					Break;
					end;
			end
		else
			begin
			Flag1:=False;
			for ii:=0 to 2 do
				begin
				for iii:=0 to 2 do
					begin
					if (ArFacesTriangles[ArFV2[High(ArFV2)]].p[ii]<>i) and  (ArFacesTriangles[ArFV2[High(ArFV2)]].p[ii]=ArFacesTriangles[ArFV2[High(ArFV2)-1]].p[iii]) then
						begin
						Flag1:=True;
						FP2:=ArFacesTriangles[ArFV2[High(ArFV2)]].p[ii];
						Break;
						end;
					end;
				if Flag1 then
					Break;
				end;
			for ii:=0 to 2 do
				if (ArFacesTriangles[ArFV2[High(ArFV2)]].p[ii]<>i) and (ArFacesTriangles[ArFV2[High(ArFV2)]].p[ii]<>FP2) then
					begin
					FP:=ArFacesTriangles[ArFV2[High(ArFV2)]].p[ii];
					Break;
					end;
			end;
		
		end;
	end;
end;

procedure TSGModel.SaveToFile(const FileWay: string);
begin
SaveToSaGe3DObjFile(FileWay);
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

procedure TSGModel.LoadOFFFromFile(const FileWay: string);
var
	Text:TextFile;
	Logo:String = '';
	i:LongWord;
begin
if SGFileExists(FileWay) then
	begin
	Assign(Text,FileWay);
	Reset(Text);
	ReadLn(Text,Logo);
	if SGUpCaseString(Logo)='OFF' then
		begin
		Clear;
		SetLength(ArObjects,1);
		NOfObjects:=1;
		ArObjects[0]:=TSG3DObject.Create;
		ArObjects[0].FPoligonesType:=GL_TRIANGLES;
		ReadLn(Text,ArObjects[0].FNOfVerts);
		ReadLn(Text,i);
		ReadLn(Text);
		
		ArObjects[0].FNOfVerts+=1;
		ArObjects[0].SetVertexLength(ArObjects[0].FNOfVerts);
		ArObjects[0].Faces:=i+1;
		ArObjects[0].FNOfFaces:=i+1;
		
		for i:=0 to ArObjects[0].FNOfVerts-1 do
			ArObjects[0].ArVertexes[i].ReadLnFromTextFile(@Text);
		for i:=0 to ArObjects[0].FNOfFaces-1 do
			begin
			ReadLn(Text,ArObjects[0].ArFacesTriangles[i].v[0],ArObjects[0].ArFacesTriangles[i].v[1],ArObjects[0].ArFacesTriangles[i].v[2]);
			end;
		end;
	Close(Text);
	end;
end;

procedure TSG3DObject.LoadFromFile(const FileWay:string);
begin
(**)
end;

class function TSGModel.GetWRLNextIdentity(const Text:PTextFile):string;
begin
Result:='';
(**)
end;

procedure TSGModel.LoadWRLFromFile(const FileWay: string);
var
	Text:TextFile;
	Id:string;
	b:byte;
begin
if SGFileExists(FileWay) then
	begin
	Assign(Text,FileWay);
	Reset(Text);
	Id:=GetWRLNextIdentity(@Text);
	(**)
	Close(Text);
	end;
end;

procedure TSGModel.LoadFromFile(const FileWay:string);
begin
if SGFileExists(FileWay) then
	begin
	if SGUpCaseString(SGGetFileExpansion(FileWay))='WRL' then
		begin
		LoadWRLFromFile(FileWay);
		end
	else
		if SGUpCaseString(SGGetFileExpansion(FileWay))='3DS' then
			begin
			Load3DSFromFile(FileWay);
			end
		else
			if SGUpCaseString(SGGetFileExpansion(FileWay))='OFF' then
				begin
				LoadOFFFromFile(FileWay);
				end
			else
				begin
				LoadFromSaGe3DObjFile(FileWay);
				end;
	end;
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
WriteLn(PredStr,'FNOfVerts = ',FNOfVerts);
WriteLn(PredStr,'FNOfFaces = ',FNOfFaces,'; RealFaceLength = ',GetFaceLength);
WriteLn(PredStr,'FNOfNormals = ',FNOfNormals);
WriteLn(PredStr,'FNOfColors = ',FNOfColors);
WriteLn(PredStr,'FNOfTexVertex = ',FNOfTexVertex);
end;

class function TSGModel.ClassName:String;
begin
Result:='TSGModel';
end;

procedure TSGModel.WriteInfo;
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
	ArObjects[i].Optimization(SaveColors,SaveNormals);
end;

function TSG3DObject.RealSize:Int64;inline;
begin
Result:=
	Length(ArFaces)*SizeOf(TSGFaceType)+
	Length(ArVertex)*SizeOf(TSGVertexType)+
	Length(ArColors)*SizeOf(TSGColor3f)+
	Length(ArNormals)*SizeOf(TSGVertex)+
	Length(ArTexVertexes)*SizeOf(TSGVertex2f);
end;

function TSGModel.RealSize:Int64;
var
	i:LongWord;
begin
Result:=0;
for i:=0 to NOfObjects-1 do
	Result+=ArObjects[i].RealSize;
end;

procedure TSG3DObject.Optimization(const SaveColors:Boolean = True;const SaveNormals:Boolean = False);
var
	i,ii,iii,iiii:LongWord;
	
	ArEmptyIdentites:packed array of 
		packed record
		EmptyID:TSGFaceType;
		AsociatedID:TSGFaceType;
		end = nil;
	FNOfEmptyIdentites:Int64 = 0;
	NewArVertexes,NewArNormals:TSGArTSGVertex;
	NewArColors:packed array of TSGColor3f = nil;
	NewNOf:LongWord = 0;
	ArBools:packed array of Boolean = nil;
	{$IFDEF SGDebuging}
		d1,d2:TSGDateTime;
		{$ENDIF}
	{FShift:LongWord = 10000;
	Ar2:packed array of
			packed record
				Verts:packed array of TSGVertex;
				Identites:packed array of TSGFaceType;
				end;

procedure CalculateArrays;
var
	Int:Int64;
begin
Int:=0;
while Int<FNOfVerts do
	begin
	SetLength(Ar2,Length(Ar2)+1);
	if Int+FShift>FNOfVerts then
		begin
		SetLength(Ar2[High(Ar2)].Verts,
		end
	else
		begin
		
		end;
	Int+=FShift;
	end;
end;}

procedure AddEmptyIdentity(const EID,AID:TSGFaceType);inline;
begin
FNOfEmptyIdentites+=1;
ArEmptyIdentites[FNOfEmptyIdentites-1].EmptyID:=EID;
ArEmptyIdentites[FNOfEmptyIdentites-1].AsociatedID:=AID;
end;

function InArEmptyIdentitesID(const ID:TSGFaceType):TSGFaceType;overload;inline;
var
	i:LongWord;
begin
Result:=0;
i:=0;
while i<=FNOfEmptyIdentites-1 do
	begin
	if ArEmptyIdentites[i].EmptyID=ID then
		begin
		Result:=i;
		Exit;
		end;
	i+=1;
	end;
end;

begin
{$IFDEF SGDebuging}
	WriteLn('Beginning optimization "'+FName+'" at ('+SGStr(SaveColors)+','+SGStr(SaveNormals)+')');
	{$ENDIF}
SetLength(ArEmptyIdentites,FNOfVerts);
FNOfEmptyIdentites:=0;
{$IFDEF SGDebuging}
	WriteLn('Begining stage 1...');
	d1.Get;
	{$ENDIF}
SetLength(ArBools,FNOfVerts);
FillChar(ArBools[0],FNOfVerts,1);
for i:=1 to FNOfVerts-1 do
	begin
	for ii:=0 to i-1 do
		begin
		if ArBools[i] then
			if ArVertexes[i]=ArVertexes[ii] then
				begin
				AddEmptyIdentity(i,ii);
				ArBools[i]:=False;
				Break;
				end;
		end;
	end;
//CalculateArrays;
{$IFDEF SGDebuging}
	d2.Get;
	WriteLn('Stage 1 complite at ',(d2-d1).GetPastMiliSeconds,' miliseconds.');
	WriteLn('Find "'+SGStr(FNOfEmptyIdentites)+'" empty vertexes ( of '+SGStr(FNOfVerts)+' max ).');
	{$ENDIF}
if not SaveColors then
	begin
	SetLength(ArColors,0);
	FNOfColors:=0;
	end;
if not SaveNormals then
	begin
	SetLength(ArNormals,0);
	FNOfNormals:=0;
	FHasNormals:=False;
	end;
SetLength(NewArVertexes,FNOfVerts-FNOfEmptyIdentites);
if SaveColors then
	SetLength(NewArColors,Length(ArColors)-FNOfEmptyIdentites);
if SaveNormals then
	SetLength(NewArNormals,Length(ArNormals)-FNOfEmptyIdentites);
{$IFDEF SGDebuging}
	WriteLn('Begining stage 2...');
	d1.Get;
	{$ENDIF}
NewNOf:=0;
for i:=0 to FNOfVerts-1 do
	begin
	if ArBools[i] then
		begin
		NewArVertexes[NewNOf]:=ArVertexes[i];
		if SaveColors then
			NewArColors[NewNOf]:=ArColors[i];
		if SaveNormals then
			NewArNormals[NewNOf]:=ArNormals[i];
		if i<>NewNOf then
			begin
			for ii:=0 to GetFaceLength-1 do
				if ArFaces[ii]=i then
					ArFaces[ii]:=NewNOf;
			for ii:=0 to FNOfEmptyIdentites-1 do
				if ArEmptyIdentites[ii].AsociatedID=i then
					ArEmptyIdentites[ii].AsociatedID:=NewNOf;
			end;
		NewNOf+=1;
		end
	else
		begin
		iiii:=InArEmptyIdentitesID(i);
		for ii:=0 to GetFaceLength-1 do
			if ArFaces[ii]=i then
				ArFaces[ii]:=ArEmptyIdentites[iiii].AsociatedID;
		end;
	end;
{$IFDEF SGDebuging}
	d2.Get;
	WriteLn('Stage 2 complite at ',(d2-d1).GetPastMiliSeconds,' muliseconds.');
	{$ENDIF}
SetLength(ArVertex,0);
if SaveColors then
	SetLength(ArColors,0);
if SaveNormals then
	SetLength(ArNormals,0);
Pointer(ArVertex):=Pointer(NewArVertexes);
if SaveColors then
	ArColors:=NewArColors;
if SaveNormals then
	ArNormals:=NewArNormals;
FNOfVerts:=NewNOf;
if SaveColors then
	FNOfColors:=NewNOf;
if SaveNormals then
	FNOfNormals:=NewNOf;
SetLength(ArEmptyIdentites,0);
SetLength(ArBools,0);
{$IFDEF SGDebuging}
	WriteLn('Optimization complite.');
	{$ENDIF}
end;

procedure TSGModel.Stripificate;
var
	i:LongWord;
begin
for i:=0 to NOfObjects-1 do
	ArObjects[i].Stripificate;
end;

function TSGModel.VertexesSize:Int64;Inline;
var
	i:LongWord;
begin
Result:=0;
for i:=0 to NOfObjects-1 do
	Result+=ArObjects[i].VertexesSize;
end;

function TSGModel.FacesSize:Int64;inline;
var
	i:LongWord;
begin
Result:=0;
for i:=0 to NOfObjects-1 do
	Result+=ArObjects[i].FacesSize;
end;

function TSGModel.NormalsSize:Int64;inline;
var
	i:LongWord;
begin
Result:=0;
for i:=0 to NOfObjects-1 do
	Result+=ArObjects[i].NormalsSize;
end;

function TSGModel.ColorsSize:Int64;inline;
var
	i:LongWord;
begin
Result:=0;
for i:=0 to NOfObjects-1 do
	Result+=ArObjects[i].ColorsSize;
end;

function TSGModel.TextureVertexesSize:Int64;inline;
var
	i:LongWord;
begin
Result:=0;
for i:=0 to NOfObjects-1 do
	Result+=ArObjects[i].TextureVertexesSize;
end;

function TSGModel.Size:Int64;inline;
var
	i:LongWord;
begin
Result:=0;
for i:=0 to NOfObjects-1 do
	Result+=ArObjects[i].Size;
end;

function TSG3DObject.VertexesSize:Int64;Inline;
begin
Result:=SizeOf(TSGVertex)*FNOfVerts;
end;

function TSG3DObject.FacesSize:Int64;inline;
begin
Result:=SizeOf(TSGFaceType)*GetFaceLength;
end;

function TSG3DObject.NormalsSize:Int64;inline;
begin
Result:=SizeOf(TSGVertex)*FNOfNormals;
end;

function TSG3DObject.ColorsSize:Int64;inline;
begin
Result:=SizeOf(TSGColor3f)*FNOfColors;
end;

function TSG3DObject.TextureVertexesSize:Int64;inline;
begin
Result:=SizeOf(TSGVertex2f)*FNOfTexVertex;
end;

function TSG3DObject.Size:Int64;inline;
begin
Result:=
	FacesSize+
	VertexesSize+
	NormalsSize+
	ColorsSize+
	TextureVertexesSize;
end;

procedure TSG3DObject.Stripificate;overload;inline;
var
	 VertexesAndTriangles:TSGArTSGArTSGFaceType = nil;
	 OutputStrip:TSGArTSGFaceType = nil;
	 b:boolean = True;
begin
{if FPoligonesType = GL_QUADS then
	Con}
if FPoligonesType = GL_TRIANGLES then
	begin
	try
		CalculateDependensies(VertexesAndTriangles);
		Stripificate(VertexesAndTriangles,OutputStrip);
	except
		begin
		b:=False;
		end;
	end;
	if b then
		begin
		SetLength(ArFaces,0);
		ArFaces:=OutputStrip;
		FPoligonesType:=GL_TRIANGLE_STRIP;
		FNOfFaces:=Length(OutputStrip);
		end
	else
		SetLength(OutputStrip,0);
	SetLength(VertexesAndTriangles,0);
	end;
end;

  procedure TSG3DObject.CalculateDependensies(var VertexesAndTriangles:TSGArTSGArTSGFaceType);
  var
    i, ii: longint;
	InputTriangles : PTSGFaceTriangle;
	
    procedure AddDependance(a: longint);inline;
    begin
      if a > High(VertexesAndTriangles) then
        SetLength(VertexesAndTriangles, a + 1);
      SetLength(VertexesAndTriangles[a], Length(VertexesAndTriangles[a]) + 1);
      VertexesAndTriangles[a, High(VertexesAndTriangles[a])] := i;
    end;

  begin
	InputTriangles:=ArFacesTriangles;
    for i := 0 to FNOfFaces-1 do
      for ii := 0 to 2 do
        AddDependance(InputTriangles[i].p[ii]);
  end;

  procedure TSG3DObject.Stripificate(var VertexesAndTriangles:TSGArTSGArTSGFaceType;var OutputStrip:TSGArTSGFaceType);overload;
  var
    triangleFinalized: array of boolean;	//Трианглы, добавленные в финальный стрип
    i: longint;
	InputTriangles:PTSGFaceTriangle;
	
    procedure GenerateStripFromTriangle(StartTriangle: longint);
    var
      TemporaryStrips: array[0..2] of array of longint;
      triangleVieved: array of boolean;		//Трианглы, добавленные в временный стрип
      triangleVievedBest: array of boolean;	//Трианглы, добавленные в лучший временный стрип
      i:longint;				//Перебирает 3 возможных стрипа
      ii, nextVertex: longint;
      max, maxN: longint;			//Для поиска лучшег временного стрипа

      function GetNextVertex: boolean;
      var
        iii, iiii: longint;
        FindedTriangle: longint;
      begin
        Result := False;
	//Ищем свободный триангл, принадлежащий двум последним точкам
        for iii := 0 to high(VertexesAndTriangles[TemporaryStrips[i, High(TemporaryStrips[i])]]) do
          for iiii := 0 to high(VertexesAndTriangles[TemporaryStrips[i, High(TemporaryStrips[i]) - 1]]) do
            if (VertexesAndTriangles[TemporaryStrips[i, High(TemporaryStrips[i])], iii] =
              VertexesAndTriangles[TemporaryStrips[i, High(TemporaryStrips[i]) - 1], iiii]) and
              (not triangleVieved[VertexesAndTriangles[TemporaryStrips[i, High(TemporaryStrips[i])], iii]]) then
            begin
              FindedTriangle := VertexesAndTriangles[TemporaryStrips[i, High(TemporaryStrips[i])], iii];
              triangleVieved[FindedTriangle]:=true;
              Result := True;
            end;
	//Если нашли
        if Result then
	  //Ищем свободную точку в триангле
          for iii := 0 to 2 do
            if (InputTriangles[FindedTriangle].p[iii] <> TemporaryStrips[i, high(TemporaryStrips[i])]) and
              (InputTriangles[FindedTriangle].p[iii] <> TemporaryStrips[i, high(TemporaryStrips[i]) - 1]) then
            begin
              nextVertex := InputTriangles[FindedTriangle].v[iii];
            end;
      end;

    begin
      SetLength(triangleVieved,FNOfFaces);
      SetLength(triangleVievedBest, FNOfFaces);
      //Перебираем временные стрипы
      for i := 0 to 2 do
      begin
	//Синхронизируем с трианглами добавленными в финальный стрип
        for ii := 0 to high(triangleFinalized) do
          triangleVieved[ii] := triangleFinalized[ii];
	//Инициализируем начальный триангл
	//Возможна оптимзация с поиском лучшего начального триангла
        SetLength(TemporaryStrips[i], 3);
        triangleVieved[i]:=true;
        case i of
          0:
          begin
            TemporaryStrips[i,0]:=InputTriangles[StartTriangle].v[0];
            TemporaryStrips[i,1]:=InputTriangles[StartTriangle].v[1];
            TemporaryStrips[i,2]:=InputTriangles[StartTriangle].v[2];
          end;
          1:
          begin
            TemporaryStrips[i,0]:=InputTriangles[StartTriangle].v[2];
            TemporaryStrips[i,1]:=InputTriangles[StartTriangle].v[0];
            TemporaryStrips[i,2]:=InputTriangles[StartTriangle].v[1];
          end;
          2:
          begin
            TemporaryStrips[i,0]:=InputTriangles[StartTriangle].v[1];
            TemporaryStrips[i,1]:=InputTriangles[StartTriangle].v[2];
            TemporaryStrips[i,2]:=InputTriangles[StartTriangle].v[0];
          end;
        end;
	//Пока к стрипу можно добавить вертекс, добавляем
        while GetNextVertex do
        begin
          SetLength(TemporaryStrips[i], Length(TemporaryStrips[i]) + 1);
          TemporaryStrips[i, High(TemporaryStrips[i])] := nextVertex;
        end;
	//Если это первый временный стрип, то он лучшй
	//Если нет, то проверяем является ли лучшим 
	//Если нет, то удаляем его для экономии памяти
        if i = 0 then
        begin
          max := Length(TemporaryStrips[i]);
          maxN := 0;
	  for ii := 0 to High(triangleVieved) do
	    triangleVievedBest[ii] := triangleVieved[ii];
        end
        else
        begin
          if max < Length(TemporaryStrips[i]) then
          begin
            max := Length(TemporaryStrips[i]);
            SetLength(TemporaryStrips[maxN], 0);
            for ii := 0 to High(triangleVievedBest) do
              triangleVievedBest[ii] := triangleVieved[ii];
            maxN := i;
          end
          else
          begin
            SetLength(TemporaryStrips[i], 0);
          end;
        end;
      end;
      //Добавляем к финальному стрипу лучший
      if Length(OutputStrip) > 0 then
      begin
        ii := High(OutputStrip);
        SetLength(OutputStrip, Length(OutputStrip) + Length(TemporaryStrips[maxN]) + 2);
        OutputStrip[ii + 1] := OutputStrip[ii];
        OutputStrip[ii + 2] := TemporaryStrips[maxN, 0];
        for i := 0 to High(TemporaryStrips[maxN]) do
          OutputStrip[ii + 3 + i] := TemporaryStrips[maxN, i];
      end
      else
      begin
        SetLength(OutputStrip, Length(TemporaryStrips[maxN]));
        for i := 0 to High(OutputStrip) do
          OutputStrip[i] := TemporaryStrips[maxN, i];
      end;
      //Запоминаем какие трианглы уже в финальном стрипе
      for i := 0 to High(triangleFinalized) do
        triangleFinalized[i] := triangleVievedBest[i];
    end;

  begin
  InputTriangles:=ArFacesTriangles;
    SetLength(triangleFinalized,FNOfFaces);
    i := 0;
    while i <= High(triangleFinalized) do
    begin
      if not triangleFinalized[i] then
        GenerateStripFromTriangle(i);
      i += 1;
    end;
  end;

class function TSG3DObject.GetPoligoneInt(const ThisPoligoneType:LongWord):Byte;inline;
begin
Result:=
	Byte(
		(ThisPoligoneType=GL_POINTS) or
		(ThisPoligoneType=GL_TRIANGLE_STRIP) or
		(ThisPoligoneType=GL_LINE_LOOP) or
		(ThisPoligoneType=GL_LINE_STRIP))
	+4*Byte( ThisPoligoneType = GL_QUADS )
	+3*Byte( ThisPoligoneType = GL_TRIANGLES )
	+2*Byte( ThisPoligoneType = GL_LINES );
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
SetLength(ArFaces ,GetFaceLength(NewLength));
end;

function TSG3DObject.ArFacesLines:PTSGFaceLine;inline;
begin
if FPoligonesType=GL_LINES then
	Result:=PTSGFaceLine(Pointer(@ArFaces[0]))
else
	Result:=nil;
end;

function TSG3DObject.ArFacesPoints:PTSGFacePoint;inline;
begin
if (
	(FPoligonesType=GL_POINTS) or
	(FPoligonesType=GL_LINE_STRIP) or
	(FPoligonesType=GL_LINE_LOOP) or
	(FPoligonesType=GL_TRIANGLE_STRIP)
	)  then
	Result:=PTSGFacePoint(Pointer(@ArFaces[0]))
else
	Result:=nil;
end;

function TSG3DObject.ArFacesQuads:PTSGFaceQuad;inline;
begin
if FPoligonesType=GL_QUADS then
	Result:=PTSGFaceQuad(Pointer(@ArFaces[0]))
else
	Result:=nil;
end;

function TSG3DObject.ArFacesTriangles:PTSGFaceTriangle;inline;
begin
if FPoligonesType=GL_TRIANGLES then
	Result:=PTSGFaceTriangle(Pointer(@ArFaces[0]))
else
	Result:=nil;
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
with TSGLoad3DS.Create do
	begin
	Import3DS(@Self,FileWay);
	Destroy;
	end;
end;

procedure TSGModel.SaveToSaGe3DObjFile(const FileWay: string);
var
    StreamComponent: TMemoryStream = nil;
    Stream: TFileStream = nil;
    Int:    int64 = 0;
    i:      longint;
begin
Stream := TFileStream.Create(FileWay,fmCreate);
Stream.WriteBuffer(NOfObjects, SizeOf(NOfObjects));
for i := 0 to NOfObjects - 1 do
	begin
	StreamComponent := TMemoryStream.Create;
	ArObjects[i].SaveToStream(StreamComponent);
	Int := StreamComponent.Size;
	Stream.WriteBuffer(Int, SizeOf(Int));
	StreamComponent.Position:=0;
	StreamComponent.SaveToStream(Stream);
	StreamComponent.Destroy;
	StreamComponent := nil;
	end;
Stream.WriteBuffer(NOfMaterials, SizeOf(NOfMaterials));
for i := 0 to NOfMaterials - 1 do
	begin
	StreamComponent := TMemoryStream.Create;
	ArMaterials[i].SaveToStream(StreamComponent);
	Int := StreamComponent.Size;
	Stream.WriteBuffer(Int, SizeOf(Int));
	StreamComponent.Position:=0;
	StreamComponent.SaveToStream(Stream);
	StreamComponent.Destroy;
	StreamComponent := nil;
	end;
Stream.Destroy;
end;

procedure TSG3dObject.SaveToStream(const Stream: TStream);
begin
Stream.WriteBuffer(FName, SizeOf(FName));
Stream.WriteBuffer(FObjectColor, SizeOf(FObjectColor));
Stream.WriteBuffer(FPoligonesType, SizeOf(FPoligonesType));
Stream.WriteBuffer(FMaterialID, SizeOf(FMaterialID));
Stream.WriteBuffer(FHasTexture, SizeOf(FHasTexture));

Stream.WriteBuffer(FNOfFaces, SizeOf(FNOfFaces));
if FNOfFaces <> 0 then
	Stream.WriteBuffer(ArFaces[0], GetFaceLength*SizeOf(TSGFaceType));

Stream.WriteBuffer(FNOfVerts, SizeOf(FNOfVerts));
if FNOfVerts <> 0 then
	Stream.WriteBuffer(ArVertexes[0], SizeOf(ArVertexes[0]) * FNOfVerts);

Stream.WriteBuffer(FNOfTexVertex, SizeOf(FNOfTexVertex));
if FNOfTexVertex <> 0 then
	Stream.WriteBuffer(ArTexVertexes[0], SizeOf(ArTexVertexes[0]) * FNOfTexVertex);

Stream.WriteBuffer(FNOfNormals, SizeOf(FNOfNormals));
if FNOfNormals <> 0 then
	Stream.WriteBuffer(ArNormals[0], SizeOf(ArNormals[0]) * FNOfNormals);

Stream.WriteBuffer(FNOfColors, SizeOf(FNOfColors));
if FNOfColors <> 0 then
	Stream.WriteBuffer(ArColors[0], SizeOf(ArColors[0]) * FNOfColors);
end;

procedure TSG3dObject.LoadFromStream(const Stream: TStream);
begin
Stream.ReadBuffer(FName, SizeOf(FName));
Stream.ReadBuffer(FObjectColor, SizeOf(FObjectColor));
Stream.ReadBuffer(FPoligonesType, SizeOf(FPoligonesType));
Stream.ReadBuffer(FMaterialID, SizeOf(FMaterialID));
Stream.ReadBuffer(FHasTexture, SizeOf(FHasTexture));

Stream.ReadBuffer(FNOfFaces, SizeOf(FNOfFaces));
if FNOfFaces <> 0 then
begin
	SetLength(ArFaces, GetFaceLength);
	Stream.ReadBuffer(ArFaces[0],GetFaceLength*SizeOf(TSGFaceType));
end;

Stream.ReadBuffer(FNOfVerts, SizeOf(FNOfVerts));
if FNOfVerts <> 0 then
begin
	SetVertexLength(FNOfVerts);//SetLength(ArVertexes, FNOfVerts);
	Stream.ReadBuffer(ArVertexes[0], SizeOf(ArVertexes[0]) * FNOfVerts);
end;

Stream.ReadBuffer(FNOfTexVertex, SizeOf(FNOfTexVertex));
if FNOfTexVertex <> 0 then
begin
	SetLength(ArTexVertexes, FNOfTexVertex);
	Stream.ReadBuffer(ArTexVertexes[0], SizeOf(ArTexVertexes[0]) * FNOfTexVertex);
end;

Stream.ReadBuffer(FNOfNormals, SizeOf(FNOfNormals));
if FNOfNormals <> 0 then
begin
	SetLength(ArNormals, FNOfNormals);
	Stream.ReadBuffer(ArNormals[0], SizeOf(ArNormals[0]) * FNOfNormals);
end;
FHasNormals := FNOfNormals <> 0;

Stream.ReadBuffer(FNOfColors, SizeOf(FNOfColors));
if FNOfColors <> 0 then
begin
	SetLength(ArColors, FNOfColors);
	Stream.ReadBuffer(ArColors[0], SizeOf(ArColors[0]) * FNOfColors);
end;
end;

procedure TSGModel.LoadFromSaGe3DObjFile(const FileWay: string);
var
    StreamComponent: TMemoryStream = nil;
    Stream: TFileStream = nil;
    Int:    int64 = 0;
    i:      longint;
begin
    Stream := TFileStream.Create(FileWay,fmOpenRead);
    //Stream.LoadFromFile(FileWay);
    Stream.Position := 0;

    Stream.ReadBuffer(NOfObjects, SizeOf(NOfObjects));
    SetLength(ArObjects, NOfObjects);
    for i := 0 to NOfObjects - 1 do
    begin
        ArObjects[i] := TSG3dObject.Create;
        StreamComponent := TMemoryStream.Create;
        Stream.ReadBuffer(Int, SizeOf(Int));
        SGLoadLoadPartStreamToStream(Stream, StreamComponent, Int);
        StreamComponent.Position := 0;
        ArObjects[i].LoadFromStream(StreamComponent);
        StreamComponent.Destroy;
        StreamComponent := nil;
    end;
    Stream.ReadBuffer(NOfMaterials, SizeOf(NOfMaterials));
    SetLength(ArMaterials, NOfMaterials);
    for i := 0 to NOfMaterials - 1 do
    begin
        ArMaterials[i] := TSGMaterialInfo.Create;
        StreamComponent := TMemoryStream.Create;
        Stream.ReadBuffer(Int, SizeOf(Int));
        SGLoadLoadPartStreamToStream(Stream, StreamComponent, Int);
        StreamComponent.Position := 0;

        ArMaterials[i].FStream := StreamComponent;
        ArMaterials[i].LoadToBitMap;
        if ArMaterials[i].ReadyToGoToTexture then
            ArMaterials[i].LoadTextureMainThread;
        ArMaterials[i].FStream := nil;
        if StreamComponent <> nil then
            StreamComponent.Destroy;
        StreamComponent := nil;
    end;
    Stream.Destroy;
end;

constructor TSGMaterialInfo.Create;
begin
    inherited Create;
    strFile:='';
    strName:='';
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
	if (i<=High(ArObjects)) and ((not ArObjects[i].FHasTexture) or (ArObjects[i].FHasTexture and (ArObjects[i].FMaterialID<=High(ArMaterials)) and (ArObjects[i].FMaterialID>=0))) then
		begin    
		if ArObjects[i].FHasTexture then
			ArMaterials[ArObjects[i].FMaterialID].BindTexture;
		ArObjects[i].Draw;
		if ArObjects[i].FHasTexture and ArMaterials[ArObjects[i].FMaterialID].Ready then
			ArMaterials[ArObjects[i].FMaterialID].DisableTexture;
		end;
	end;
end;

function TSG3dObject.GetSizeOf:int64;
begin
Result:=
	GetFaceLength*SizeOf(TSGFaceType)+
	FNOfVerts*SizeOf(TSGVertex)+
	FNOfColors*SizeOf(TSGColor3f)+
	FNOfNormals*SizeOf(TSGVertex)+
	FNOfTexVertex*SizeOf(TSGVertex2f);
end;

constructor TSG3dObject.Create;
begin
    inherited;
    FEnableCullFace := True;
    FObjectColor.Import(1, 1, 1, 1);
    FHasTexture := False;
    FHasNormals := False;
    FNOfNormals := 0;
    FNOfFaces := 0;
    FNOfVerts := 0;
    FNOfTexVertex := 0;
    FNOfColors:=0;
    ArColors := nil;
    ArVertex := nil;
    ArNormals := nil;
    ArFaces := nil;
    ArTexVertexes := nil;
    FName := '';
    FMaterialID := -1;
    FPoligonesType:=GL_TRIANGLES;
    FEnableVBO:=False;
    FVBOColors:=0;
    FVBOFaces:=0;
    FVBONormals:=0;
    FVBOTexVertexes:=0;
    FVBOVertexes:=0;
    FVertexType:=TSGMeshVertexType3f;
end;

destructor TSG3dObject.Destroy;
begin
ClearArrays;
inherited;
end;

procedure TSG3dObject.Draw; inline;
begin
{$IFDEF SGMoreDebuging}
	WriteLn('Call "TSG3dObject.Draw" : "'+ClassName+'" is sucsesfull');
	{$ENDIF}
    if FEnableCullFace then
    begin
        glEnable(gl_cull_face);
        glCullFace(gl_back);
    end;
    BasicDraw;
    if FEnableCullFace then
    begin
        glCullFace(gl_front);
        BasicDraw;
        glDisable(gl_cull_face);
    end;
end;

procedure TSG3DObject.ClearArrays(const ClearN:boolean = True);
begin
if ArNormals<>nil then
	begin
	SetLength(ArNormals,0);
	ArNormals:=nil;
	end;
if ArVertexes<>nil then
	begin
	SetLength(ArVertex,0);
	ArVertex:=nil;
	end;
if ArTexVertexes<>nil then
	begin
	SetLength(ArTexVertexes,0);
	ArTexVertexes:=nil;
	end;
if ArFaces<>nil then
	begin 
	SetLength(ArFaces,0);
	ArFaces:=nil;
	end;
if ArColors<>nil then
	begin
	SetLength(ArColors,0);
	ArColors:=nil;
	end;
if ClearN then
	begin
	FNOfFaces:=0;
	FNOfVerts:=0;
	FNOfNormals:=0;
	FNOfTexVertex:=0;
	FNOfColors:=0;
	end;
end;

procedure TSG3dObject.SaveFromSaGe3DObjFile(const FileWay:string);
var
	Stream:TStream = nil;
begin
Stream:=TFileStream.Create(FileWay,fmCreate);
SaveToStream(Stream);
Stream.Destroy;
end;

procedure TSG3dObject.LoadFromSaGe3DObjFile(const FileWay:string);
var
	Stream:TStream = nil;
begin
if SGFileExists(FileWay) then
	begin
	Stream:=TFileStream.Create(FileWay,fmOpenRead);
	LoadFromStream(Stream);
	Stream.Destroy;
	end;
end;

procedure TSG3dObject.BasicDraw; inline;
begin
FObjectColor.Color;

if FEnableVBO then
	glEnable(GL_ARRAY_BUFFER_ARB);

glEnableClientState(GL_VERTEX_ARRAY);
if FHasNormals then
	glEnableClientState(GL_NORMAL_ARRAY);
if FHasTexture then
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
if FNOfColors<>0 then
	glEnableClientState(GL_COLOR_ARRAY);

if FEnableVBO then
	begin
	glBindBufferARB(GL_ARRAY_BUFFER_ARB,FVBOVertexes);
	glVertexPointer(3,GL_FLOAT,SizeOf(TSGVertex),nil);
	
	if FHasNormals then
		begin
		glBindBufferARB(GL_ARRAY_BUFFER_ARB,FVBONormals);
		glNormalPointer(GL_FLOAT,SizeOf(TSGVertex),nil);
		end;
	
	if FNOfColors<>0 then
		begin
		glBindBufferARB(GL_ARRAY_BUFFER_ARB,FVBOColors);
		glColorPointer(3,GL_FLOAT,SizeOf(TSGVertex),nil);
		end;
	
	if FHasTexture then
		begin
		glBindBufferARB(GL_ARRAY_BUFFER_ARB,FVBOTexVertexes);
		glTexCoordPointer(2, GL_FLOAT, SizeOf(TSGVertex2f),nil);
		end;
	
	glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB ,FVBOFaces);
	glDrawElements(FPoligonesType, GetFaceLength,GL_UNSIGNED_INT,nil);
	
	glBindBufferARB(GL_ARRAY_BUFFER_ARB,0);
	end
else
	begin
    glVertexPointer(2+Byte(FVertexType=TSGMeshVertexType3f), GL_FLOAT, SizeOf(TSGVertexType)*(2+Byte(FVertexType=TSGMeshVertexType3f)), @ArVertex[0]);
    if FHasNormals then
        glNormalPointer(GL_FLOAT, SizeOf(TSGVertex), @ArNormals[0]);
    if FHasTexture then
        glTexCoordPointer(2, GL_FLOAT, SizeOf(TSGVertex2f), @ArTexVertexes[0]);
    if FNOfColors<>0 then
		glColorPointer(3,GL_FLOAT,SizeOf(TSGColor3f),@ArColors[0]);
    glDrawElements(FPoligonesType, GetFaceLength , GL_UNSIGNED_INT, @ArFaces[0]);
    end;

glDisableClientState(GL_VERTEX_ARRAY);
if FHasNormals then
	glDisableClientState(GL_NORMAL_ARRAY);
if FHasTexture then
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
if FNOfColors<>0 then
	glDisableClientState(GL_COLOR_ARRAY);

if FEnableVBO then
	glDisable(GL_ARRAY_BUFFER_ARB);
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

procedure TSG3dObject.LoadToVBO;
begin
	glEnable(GL_ARRAY_BUFFER_ARB);
	
	glGenBuffersARB(1, @FVBOVertexes);
	glGenBuffersARB(1, @FVBOFaces);
	if FHasNormals then 
		glGenBuffersARB(1, @FVBONormals);
	if FNOfColors<>0 then
		glGenBuffersARB(1, @FVBOColors);
	if FHasTexture then
		glGenBuffersARB(1, @FVBOTexVertexes);


	glBindBufferARB(GL_ARRAY_BUFFER_ARB,FVBOVertexes);
	glBufferDataARB (GL_ARRAY_BUFFER_ARB,FNOfVerts*SizeOf(TSGVertexType)*(2+Byte(FVertexType=TSGMeshVertexType3f)),@ArVertex[0], GL_STATIC_DRAW_ARB);

	if FHasNormals then
		begin
		glBindBufferARB(GL_ARRAY_BUFFER_ARB,FVBONormals);
		glBufferDataARB (GL_ARRAY_BUFFER_ARB,FNOfNormals*SizeOf(TSGVertex),@ArNormals[0], GL_STATIC_DRAW_ARB);
		end;

	if FNOfColors<>0 then
		begin
		glBindBufferARB(GL_ARRAY_BUFFER_ARB,FVBOColors);
		glBufferDataARB (GL_ARRAY_BUFFER_ARB,FNOfColors*SizeOf(TSGVertex),@ArColors[0], GL_STATIC_DRAW_ARB);
		end;

	if FHasTexture then
		begin
		glBindBufferARB(GL_ARRAY_BUFFER_ARB,FVBOTexVertexes);
		glBufferDataARB (GL_ARRAY_BUFFER_ARB,FNOfTexVertex*SizeOf(TSGVertex2f),@ArTexVertexes[0], GL_STATIC_DRAW_ARB);
		end;

	glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB,FVBOFaces);
	glBufferDataARB (GL_ELEMENT_ARRAY_BUFFER_ARB,GetFaceLength*SizeOf(TSGFaceType),@ArFaces[0], GL_STATIC_DRAW_ARB);

	glBindBufferARB(GL_ARRAY_BUFFER_ARB,0);
	
	glDisable(GL_ARRAY_BUFFER_ARB);
	
//	Delay(100);
	ClearArrays(False);
	FEnableVBO:=True;

end;

procedure TSG3DObject.ClearVBO;inline;
begin
glDeleteBuffersARB(1,@FVBOFaces);
FVBOFaces:=0;
if FHasNormals then
	begin
	glDeleteBuffersARB(1,@FVBONormals);
	FVBONormals:=0;
	end;
glDeleteBuffersARB(1,@FVBOVertexes);
FVBOVertexes:=0;
if FHasTexture then
	begin
	glDeleteBuffersARB(1,@FVBOTexVertexes);
	FVBOTexVertexes:=0;
	end;
if FNOfColors<>0 then
	begin
	glDeleteBuffersARB(1,@FVBOColors);
	FVBOColors:=0;
	end;
end;

end.

