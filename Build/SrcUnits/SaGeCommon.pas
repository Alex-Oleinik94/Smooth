{$INCLUDE Includes\SaGe.inc}
unit SaGeCommon;
interface 
uses
	 SaGeBase
	,SaGeBased
	,SaGeRender
	,Classes
	,SysUtils;
	
type
	TSGVertexFormat=(SG_VERTEX_3F,SG_VERTEX_2F);
	
	TSGThreadProcedure = SaGeBase.TSGThreadProcedure;
	TSGThread = SaGeBase.TSGThread;
	SGThread = SaGeBase.TSGThread;
	
	TSGPoint2f=object
		x,y:longint;
		procedure Import(const x1:longint = 0; const y1:longint = 0);inline;
		procedure Write;inline;
		procedure Vertex(const VRender:TSGRender);inline;
		end;
	TSGPoint = TSGPoint2f;
	SGPoint = TSGPoint2f;
	SGPoint2f = TSGPoint2f;
	PSGPoint = ^ SGPoint;
	
	TSGPoint3f=object(SGPoint)
			public
		z:longint;
			public
		procedure Import(const x1:LongInt = 0;const x2:LongInt = 0;const x3:LongInt = 0);inline;
		procedure Vertex(const VRender:TSGRender);inline;
		end;
	SGPoint3f = TSGPoint3f;
	PSGPoint3f = ^ SGPoint3f;
	
	TSGVertexType = type single;
	
	TSGVertex2f=object
		x,y:TSGVertexType;
		procedure Vertex(const VRender:TSGRender);inline;
		procedure TexCoord(const VRender:TSGRender);inline;
		procedure SetVariables(const x1:real = 0; const y1:real = 0);inline;
		procedure Import(const x1:real = 0;const y1:real = 0);inline;
		procedure Write;inline;
		procedure WriteLn;inline;
		procedure Round;inline;overload;
		procedure Translate(const VRender:TSGRender);inline;
		end;
	PTSGVertex2f=^TSGVertex2f;
	TArTSGVertex2f = type packed array of TSGVertex2f;
	PTArTSGVertex2f = ^TArTSGVertex2f;
	SGVertex2f = TSGVertex2f;
	Vertex2f = TSGVertex2f;
	
	TSGComplexNumber = object(TSGVertex2f)
		end;
	
	TSGVertex3f=object(TSGVertex2f)
		z:TSGVertexType;
		procedure Vertex(const VRender:TSGRender);inline;
		procedure SetVariables(const x1:real = 0; const y1:real = 0; const z1:real = 0);inline;
		procedure Import(const x1:real = 0; const y1:real = 0; const z1:real = 0);inline;
		procedure Normal(const VRender:TSGRender);inline;
		procedure LightPosition(const VRender:TSGRender;const Ligth:LongInt = SGR_LIGHT0);inline;
		procedure VertexPoint(const VRender:TSGRender);inline;
		procedure Write;inline;
		procedure WriteLn;inline;
		procedure Vertex(const VRender:TSGRender;Const P:Pointer);inline;
		procedure Normalize;inline;
		procedure ReadFromTextFile(const Fail:PTextFile);inline;
		procedure ReadLnFromTextFile(const Fail:PTextFile);inline;
		procedure Translate(const VRender:TSGRender);inline;
		end;
	SGVertex3f=TSGVertex3f;
	SGVertex=SGVertex3f;
	TSGVertex=SGVertex;
	PTSGVertex3f=^TSGVertex3f;
	PSGVertex = PTSGVertex3f;
	PSGVertex3f = PTSGVertex3f;
	TArTSGVertex3f = type packed array of TSGVertex3f;
	ArrayOfTSGVertex3f = TArTSGVertex3f;
	TArTSGVertex = TArTSGVertex3f;
	TArSGVertex = TArTSGVertex3f;
	ArSGVertex = TArTSGVertex3f;
	TSGArTSGVertex = TArTSGVertex3f;
	TSGArSGVertex = TArTSGVertex3f;
	SGArTSGVertex = TArTSGVertex3f;
	SGArSGVertex = TArTSGVertex3f;
	SGArVertex = TArTSGVertex3f;
	ArVertex = TArTSGVertex3f;
	PTArTSGVertex3f = ^TArTSGVertex3f;
	TSGVertexFunction = function (a:SGVertex):SGVertex;
	TSGShodowVertexProcedure=procedure (Param1,Param2,Param3:single);cdecl;
	TSGArLongWord = type packed array of LongWord;
	TSGScreenVertexes=object
		Vertexes:array[0..1] of TSGVertex2f;
		procedure Import(const x1:real = 0;const y1:real = 0;const x2:real = 0;const y2:real = 0);
		procedure Write;inline;
		procedure ProcSumX(r:Real);inline;
		procedure ProcSumY(r:Real);inline;
		property SumX:real write ProcSumX;
		property SumY:real write ProcSumY;
		property X1:TSGVertexType read Vertexes[0].x write Vertexes[0].x;
		property Y1:TSGVertexType read Vertexes[0].y write Vertexes[0].y;
		property X2:TSGVertexType read Vertexes[1].x write Vertexes[1].x;
		property Y2:TSGVertexType read Vertexes[1].y write Vertexes[1].y;
		function VertexInView(const Vertex:TSGVertex2f):Boolean;inline;
		function AbsX:TSGVertexType;inline;
		function AbsY:TSGVertexType;inline;
		end;
	
	TSGVisibleVertex=object(TSGVertex3f)
		Visible:Boolean;
		end;
	SGVisibleVertex = TSGVisibleVertex;
	PSGVisibleVertex = ^SGVisibleVertex;
	TArSGVisibleVertex = type packed array of TSGVisibleVertex;
	TArTSGVisibleVertex = TArSGVisibleVertex;
	TSGVisibleVertexFunction = function (a:TSGVisibleVertex;CONST b:Pointer):TSGVisibleVertex;
	TSGPointerProcedure = procedure (a:Pointer);
	TSGProcedure = procedure;
	
	PTSGColor3f=^TSGColor3f;
	TSGColor3f=object
		r,g,b:single;
		procedure Color(const VRender:TSGRender);inline;
		procedure SetColor(const VRender:TSGRender);inline;
		procedure Import(const r1:single = 0; const g1:single = 0; const b1:single = 0);
		procedure ReadFromStream(const Stream:TStream);inline;
		procedure WriteToStream(const Stream:TStream);inline;
		procedure Normalize();inline;
		end;
	PTArTSGColor3f = ^TArTSGColor3f;
	TArTSGColor3f = array of TSGColor3f;
	
	PTSGColor4f = ^ TSGColor4f;
	TSGColor4f=object(TSGColor3f)
		a:single;
		procedure SetColor(const VRender:TSGRender);
		procedure Color(const VRender:TSGRender);
		procedure SetVariables(const r1:real = 0; const g1:real = 0; const b1:real = 0; const a1:real = 1);
		function AddAlpha(const NewAlpha:real = 1):TSGColor4f;
		function WithAlpha(const NewAlpha:real = 1):TSGColor4f;
		procedure Import(const r1:real = 0; const g1:real = 0; const b1:real = 0;const a1:real = 1);
		procedure ReadFromStream(const Stream:TStream);inline;
		procedure WriteToStream(const Stream:TStream);inline;
		end;
	SGColor4f = TSGColor4f;
	SGColor = TSGColor4f;
	PTArTSGColor4f = ^TArTSGColor4f;
	TArTSGColor4f =type packed array of TSGColor4f;
	TArSGColor4f = TArTSGColor4f;
	TArSGColor = TArTSGColor4f;
	TArColor = TArTSGColor4f;
	ArColor = TArTSGColor4f;
	ArSGColor = TArTSGColor4f;
	ArSGColor4f = TArSGColor4f;
