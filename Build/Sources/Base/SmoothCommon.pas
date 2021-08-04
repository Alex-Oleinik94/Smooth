{$INCLUDE Smooth.inc}

{$DEFINE COMMON_FLOAT32}
//{$DEFINE COMMON_FLOAT64}
{$IFNDEF WITHOUT_EXTENDED}
	//{$DEFINE COMMON_FLOAT80}
	{$ENDIF}

unit SmoothCommon;

interface

uses
	 SmoothBase
	,SmoothLists
	,SmoothArithmeticUtils
	,SmoothCommonStructs
	;

type
{$IFDEF COMMON_FLOAT80}
	TSCommonFloat = TSFloat80;
	TSCommonVector2 = TSVector2e;
	TSCommonVector3 = TSVector3e;
	TSCommonVector4 = TSVector4e;
{$ELSE  COMMON_FLOAT80}
{$IFDEF COMMON_FLOAT64}
	TSCommonFloat = TSFloat64;
	TSCommonVector2 = TSVector2d;
	TSCommonVector3 = TSVector3d;
	TSCommonVector4 = TSVector4d;
{$ELSE  COMMON_FLOAT64}
	TSCommonFloat = TSFloat32;
	TSCommonVector2 = TSVector2f;
	TSCommonVector3 = TSVector3f;
	TSCommonVector4 = TSVector4f;
{$ENDIF COMMON_FLOAT64}
{$ENDIF COMMON_FLOAT80}
type
	TSScreenVerticesFloat = TSFloat64;
	TSScreenVerticesVector2 = TSVector2d;
	TSScreenVertices = object
			public
		function Create (const x1 : TSScreenVerticesFloat = 0; const y1 : TSScreenVerticesFloat = 0; const x2 : TSScreenVerticesFloat = 0; const y2 : TSScreenVerticesFloat = 0) : TSScreenVertices; static;
			private
		Vertices : array[0..1] of TSScreenVerticesVector2;
			public
		procedure Import(const x1 : TSScreenVerticesFloat = 0; const y1 : TSScreenVerticesFloat = 0; const x2 : TSScreenVerticesFloat = 0; const y2 : TSScreenVerticesFloat = 0);
		procedure Write();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ProcSumX(r : TSScreenVerticesFloat);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ProcSumY(r : TSScreenVerticesFloat);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function VectorInView(const Vector : TSScreenVerticesVector2) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AbsX() : TSScreenVerticesFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AbsY() : TSScreenVerticesFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property SumX : TSScreenVerticesFloat write ProcSumX;
		property SumY : TSScreenVerticesFloat write ProcSumY;
		property X1   : TSScreenVerticesFloat read  Vertices[0].x write Vertices[0].x;
		property Y1   : TSScreenVerticesFloat read  Vertices[0].y write Vertices[0].y;
		property X2   : TSScreenVerticesFloat read  Vertices[1].x write Vertices[1].x;
		property Y2   : TSScreenVerticesFloat read  Vertices[1].y write Vertices[1].y;
		end;

operator * (const a : TSScreenVertices; const b : TSScreenVerticesFloat) : TSScreenVertices;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

type
	TSCustomPosition = record
		case byte of
		0: (FLocation : TSCommonVector3; FTurn   : TSCommonVector3);
		1: (X, Y, Z   : TSCommonFloat;   A, B, G : TSCommonFloat);
		end;
	
	PSPosition = ^ TSPosition;
	TSPosition = object
			protected
		FPosition : TSCustomPosition;
			public
		property x         : TSCommonFloat    read FPosition.x         write FPosition.x;
		property y         : TSCommonFloat    read FPosition.y         write FPosition.y;
		property z         : TSCommonFloat    read FPosition.z         write FPosition.z;
		property a         : TSCommonFloat    read FPosition.a         write FPosition.a;
		property b         : TSCommonFloat    read FPosition.b         write FPosition.b;
		property g         : TSCommonFloat    read FPosition.g         write FPosition.g;
		property Location  : TSCommonVector3  read FPosition.FLocation write FPosition.FLocation;
		property Turn      : TSCommonVector3  read FPosition.FTurn     write FPosition.FTurn;
		property Position  : TSCustomPosition read FPosition           write FPosition;
		end;

