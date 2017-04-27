{$INCLUDE SaGe.inc}

{$DEFINE COMMON_FLOAT32}
//{$DEFINE COMMON_FLOAT64}
{$IFNDEF WITHOUT_EXTENDED}
	//{$DEFINE COMMON_FLOAT80}
	{$ENDIF}

unit SaGeCommon;

interface

uses
	 SaGeBase
	,SaGeMathUtils
	,SaGeCommonStructs
	;

type
{$IFDEF COMMON_FLOAT80}
	TSGCommonFloat = TSGFloat80;
	TSGCommonVector2 = TSGVector2e;
	TSGCommonVector3 = TSGVector3e;
	TSGCommonVector4 = TSGVector4e;
{$ELSE  COMMON_FLOAT80}
{$IFDEF COMMON_FLOAT64}
	TSGCommonFloat = TSGFloat64;
	TSGCommonVector2 = TSGVector2d;
	TSGCommonVector3 = TSGVector3d;
	TSGCommonVector4 = TSGVector4d;
{$ELSE  COMMON_FLOAT64}
	TSGCommonFloat = TSGFloat32;
	TSGCommonVector2 = TSGVector2f;
	TSGCommonVector3 = TSGVector3f;
	TSGCommonVector4 = TSGVector4f;
{$ENDIF COMMON_FLOAT64}
{$ENDIF COMMON_FLOAT80}
type
	TSGScreenVertexes = object
			private
		Vertexes : array[0..1] of TSGCommonVector2;
			public
		procedure Import(const x1 : TSGCommonFloat = 0; const y1 : TSGCommonFloat = 0; const x2 : TSGCommonFloat = 0; const y2 : TSGCommonFloat = 0);
		procedure Write();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ProcSumX(r : TSGCommonFloat);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ProcSumY(r : TSGCommonFloat);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function VectorInView(const Vector : TSGCommonVector2) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AbsX() : TSGCommonFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AbsY() : TSGCommonFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property SumX : TSGCommonFloat write ProcSumX;
		property SumY : TSGCommonFloat write ProcSumY;
		property X1   : TSGCommonFloat read  Vertexes[0].x write Vertexes[0].x;
		property Y1   : TSGCommonFloat read  Vertexes[0].y write Vertexes[0].y;
		property X2   : TSGCommonFloat read  Vertexes[1].x write Vertexes[1].x;
		property Y2   : TSGCommonFloat read  Vertexes[1].y write Vertexes[1].y;
		end;

operator * (const a : TSGScreenVertexes; const b : TSGCommonFloat) : TSGScreenVertexes;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

type
	TSGCustomPosition = record
		case byte of
		0: (FLocation : TSGCommonVector3; FTurn   : TSGCommonVector3);
		1: (X, Y, Z   : TSGCommonFloat;   A, B, G : TSGCommonFloat);
		end;
	
	PSGPosition = ^ TSGPosition;
	TSGPosition = object
			protected
		FPosition : TSGCustomPosition;
			public
		property x         : TSGCommonFloat    read FPosition.x         write FPosition.x;
		property y         : TSGCommonFloat    read FPosition.y         write FPosition.y;
		property z         : TSGCommonFloat    read FPosition.z         write FPosition.z;
		property a         : TSGCommonFloat    read FPosition.a         write FPosition.a;
		property b         : TSGCommonFloat    read FPosition.b         write FPosition.b;
		property g         : TSGCommonFloat    read FPosition.g         write FPosition.g;
		property Location  : TSGCommonVector3  read FPosition.FLocation write FPosition.FLocation;
		property Turn      : TSGCommonVector3  read FPosition.FTurn     write FPosition.FTurn;
		property Position  : TSGCustomPosition read FPosition           write FPosition;
		end;

operator + (const a, b : TSGPosition) : TSGPosition;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator + (const a, b : TSGCustomPosition) : TSGCustomPosition;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGGetArrayOfRoundQuad(const Vertex1,Vertex3: TSGVertex3f; const Radius:real; const Interval:LongInt):TSGVertex3fList;
function SGGetPointsCirclePoints(const FPoints:TSGVertex2fList):TSGUInt32List;