type
	TSGArFor0To255OfBoolean = type packed array [0..255] of boolean;
	TSGArFor0To2OfBoolean = type packed array [0..2] of boolean;
	TSGArFor0To3OfSGPoint = type packed array [0..3]of SGPoint;
	TSGArFor1To4OfSGVertex = type packed array [1..4] of SGVertex;
	PTSGArFor1To4OfSGVertex = ^TSGArFor1To4OfSGVertex;
	PSGArFor1To4OfSGVertex = PTSGArFor1To4OfSGVertex;
type
	TSGCustomPosition = record
		case byte of
		0: (FLocation : TSGVertex3f; FTurn   : TSGVertex3f);
		1: (X, Y, Z   : TSGSingle;   A, B, G : TSGSingle);
		end;
	
	PSGPosition = ^ TSGPosition;
	TSGPosition = object
			protected
		FPosition : TSGCustomPosition;
			public
		property x         : TSGSingle   read FPosition.x         write FPosition.x;
		property y         : TSGSingle   read FPosition.y         write FPosition.y;
		property z         : TSGSingle   read FPosition.z         write FPosition.z;
		property a         : TSGSingle   read FPosition.a         write FPosition.a;
		property b         : TSGSingle   read FPosition.b         write FPosition.b;
		property g         : TSGSingle   read FPosition.g         write FPosition.g;
		property Location  : TSGVertex3f read FPosition.FLocation write FPosition.FLocation;
		property Turn      : TSGVertex3f read FPosition.FTurn     write FPosition.FTurn;
		end;
const
	NilVertex:SGVertex = (x:0;y:0;z:0);
	NilColor:SGColor = (r:0;g:0;b:0;a:0);

operator + (const a,b:TSGComplexNumber):TSGComplexNumber;overload;inline;
operator * (const a,b:TSGComplexNumber):TSGComplexNumber;inline;overload;
operator - (const a,b:TSGComplexNumber):TSGComplexNumber;overload;inline;
operator / (const a,b:TSGComplexNumber):TSGComplexNumber;inline;overload;
operator ** (const a:TSGComplexNumber;const b:LongInt):TSGComplexNumber;inline;overload;
operator = (const a,b:TSGComplexNumber):Boolean;overload;inline;

operator * (const a:SGColor;const b:real):SGColor;inline;overload;
operator * (const b:extended;const a:SGColor):SGColor;inline;overload;
operator * (const a:SGColor;const b:byte):SGColor;inline;overload;
operator * (const a:SGColor;const b:longint):SGColor;inline;overload;
operator * (const a:SGColor;const b:int64):SGColor;inline;overload;
operator * (const b:int64;const a:SGColor):SGColor;inline;overload;
operator * (const b:longint;const a:SGColor):SGColor;inline;overload;
operator * (const b:byte;const a:SGColor):SGColor;inline;overload;
operator + (const a,b:SGColor):SGColor;inline;overload;
operator - (const a,b:SGColor):SGColor;inline;overload;
operator / (const a:SGColor;const b:real):SGColor;inline;overload;

operator * (const a:TSGColor3f;const b:real):SGColor;inline;overload;
operator / (const a:TSGColor3f;const b:real):SGColor;inline;overload;

//��������� ������������ ���� �������� ����������� ������������
operator * (const a,b:SGVertex):SGVertex;inline;overload;

operator + (const a,b:SGVertex):SGVertex;inline;overload;
operator - (const a,b:SGVertex):SGVertex;inline;overload;
operator / (const a:SGVertex;const b:real):SGVertex;inline;overload;
operator * (const a:SGVertex;const b:real):SGVertex;inline;overload;
operator * (const b:real;const a:SGVertex):SGVertex;inline;overload;
operator + (const a:SGVertex;const b:SGVertex2f):SGVertex;inline;overload;
operator + (const a:SGVertex2f;const b:SGVertex):SGVertex;inline;overload;
operator + (const a,b:SGVertex2f):SGVertex2f;overload;inline;overload;
operator + (const a,b:SGVertex2f):SGVertex;inline;overload;
operator - (const a:TSGVertex):TSGVertex;overload;inline;
operator * (const a:SGVertex2f;const b:real):SGVertex2f;overload;inline;
operator / (const a:SGVertex2f;const b:real):SGVertex2f;overload;inline;
operator * (const b:real;const a:SGVertex2f):SGVertex2f;overload;inline;
operator / (const b:real;const a:SGVertex2f):SGVertex2f;overload;inline;
operator = (const a,b:TSGVertex3f):Boolean;overload;inline;
operator - (const a,b:TSGVertex2f):TSGVertex2f;overload;inline;
operator - (const a:TSGVertex2f):TSGVertex2f;overload;inline;
operator * (const a,b:TSGVertex2f):TSGVertex2f;overload;inline;
operator + (const a:SGVertex2f;const b:TSGVertexType):SGVertex2f;overload;inline;
operator - (const a:SGVertex2f;const b:TSGVertexType):SGVertex2f;overload;inline;
operator := (const b:single):TSGVertex3f;overload;inline;

operator + (const a,b:SGPoint):SGPoint;inline;overload;
operator - (const a,b:SGPoint):SGPoint;inline;overload;
operator / (const a:SGPoint;const b:Int64):SGPoint;overload;inline;
operator div (const a:SGPoint;const b:Int64):SGPoint;overload;inline;
operator = (const a,b:TSGPoint2f):Boolean;overload;inline;
operator * (const a:TSGPoint2f;const b:real):TSGVertex2f;overload;inline;
operator + (const a:TSGPoint2f;const b:integer):TSGPoint2f;overload;inline;

