{$I Includes\SaGe.inc}

unit SaGeExamples;

interface
uses
	SaGeCommon
	,SaGeMesh
	,SaGeFractals
	,SaGeUtils
	,SaGeContext
	,SaGeShaders
	,Gl
	,Glu
	,GLext
	,SaGeCL
	,SaGeNet
	,SaGeMath
	,SaGeGeneticalAlgoritm
	,SaGeBase;
type
	TSGExampleShader=class(TSGDrawClass)
			public
		constructor Create;override;
		destructor Destroy;override;
		class function ClassName:string;override;
		procedure Draw;override;
		end;
const
	mNothink=0;
	mGround=1;
	mcCQ=30;
	mcCH = mcCQ -1;
type
	mData=class(TObject)
		end;
	mChank=object
			public
		constructor Create;
		destructor Destroy;
			public
		FCoord:TSGPoint3f;
		FBlocks:
			packed array[0..mcCH] of 
				packed array[0..mcCH] of
					packed array[0..mcCH] of
						LongWord;
		FBlocksData:packed array of 
			packed record
			FCoord:TSGPoint3f;
			FData:mData;
			end;
		FMesh:TSG3DObject;
		FMeshReady:Boolean;
			public
		procedure Clear;
		property Coord:TSGPoint3f read FCoord write FCoord;
		procedure Draw;
		procedure DrawBlock(const p3:TSGVertex3f;const t:LongWord);inline;
		procedure CalculateMesh;
		function TerrineToTex(const i:LongWord):TSGVertex2f;inline;
		end;
	TSGMinecraft=class(TSGDrawClass)
			public
		constructor Create;override;
		destructor Destroy;override;
		class function ClassName:string;override;
		procedure Draw;override;
			public
		FPlayerPosition:TSGVertex3f;
		FWorld:packed array of
			mChank;
		FVO:SGIdentityObject;
		FTerrain:TSGGLImage;
		FAngles:TSGVertex2f;
		FTime:TSGDateTime;
			public
		procedure CalculateWorld;
		end;
type
	TSGSeaBatle=class(TSGDrawClass)
			public
		constructor Create;override;
		destructor Destroy;override;
		class function ClassName:string;override;
		procedure Draw;override;
			public
		FAskConnection,FSayConnection:TSGUDPConnection;
		end;
type
	TSGBezierCurve =object
		StartArray : TArTSGVertex3f;
		EndArray : TArTSGVertex3f;
		Detalization:dword;
		procedure Clear;
		procedure InitVertex(const k:TSGVertex3f);
		procedure Calculate;
		procedure Init(const p:Pointer = nil);
		procedure SetArray(const a:TArTSGVertex3f);
		function SetDetalization(const l:dword):boolean;
		function GetDetalization:longword;
		procedure CalculateRandom(Detalization1,KolVertex,Diapazon:longint);
		end;
	SGBezierCurve = TSGBezierCurve;
{$DEFINE SGREADINTERFACE}
{$i Includes\SaGeExampleGraphViewer.inc}
{$i Includes\SaGeExampleGeneticalAlgoritm.inc}
{$i Includes\SaGeExampleGraphViewer3D.inc}
{$UNDEF SGREADINTERFACE}

implementation

{$DEFINE SGREADIMPLEMENTATION}
{$i Includes\SaGeExampleGraphViewer.inc}
{$i Includes\SaGeExampleGeneticalAlgoritm.inc}
{$i Includes\SaGeExampleGraphViewer3D.inc}
{$UNDEF SGREADIMPLEMENTATION}

procedure TSGBezierCurve.Calculate;
var
	i:longword;

function GetKoor(const R:real;const A:TArTSGVertex3f):TSGVertex3f;
var
	A2:TArTSGVertex3f;
	i:longint;
begin
if Length(a)=2 then
	begin
	GetKoor:=SGGetVertexInAttitude(A[Low(A)],A[High(A)],r);
	end
else
	begin
	SetLength(A2,Length(A)-1);
	for i:=Low(A2) to High(A2) do
		A2[i]:=SGGetVertexInAttitude(A[i],A[i+1],r);
	GetKoor:=GetKoor(R,A2);
	SetLength(A2,0);
	end;
end;

begin
SetLength(EndArray,Detalization+1);
for i:=Low(EndArray) to High(EndArray) do
	begin
	EndArray[i]:=GetKoor(i/Detalization,StartArray);
	end;