operator + (const a, b : TSPosition) : TSPosition;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator + (const a, b : TSCustomPosition) : TSCustomPosition;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

type
	TSMathFloat = TSFloat64;

function SComputeDeterminantMatrix2x2(const m00, m01, m10, m11 : TSMathFloat) : TSMathFloat;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SComputeDeterminantMatrix3x3(const m1, m2, m3, m4, m5, m6, m7, m8, m9 : TSMathFloat) : TSMathFloat;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}

type
	PSPlane3D = ^ TSPlane3D;
	TSPlane3D  = object
			public
		a, b, c, d : TSMathFloat;
			public
		procedure Import(const a1 : TSMathFloat = 0; const b1 : TSMathFloat = 0; const c1 : TSMathFloat = 0; const d1 : TSMathFloat = 0);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		procedure Write();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		end;

function SPlane3DFrom3Points(const x1, y1, z1, x2, y2, z2, x0, y0, z0 : TSMathFloat) : TSPlane3D;{$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;
function SPlane3DFrom2VectorsAndPoint(const x1, y1, z1, x2, y2, z2, x0, y0, z0 : TSMathFloat) : TSPlane3D;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}

function SCosSinAngle(const Cosinus, Sinus : TSMathFloat) : TSMathFloat; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGetPointsCirclePoints(const FPoints:TSVertex2fList):TSUInt32List;

Procedure SRotatePoint(Var Xp, Yp, Zp: TSSingle;const Xv, Yv, Zv, Angle: TSSingle); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SRotatePoint(const Point : TSVertex3f; const Os : TSVertex3f; const Angle : TSSingle):TSVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

function SColor4fFromUInt32(const Number : TSUInt32; const WithAlpha : TSBool = False): TSColor4f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SPlane3DFrom3Points(const Point1, Point2, Point3 : TSCommonVector3) : TSPlane3D;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SZ(const Z : TSCommonFloat) : TSCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SY(const Y : TSCommonFloat) : TSCommonVector2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SX(const X : TSCommonFloat) : TSCommonVector2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function S2LinesIntersectionVector(const Line1Point1, Line1Point2, Line2Point1, Line2Point2 : TSCommonVector3) : TSCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function S2LinesIntersectionVector(const Line1Point1, Line1Point2, Line2Point1, Line2Point2 : TSCommonVector2) : TSCommonVector2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function S3PlaneIntersectionVector(const p1, p2, p3 : TSPlane3D): TSCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function STriangleNormal(const Point1, Point2, Point3 : TSCommonVector3) : TSCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SVectorInAttitude(const t1, t2 : TSCommonVector3; const r : TSCommonFloat = 0.5) : TSCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function STriangleSize(const a,b,c:TSVertex3f):TSFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function STriangleSize(const a,b,c:TSVertex2f):TSFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function STriangleSize(const a,b,c:TSFloat)   :TSFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

function SIsVectorOnQuad(const Vector, QuadVector1, QuadVector3 : TSCommonVector3) : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SIsVectorOnQuad(const Vector, QuadVector1, QuadVector2, QuadVector3, QuadVector4: TSCommonVector3) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SIsVertexOnTriangle(const t1, t2, t3, v : TSCommonVector2; const Zero : TSCommonFloat = SZero):TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SIsVertexOnTriangle(const t1, t2, t3, v : TSCommonVector3; const Zero : TSCommonFloat = SZero):TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SIsVertexOnLine(const t1, t2, v : TSCommonVector3; const Zero : TSCommonFloat = SZero) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SIsVertexOnLine(const t1, t2, v : TSCommonVector2; const Zero : TSCommonFloat = SZero) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SIsVertexOnLine(const t1, t2, v : TSCommonFloat;   const Zero : TSCommonFloat = SZero) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

function SIsTriangleConvex(const v1, v2, v3 : TSCommonVector3) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SIsTriangleConvex(const v1, v2, v3 : TSCommonFloat  ) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

function SCosSinAngle(const Coodrs : TSCommonVector2) : TSCommonFloat; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