operator + (const a:TSGVertex2f;const b:TSGPoint2f):TSGVertex2f;overload;inline;
operator := (const a:TSGPoint2f):TSGVertex2f;overload;inline;

operator * (const a:TSGScreenVertexes;const b:real):TSGScreenVertexes;inline;overload;

function SGGetVertexInAttitude(const t1,t2:TSGVertex3f; const r:real = 0.5):TSGVertex3f;inline;
function SGTSGVertex3fImport(const x:real = 0;const y:real = 0;const z:real = 0):TSGVertex3f;inline;
function SGVertexImport(const x:real = 0;const y:real = 0;const z:real = 0):TSGVertex3f;inline;
function SGPointImport(const NewX:Real = 0; const NewY:Real = 0 ):SGPoint;inline;
function SGPointImport(const NewX:LongInt = 0; const NewY:LongInt = 0 ):SGPoint;inline;
//procedure SGQuad(const Vertex1:SGVertex;const Vertex2:SGVertex;const Vertex3:SGVertex;const Vertex4:SGVertex);
function SGVertexOnQuad(const Vertex:SGVertex; const QuadVertex1:SGVertex;const QuadVertex2:SGVertex;const QuadVertex3:SGVertex;const QuadVertex4:SGVertex):boolean;inline;
function SGAbsTwoVertex(const Vertex1:SGVertex;const Vertex2:SGVertex):TSGSingle;inline;
function SGTreugPlosh(const a1,a2,a3:SGVertex):real;inline;
function SGVertexOnQuad(const Vertex:SGVertex; const QuadVertex1:SGVertex;const QuadVertex3:SGVertex):boolean;inline;
function SGGetVertexOnIntersectionOfThreePlane(p1,p2,p3:SGPlane):SGVertex;inline;
function SGGetVertexWhichNormalFromThreeVertex(const p1,p2,p3:SGVertex):SGVertex;inline;
function SGGetPlaneFromThreeVertex(const a1,a2,a3:SGVertex):SGPlane;inline;
function Random(const lx,ly:LongWord):TSGPoint2f;overload;inline;
function SGGetVertexOnIntersectionOfTwoLinesFromFourVertex(const q1,q2,w1,w2:SGVertex):SGVertex;inline;
procedure SGRoundQuad(const VRender:TSGRender;const Vertex1,Vertex3:SGVertex; const Radius:real; const Interval:LongInt;const QuadColor:SGColor; const LinesColor:SGColor4f; const WithLines:boolean = False;const WithQuad:boolean = True);
function SGColorImport(const r1:real = 0;const g1:real = 0;const b1:real = 0;const a1:real = 1):SGColor;inline;
function SGPoint2fToVertex2f(const Point:SGPoint):SGVertex2f;inline;
function SGPoint2fToVertex3f(const Point:SGPoint):SGVertex3f;inline;
function SGGetArrayOfRoundQuad(const Vertex1,Vertex3:SGVertex; const Radius:real; const Interval:LongInt):SGArVertex;
procedure SGRoundWindowQuad(const VRender:TSGRender;const Vertex11,Vertex13:SGVertex;const Vertex21,Vertex23:SGVertex; 
	const Radius1:real;const Radius2:real; const Interval:LongInt;const QuadColor1:SGColor;const QuadColor2:SGColor;
	const WithLines:boolean; const LinesColor1:SGColor4f; const LinesColor2:SGColor4f);inline;
procedure SGConstructRoundQuad(const VRender:TSGRender;const ArVertex:SGArSGVertex;const Interval:LongInt;const QuadColor:SGColor; const LinesColor:SGColor4f; const WithLines:boolean = False;const WithQuad:boolean = True);
function SGAbsTwoVertex2f(const Vertex1,Vertex2:SGVertex2f):TSGSingle;inline;
procedure SGQuickRePlaceVertexType(var LongInt1,LongInt2:TSGVertexType); inline;
function SGVertex2fToPoint2f(const Vertex:TSGVertex2f):TSGPoint2f;inline;
function SGVertex2fImport(const x:real = 0;const y:real = 0):TSGVertex2f;inline;
function SGComplexNumberImport(const x:real = 0;const y:real = 0):TSGComplexNumber;inline;
function SGPoint2fImport(const x1:int64 = 0; const y1:int64 = 0):TSGPoint2f;overload;inline;
function SGPoint2fImport(const x1:extended = 0; const y1:extended = 0):TSGPoint2f;overload;inline;
function SGGetColor4fFromLongWord(const LongWordColor:LongWord;const WithAlpha:Boolean = False):SGColor4f;inline;
function SGGetPointsCirclePoints(const FPoints:TArTSGVertex2f):TSGArLongWord;
function SGX(const v:Single):TSGVertex3f;inline;
function SGY(const v:Single):TSGVertex3f;inline;
function SGZ(const v:Single):TSGVertex3f;inline;
function Abs(const a:TSGVertex2f):extended;overload;inline;

implementation

operator * (const a,b:SGVertex):SGVertex;inline;overload;
begin
Result.Import(a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x);
end;

operator := (const b:single):TSGVertex3f;overload;inline;
begin
Result.Import(b,b,b);
end;

function Abs(const a:TSGVertex2f):extended;overload;inline;
begin
Result:=sqrt(sqr(a.x)+sqr(a.y));
end;

procedure TSGScreenVertexes.ProcSumX(r:Real);inline;
begin
Vertexes[0].x+=r;
Vertexes[1].x+=r;
end;

procedure TSGScreenVertexes.ProcSumY(r:Real);inline;
begin
Vertexes[0].y+=r;
Vertexes[1].y+=r;
end;

procedure TSGVertex3f.WriteLn;inline;
begin
Write;
System.WriteLn()
end;

procedure TSGVertex3f.Write;inline;
begin
inherited Write;
System.Write(' ',z:0:10)
end;

procedure TSGVertex2f.Write;inline;
begin
System.Write(x:0:10,' ',y:0:10);
end;

procedure TSGVertex2f.WriteLn;inline;
begin
Write;
System.Writeln;
end;

procedure TSGScreenVertexes.Write;inline;
begin
Vertexes[0].Write;
System.Write(' ');
Vertexes[1].WriteLn;
end;

operator * (const a:TSGScreenVertexes;const b:real):TSGScreenVertexes;inline;overload;
var
	x,y,x1,y1:real;
begin
x:=(a.x1+a.x2)/2;
y:=(a.y1+a.y2)/2;
x1:=abs(a.x1-x);
y1:=abs(a.y1-y);
x1*=b;
y1*=b;
Result.Import(
	x-x1,
	y-y1,
	x+x1,
	y+y1);
end;