end;

procedure TSGBezierCurve.InitVertex(const k:TSGVertex3f);
begin
SetLength(StartArray,Length(StartArray)+1);
StartArray[High(StartArray)]:=k;
end;

procedure TSGBezierCurve.Clear;
begin
SetLength(StartArray,0);
SetLength(EndArray,0);
SetDetalization(40);
end;
function TSGBezierCurve.GetDetalization:longword;
begin
GetDetalization:=Detalization;
end;

procedure TSGBezierCurve.SetArray(const a:TArTSGVertex3f);
begin
SetLength(StartArray,0);
StartArray:=a;
end;

function TSGBezierCurve.SetDetalization(const l:dword):boolean;
begin
if l>0 then
	begin
	SetDetalization:=true;
	Detalization:=l;
	end
else
	SetDetalization:=false;
end;

procedure TSGBezierCurve.Init(const p:Pointer = nil);
var	
	i:longint;
begin
GlBegin(GL_LINE_STRIP);
for i:=Low(EndArray) to High(EndArray) do
	begin
	EndArray[i].Vertex(p);
	end;
GlEnd();
end;

procedure TSGBezierCurve.CalculateRandom(Detalization1,KolVertex,Diapazon:longint);
var
	i:longint;
begin
Clear;
SetDetalization(Detalization1);
for i:=1 to KolVertex do
	InitVertex(SGTSGVertex3fImport(
		SGRandomMinus*random(Diapazon)/(random(Diapazon)+1),
		SGRandomMinus*random(Diapazon)/(random(Diapazon)+1),
		SGRandomMinus*random(Diapazon)/(random(Diapazon)+1)));
Calculate;
end;

procedure mmmSeaBatleReceieve(Parant:TSGUDPConnection;AStream:TMemoryStream; aSocket: TSGSocket);
begin

end;

constructor TSGSeaBatle.Create;
begin
inherited;
FAskConnection:=TSGUDPConnection.Create;
FAskConnection.ConnectionMode:=TSGServerMode;
FAskConnection.ReceiveProcedure:=TSGReceiveProcedure(@mmmSeaBatleReceieve);
FAskConnection.Port:=1842;
FAskConnection.Start;
end;

destructor TSGSeaBatle.Destroy;
begin
FAskConnection.Destroy;
inherited;
end;

class function TSGSeaBatle.ClassName:string;
begin
Result:='See Batle';
end;

procedure TSGSeaBatle.Draw;
begin

end;

{procedure OZConnect;
begin

end;

procedure OZListen;
var
	Connection:TSGUDPConnection;

begin

end;

begin
SGConsoleMenu(
	SGConsoleRecord('Connect',@OZConnect)+
	SGConsoleRecord('Listen',@OZListen)+
	SGConsoleRecord('Exit',nil));
Halt(1);
}
function mChank.TerrineToTex(const i:LongWord):TSGVertex2f;inline;
begin
Result.Import(((i mod 16))/16,(15-(i div 16))/16);
end;

procedure mChank.CalculateMesh;
var
	Ar:
		packed array[-1..mcCQ,-1..mcCQ,-1..mcCQ] of Boolean;
	Point:TSGPoint3f;

function IsExists(const Point:TSGPoint3f):Boolean;inline;
begin
Result:=
	(Point.x>=-1) and (Point.x<=mcCQ) and 
	(Point.y>=-1) and (Point.y<=mcCQ) and 
	(Point.z>=-1) and (Point.z<=mcCQ) and 
	(not Ar[Point.x,Point.y,Point.z]);
end;

procedure Add(const p1,p2:TSGPoint3f;const VType:Byte);
var
	tv2:TSGVertex2f;
	v1,v2,v3,v4:TSGVertex3f;
begin
tv2:=TerrineToTex(FBlocks[p2.x,p2.y,p2.z]);
SGLog.Sourse('p1('+SGStr(p1.x)+' '+SGStr(p1.y)+' '+SGStr(p1.z)+'),p2('+SGStr(p2.x)+' '+SGStr(p2.y)+' '+SGStr(p2.z)+')'+SGStr(VType));
case VType of
1:
	begin
	v1.Import((p1.x+p2.x)/2,p2.y+0.5,p2.z+0.5);
	v2.Import((p1.x+p2.x)/2,p2.y-0.5,p2.z+0.5);
	v3.Import((p1.x+p2.x)/2,p2.y-0.5,p2.z-0.5);
	v4.Import((p1.x+p2.x)/2,p2.y+0.5,p2.z-0.5);
	end;
