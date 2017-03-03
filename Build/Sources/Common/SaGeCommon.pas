{$INCLUDE SaGe.inc}

unit SaGeCommon;

interface

uses
	 SaGeBase
	,SaGeMathUtils
	;

{$DEFINE INC_PLACE_INTERFACE}
{$INCLUDE SaGeCommonStructs.inc}
{$UNDEF INC_PLACE_INTERFACE}

type
	TSGArLongWord = type packed array of LongWord;
	TSGScreenVertexes = object
		Vertexes:array[0..1] of TSGVertex2f;
		procedure Import(const x1:real = 0;const y1:real = 0;const x2:real = 0;const y2:real = 0);
		procedure Write;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ProcSumX(r:Real);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ProcSumY(r:Real);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		property SumX:real write ProcSumX;
		property SumY:real write ProcSumY;
		property X1:TSGFloat32 read Vertexes[0].x write Vertexes[0].x;
		property Y1:TSGFloat32 read Vertexes[0].y write Vertexes[0].y;
		property X2:TSGFloat32 read Vertexes[1].x write Vertexes[1].x;
		property Y2:TSGFloat32 read Vertexes[1].y write Vertexes[1].y;
		function VertexInView(const Vertex:TSGVertex2f):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AbsX:TSGFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AbsY:TSGFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

	TSGVisibleVertex = object(TSGVertex3f)
		Visible : TSGBoolean;
		end;
	TSGVisibleVertexList = packed array of TSGVisibleVertex;
	TSGVisibleVertexFunction = function (a : TSGVisibleVertex; const b : Pointer) : TSGVisibleVertex;
	TSGPointerProcedure = procedure (a : Pointer);
	TSGProcedure = procedure;

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
		property x         : TSGSingle         read FPosition.x         write FPosition.x;
		property y         : TSGSingle         read FPosition.y         write FPosition.y;
		property z         : TSGSingle         read FPosition.z         write FPosition.z;
		property a         : TSGSingle         read FPosition.a         write FPosition.a;
		property b         : TSGSingle         read FPosition.b         write FPosition.b;
		property g         : TSGSingle         read FPosition.g         write FPosition.g;
		property Location  : TSGVertex3f       read FPosition.FLocation write FPosition.FLocation;
		property Turn      : TSGVertex3f       read FPosition.FTurn     write FPosition.FTurn;
		property CustomPos : TSGCustomPosition read FPosition           write FPosition;
		end;

operator * (const a:TSGScreenVertexes;const b:real):TSGScreenVertexes;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