procedure TSGScreenVertexes.Import(const x1:real = 0;const y1:real = 0;const x2:real = 0;const y2:real = 0);inline;
begin
Vertexes[0].x:=x1;
Vertexes[0].y:=y1;
Vertexes[1].x:=x2;
Vertexes[1].y:=y2;
end;

function SGAbsTwoVertex2f(const Vertex1,Vertex2:SGVertex2f):TSGSingle;inline;
begin
Result:=sqrt(sqr(Vertex1.x-Vertex2.x)+sqr(Vertex1.y-Vertex2.y));
end;

procedure TSGVertex3f.VertexPoint(const VRender:TSGRender);inline;
begin
VRender.BeginScene(SGR_POINTS);
Vertex(VRender);
VRender.EndScene();
end;

procedure TSGVertex3f.LightPosition(const VRender:TSGRender;const Ligth:LongInt = SGR_LIGHT0);inline;
var
	Light:array[0..3] of TSGVertexType;
	AmbientLight : array[0..3] of TSGVertexType = (0.5,0.5,0.5,1.0);
	DiffuseLight : array[0..3] of TSGVertexType = (1.0,1.0,1.0,1.0);
	SpecularLight : array[0..3] of TSGVertexType = (1.0,1.0,1.0,1.0);
begin
Light[0]:=x;
Light[1]:=y;
Light[2]:=z;
Light[3]:=2;
VRender.Enable(Ligth);
VRender.Lightfv(Ligth,SGR_AMBIENT, @AmbientLight);
VRender.Lightfv(Ligth,SGR_DIFFUSE, @DiffuseLight);
VRender.Lightfv(Ligth,SGR_SPECULAR, @SpecularLight);
VRender.Lightfv(Ligth,SGR_POSITION,@Light);
end;

procedure TSGVertex3f.Normal(const VRender:TSGRender);inline;
begin
VRender.Normal3f(x,y,z);
end;

procedure SGWndSomeQuad(const a,c:SGVertex;const VRender:TSGRender);inline;
var
	b,d:SGVertex;
begin
b.Import(c.x,a.y,a.z);
d.Import(a.x,c.y,a.z);
VRender.BeginScene(SGR_QUADS);
VRender.TexCoord2f(0,1);a.Vertex(VRender);
VRender.TexCoord2f(1,1);b.Vertex(VRender);
VRender.TexCoord2f(1,0);c.Vertex(VRender);
VRender.TexCoord2f(0,0);d.Vertex(VRender);
VRender.EndScene();
end;

operator + (const a:SGVertex;const b:SGVertex2f):SGVertex;inline;
begin
Result.Import(a.x+b.x,a.y+b.y,a.z);
end;

operator + (const a:SGVertex2f;const b:SGVertex):SGVertex;inline;
begin
Result.Import(a.x+b.x,a.y+b.y,b.z);
end;

operator + (const a,b:SGVertex2f):SGVertex2f;inline;
begin
Result.Import(a.x+b.x,a.y+b.y);
end;

operator + (const a,b:SGVertex2f):SGVertex;inline;
begin
Result.Import(a.x+b.x,a.y+b.y);
end;

procedure SGSomeQuad(a,b,c,d:SGVertex;vl,np:SGPoint;const VRender:TSGRender);inline;
begin
VRender.BeginScene(SGR_QUADS);
VRender.TexCoord2f(vl.x, vl.y);
a.Vertex(VRender);
VRender.TexCoord2f(np.x, vl.y);
b.Vertex(VRender);
VRender.TexCoord2f(np.x, np.y);
c.Vertex(VRender);
VRender.TexCoord2f(vl.x, np.y);
d.Vertex(VRender);
VRender.EndScene();
end;

procedure SGRoundWindowQuad(const VRender:TSGRender;const Vertex11,Vertex13:SGVertex;const Vertex21,Vertex23:SGVertex; 
	const Radius1:real;const Radius2:real; const Interval:LongInt;const QuadColor1:SGColor;const QuadColor2:SGColor;
	const WithLines:boolean; const LinesColor1:SGColor4f; const LinesColor2:SGColor4f);inline;
begin
SGRoundQuad(VRender,Vertex11,Vertex13,Radius1,Interval,QuadColor1,LinesColor1,WithLines);
SGRoundQuad(VRender,Vertex21,Vertex23,Radius2,Interval,QuadColor2,LinesColor2,WithLines);
end;

procedure SGRoundQuad(
	const VRender:TSGRender;
	const Vertex1,Vertex3:SGVertex; 
	const Radius:real; 
	const Interval:LongInt;
	const QuadColor:SGColor; 
	const LinesColor:SGColor4f; 
	const WithLines:boolean = False;
	const WithQuad:boolean = True);inline;
var
	ArVertex:TSGArTSGVertex = nil;
begin
ArVertex:=SGGetArrayOfRoundQuad(Vertex1,Vertex3,Radius,Interval);
SGConstructRoundQuad(VRender,ArVertex,Interval,QuadColor,LinesColor,WithLines,WithQuad);
SetLength(ArVertex,0);
end;

function SGGetArrayOfRoundQuad(const Vertex1,Vertex3:SGVertex; const Radius:real; const Interval:LongInt):SGArVertex;
var
	Vertex2,Vertex4:SGVertex;
	VertexR1,VertexR2,VertexR3,VertexR4:SGVertex;
	I,ii:LongInt;
begin
Result:=nil;
Vertex2.Import(Vertex3.x,Vertex1.y,(Vertex1.z+Vertex3.z)/2);
Vertex4.Import(Vertex1.x,Vertex3.y,(Vertex1.z+Vertex3.z)/2);
VertexR1.Import(Vertex1.x+Radius,Vertex1.y-Radius,Vertex1.z);
VertexR2.Import(Vertex2.x-Radius,Vertex2.y-Radius,Vertex2.z);
VertexR3.Import(Vertex3.x-Radius,Vertex3.y+Radius,Vertex3.z);
VertexR4.Import(Vertex4.x+Radius,Vertex4.y+Radius,Vertex4.z);
SetLength(Result,Interval*4+4);
ii:=0;
For i:=0 to Interval do
	begin
	Result[ii].Import(VertexR2.x+cos((Pi/2)/(Interval)*i)*Radius,VertexR2.y+sin((Pi/2)/(Interval)*i+Pi)*Radius+2*Radius,VertexR2.z); 
	ii+=1;
	end;
For i:=0 to Interval do
	begin
	Result[ii].Import(VertexR1.x+cos((Pi/2)*i/(Interval)+Pi/2)*Radius,VertexR1.y+sin((Pi/2)*i/(Interval)+3*Pi/2)*Radius+2*Radius,VertexR1.z); 
	ii+=1;
	end;