2:
	begin
	v4.Import((p1.x+p2.x)/2,p2.y+0.5,p2.z+0.5);
	v3.Import((p1.x+p2.x)/2,p2.y-0.5,p2.z+0.5);
	v2.Import((p1.x+p2.x)/2,p2.y-0.5,p2.z-0.5);
	v1.Import((p1.x+p2.x)/2,p2.y+0.5,p2.z-0.5);
	end;
3:
	begin
	v4.Import(p2.x+0.5,(p1.y+p2.y)/2,p2.z+0.5);
	v3.Import(p2.x-0.5,(p1.y+p2.y)/2,p2.z+0.5);
	v2.Import(p2.x-0.5,(p1.y+p2.y)/2,p2.z-0.5);
	v1.Import(p2.x+0.5,(p1.y+p2.y)/2,p2.z-0.5);
	end;
4:
	begin
	v1.Import(p2.x+0.5,(p1.y+p2.y)/2,p2.z+0.5);
	v2.Import(p2.x-0.5,(p1.y+p2.y)/2,p2.z+0.5);
	v3.Import(p2.x-0.5,(p1.y+p2.y)/2,p2.z-0.5);
	v4.Import(p2.x+0.5,(p1.y+p2.y)/2,p2.z-0.5);
	end;
5:
	begin
	v1.Import(p2.x+0.5,p2.y+0.5,(p1.z+p2.z)/2);
	v2.Import(p2.x-0.5,p2.y+0.5,(p1.z+p2.z)/2);
	v3.Import(p2.x-0.5,p2.y-0.5,(p1.z+p2.z)/2);
	v4.Import(p2.x+0.5,p2.y-0.5,(p1.z+p2.z)/2);
	end;
6:
	begin
	v4.Import(p2.x+0.5,p2.y+0.5,(p1.z+p2.z)/2);
	v3.Import(p2.x-0.5,p2.y+0.5,(p1.z+p2.z)/2);
	v2.Import(p2.x-0.5,p2.y-0.5,(p1.z+p2.z)/2);
	v1.Import(p2.x+0.5,p2.y-0.5,(p1.z+p2.z)/2);
	end;
end;

v4.Import(v4.x+FCoord.x*mcCQ+0.5,v4.y+FCoord.y*mcCQ+0.5,v4.z+FCoord.z*mcCQ+0.5);
v3.Import(v3.x+FCoord.x*mcCQ+0.5,v3.y+FCoord.y*mcCQ+0.5,v3.z+FCoord.z*mcCQ+0.5);
v2.Import(v2.x+FCoord.x*mcCQ+0.5,v2.y+FCoord.y*mcCQ+0.5,v2.z+FCoord.z*mcCQ+0.5);
v1.Import(v1.x+FCoord.x*mcCQ+0.5,v1.y+FCoord.y*mcCQ+0.5,v1.z+FCoord.z*mcCQ+0.5);

FMesh.SetVertexLength(FMesh.FNOfVerts+4);
FMesh.FNOfVerts+=4;
FMesh.ArVertexes[FMesh.FNOfVerts-4]:=v4;
FMesh.ArVertexes[FMesh.FNOfVerts-3]:=v3;
FMesh.ArVertexes[FMesh.FNOfVerts-2]:=v2;
FMesh.ArVertexes[FMesh.FNOfVerts-1]:=v1;

SetLength(FMesh.ArTexVertexes,FMesh.FNOfTexVertex+4);
FMesh.FNOfTexVertex+=4;
FMesh.ArTexVertexes[FMesh.FNOfTexVertex-4].Import(tv2.x+1/16,tv2.y+1/16);
FMesh.ArTexVertexes[FMesh.FNOfTexVertex-3].Import(tv2.x+1/16,tv2.y     );
FMesh.ArTexVertexes[FMesh.FNOfTexVertex-2].Import(tv2.x     ,tv2.y     );
FMesh.ArTexVertexes[FMesh.FNOfTexVertex-1].Import(tv2.x     ,tv2.y+1/16);