function SPoint2int32ToVertex3f(const Point : TSPoint2int32):TSVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SStrVector3f(const Vector : TSVector3f; const Numbers : TSByte = 6) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SColor4fTo4uint8(const Color : TSVector4f) : TSVector4uint8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

operator + (const a : TSVertex2f; const b : TSVertex2int32) : TSVertex2f; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 Crt
	,Math
	,SysUtils
	
	,SmoothRenderBase
	,SmoothStringUtils
	;

function SCosSinAngle(const Cosinus, Sinus : TSMathFloat) : TSMathFloat; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Cosinus = -1 then
	Result := PI
else if Cosinus = 1 then
	Result := 0
else if Sinus = -1 then
	Result := 3 * PI / 2
else if Sinus = 1 then
	Result := PI / 2
else if Sinus > SZero then
	Result := ArcCos(Cosinus)
else
	Result := ArcCos(- Cosinus) + PI;
end;

function SPlane3DFrom2VectorsAndPoint(const x1, y1, z1, x2, y2, z2, x0, y0, z0 : TSMathFloat) : TSPlane3D;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := SPlane3DFrom3Points(
	x0,      y0,      z0,
	x0 + x1, y0 + y1, z0 + z1,
	x0 + x2, y0 + y2, z0 + z2);
end;

function SPlane3DFrom3Points(const x1, y1, z1, x2, y2, z2, x0, y0, z0 : TSMathFloat) : TSPlane3D;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result.Import(
	+ SComputeDeterminantMatrix2x2(y1 - y0, z1 - z0, y2 - y0, z2 - z0),
	- SComputeDeterminantMatrix2x2(x1 - x0, z1 - z0, x2 - x0, z2 - z0),
	+ SComputeDeterminantMatrix2x2(x1 - x0, y1 - y0, x2 - x0, y2 - y0),
	- x0 * SComputeDeterminantMatrix2x2(y1 - y0, z1 - z0, y2 - y0, z2 - z0)
	+ y0 * SComputeDeterminantMatrix2x2(x1 - x0, z1 - z0, x2 - x0, z2 - z0)
	- z0 * SComputeDeterminantMatrix2x2(x1 - x0, y1 - y0, x2 - x0, y2 - y0))
	;
end;

procedure TSPlane3D.Import(const a1 : TSMathFloat = 0; const b1 : TSMathFloat = 0; const c1 : TSMathFloat = 0; const d1 : TSMathFloat = 0);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
a := a1;
b := b1;
c := c1;
d := d1;
end;

procedure TSPlane3D.Write();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
System.Write(a:0:10, ' ', b:0:10, ' ', c:0:10, ' ', d:0:10);
end;

function SComputeDeterminantMatrix3x3(const m1, m2, m3, m4, m5, m6, m7, m8, m9 : TSMathFloat) : TSMathFloat;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := 
	  m1 * SComputeDeterminantMatrix2x2(m5, m6, m8, m9)
	- m2 * SComputeDeterminantMatrix2x2(m4, m6, m7, m9)
	+ m3 * SComputeDeterminantMatrix2x2(m4, m5, m7, m8)
	;
end;

function SComputeDeterminantMatrix2x2(const m00, m01, m10, m11 : TSMathFloat) : TSMathFloat;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := m00 * m11 - m01 * m10;
end;

operator + (const a : TSVertex2f; const b : TSVertex2int32) : TSVertex2f; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(a.x + b.x, a.y + b.y);
end;

function SColor4fTo4uint8(const Color : TSVector4f) : TSVector4uint8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function Convert(const Value : TSFloat32) : TSByte; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (Value >= 1) then
	Result := 255
else if (Value > 0) then
	Result := Round(Value * 255)
else
	Result := 0;
end;

begin
Result.x := Convert(Color.x);
Result.y := Convert(Color.y);
Result.z := Convert(Color.z);
Result.w := Convert(Color.w);
end;

function SStrVector3f(const Vector : TSVector3f; const Numbers : TSByte = 6) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := '(' + SStrReal(Vector.x, Numbers) + ', ' + SStrReal(Vector.y, Numbers) + ', ' + SStrReal(Vector.z, Numbers) + ')';
end;