For i:=0 to Interval do
	begin 
	Result[ii].Import(VertexR4.x+cos((Pi/2)*i/Interval+Pi)*Radius,VertexR4.y+sin((Pi/2)*i/(Interval))*Radius-2*Radius,VertexR4.z); 
	ii+=1;
	end;
For i:=0 to Interval do
	begin 
	Result[ii].Import(VertexR3.x+cos((Pi/2)*i/(Interval)+3*Pi/2)*Radius,VertexR3.y+sin((Pi/2)*i/(Interval)+Pi/2)*Radius-2*Radius,VertexR3.z); 
	ii+=1;
	end;
end;

procedure SGConstructRoundQuad(
	const VRender:TSGRender;
	const ArVertex:SGArSGVertex;
	const Interval:LongInt;
	const QuadColor:SGColor; 
	const LinesColor:SGColor4f; 
	const WithLines:boolean = False;
	const WithQuad:boolean = True);
var
	I:LongInt;
begin
if WithQuad then
	begin
	(QuadColor).Color(VRender);
	VRender.BeginScene(SGR_QUADS);//glBegin(GL_QUADS);
	for i:=0 to Interval-1 do
		begin
		ArVertex[Interval-i].Vertex(VRender);
		ArVertex[Interval+1+i].Vertex(VRender);
		ArVertex[Interval+2+i].Vertex(VRender);
		ArVertex[Interval-i-1].Vertex(VRender);
		end;
	ArVertex[0].Vertex(VRender);
	ArVertex[2*Interval+1].Vertex(VRender);
	ArVertex[2*Interval+2].Vertex(VRender);
	ArVertex[4*(Interval+1)-1].Vertex(VRender);
	for i:=0 to Interval-1 do
		begin
		ArVertex[(Interval+1)*2+i].Vertex(VRender);
		ArVertex[(Interval+1)*2+i+1].Vertex(VRender);
		ArVertex[(Interval+1)*4-2-i].Vertex(VRender);
		ArVertex[(Interval+1)*4-1-i].Vertex(VRender);
		end;
	VRender.EndScene();//glEnd();
	end;
if WithLines then
	begin
	LinesColor.Color(VRender);
	VRender.BeginScene(SGR_LINE_LOOP);//glBegin(GL_LINE_LOOP);
	for i:=Low(ArVertex) to High(ArVertex) do
		ArVertex[i].Vertex(VRender);
	VRender.EndScene();//glEnd();
	end;
end;

function SGPoint2fToVertex3f(const Point:SGPoint):SGVertex3f;inline;
begin
Result.Import(Point.x,Point.y,0);
end;

operator * (const a:SGColor;const b:real):SGColor;inline;
begin
Result.SetVariables(a.r*b,a.g*b,a.b*b,a.a*b);
end;

function SGColorImport(const r1:real = 0;const g1:real = 0;const b1:real = 0;const a1:real = 1):SGColor;inline;
begin
Result.SetVariables(r1,g1,b1,a1);
end;

function SGPoint2fToVertex2f(const Point:SGPoint):SGVertex2f;inline;
begin
Result.Import(Point.x,Point.y);
end;

procedure TSGVertex2f.Import(const x1:real = 0;const y1:real = 0);inline;
begin
x:=x1;
y:=y1;
end;

procedure TSGPoint2f.Vertex(const VRender:TSGRender);inline;
begin
VRender.Vertex2f(x,y);
end;

procedure TSGColor3f.Normalize();inline;
var
	kk:single;
begin
kk:=SGAbsTwoVertex(NilVertex,SGVertexImport(r,g,b));
r/=kk;
g/=kk;
b/=kk;
end;

procedure TSGVertex3f.Normalize();inline;
var
	vabs:real;
begin
vabs:=SGAbsTwoVertex(Self,NilVertex);
x/=vabs;
y/=vabs;
z/=vabs;
end;

procedure TSGVertex3f.Vertex(const VRender:TSGRender;Const P:Pointer);inline;
begin
if p=nil then
	VRender.Vertex3f(x,y,z)
else
	TSGShodowVertexProcedure(p)(x,y,z);
end;

function TSGColor4f.AddAlpha(const NewAlpha:real = 1):TSGColor4f;inline;
begin
a*=NewAlpha;
Result:=Self;
end;

function SGComplexNumberImport(const x:real = 0;const y:real = 0):TSGComplexNumber;inline;
begin
Result.Import(x,y);
end;

function SGVertex2fImport(const x:real = 0;const y:real = 0):TSGVertex2f;inline;
begin
Result.Import(x,y);
end;

operator - (const a,b:TSGComplexNumber):TSGComplexNumber;inline;
begin
Result.Import(a.x-b.x,a.y-b.y);
end;

operator / (const a,b:TSGComplexNumber):TSGComplexNumber;inline;
begin
Result.Import(
	(a.x*b.x+a.y*b.y)/(b.x*b.x-b.y*b.y),
	(a.y*b.x-a.x*b.y)/(b.x*b.x-b.y*b.y));
end;

operator * (const a,b:TSGComplexNumber):TSGComplexNumber;inline;overload;
begin
result.Import(a.x*b.x-a.y*b.y,a.x*b.y+b.x*a.y);
end;

operator + (const a,b:TSGComplexNumber):TSGComplexNumber;inline;
begin
Result.Import(a.x+b.x,a.y+b.y);
end;

function SGVertex2fToPoint2f(const Vertex:TSGVertex2f):TSGPoint2f;inline;
begin
Result.Import(
	Round(Vertex.X),
	Round(Vertex.Y));
end;

procedure SGQuickRePlaceVertexType(var LongInt1,LongInt2:TSGVertexType);inline;
var
	a:TSGVertexType;
begin
a:=LongInt1;
LongInt1:=LongInt2;
LongInt2:=a;
end;

operator ** (const a:TSGComplexNumber;const b:LongInt):TSGComplexNumber;inline;overload;
var
	i:LongInt;
begin
Result.Import(1,0);
for i:=1 to b do
	Result*=a;
end;


function TSGScreenVertexes.AbsX:TSGVertexType;inline;
begin
Result:=Abs(X1-X2);
end;

function TSGScreenVertexes.AbsY:TSGVertexType;inline;
begin
Result:=Abs(Y1-Y2);
end;

function TSGScreenVertexes.VertexInView(const Vertex:TSGVertex2f):Boolean;inline;
begin
Result:=(Vertex.x<SGMax(X1,X2)) and 
	(Vertex.y<SGMax(Y1,Y2)) and 
	(Vertex.x>SGMin(X1,X2)) and 
	(Vertex.y>SGMin(Y1,Y2));
end;