FMesh.SetFaceLength(FMesh.FNOfFaces+1);
FMesh.ArFacesQuads[FMesh.FNOfFaces].p[0]:=FMesh.FNOfVerts-1;
FMesh.ArFacesQuads[FMesh.FNOfFaces].p[1]:=FMesh.FNOfVerts-2;
FMesh.ArFacesQuads[FMesh.FNOfFaces].p[2]:=FMesh.FNOfVerts-3;
FMesh.ArFacesQuads[FMesh.FNOfFaces].p[3]:=FMesh.FNOfVerts-4;
FMesh.FNOfFaces+=1;
end;

procedure Rec(const Point:TSGPoint3f);
var
	i,ii,iii:ShortInt;
	Point2:TSGPoint3f;
begin
//SGLog.Sourse('R '+SGStr(Point.x)+' '+SGStr(Point.y)+' '+SGStr(Point.z));
Ar[Point.x,Point.y,Point.z]:=True;
for i:=-1 to 1 do
	for ii:=-1 to 1 do
		for iii:=-1 to 1 do
			if (not((i=0) and (ii=0) and (iii=0))) and (
				((i=0) and (ii=0)) or 
				((i=0) and (iii=0)) or 
				((ii=0) and (iii=0)) )then
				begin
				Point2.Import(Point.x+i,Point.y+ii,Point.z+iii);
				if IsExists(Point2) then
					begin
					if ((Point2.x<>-1) and 
						(Point2.y<>-1) and 
						(Point2.z<>-1) and 
						(Point2.x<>mcCQ) and 
						(Point2.y<>mcCQ) and 
						(Point2.z<>mcCQ) and 
						(FBlocks[Point2.x,Point2.y,Point2.z]=0)) or
						(not ((Point2.x<>-1) and 
						(Point2.y<>-1) and 
						(Point2.z<>-1) and 
						(Point2.x<>mcCQ) and 
						(Point2.y<>mcCQ) and 
						(Point2.z<>mcCQ)))
						 then
						Rec(Point2)
					else
						Add(Point,Point2,
							Byte(i=1)+
							Byte(i=-1)*2+
							Byte(ii=1)*3+
							Byte(ii=-1)*4+
							Byte(iii=1)*5+
							Byte(iii=-1)*6);
					end;
				end;
end;
begin
if FMesh<>nil then
	FMesh.Destroy;

FMesh:=TSG3DObject.Create;
with FMesh do
	begin
	FEnableCullFace:=False;
	FPoligonesType:=GL_QUADS;
	FHasTexture:=True;
	FillChar(Ar,SizeOf(Ar),0);
	FObjectColor:=SGGetColor4fFromLongWord($FFFFFFFF);
	Point.Import(-1,-1,-1);
	Rec(Point);
	//LoadToVBO;
	//WriteInfo('');
	end;
FMeshReady:=True;
end;

constructor mChank.Create;
begin
FCoord.Import(0,0,0);
FBlocksData:=nil;
Clear;
FMesh:=nil;
FMeshReady:=False;
end;
procedure mChank.Clear;
begin
fillchar(FBlocks,SizeOf(FBlocks),0);
if FBlocksData<>nil then
	begin
	SetLength(FBlocksData,0);
	FBlocksData:=nil;
	end;
if FMesh<>nil then
	FMesh.Destroy;
FMesh:=nil;
FMeshReady:=False;
end;

constructor TSGMinecraft.Create;
begin
inherited;
FAngles.Import(0,pi/2);
FPlayerPosition.Import(random(1000),random(1000),0);
CalculateWorld;
FVO.Clear;
FTerrain:=TSGGLImage.Create;
FTerrain.Way:=TextureDirectory+Slash+'Minecraft'+Slash+'terrain.png';
FTerrain.Loading;
SGContext.ShowCursor(False);
SGContext.SetCursorPosition(SGPoint2fImport(Trunc(SGContext.Width / 2),Trunc(SGContext.Height / 2)));
FTime.Get;
end;

procedure TSGMinecraft.CalculateWorld;
var
	i,ii,iii:LongWord;
begin
SetLength(FWorld,1);
FWorld[0].Create;
FWorld[0].FCoord.Import(
	Trunc(FPlayerPosition.x) div mcCQ,
	Trunc(FPlayerPosition.y) div mcCQ);
for i:=0 to mcCQ-1 do
	for ii:=0 to mcCQ-1 do
		for iii:=0 to mcCQ-1 do
			begin
			FWorld[0].FBlocks[i,ii,iii]:=random(4);
			end;