function SGRotatePoint(const Point : TSGVertex3f; const Os : TSGVertex3f; const Angle : TSGSingle):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGColor4fFromUInt32(const Number : TSGUInt32; const WithAlpha : TSGBool = False): TSGColor4f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGPlane3DFrom3Points(const Point1, Point2, Point3 : TSGCommonVector3) : TSGPlane3D;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SGZ(const Z : TSGCommonFloat) : TSGCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGY(const Y : TSGCommonFloat) : TSGCommonVector2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGX(const X : TSGCommonFloat) : TSGCommonVector2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGTwoLinesIntersectionVector(const Line1Point1, Line1Point2, Line2Point1, Line2Point2 : TSGCommonVector3) : TSGCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGThreePlaneIntersectionVector(const p1, p2, p3 : TSGPlane3D): TSGCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGTriangleNormal(const Point1, Point2, Point3 : TSGCommonVector3) : TSGCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGVectorInAttitude(const t1, t2 : TSGCommonVector3; const r : TSGCommonFloat = 0.5) : TSGCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGTriangleSize(const a,b,c:TSGVertex3f):TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGTriangleSize(const a,b,c:TSGVertex2f):TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGTriangleSize(const a,b,c:TSGFloat)   :TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

function SGIsVectorOnQuad(const Vector, QuadVector1, QuadVector3 : TSGCommonVector3) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SGIsVectorOnQuad(const Vector, QuadVector1, QuadVector2, QuadVector3, QuadVector4: TSGCommonVector3) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SGIsVertexOnTriangle(const t1, t2, t3, v : TSGCommonVector2; const Zero : TSGCommonFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsVertexOnTriangle(const t1, t2, t3, v : TSGCommonVector3; const Zero : TSGCommonFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsVertexOnLine(const t1, t2, v : TSGCommonVector3; const Zero : TSGCommonFloat = SGZero) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsVertexOnLine(const t1, t2, v : TSGCommonVector2; const Zero : TSGCommonFloat = SGZero) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsVertexOnLine(const t1, t2, v : TSGCommonFloat;   const Zero : TSGCommonFloat = SGZero) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

function SGIsTriangleConvex(const v1, v2, v3 : TSGCommonVector3) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsTriangleConvex(const v1, v2, v3 : TSGCommonFloat  ) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

function SGCosSinAngle(const Coodrs : TSGCommonVector2) : TSGCommonFloat; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

function SGPoint2int32ToVertex3f(const Point : TSGPoint2int32):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGStrVector3f(const Vector : TSGVector3f; const Numbers : TSGByte = 6) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 Crt
	,Math
	,SysUtils
	
	,SaGeRenderBase
	,SaGeStringUtils
	;

function SGStrVector3f(const Vector : TSGVector3f; const Numbers : TSGByte = 6) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := '(' + SGStrReal(Vector.x, Numbers) + ', ' + SGStrReal(Vector.y, Numbers) + ', ' + SGStrReal(Vector.z, Numbers) + ')';
end;

function SGPoint2int32ToVertex3f(const Point : TSGPoint2int32):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(Point.x, Point.y);
end;

function SGCosSinAngle(const Coodrs : TSGCommonVector2) : TSGCommonFloat; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := SGCosSinAngle(Coodrs.x, Coodrs.y);
end;

function SGIsTriangleConvex(const v1, v2, v3 : TSGCommonFloat):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	sv1, sv2, sv3 : TSGCommonFloat;
begin
sv1 := Sqr(v1);
sv2 := Sqr(v2);
sv3 := Sqr(v3);
Result :=
	(sv1 < sv2 + sv3) and
	(sv2 < sv1 + sv3) and
	(sv3 < sv2 + sv1);
end;

function SGIsTriangleConvex(const v1, v2, v3 : TSGCommonVector3) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SGIsTriangleConvex(Abs(v3 - v2), Abs(v3 - v1), Abs(v1 - v2));
end;

function SGIsVertexOnLine(const t1,t2,v : TSGCommonFloat;    const Zero : TSGCommonFloat = SGZero) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	l : TSGCommonFloat;
begin
l := Abs(t2-t1);
Result := Abs(l - Abs(t1 - v) - Abs(t2 - v)) < Zero * l;
end;

function SGIsVertexOnLine(const t1, t2, v : TSGCommonVector3; const Zero : TSGCommonFloat = SGZero) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	l : TSGCommonFloat;
begin
l := Abs(t2-t1);
Result := Abs(l - Abs(t1 - v) - Abs(t2 - v)) < Zero * l;
end;

function SGIsVertexOnLine(const t1, t2, v : TSGCommonVector2; const Zero : TSGCommonFloat = SGZero) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	l : TSGCommonFloat;
begin
l := Abs(t2-t1);
Result := Abs(l - Abs(t1-v) - Abs(t2-v)) < Zero * l;
end;

function SGIsVertexOnTriangle(const t1, t2, t3, v : TSGCommonVector2; const Zero : TSGCommonFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	t1t2, t2t3, t3t1, vt1, vt2, vt3, s: TSGCommonFloat;
begin
Result := SGIsVertexOnLine(t1, t2, v) or SGIsVertexOnLine(t1, t3, v) or SGIsVertexOnLine(t3, t2, v);
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

function SGIsVertexOnTriangle(const t1, t2, t3, v : TSGCommonVector3; const Zero : TSGCommonFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	t1t2, t2t3, t3t1, vt1, vt2, vt3, s: TSGCommonFloat;
begin
Result := SGIsVertexOnLine(t1, t2, v) or SGIsVertexOnLine(t1, t3, v) or SGIsVertexOnLine(t3, t2, v);
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

function SGTriangleSize(const a, b, c:TSGVertex2f):TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SGTriangleSize(Abs(a - c), Abs(c - b), Abs(b - a));
end;

function SGTriangleSize(const a, b, c:TSGVertex3f) : TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SGTriangleSize(Abs(a - c), Abs(c - b), Abs(b - a));
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

operator + (const a, b : TSGPosition) : TSGPosition; overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Position := a.Position + b.Position;
end;

operator + (const a, b : TSGCustomPosition) : TSGCustomPosition;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.FLocation := a.FLocation + b.FLocation;
Result.FTurn     := a.FTurn     + b.FTurn;
end;

procedure TSGScreenVertexes.ProcSumX(r : TSGCommonFloat);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Vertexes[0].x += r;
Vertexes[1].x += r;
end;

procedure TSGScreenVertexes.ProcSumY(r : TSGCommonFloat);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Vertexes[0].y += r;
Vertexes[1].y += r;
end;

procedure TSGScreenVertexes.Write;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Vertexes[0].Write();
System.Write(' ');
Vertexes[1].WriteLn();
end;

operator * (const a:TSGScreenVertexes; const b : TSGCommonFloat):TSGScreenVertexes;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
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

procedure TSGScreenVertexes.Import(const x1 : TSGCommonFloat = 0; const y1 : TSGCommonFloat = 0; const x2 : TSGCommonFloat = 0; const y2 : TSGCommonFloat = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Vertexes[0].x := x1;
Vertexes[0].y := y1;
Vertexes[1].x := x2;
Vertexes[1].y := y2;
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

function TSGScreenVertexes.AbsX() : TSGCommonFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Abs(X1 - X2);
end;

function TSGScreenVertexes.AbsY() : TSGCommonFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Abs(Y1 - Y2);
end;

function TSGScreenVertexes.VectorInView(const Vector : TSGCommonVector2) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=
	(Vector.x < Max(X1, X2)) and
	(Vector.y < Max(Y1, Y2)) and
	(Vector.x > Min(X1, X2)) and
	(Vector.y > Min(Y1, Y2));
end;

function SGColor4fFromUInt32(const Number : TSGUInt32; const WithAlpha : TSGBool = False): TSGColor4f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
type
	TSGUInt8List4 = packed array [0..3] of TSGUInt8;
begin
if WithAlpha then
	Result.Import(
		TSGUInt8List4(Number)[3] / 255,
		TSGUInt8List4(Number)[2] / 255,
		TSGUInt8List4(Number)[1] / 255,
		TSGUInt8List4(Number)[0] / 255)
else
	Result.Import(
		TSGUInt8List4(Number)[2] / 255,
		TSGUInt8List4(Number)[1] / 255,
		TSGUInt8List4(Number)[0] / 255,
		1);
end;

function SGGetPointsCirclePoints(const FPoints:TSGVertex2fList):TSGUInt32List;

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

function SGVectorInAttitude(const t1, t2 : TSGCommonVector3; const r : TSGCommonFloat = 0.5) : TSGCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(
	- r * (t1.x - t2.x) + t1.x,
	- r * (t1.y - t2.y) + t1.y,
	- r * (t1.z - t2.z) + t1.z);
end;

function SGTwoLinesIntersectionVector(const Line1Point1, Line1Point2, Line2Point1, Line2Point2 : TSGCommonVector3) : TSGCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Point : TSGCommonVector3;
begin
Point := Line1Point2;
Point += SGTriangleNormal(Line1Point1, Line1Point2, Line2Point1);
Result := SGThreePlaneIntersectionVector(
	SGPlane3DFrom3Points(Line1Point1, Line1Point2, Point),
	SGPlane3DFrom3Points(SGVectorInAttitude(Line1Point1, Line1Point2), Line2Point1, Line2Point2),
	SGPlane3DFrom3Points(SGVectorInAttitude(Line1Point1, Point),       Line2Point1, Line2Point2));
end;

function SGPlane3DFrom3Points(const Point1, Point2, Point3 : TSGCommonVector3) : TSGPlane3D;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGPlane3DFrom3Points(Point1.x, Point1.y, Point1.z, Point2.x, Point2.y, Point2.z, Point3.x, Point3.y, Point3.z);
end;

function SGTriangleNormal(const Point1, Point2, Point3 : TSGCommonVector3) : TSGCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(
	Point1.y*(Point2.z-Point3.z)+Point2.y*(Point3.z-Point1.z)+Point3.y*(Point1.z-Point2.z),
	Point1.z*(Point2.x-Point3.x)+Point2.z*(Point3.x-Point1.x)+Point3.z*(Point1.x-Point2.x),
	Point1.x*(Point2.y-Point3.y)+Point2.x*(Point3.y-Point1.y)+Point3.x*(Point1.y-Point2.y));
Result := Result.Normalized();
end;

function SGIsVectorOnQuad(const Vector, QuadVector1, QuadVector3 : TSGCommonVector3) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := SGIsVectorOnQuad(
	Vector,
	QuadVector1,
	SGVertex3fImport(
		QuadVector1.x,
		QuadVector3.y,
		QuadVector1.z),
	QuadVector3,
	SGVertex3fImport(
		QuadVector3.x,
		QuadVector1.y,
		QuadVector3.z));
end;

function SGIsVectorOnQuad(const Vector, QuadVector1, QuadVector2, QuadVector3, QuadVector4: TSGCommonVector3) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Abs(
	(Abs(QuadVector1 - QuadVector2) * Abs(QuadVector2 - QuadVector3))
	- (
		SGTriangleSize(Vector, QuadVector1, QuadVector2)+
		SGTriangleSize(Vector, QuadVector2, QuadVector3)+
		SGTriangleSize(Vector, QuadVector3, QuadVector4)+
		SGTriangleSize(Vector, QuadVector4, QuadVector1))
	) < SGZero;
end;

function SGThreePlaneIntersectionVector(const p1, p2, p3 : TSGPlane3D): TSGCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	de, de1, de2, de3 : TSGMathFloat;
	p1_d, p2_d, p3_d : TSGMathFloat;
begin
p1_d := - p1.d;
p2_d := - p2.d;
p3_d := - p3.d;
de   := SGComputeDeterminantMatrix3x3(p1.a, p1.b, p1.c, p2.a, p2.b, p2.c, p3.a, p3.b, p3.c);
de1  := SGComputeDeterminantMatrix3x3(p1_d, p1.b, p1.c, p2_d, p2.b, p2.c, p3_d, p3.b, p3.c);
de2  := SGComputeDeterminantMatrix3x3(p1.a, p1_d, p1.c, p2.a, p2_d, p2.c, p3.a, p3_d, p3.c);
de3  := SGComputeDeterminantMatrix3x3(p1.a, p1.b, p1_d, p2.a, p2.b, p2_d, p3.a, p3.b, p3_d);
Result.Import(de1 / de, de2 / de, de3 / de);
end;

function SGX(const X : TSGCommonFloat) : TSGCommonVector2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(X, 0);
end;

function SGY(const Y : TSGCommonFloat) : TSGCommonVector2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(0, Y);
end;

function SGZ(const Z : TSGCommonFloat) : TSGCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(0, 0, Z);
end;

end.