operator + (const a,b:SGColor):SGColor;inline;
begin
Result.r:=a.r+b.r;
Result.g:=a.g+b.g;
Result.b:=a.b+b.b;
Result.a:=a.a+b.a;
end;

operator - (const a,b:SGColor):SGColor;inline;
begin
Result.r:=a.r-b.r;
Result.g:=a.g-b.g;
Result.b:=a.b-b.b;
Result.a:=a.a-b.a;
end;

operator * (const a:TSGColor3f;const b:real):SGColor;inline;overload;
begin
Result.r:=a.r*b;
Result.g:=a.g*b;
Result.b:=a.b*b;
end;

operator / (const a:TSGColor3f;const b:real):SGColor;inline;overload;
begin
Result.r:=a.r/b;
Result.g:=a.g/b;
Result.b:=a.b/b;
end;

operator / (const a:SGColor;const b:real):SGColor;inline;overload;
begin
Result.r:=a.r/b;
Result.g:=a.g/b;
Result.b:=a.b/b;
Result.a:=a.a/b;
end;

function SGGetColor4fFromLongWord(const LongWordColor:LongWord;const WithAlpha:Boolean = False):SGColor4f;inline;
type
	LongWordByteArray = packed array [0..3] of byte;
begin
if WithAlpha then
	begin
	Result.Import(
		LongWordByteArray(LongWordColor)[3]/255,
		LongWordByteArray(LongWordColor)[2]/255,
		LongWordByteArray(LongWordColor)[1]/255,
		LongWordByteArray(LongWordColor)[0]/255);
	
	end
else
	begin
	Result.Import(
		LongWordByteArray(LongWordColor)[2]/255,
		LongWordByteArray(LongWordColor)[1]/255,
		LongWordByteArray(LongWordColor)[0]/255,
		1);
	end;
end;

function SGPoint2fImport(const x1:extended = 0; const y1:extended = 0):TSGPoint2f;overload;inline;
begin
Result.x:=Round(x1);
Result.y:=Round(y1);
end;

function SGPoint2fImport(const x1:int64 = 0; const y1:int64 = 0):TSGPoint2f;overload;inline;
begin
Result.x:=x1;
Result.y:=y1;
end;

procedure TSGVertex2f.Round;inline;overload;
begin
x:=System.Round(x);
y:=System.Round(y);
end;

procedure TSGColor4f.Import(const r1:real = 0; const g1:real = 0; const b1:real = 0;const a1:real = 1);inline;
begin
r:=r1;
b:=b1;
g:=g1;
a:=a1;
end;

function TSGColor4f.WithAlpha(const NewAlpha:real = 1):TSGColor4f;inline;
begin
Result:=Self;
Result.a*=NewAlpha;
end;

procedure TSGVertex3f.Translate(const VRender:TSGRender);inline;
begin
VRender.Translatef(x,y,z);
end;

procedure TSGVertex2f.Translate(const VRender:TSGRender);inline;
begin
VRender.Translatef(x,y,0);
end;

procedure TSGVertex3f.ReadFromTextFile(const Fail:PTextFile);inline;
begin
Read(Fail^,x,y,z);
end;

procedure TSGVertex3f.ReadLnFromTextFile(const Fail:PTextFile);inline;
begin
ReadFromTextFile(Fail);
ReadLn(Fail^);
end;

operator = (const a,b:TSGComplexNumber):Boolean;overload;inline;
begin
Result:=(a.x=b.x) and (b.y=a.y);
end;

operator * (const b:real;const a:SGVertex2f):SGVertex2f;overload;inline;
begin
Result.Import(a.x*b,a.y*b);
end;

operator / (const b:real;const a:SGVertex2f):SGVertex2f;overload;inline;
begin
Result.Import(b/a.x,b/a.y);
end;

operator * (const b:extended;const a:SGColor):SGColor;inline;overload;
begin
Result.Import(a.r*b,a.g*b,a.b*b,a.a*b);
end;

operator * (const a:SGColor;const b:byte):SGColor;inline;overload;
begin
Result.Import(a.r*b,a.g*b,a.b*b,a.a*b);
end;

operator * (const a:SGColor;const b:longint):SGColor;inline;overload;
begin
Result.Import(a.r*b,a.g*b,a.b*b,a.a*b);
end;

operator * (const a:SGColor;const b:int64):SGColor;inline;overload;
begin
Result.Import(a.r*b,a.g*b,a.b*b,a.a*b);
end;

operator * (const b:byte;const a:SGColor):SGColor;inline;overload;
begin
Result.Import(a.r*b,a.g*b,a.b*b,a.a*b);
end;

operator * (const b:longint;const a:SGColor):SGColor;inline;overload;
begin
Result.Import(a.r*b,a.g*b,a.b*b,a.a*b);
end;

operator * (const b:int64;const a:SGColor):SGColor;inline;overload;
begin
Result.Import(a.r*b,a.g*b,a.b*b,a.a*b);
end;

procedure TSGPoint3f.Vertex(const VRender:TSGRender);inline;
begin
VRender.Vertex3f(x,y,z);
end;

procedure TSGPoint3f.Import(const x1:LongInt = 0;const x2:LongInt = 0;const x3:LongInt = 0);inline;
begin
x:=x1;
y:=x2;
z:=x3;
end;

function SGGetPointsCirclePoints(const FPoints:TArTSGVertex2f):TSGArLongWord;

function GetNext(const p1,p2:LongWord):LongWord;
var
	a2,// квадрат альфа
	b2,//квадрат бетта
	TemCos,//Косиеус сейчас
	MinCos,//Охуенный косинус, который нада найти
	a:single;
	i:LongWord;

begin
MinCos:=1;
Result:=Length(FPoints);
a2:=(sqr(FPoints[p1].x-FPoints[p2].x)+sqr(FPoints[p1].y-FPoints[p2].y));
a:=sqrt(a2);
for i:=0 to High(FPoints) do
	if (i<>p1) and (i<>p2) then
		begin
		b2:=(sqr(FPoints[i].x-FPoints[p2].x)+sqr(FPoints[i].y-FPoints[p2].y));
		TemCos:=((sqr(FPoints[i].x-FPoints[p1].x)+sqr(FPoints[i].y-FPoints[p1].y))-a2-b2)/(-2*a*sqrt(b2));
		if (TemCos<MinCos) then
			begin
			Result:=i;
			MinCos:=TemCos;
			end;
		end;
if Result=Length(FPoints) then
	raise  Exception.Create('Ebat ti loh!!!');
end;

vAR
	I,ii:LongWord;