function SPoint2int32ToVertex3f(const Point : TSPoint2int32):TSVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(Point.x, Point.y);
end;

function SCosSinAngle(const Coodrs : TSCommonVector2) : TSCommonFloat; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := SCosSinAngle(Coodrs.x, Coodrs.y);
end;

function SIsTriangleConvex(const v1, v2, v3 : TSCommonFloat):TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	sv1, sv2, sv3 : TSCommonFloat;
begin
sv1 := Sqr(v1);
sv2 := Sqr(v2);
sv3 := Sqr(v3);
Result :=
	(sv1 < sv2 + sv3) and
	(sv2 < sv1 + sv3) and
	(sv3 < sv2 + sv1);
end;

function SIsTriangleConvex(const v1, v2, v3 : TSCommonVector3) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SIsTriangleConvex(Abs(v3 - v2), Abs(v3 - v1), Abs(v1 - v2));
end;

function SIsVertexOnLine(const t1,t2,v : TSCommonFloat;    const Zero : TSCommonFloat = SZero) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	l : TSCommonFloat;
begin
l := Abs(t2-t1);
Result := Abs(l - Abs(t1 - v) - Abs(t2 - v)) < Zero * l;
end;

function SIsVertexOnLine(const t1, t2, v : TSCommonVector3; const Zero : TSCommonFloat = SZero) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	l : TSCommonFloat;
begin
l := Abs(t2-t1);
Result := Abs(l - Abs(t1 - v) - Abs(t2 - v)) < Zero * l;
end;

function SIsVertexOnLine(const t1, t2, v : TSCommonVector2; const Zero : TSCommonFloat = SZero) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	l : TSCommonFloat;
begin
l := Abs(t2-t1);
Result := Abs(l - Abs(t1-v) - Abs(t2-v)) < Zero * l;
end;

function SIsVertexOnTriangle(const t1, t2, t3, v : TSCommonVector2; const Zero : TSCommonFloat = SZero):TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	t1t2, t2t3, t3t1, vt1, vt2, vt3, s: TSCommonFloat;
begin
Result := SIsVertexOnLine(t1, t2, v) or SIsVertexOnLine(t1, t3, v) or SIsVertexOnLine(t3, t2, v);
if not Result then
	begin
	t1t2 := Abs(t1 - t2);
	t2t3 := Abs(t2 - t3);
	t3t1 := Abs(t3 - t1);

	vt1 := Abs(v - t1);
	vt2 := Abs(v - t2);
	vt3 := Abs(v - t3);

	s := STriangleSize(t1t2, t2t3, t3t1);

	Result := Abs(
		  s
		- STriangleSize(t1t2, vt1, vt2)
		- STriangleSize(t2t3, vt3, vt2)
		- STriangleSize(t3t1, vt1, vt3)
			) < Zero * s;
	end;
end;

function SIsVertexOnTriangle(const t1, t2, t3, v : TSCommonVector3; const Zero : TSCommonFloat = SZero):TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	t1t2, t2t3, t3t1, vt1, vt2, vt3, s: TSCommonFloat;
begin
Result := SIsVertexOnLine(t1, t2, v) or SIsVertexOnLine(t1, t3, v) or SIsVertexOnLine(t3, t2, v);
if not Result then
	begin
	t1t2 := Abs(t1 - t2);
	t2t3 := Abs(t2 - t3);
	t3t1 := Abs(t3 - t1);

	vt1 := Abs(v - t1);
	vt2 := Abs(v - t2);
	vt3 := Abs(v - t3);

	s := STriangleSize(t1t2, t2t3, t3t1);

	Result := Abs(
		  s
		- STriangleSize(t1t2, vt1, vt2)
		- STriangleSize(t2t3, vt3, vt2)
		- STriangleSize(t3t1, vt1, vt3)
			) < Zero * s;
	end;
end;

function STriangleSize(const a,b,c:TSFloat)   :TSFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	p : TSFloat;
begin
p := (a + b + c) / 2;
Result := sqrt(p*(p-a)*(p-b)*(p-c));
end;

function STriangleSize(const a, b, c:TSVertex2f):TSFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := STriangleSize(Abs(a - c), Abs(c - b), Abs(b - a));
end;