operator + (const a,b:TSGPosition):TSGPosition;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator + (const a,b:TSGCustomPosition):TSGCustomPosition;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGGetVertexInAttitude(const t1,t2:TSGVertex3f; const r:real = 0.5):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGTSGVertex3fImport(const x:real = 0;const y:real = 0;const z:real = 0):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
//procedure SGQuad(const Vertex1: TSGVertex3f;const Vertex2: TSGVertex3f;const Vertex3: TSGVertex3f;const Vertex4: TSGVertex3f);
function SGVertexOnQuad(const Vertex: TSGVertex3f; const QuadVertex1: TSGVertex3f;const QuadVertex2: TSGVertex3f;const QuadVertex3: TSGVertex3f;const QuadVertex4: TSGVertex3f):boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGTreugPlosh(const a1,a2,a3: TSGVertex3f):real;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGVertexOnQuad(const Vertex: TSGVertex3f; const QuadVertex1: TSGVertex3f;const QuadVertex3: TSGVertex3f):boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetVertexOnIntersectionOfThreePlane(p1,p2,p3:TSGPlane3D): TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetVertexWhichNormalFromThreeVertex(const p1,p2,p3: TSGVertex3f): TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetPlaneFromThreeVertex(const a1,a2,a3: TSGVertex3f):TSGPlane3D;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetVertexOnIntersectionOfTwoLinesFromFourVertex(const q1,q2,w1,w2: TSGVertex3f): TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetArrayOfRoundQuad(const Vertex1,Vertex3: TSGVertex3f; const Radius:real; const Interval:LongInt):TSGVertex3fList;
procedure SGQuickRePlaceVertexType(var LongInt1,LongInt2:TSGFloat32); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetColor4fFromLongWord(const LongWordColor:LongWord;const WithAlpha:Boolean = False): TSGColor4f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetPointsCirclePoints(const FPoints:TSGVertex2fList):TSGArLongWord;
function SGX(const v:Single):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGY(const v:Single):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGZ(const v:Single):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGRotatePoint(const Point : TSGVertex3f; const Os : TSGVertex3f; const Angle : TSGSingle):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGTriangleSize(const a,b,c:TSGVertex3f):TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGTriangleSize(const a,b,c:TSGVertex2f):TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGTriangleSize(const a,b,c:TSGFloat)   :TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsVertexOnTriangle(const t1,t2,t3,v:TSGVertex2f; const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsVertexOnTriangle(const t1,t2,t3,v:TSGVertex3f; const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsVertexOnLine(const t1,t2,v : TSGVertex3f; const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsVertexOnLine(const t1,t2,v : TSGVertex2f; const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsVertexOnLine(const t1,t2,v : TSGFloat;    const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGGetNextDynamicArrayIndex(const Index, HighOfArray : TSGLongWord): TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGIsTriangleConvex(const v1,v2,v3:TSGVertex3f):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsTriangleConvex(const v1,v2,v3:TSGFloat):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

function SGGetAngleFromCosSin(const Coodrs : TSGVertex2f):TSGFloat; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGPoint2int32ToVertex3f(const P : TSGPoint2int32):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 Math
	,Crt
	
	,SysUtils
	,SaGeRenderBase
	;

{$DEFINE INC_PLACE_IMPLEMENTATION}
{$INCLUDE SaGeCommonStructs.inc}
{$UNDEF INC_PLACE_IMPLEMENTATION}

function SGPoint2int32ToVertex3f(const P : TSGPoint2int32):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(P.x, P.y);
end;

function SGGetAngleFromCosSin(const Coodrs : TSGVertex2f):TSGFloat; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Coodrs.x = -1 then
	Result := PI
else if Coodrs.x = 1 then
	Result := 0
else if Coodrs.y = -1 then
	Result := 3*PI/2
else if Coodrs.y = 1 then
	Result := PI/2
else if Coodrs.y > SGZero then
	Result := ArcCos(Coodrs.x)
else
	Result := ArcCos(-Coodrs.x) + PI;
end;

function SGIsTriangleConvex(const v1,v2,v3:TSGFloat):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	sv1, sv2, sv3 : TSGFloat;
begin
sv1 := Sqr(v1);
sv2 := Sqr(v2);
sv3 := Sqr(v3);
Result :=
	(sv1 < sv2 + sv3) and
	(sv2 < sv1 + sv3) and
	(sv3 < sv2 + sv1);
end;

function SGIsTriangleConvex(const v1,v2,v3:TSGVertex3f):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SGIsTriangleConvex(Abs(v3-v2),Abs(v3-v1),Abs(v1-v2));
end;

function SGGetNextDynamicArrayIndex(const Index, HighOfArray : TSGLongWord): TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (Index + 1) * Byte(Index <> HighOfArray);
end;

function SGIsVertexOnLine(const t1,t2,v : TSGFloat;    const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	l : TSGFloat;
begin
l := Abs(t2-t1);
Result := Abs(l - Abs(t1-v) - Abs(t2-v)) < Zero * l;
end;

function SGIsVertexOnLine(const t1,t2,v : TSGVertex3f; const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	l : TSGFloat;
begin
l := Abs(t2-t1);
Result := Abs(l - Abs(t1-v) - Abs(t2-v)) < Zero * l;
end;

function SGIsVertexOnLine(const t1,t2,v : TSGVertex2f; const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	l : TSGFloat;
begin
l := Abs(t2-t1);
Result := Abs(l - Abs(t1-v) - Abs(t2-v)) < Zero * l;
end;

function SGIsVertexOnTriangle(const t1,t2,t3,v:TSGVertex2f; const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	t1t2, t2t3, t3t1, vt1, vt2, vt3, s: TSGFloat;
begin
Result := SGIsVertexOnLine(t1,t2,v) or SGIsVertexOnLine(t1,t3,v) or SGIsVertexOnLine(t3,t2,v);
if not Result then
	begin
	t1t2 := Abs(t1 - t2);
	t2t3 := Abs(t2 - t3);
	t3t1 := Abs(t3 - t1);

	vt1 := Abs(v - t1);
	vt2 := Abs(v - t2);
	vt3 := Abs(v - t3);

	s := SGTriangleSize(t1t2, t2t3, t3t1);

	Result := Abs(
		  s
		- SGTriangleSize(t1t2, vt1, vt2)
		- SGTriangleSize(t2t3, vt3, vt2)
		- SGTriangleSize(t3t1, vt1, vt3)
			) < Zero * s;
	end;
end;

function SGIsVertexOnTriangle(const t1,t2,t3,v:TSGVertex3f; const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	t1t2, t2t3, t3t1, vt1, vt2, vt3, s: TSGFloat;
begin
Result := SGIsVertexOnLine(t1,t2,v) or SGIsVertexOnLine(t1,t3,v) or SGIsVertexOnLine(t3,t2,v);
if not Result then
	begin
	t1t2 := Abs(t1 - t2);
	t2t3 := Abs(t2 - t3);
	t3t1 := Abs(t3 - t1);

	vt1 := Abs(v - t1);
	vt2 := Abs(v - t2);
	vt3 := Abs(v - t3);

	s := SGTriangleSize(t1t2, t2t3, t3t1);

	Result := Abs(
		  s
		- SGTriangleSize(t1t2, vt1, vt2)
		- SGTriangleSize(t2t3, vt3, vt2)
		- SGTriangleSize(t3t1, vt1, vt3)
			) < Zero * s;
	end;
end;

function SGTriangleSize(const a,b,c:TSGFloat)   :TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	p : TSGFloat;
begin
p := (a + b + c) / 2;
Result := sqrt(p*(p-a)*(p-b)*(p-c));
end;

function SGTriangleSize(const a,b,c:TSGVertex2f):TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SGTriangleSize(Abs(a-c),Abs(c-b),Abs(b-a));
end;

function SGTriangleSize(const a,b,c:TSGVertex3f):TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SGTriangleSize(Abs(a-c),Abs(c-b),Abs(b-a));
end;

function SGRotatePoint(const Point : TSGVertex3f; const Os : TSGVertex3f; const Angle : TSGSingle):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
Procedure RotatePoint(Var Xp, Yp, Zp: TSGSingle;const Xv, Yv, Zv, Angle: TSGSingle); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Temp, TempV, Nx, Ny, Nz: TSGSingle;
	C, S : TSGSingle;
Begin
C := Cos(Angle);
S := Sin(Angle);
Temp := 1.0 - C;

TempV := Temp * Xv;
Nx:=Xp * (Xv * TempV + C) +
	Yp * (Yv * TempV - S * Zv) +
	Zp * (Zv * TempV + S * Yv);

TempV := Temp * Yv;
Ny:=Xp * (Xv * TempV + S * Zv) +
	Yp * (Yv * TempV + C) +
	Zp * (Zv * TempV - S * Xv);

TempV := Temp * Zv;
Nz:=Xp * (Xv * TempV - S * Yv) +
	Yp * (Yv * TempV + S * Xv) +
	Zp * (Zv * TempV + C);

Xp:=Nx;
Yp:=Ny;
Zp:=Nz;
End;
begin
Result := Point;
RotatePoint (Result.x, Result.y, Result.z, Os.x, Os.y, Os.z, Angle);
end;

operator + (const a,b:TSGPosition):TSGPosition;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.CustomPos := a.CustomPos + b.CustomPos;
end;

operator + (const a,b:TSGCustomPosition):TSGCustomPosition;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.FLocation := a.FLocation + b.FLocation;
Result.FTurn := a.FTurn + b.FTurn;
end;

procedure TSGScreenVertexes.ProcSumX(r:Real);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Vertexes[0].x+=r;
Vertexes[1].x+=r;
end;

procedure TSGScreenVertexes.ProcSumY(r:Real);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Vertexes[0].y+=r;
Vertexes[1].y+=r;
end;

procedure TSGScreenVertexes.Write;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Vertexes[0].Write();
System.Write(' ');
Vertexes[1].WriteLn();
end;

operator * (const a:TSGScreenVertexes;const b:real):TSGScreenVertexes;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
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

procedure TSGScreenVertexes.Import(const x1:real = 0;const y1:real = 0;const x2:real = 0;const y2:real = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Vertexes[0].x:=x1;
Vertexes[0].y:=y1;
Vertexes[1].x:=x2;
Vertexes[1].y:=y2;
end;

function SGGetArrayOfRoundQuad(const Vertex1,Vertex3: TSGVertex3f; const Radius:real; const Interval:LongInt):TSGVertex3fList;
var
	Vertex2,Vertex4: TSGVertex3f;
	VertexR1,VertexR2,VertexR3,VertexR4: TSGVertex3f;
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

function SGVertex2fImport(const x:real = 0;const y:real = 0):TSGVertex2f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(x,y);
end;

procedure SGQuickRePlaceVertexType(var LongInt1,LongInt2:TSGFloat32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	a:TSGFloat32;
begin
a:=LongInt1;
LongInt1:=LongInt2;
LongInt2:=a;
end;

function TSGScreenVertexes.AbsX:TSGFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=Abs(X1-X2);
end;

function TSGScreenVertexes.AbsY:TSGFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=Abs(Y1-Y2);
end;

function TSGScreenVertexes.VertexInView(const Vertex:TSGVertex2f):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=
	(Vertex.x<Max(X1,X2)) and
	(Vertex.y<Max(Y1,Y2)) and
	(Vertex.x>Min(X1,X2)) and
	(Vertex.y>Min(Y1,Y2));
end;

function SGGetColor4fFromLongWord(const LongWordColor:LongWord;const WithAlpha:Boolean = False): TSGColor4f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

function SGGetPointsCirclePoints(const FPoints:TSGVertex2fList):TSGArLongWord;

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
if Result = Length(FPoints) then
	raise Exception.Create('GetNext(const p1,p2:LongWord) : Result = Length(FPoints).');
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

function SGTSGVertex3fImport(const x:real = 0;const y:real = 0;const z:real = 0):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.x:=x;
Result.y:=y;
Result.z:=z;
end;

function SGGetVertexInAttitude(const t1,t2:TSGVertex3f; const r:real = 0.5):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(
	-r*(t1.x-t2.x)+t1.x,
	-r*(t1.y-t2.y)+t1.y,
	-r*(t1.z-t2.z)+t1.z);
end;

function SGGetVertexOnIntersectionOfTwoLinesFromFourVertex(const q1,q2,w1,w2: TSGVertex3f): TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	q3: TSGVertex3f;
begin
q3:=q2;
q3+=SGGetVertexWhichNormalFromThreeVertex(q1,q2,w1);
Result:=SGGetVertexOnIntersectionOfThreePlane(
	SGGetPlaneFromThreeVertex(q1,q2,q3),
	SGGetPlaneFromThreeVertex(SGGetVertexInAttitude(q1,q2),w1,w2),
	SGGetPlaneFromThreeVertex(SGGetVertexInAttitude(q1,q3),w1,w2));
end;

function SGGetPlaneFromThreeVertex(const a1, a2, a3: TSGVertex3f) : TSGPlane3D;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGPlane3DFrom3Points(a1.x, a1.y, a1.z, a2.x, a2.y, a2.z, a3.x, a3.y, a3.z);
end;

function SGGetVertexWhichNormalFromThreeVertex(const p1,p2,p3: TSGVertex3f): TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var a,b,c:real;
begin
a:=p1.y*(p2.z-p3.z)+p2.y*(p3.z-p1.z)+p3.y*(p1.z-p2.z);
b:=p1.z*(p2.x-p3.x)+p2.z*(p3.x-p1.x)+p3.z*(p1.x-p2.x);
c:=p1.x*(p2.y-p3.y)+p2.x*(p3.y-p1.y)+p3.x*(p1.y-p2.y);
Result.Import(a/(sqrt(a*a+b*b+c*c)),b/(sqrt(a*a+b*b+c*c)),c/(sqrt(a*a+b*b+c*c)));
end;

function SGTreugPlosh(const a1,a2,a3: TSGVertex3f):real;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	p:real;
begin
p:=(Abs(a1 - a2)+Abs(a1 - a3)+Abs(a3 - a2))/2;
SGTreugPlosh:=sqrt(p*(p-Abs(a1 - a2))*(p-Abs(a3 - a2))*(p-Abs(a1 - a3)));
end;

function SGVertexOnQuad(const Vertex: TSGVertex3f; const QuadVertex1: TSGVertex3f;const QuadVertex3: TSGVertex3f):boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=SGVertexOnQuad(
	Vertex,
	QuadVertex1,
	SGVertex3fImport(
		QuadVertex1.x,
		QuadVertex3.y,
		QuadVertex1.z),
	QuadVertex3,
	SGVertex3fImport(
		QuadVertex3.x,
		QuadVertex1.y,
		QuadVertex3.z));
end;

function SGVertexOnQuad(const Vertex: TSGVertex3f; const QuadVertex1: TSGVertex3f;const QuadVertex2: TSGVertex3f;const QuadVertex3: TSGVertex3f;const QuadVertex4: TSGVertex3f):boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if abs(
	(Abs(QuadVertex1 - QuadVertex2)*Abs(QuadVertex2 - QuadVertex3))
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

function SGGetVertexOnIntersectionOfThreePlane(p1,p2,p3:TSGPlane3D): TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var de, de1, de2, de3 : TSGMathFloat;
begin
p1.d:=-1*(p1.d);
p2.d:=-1*(p2.d);
p3.d:=-1*(p3.d);
de  := SGComputeDeterminantMatrix3x3(p1.a,p1.b,p1.c,p2.a,p2.b,p2.c,p3.a,p3.b,p3.c);
de1 := SGComputeDeterminantMatrix3x3(p1.d,p1.b,p1.c,p2.d,p2.b,p2.c,p3.d,p3.b,p3.c);
de2 := SGComputeDeterminantMatrix3x3(p1.a,p1.d,p1.c,p2.a,p2.d,p2.c,p3.a,p3.d,p3.c);
de3 := SGComputeDeterminantMatrix3x3(p1.a,p1.b,p1.d,p2.a,p2.b,p2.d,p3.a,p3.b,p3.d);
Result.Import(de1/de,de2/de,de3/de);
end;

function SGX(const v:Single):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(v,0,0);
end;

function SGY(const v:Single):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(0,v,0);
end;

function SGZ(const v:Single):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(0,0,v);
end;

end.