begin
SetLength(Result,2);
Result[0]:=0;
Result[1]:=1;
repeat
ii:=GetNext(Result[High(Result)-1],Result[High(Result)]);
SetLength(Result,Length(Result)+1);
Result[High(Result)]:=ii;
ii:=0;
for i:=1 to High(Result)-2 do
	begin
	if (Result[i]=Result[High(Result)])  and (Result[i-1]=Result[High(Result)-1])then
		begin
		ii:=1;
		break;
		end;
	end;
until (ii=1);
for ii:=i+1 to High(Result) do
	begin
	Result[ii-i-1]:=Result[ii];
	end;
SetLength(Result,Length(Result)-i-1);
end;


operator + (const a:SGVertex2f;const b:TSGVertexType):SGVertex2f;overload;inline;
begin
Result.Import(a.x+b,a.y+b);
end;

operator - (const a:SGVertex2f;const b:TSGVertexType):SGVertex2f;overload;inline;
begin
Result.Import(a.x-b,a.y-b);
end;

function SGTSGVertex3fImport(const x:real = 0;const y:real = 0;const z:real = 0):TSGVertex3f;inline;
begin
Result.x:=x;
Result.y:=y;
Result.z:=z;
end;

function SGGetVertexInAttitude(const t1,t2:TSGVertex3f; const r:real = 0.5):TSGVertex3f;inline;
begin
Result.SetVariables(
	-r*(t1.x-t2.x)+t1.x,
	-r*(t1.y-t2.y)+t1.y,
	-r*(t1.z-t2.z)+t1.z);
end;


function SGGetVertexOnIntersectionOfTwoLinesFromFourVertex(const q1,q2,w1,w2:SGVertex):SGVertex;inline;
var
	q3:SGVertex;
begin
q3:=q2;
q3+=SGGetVertexWhichNormalFromThreeVertex(q1,q2,w1);
Result:=SGGetVertexOnIntersectionOfThreePlane(
	SGGetPlaneFromThreeVertex(q1,q2,q3),
	SGGetPlaneFromThreeVertex(SGGetVertexInAttitude(q1,q2),w1,w2),
	SGGetPlaneFromThreeVertex(SGGetVertexInAttitude(q1,q3),w1,w2));
end;

function SGGetPlaneFromThreeVertex(const a1,a2,a3:SGVertex):SGPlane;inline;
begin
Result:=SGGetPlaneFromNineReals(a1.x,a1.y,a1.z,a2.x,a2.y,a2.z,a3.x,a3.y,a3.z);
end;

procedure SGPoint.Import(const x1:longint = 0; const y1:longint = 0);inline;
begin
x:=x1;
y:=y1;
end;

operator + (const a,b:SGPoint):SGPoint;inline;
begin
Result.x:=a.x+b.x;
Result.y:=a.y+b.y;
end;

operator - (const a,b:SGPoint):SGPoint;inline;
begin
Result.x:=a.x-b.x;
Result.y:=a.y-b.y;
end;

procedure TSGColor3f.Color(const VRender:TSGRender);inline;
begin
SetColor(VRender);
end;

procedure TSGColor3f.SetColor(const VRender:TSGRender);inline;
begin
VRender.Color3f(r,g,b);
end;

procedure TSGColor3f.Import(const r1: single; const g1: single; const b1: single);inline;
begin
  r:=r1;
  g:=g1;
  b:=b1;
end;

function SGGetVertexWhichNormalFromThreeVertex(const p1,p2,p3:SGVertex):SGVertex;inline;
var a,b,c:real;
begin
a:=p1.y*(p2.z-p3.z)+p2.y*(p3.z-p1.z)+p3.y*(p1.z-p2.z);
b:=p1.z*(p2.x-p3.x)+p2.z*(p3.x-p1.x)+p3.z*(p1.x-p2.x);
c:=p1.x*(p2.y-p3.y)+p2.x*(p3.y-p1.y)+p3.x*(p1.y-p2.y);
Result.Import(a/(sqrt(a*a+b*b+c*c)),b/(sqrt(a*a+b*b+c*c)),c/(sqrt(a*a+b*b+c*c)));
end;

function SGPointImport(const NewX:LongInt = 0; const NewY:LongInt = 0 ):SGPoint;inline;
begin
Result.x:=NewX;
Result.y:=NewY;
end;

function SGPointImport(const NewX:Real = 0; const NewY:Real = 0 ):SGPoint;inline;
begin
Result.x:=Round(NewX);
Result.y:=Round(NewY);
end;

procedure TSGVertex3f.Import(const x1:real = 0; const y1:real = 0; const z1:real = 0);inline;
begin
x:=x1;
y:=y1;
z:=z1;
end;

function SGVertexImport(const x:real = 0;const y:real = 0;const z:real = 0):TSGVertex3f;inline;
begin
Result.x:=x;
Result.y:=y;
Result.z:=z;
end;

operator / (const a:SGVertex;const b:real):SGVertex;inline;
begin
Result.x:=a.x/b;
Result.y:=a.y/b;
Result.z:=a.z/b;
end;

operator * (const a:SGVertex;const b:real):SGVertex;inline;
begin
Result.x:=a.x*b;
Result.y:=a.y*b;
Result.z:=a.z*b;
end;



operator - (const a,b:SGVertex):SGVertex;inline;
begin
Result.x:=a.x-b.x;
Result.y:=a.y-b.y;
Result.z:=a.z-b.z;
end;

operator + (const a,b:SGVertex):SGVertex;inline;
begin
Result.x:=a.x+b.x;
Result.y:=a.y+b.y;
Result.z:=a.z+b.z;
end;

function SGAbsTwoVertex(const Vertex1:SGVertex;const Vertex2:SGVertex):TSGSingle;inline;
begin
Result:=sqrt(sqr(Vertex1.x-Vertex2.x)+sqr(Vertex1.y-Vertex2.y)+sqr(Vertex1.z-Vertex2.z));
end;

function SGTreugPlosh(const a1,a2,a3:SGVertex):real;inline;
var
	p:real;
begin
p:=(SGAbsTwoVertex(a1,a2)+SGAbsTwoVertex(a1,a3)+SGAbsTwoVertex(a3,a2))/2;
SGTreugPlosh:=sqrt(p*(p-SGAbsTwoVertex(a1,a2))*(p-SGAbsTwoVertex(a3,a2))*(p-SGAbsTwoVertex(a1,a3)));
end;

function SGVertexOnQuad(const Vertex:SGVertex; const QuadVertex1:SGVertex;const QuadVertex3:SGVertex):boolean;inline;
begin
Result:=SGVertexOnQuad(
	Vertex,
	QuadVertex1,
	SGVertexImport(
		QuadVertex1.x,
		QuadVertex3.y,
		QuadVertex1.z),
	QuadVertex3,
	SGVertexImport(
		QuadVertex3.x,
		QuadVertex1.y,
		QuadVertex3.z));