function STriangleSize(const a, b, c:TSVertex3f) : TSFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := STriangleSize(Abs(a - c), Abs(c - b), Abs(b - a));
end;

Procedure SRotatePoint(Var Xp, Yp, Zp: TSSingle;const Xv, Yv, Zv, Angle: TSSingle); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
var
	Temp, TempV, Nx, Ny, Nz: TSSingle;
	C, S : TSSingle;
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

function SRotatePoint(const Point : TSVertex3f; const Os : TSVertex3f; const Angle : TSSingle):TSVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Point;
SRotatePoint (Result.x, Result.y, Result.z, Os.x, Os.y, Os.z, Angle);
end;

operator + (const a, b : TSPosition) : TSPosition; overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Position := a.Position + b.Position;
end;

operator + (const a, b : TSCustomPosition) : TSCustomPosition;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.FLocation := a.FLocation + b.FLocation;
Result.FTurn     := a.FTurn     + b.FTurn;
end;

procedure TSScreenVertices.ProcSumX(r : TSScreenVerticesFloat);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Vertices[0].x += r;
Vertices[1].x += r;
end;

procedure TSScreenVertices.ProcSumY(r : TSScreenVerticesFloat);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Vertices[0].y += r;
Vertices[1].y += r;
end;

procedure TSScreenVertices.Write;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Vertices[0].Write();
System.Write(' ');
Vertices[1].WriteLn();
end;

operator * (const a:TSScreenVertices; const b : TSScreenVerticesFloat):TSScreenVertices;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
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

function TSScreenVertices.Create (const x1 : TSScreenVerticesFloat = 0; const y1 : TSScreenVerticesFloat = 0; const x2 : TSScreenVerticesFloat = 0; const y2 : TSScreenVerticesFloat = 0) : TSScreenVertices;
begin
Result.Import(x1, y1, x2, y2);
end;