FWorld[0].CalculateMesh;
end;

destructor TSGMinecraft.Destroy;
begin
inherited;
end;

class function TSGMinecraft.ClassName:string;
begin
Result:='SaGe Minecraft';
end;

procedure TSGMinecraft.Draw;
var
	i:LongWord;
	a:TSGVertex2f;
	FViewVertex:TSGVertex3f;
	FTime2:TSGDateTime;
	ElapsedTime:LongWord;
begin
//Calculate ElapsedTime
FTime2.Get;
ElapsedTime:=(FTime2-FTime).GetPastMiliSeconds;
FTime:=FTime2;

glLoadIdentity;
a:=SGContext.GetCursorPosition-SGPoint2fImport(Trunc(SGContext.Width / 2),Trunc(SGContext.Height / 2));
SGContext.SetCursorPosition(SGPoint2fImport(Trunc(SGContext.Width / 2),Trunc(SGContext.Height / 2)));
a.Import(a.x/SGContext.Width,a.y/SGContext.Height);
if FAngles.y-a.y >= pi-0.01 then
	FAngles.y:=pi -0.01
else
	if FAngles.y-a.y<=0.01 then
		FAngles.y:=0.01
	else
		FAngles.y-=a.y;
FAngles.x-=a.x;
if FAngles.x>2*pi then 
	FAngles.x-=2*pi
else
	if FAngles.x<0 then
		FAngles.x+=2*pi;
FViewVertex.Import(
	sin(FAngles.x)*(1-abs(FAngles.y-pi/2)/(pi/2))
	,cos(FAngles.x)*(1-abs(FAngles.y-pi/2)/(pi/2)),
	cos(FAngles.y));
if SGContext.KeysPressed(87) then
	FPlayerPosition+=SGVertex2fImport(sin(FAngles.x),cos(FAngles.x))*0.07*ElapsedTime;
if SGContext.KeysPressed(83) then
	FPlayerPosition-=SGVertexImport(sin(FAngles.x),cos(FAngles.x),0)*0.07*ElapsedTime;

SGLookAt(
	FPlayerPosition-SGZ(1.4),
	FPlayerPosition-SGZ(1.4)+FViewVertex,
	SGVertexImport(0,0,-1));



if (SGContext.KeyPressedByte=112) and (SGContext.KeyPressedType=SGDownKey) then
	FWorld[0].FMeshReady:= not FWorld[0].FMeshReady;

glEnable(GL_CULL_FACE);
glCullFace(GL_FRONT);
FTerrain.BindTexture;
for i:=0 to High(FWorld) do
	FWorld[i].Draw;
FTerrain.DisableTexture;
glDisable(GL_CULL_FACE);
end;

destructor mChank.Destroy;
begin
end;

procedure mChank.DrawBlock(const p3:TSGVertex3f;const t:LongWord);inline;
var
	i,ii:LongWord;
const 
	c116=1/16;
	c1256=1/256;