end;

function SGVertexOnQuad(const Vertex:SGVertex; const QuadVertex1:SGVertex;const QuadVertex2:SGVertex;const QuadVertex3:SGVertex;const QuadVertex4:SGVertex):boolean;inline;
begin
if abs(
	(SGAbsTwoVertex(QuadVertex1,QuadVertex2)*SGAbsTwoVertex(QuadVertex2,QuadVertex3))
	-
	(
		SGTreugPlosh(Vertex,QuadVertex1,QuadVertex2)+
		SGTreugPlosh(Vertex,QuadVertex2,QuadVertex3)+
		SGTreugPlosh(Vertex,QuadVertex3,QuadVertex4)+
		SGTreugPlosh(Vertex,QuadVertex4,QuadVertex1))
	)>SGZero then
	Result:=False
else
	Result:=True;
end;

function SGGetVertexOnIntersectionOfThreePlane(p1,p2,p3:SGPlane):SGVertex;inline;
var de,de1,de2,de3:real;
begin
p1.d:=-1*(p1.d);
p2.d:=-1*(p2.d);
p3.d:=-1*(p3.d);
de:=SGGetMatrix3x3(p1.a,p1.b,p1.c,p2.a,p2.b,p2.c,p3.a,p3.b,p3.c);
de1:=SGGetMatrix3x3(p1.d,p1.b,p1.c,p2.d,p2.b,p2.c,p3.d,p3.b,p3.c);
de2:=SGGetMatrix3x3(p1.a,p1.d,p1.c,p2.a,p2.d,p2.c,p3.a,p3.d,p3.c);
de3:=SGGetMatrix3x3(p1.a,p1.b,p1.d,p2.a,p2.b,p2.d,p3.a,p3.b,p3.d);
Result.Import(de1/de,de2/de,de3/de);
end;

procedure TSGPoint2f.Write;inline;
begin
writeln(x,' ',y);
end;


function Random(const lx,ly:LongWord):TSGPoint2f;overload;inline;
begin
Result.Import(Random(lx),Random(ly));
end;

operator := (const a:TSGPoint2f):TSGVertex2f;overload;inline;
begin
Result.Import(a.x,a.y); 
end;

operator * (const a,b:TSGVertex2f):TSGVertex2f;overload;inline;
begin
Result.Import(a.x*b.x,a.y*b.y);
end;

operator * (const a:TSGPoint2f;const b:real):TSGVertex2f;overload;inline;
begin
Result.x:=a.x*b;
Result.y:=a.y*b;
end;

operator + (const a:TSGPoint2f;const b:integer):TSGPoint2f;overload;inline;
begin
Result.Import(a.x+b,a.y+b);
end;

operator + (const a:TSGVertex2f;const b:TSGPoint2f):TSGVertex2f;overload;inline;
begin
Result.Import(a.x+b.x,a.y+b.y);
end;

operator - (const a,b:TSGVertex2f):TSGVertex2f;overload;inline;
begin
Result.x:=a.x-b.x;
Result.y:=a.y-b.y;
end;

operator - (const a:TSGVertex2f):TSGVertex2f;overload;inline;
begin
Result.x:=-a.x;
Result.y:=-a.y;
end;

operator * (const a:SGVertex2f;const b:real):SGVertex2f;overload;inline;
begin
Result.Import(a.x*b,a.y*b);
end;

operator / (const a:SGVertex2f;const b:real):SGVertex2f;overload;inline;
begin
Result.Import(a.x/b,a.y/b);
end;

operator = (const a,b:TSGPoint2f):Boolean;overload;inline;
begin
Result:=(a.x=b.x) and (a.y=b.y);
end;

operator = (const a,b:TSGVertex3f):Boolean;overload;inline;
begin
Result:=(Abs(a.x-b.x)+Abs(a.y-b.y)+Abs(a.z-b.z))<SGZero;
end;

operator / (const a:SGPoint;const b:Int64):SGPoint;overload;inline;
begin
Result:=a div b;
end;

operator div (const a:SGPoint;const b:Int64):SGPoint;overload;inline;
begin
Result.x:=a.x div b;
Result.y:=a.y div b;
end;

procedure TSGColor3f.ReadFromStream(const Stream:TStream);inline;
begin
Stream.ReadBuffer(Self,SizeOf(r)*3);
end;

procedure TSGColor3f.WriteToStream(const Stream:TStream);inline;
begin
Stream.WriteBuffer(Self,SizeOf(r)*3);
end;

procedure TSGColor4f.ReadFromStream(const Stream:TStream);inline;
begin
Stream.ReadBuffer(Self,SizeOf(r)*4);
end;

procedure TSGColor4f.WriteToStream(const Stream:TStream);inline;
begin
Stream.WriteBuffer(Self,SizeOf(r)*4);
end;

operator - (const a:TSGVertex):TSGVertex;overload;inline;
begin
Result.x:=-a.x;
Result.y:=-a.y;
Result.z:=-a.z;
end;

operator * (const b:real;const a:SGVertex):SGVertex;inline;overload;
begin
Result:=a*b;
end;

function SGX(const v:Single):TSGVertex3f;inline;
begin
Result.Import(v,0,0);
end;

function SGY(const v:Single):TSGVertex3f;inline;
begin
Result.Import(0,v,0);
end;

function SGZ(const v:Single):TSGVertex3f;inline;
begin
Result.Import(0,0,v);
end;

procedure TSGVertex2f.SetVariables(const x1:real = 0; const y1:real = 0);inline;
begin
x:=x1;
y:=y1;
end;

procedure TSGVertex3f.SetVariables(const x1:real = 0; const y1:real = 0; const z1:real = 0);inline;
begin
x:=x1;
y:=y1;
z:=z1;
end;

procedure TSGColor4f.SetVariables(const r1:real = 0; const g1:real = 0; const b1:real = 0; const a1:real = 1);inline;
begin
r:=r1;
g:=g1;
b:=b1;
a:=a1;
end;

procedure TSGVertex2f.TexCoord(const VRender:TSGRender);inline;
begin
VRender.TexCoord2f(x,y);
end;

procedure TSGColor4f.SetColor(const VRender:TSGRender);inline;
begin
Color(VRender);
end;

procedure TSGColor4f.Color(const VRender:TSGRender);inline;
begin
VRender.Color4f(r,g,b,a);
end;

procedure TSGVertex2f.Vertex(const VRender:TSGRender);inline;
begin
VRender.Vertex2f(x,y);
end;

procedure TSGVertex3f.Vertex(const VRender:TSGRender);inline;
begin
VRender.Vertex3f(x,y,z);
end;



end.