procedure TSScreenVertices.Import(const x1 : TSScreenVerticesFloat = 0; const y1 : TSScreenVerticesFloat = 0; const x2 : TSScreenVerticesFloat = 0; const y2 : TSScreenVerticesFloat = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Vertices[0].x := x1;
Vertices[0].y := y1;
Vertices[1].x := x2;
Vertices[1].y := y2;
end;

function TSScreenVertices.AbsX() : TSScreenVerticesFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Abs(X1 - X2);
end;

function TSScreenVertices.AbsY() : TSScreenVerticesFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Abs(Y1 - Y2);
end;

function TSScreenVertices.VectorInView(const Vector : TSScreenVerticesVector2) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=
	(Vector.x < Max(X1, X2)) and
	(Vector.y < Max(Y1, Y2)) and
	(Vector.x > Min(X1, X2)) and
	(Vector.y > Min(Y1, Y2));
end;

function SColor4fFromUInt32(const Number : TSUInt32; const WithAlpha : TSBool = False): TSColor4f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
type
	TSUInt8List4 = packed array [0..3] of TSUInt8;
begin
if WithAlpha then
	Result.Import(
		TSUInt8List4(Number)[3] / 255,
		TSUInt8List4(Number)[2] / 255,
		TSUInt8List4(Number)[1] / 255,
		TSUInt8List4(Number)[0] / 255)
else
	Result.Import(
		TSUInt8List4(Number)[2] / 255,
		TSUInt8List4(Number)[1] / 255,
		TSUInt8List4(Number)[0] / 255,
		1);
end;

function SGetPointsCirclePoints(const FPoints:TSVertex2fList):TSUInt32List;

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

function SVectorInAttitude(const t1, t2 : TSCommonVector3; const r : TSCommonFloat = 0.5) : TSCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(
	- r * (t1.x - t2.x) + t1.x,
	- r * (t1.y - t2.y) + t1.y,
	- r * (t1.z - t2.z) + t1.z);
end;

function S2LinesIntersectionVector(const Line1Point1, Line1Point2, Line2Point1, Line2Point2 : TSCommonVector2) : TSCommonVector2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := S2LinesIntersectionVector(
	TSCommonVector3.Create(Line1Point1.x, Line1Point1.y),
	TSCommonVector3.Create(Line1Point2.x, Line1Point2.y),
	TSCommonVector3.Create(Line2Point1.x, Line2Point1.y),
	TSCommonVector3.Create(Line2Point2.x, Line2Point2.y));
end;

function S2LinesIntersectionVector(const Line1Point1, Line1Point2, Line2Point1, Line2Point2 : TSCommonVector3) : TSCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Point : TSCommonVector3;
begin
Point := Line1Point2;
Point += STriangleNormal(Line1Point1, Line1Point2, Line2Point1);
Result := S3PlaneIntersectionVector(
	SPlane3DFrom3Points(Line1Point1, Line1Point2, Point),
	SPlane3DFrom3Points(SVectorInAttitude(Line1Point1, Line1Point2), Line2Point1, Line2Point2),
	SPlane3DFrom3Points(SVectorInAttitude(Line1Point1, Point),       Line2Point1, Line2Point2));
end;

function SPlane3DFrom3Points(const Point1, Point2, Point3 : TSCommonVector3) : TSPlane3D;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SPlane3DFrom3Points(Point1.x, Point1.y, Point1.z, Point2.x, Point2.y, Point2.z, Point3.x, Point3.y, Point3.z);
end;

function STriangleNormal(const Point1, Point2, Point3 : TSCommonVector3) : TSCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(
	Point1.y*(Point2.z-Point3.z)+Point2.y*(Point3.z-Point1.z)+Point3.y*(Point1.z-Point2.z),
	Point1.z*(Point2.x-Point3.x)+Point2.z*(Point3.x-Point1.x)+Point3.z*(Point1.x-Point2.x),
	Point1.x*(Point2.y-Point3.y)+Point2.x*(Point3.y-Point1.y)+Point3.x*(Point1.y-Point2.y));
Result := Result.Normalized();
end;

function SIsVectorOnQuad(const Vector, QuadVector1, QuadVector3 : TSCommonVector3) : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := SIsVectorOnQuad(
	Vector,
	QuadVector1,
	SVertex3fImport(
		QuadVector1.x,
		QuadVector3.y,
		QuadVector1.z),
	QuadVector3,
	SVertex3fImport(
		QuadVector3.x,
		QuadVector1.y,
		QuadVector3.z));
end;

function SIsVectorOnQuad(const Vector, QuadVector1, QuadVector2, QuadVector3, QuadVector4: TSCommonVector3) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Abs(
	(Abs(QuadVector1 - QuadVector2) * Abs(QuadVector2 - QuadVector3))
	- (
		STriangleSize(Vector, QuadVector1, QuadVector2)+
		STriangleSize(Vector, QuadVector2, QuadVector3)+
		STriangleSize(Vector, QuadVector3, QuadVector4)+
		STriangleSize(Vector, QuadVector4, QuadVector1))
	) < SZero;
end;

function S3PlaneIntersectionVector(const p1, p2, p3 : TSPlane3D): TSCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	de, de1, de2, de3 : TSMathFloat;
	p1_d, p2_d, p3_d : TSMathFloat;
begin
p1_d := - p1.d;
p2_d := - p2.d;
p3_d := - p3.d;
de   := SComputeDeterminantMatrix3x3(p1.a, p1.b, p1.c, p2.a, p2.b, p2.c, p3.a, p3.b, p3.c);
de1  := SComputeDeterminantMatrix3x3(p1_d, p1.b, p1.c, p2_d, p2.b, p2.c, p3_d, p3.b, p3.c);
de2  := SComputeDeterminantMatrix3x3(p1.a, p1_d, p1.c, p2.a, p2_d, p2.c, p3.a, p3_d, p3.c);
de3  := SComputeDeterminantMatrix3x3(p1.a, p1.b, p1_d, p2.a, p2.b, p2_d, p3.a, p3.b, p3_d);
Result.Import(de1 / de, de2 / de, de3 / de);
end;

function SX(const X : TSCommonFloat) : TSCommonVector2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(X, 0);
end;

function SY(const Y : TSCommonFloat) : TSCommonVector2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(0, Y);
end;

function SZ(const Z : TSCommonFloat) : TSCommonVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(0, 0, Z);
end;

end.