begin
case t of
1,2,3,4,5,6,7,8,9,10,11,12,13:
	begin
	case t of
	1: begin i:=0; ii:=15;end;
	2: begin i:=1; ii:=15;end;
	3: begin i:=2; ii:=15;end;
	4: begin i:=0; ii:=14;end;
	5: begin i:=1; ii:=14;end;
	6: begin i:=2; ii:=14;end;
	7: begin i:=0; ii:=13;end;
	8: begin i:=1; ii:=13;end;
	9: begin i:=2; ii:=13;end;
	10:begin i:=3; ii:=14;end;
	11:begin i:=0; ii:=5;end;
	12:begin i:=3; ii:=12;end;
	13:begin i:=2; ii:=12;end;
	end;
	
	SGColor3f(1,1,1);
	glBegin(GL_QUADS);
	
	glTexCoord2f(c116*i+c1256,c116*ii+c1256);
	(p3+SGVertexImport(1,1,1)).Vertex;
	glTexCoord2f(c116*i+c116-c1256,c116*ii+c1256);
	(p3+SGVertexImport(1,0,1)).Vertex;
	glTexCoord2f(c116*i+c116-c1256,c116*ii+c116-c1256);
	(p3+SGVertexImport(1,0,0)).Vertex;
	glTexCoord2f(c116*i+c1256,c116*ii+c116-c1256);
	(p3+SGVertexImport(1,1,0)).Vertex;
	
	glTexCoord2f(c116*i+c1256,c116*ii+c1256);
	(p3+SGVertexImport(1,1,1)).Vertex;
	glTexCoord2f(c116*i+c116-c1256,c116*ii+c1256);
	(p3+SGVertexImport(0,1,1)).Vertex;
	glTexCoord2f(c116*i+c116-c1256,c116*ii+c116-c1256);
	(p3+SGVertexImport(0,0,1)).Vertex;
	glTexCoord2f(c116*i+c1256,c116*ii+c116-c1256);
	(p3+SGVertexImport(1,0,1)).Vertex;
	
	glTexCoord2f(c116*i+c1256,c116*ii+c1256);
	(p3+SGVertexImport(1,1,1)).Vertex;
	glTexCoord2f(c116*i+c116-c1256,c116*ii+c1256);
	(p3+SGVertexImport(0,1,1)).Vertex;
	glTexCoord2f(c116*i+c116-c1256,c116*ii+c116-c1256);
	(p3+SGVertexImport(0,1,0)).Vertex;
	glTexCoord2f(c116*i+c1256,c116*ii+c116-c1256);
	(p3+SGVertexImport(1,1,0)).Vertex;
	
	glTexCoord2f(c116*i+c1256,c116*ii+c1256);
	p3.Vertex;
	glTexCoord2f(c116*i+c116-c1256,c116*ii+c1256);
	(p3+SGX(1)).Vertex;
	glTexCoord2f(c116*i+c116-c1256,c116*ii+c116-c1256);
	(p3+SGX(1)+SGY(1)).Vertex;
	glTexCoord2f(c116*i+c1256,c116*ii+c116-c1256);
	(p3+SGY(1)).Vertex;
	
	glTexCoord2f(c116*i+c1256,c116*ii+c1256);
	p3.Vertex;
	glTexCoord2f(c116*i+c116-c1256,c116*ii+c1256);
	(p3+SGZ(1)).Vertex;
	glTexCoord2f(c116*i+c116-c1256,c116*ii+c116-c1256);
	(p3+SGZ(1)+SGY(1)).Vertex;
	glTexCoord2f(c116*i+c1256,c116*ii+c116-c1256);
	(p3+SGY(1)).Vertex;
	
	glTexCoord2f(c116*i+c1256,c116*ii+c1256);
	p3.Vertex;
	glTexCoord2f(c116*i+c116-c1256,c116*ii+c1256);
	(p3+SGX(1)).Vertex;
	glTexCoord2f(c116*i+c116-c1256,c116*ii+c116-c1256);
	(p3+SGX(1)+SGZ(1)).Vertex;
	glTexCoord2f(c116*i+c1256,c116*ii+c116-c1256);
	(p3+SGZ(1)).Vertex;
	glEnd();
	end;
end;
end;

procedure mChank.Draw;
var
	i,ii,iii:Word;
	p3:TSGVertex3f;
begin
if FMeshReady then
	FMesh.Draw
else
	for i:=0 to mcCQ-1 do
		for ii:=0 to mcCQ-1  do
			 for iii:=0 to mcCQ-1 do
				begin
				p3.Import(
					FCoord.x*mcCQ+i,
					FCoord.y*mcCQ+ii,
					FCoord.z*mcCQ+iii);
				DrawBlock(p3,FBlocks[i,ii,iii]);
				end; 
end;






constructor TSGExampleShader.Create;
var
	Shader:TSGShader = nil;
begin
inherited;
Shader:=TSGShader.Create(GL_VERTEX_SHADER);
Shader.Sourse(
	'#version 150'+#13+#10+
	'uniform mat4 viewMatrix, projMatrix;'+#13+#10+
	''+#13+#10+
	'in vec4 position;'+#13+#10+
	'in vec3 color;'+#13+#10+
	''+#13+#10+
	'out vec3 Color;'+#13+#10+
	''+#13+#10+
	'void main()'+#13+#10+
	'	{'+#13+#10+
	'	Color = color;'+#13+#10+
	'	gl_Position = projMatrix * viewMatrix * position ;'+#13+#10+
	'	}');
Shader.Compile;

end;

destructor TSGExampleShader.Destroy;
begin

inherited;
end;

class function TSGExampleShader.ClassName:string;
begin
Result:='Exaple Shaders';
end;

procedure TSGExampleShader.Draw;
begin

end;


end.
