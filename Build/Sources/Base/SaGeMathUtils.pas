{$INCLUDE SaGe.inc}

unit SaGeMathUtils;

interface

uses
	 SaGeBase
	;

const
	//Используется для вычисления с Эпсилон
	SGZero = 0.0001;
var
	//Несуществующее значение
	Nan : TSGFloat64;
	//Бесконечное значение
	Inf : TSGFloat64;
 
operator ** (const a, b: TSGDouble) 	: TSGDouble; 	{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload; 
operator ** (const a, b: TSGByte) 		: TSGByte; 		{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
operator ** (const a, b: TSGLongWord) 	: TSGInt64;		{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
operator ** (const a, b : TSGLongInt) 	: TSGLongInt;	{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload; 
operator ** (const a, b : TSGSingle) 	: TSGSingle; 	{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

operator ** (const a : TSGReal;     const b : TSGInt32) : TSGReal;       {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
operator ** (const a : TSGSingle;   const b : TSGInt32) : TSGSingle;     {$IFDEF SUPPORTINLINE}inline;{$ENDIF}	overload;
{$IFNDEF WITHOUT_EXTENDED}
operator ** (const a : TSGExtended; const b : TSGInt32) : TSGExtended;   {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
{$ENDIF WITHOUT_EXTENDED}

function Max(const a, b : TSGFloat32) : TSGFloat32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Max(const a, b : TSGFloat64) : TSGFloat64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
{$IFNDEF WITHOUT_EXTENDED}
function Max(const a, b : TSGFloat80) : TSGFloat80; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
{$ENDIF WITHOUT_EXTENDED}
function Max(const a, b : TSGInt8) : TSGInt8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Max(const a, b : TSGUInt8) : TSGUInt8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Max(const a, b : TSGInt16) : TSGInt16; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Max(const a, b : TSGUInt16) : TSGUInt16; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Max(const a, b : TSGInt32) : TSGInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Max(const a, b : TSGUInt32) : TSGUInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Max(const a, b : TSGInt64) : TSGInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Max(const a, b : TSGUInt64) : TSGUInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

function Min(const a, b : TSGFloat32) : TSGFloat32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Min(const a, b : TSGFloat64) : TSGFloat64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
{$IFNDEF WITHOUT_EXTENDED}
function Min(const a, b : TSGFloat80) : TSGFloat80; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
{$ENDIF WITHOUT_EXTENDED}
function Min(const a, b : TSGInt8) : TSGInt8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Min(const a, b : TSGUInt8) : TSGUInt8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Min(const a, b : TSGInt16) : TSGInt16; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Min(const a, b : TSGUInt16) : TSGUInt16; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Min(const a, b : TSGInt32) : TSGInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Min(const a, b : TSGUInt32) : TSGUInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Min(const a, b : TSGInt64) : TSGInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Min(const a, b : TSGUInt64) : TSGUInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

function Log(const a, b : TSGFloat64) : TSGFloat64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGCountSimbolsInNumber(L : TSGInt32) : TSGInt32;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SGRandomOne() : TSGInt8;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}

function SGFloatExists(const F : TSGFloat64) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGFloatsEqual(const F1, F2 : TSGFloat32) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SGFloatsEqual(const F1, F2 : TSGFloat64) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
{$IFNDEF WITHOUT_EXTENDED}
function SGFloatsEqual(const F1, F2 : TSGFloat80) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
{$ENDIF WITHOUT_EXTENDED}

function SGTruncUp(const T : TSGFloat64) : TSGInt32;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
function SGTruncUp(const T : TSGFloat32) : TSGInt32;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
{$IFNDEF WITHOUT_EXTENDED}
function SGTruncUp(const T : TSGFloat80) : TSGInt64;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
{$ENDIF WITHOUT_EXTENDED}

type
	TSGMathFloat = TSGFloat64;

function SGComputeDeterminantMatrix2x2(const m00, m01, m10, m11 : TSGMathFloat) : TSGMathFloat;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SGComputeDeterminantMatrix3x3(const m1, m2, m3, m4, m5, m6, m7, m8, m9 : TSGMathFloat) : TSGMathFloat;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}

type
	PSGPlane3D = ^ TSGPlane3D;
	TSGPlane3D  = object
		a, b, c, d : TSGMathFloat;
		procedure Import(const a1 : TSGMathFloat = 0; const b1 : TSGMathFloat = 0; const c1 : TSGMathFloat = 0; const d1 : TSGMathFloat = 0);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		procedure Write();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		end;

function SGPlane3DFrom3Points(const x1, y1, z1, x2, y2, z2, x0, y0, z0 : TSGMathFloat) : TSGPlane3D;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
//function SGPlane3DFrom2VectorsAndPoint(const x1, y1, z1, x2, y2, z2, x0, y0, z0 : TSGMathFloat) : TSGPlane3D;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}

implementation

uses
	 Math
	
	,SaGeBaseUtils
	;

function SGPlane3DFrom3Points(const x1, y1, z1, x2, y2, z2, x0, y0, z0 : TSGMathFloat) : TSGPlane3D;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result.Import(
	+ SGComputeDeterminantMatrix2x2(y1 - y0, z1 - z0, y2 - y0, z2 - z0),
	- SGComputeDeterminantMatrix2x2(x1 - x0, z1 - z0, x2 - x0, z2 - z0),
	+ SGComputeDeterminantMatrix2x2(x1 - x0, y1 - y0, x2 - x0, y2 - y0),
	- x0 * SGComputeDeterminantMatrix2x2(y1 - y0, z1 - z0, y2 - y0, z2 - z0)
	+ y0 * SGComputeDeterminantMatrix2x2(x1 - x0, z1 - z0, x2 - x0, z2 - z0)
	- z0 * SGComputeDeterminantMatrix2x2(x1 - x0, y1 - y0, x2 - x0, y2 - y0))
	;
end;

function SGRandomOne() : TSGInt8;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if Random(2) = 0 then
	Result := -1
else
	Result := 1;
end;

procedure TSGPlane3D.Import(const a1 : TSGMathFloat = 0; const b1 : TSGMathFloat = 0; const c1 : TSGMathFloat = 0; const d1 : TSGMathFloat = 0);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
a := a1;
b := b1;
c := c1;
d := d1;
end;

procedure TSGPlane3D.Write();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
System.Write(a:0:10, ' ', b:0:10, ' ', c:0:10, ' ', d:0:10);
end;

function SGCountSimbolsInNumber(L : TSGInt32) : TSGInt32;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := 0;
while L <> 0 do
	begin
	Result += 1;
	L := L div 10;
	end;
end;

function SGComputeDeterminantMatrix3x3(const m1, m2, m3, m4, m5, m6, m7, m8, m9 : TSGMathFloat) : TSGMathFloat;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := 
	  m1 * SGComputeDeterminantMatrix2x2(m5, m6, m8, m9)
	- m2 * SGComputeDeterminantMatrix2x2(m4, m6, m7, m9)
	+ m3 * SGComputeDeterminantMatrix2x2(m4, m5, m7, m8)
	;
end;

function SGComputeDeterminantMatrix2x2(const m00, m01, m10, m11 : TSGMathFloat) : TSGMathFloat;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := m00 * m11 - m01 * m10;
end;

function SGFloatExists(const F : TSGFloat64) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := 
	//(TSGUInt64(Nan) <> TSGUInt64(F)) and
	(TSGUInt64(Inf) <> TSGUInt64(F)) and
	(TSGUInt64(-Inf) <> TSGUInt64(F));
end;

function SGFloatsEqual(const F1, F2 : TSGFloat32) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Abs(F1 - F2) <= SGZero;
end;

function SGFloatsEqual(const F1, F2 : TSGFloat64) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Abs(F1 - F2) <= SGZero;
end;

{$IFNDEF WITHOUT_EXTENDED}
function SGFloatsEqual(const F1, F2 : TSGFloat80) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Abs(F1 - F2) <= SGZero;
end;
{$ENDIF WITHOUT_EXTENDED}

function Log(const a, b : TSGFloat64) : TSGFloat64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Ln(b) / Ln(a);
end;

function Max(const a, b : TSGFloat32) : TSGFloat32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

function Max(const a, b : TSGFloat64) : TSGFloat64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

{$IFNDEF WITHOUT_EXTENDED}
function Max(const a, b : TSGFloat80) : TSGFloat80; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;
{$ENDIF WITHOUT_EXTENDED}

function Max(const a, b : TSGInt8) : TSGInt8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

function Max(const a, b : TSGUInt8) : TSGUInt8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

function Max(const a, b : TSGInt16) : TSGInt16; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

function Max(const a, b : TSGUInt16) : TSGUInt16; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

function Max(const a, b : TSGInt32) : TSGInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

function Max(const a, b : TSGUInt32) : TSGUInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

function Max(const a, b : TSGInt64) : TSGInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

function Max(const a, b : TSGUInt64) : TSGUInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

function Min(const a, b : TSGFloat32) : TSGFloat32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

function Min(const a, b : TSGFloat64) : TSGFloat64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

{$IFNDEF WITHOUT_EXTENDED}
function Min(const a, b : TSGFloat80) : TSGFloat80; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;
{$ENDIF WITHOUT_EXTENDED}

function Min(const a, b : TSGInt8) : TSGInt8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

function Min(const a, b : TSGUInt8) : TSGUInt8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

function Min(const a, b : TSGInt16) : TSGInt16; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

function Min(const a, b : TSGUInt16) : TSGUInt16; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

function Min(const a, b : TSGInt32) : TSGInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

function Min(const a, b : TSGUInt32) : TSGUInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

function Min(const a, b : TSGInt64) : TSGInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

function Min(const a, b : TSGUInt64) : TSGUInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

operator ** (const a, b: TSGDouble) 		: TSGDouble; 	{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload; 
begin
Result := Power(a, b);
end;

operator ** (const a, b: TSGByte) 		: TSGByte; 		{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Round(Power(a, b));
end;

operator ** (const a, b: TSGLongWord) 	: TSGInt64;		{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Round(Power(a, b));
end;
 
operator ** (const a : TSGReal; 	const b : TSGLongInt) : TSGReal; 	{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Power(a, b);
end;

{$IFNDEF WITHOUT_EXTENDED}
operator ** (const a : TSGExtended; 	const b : TSGLongInt) : TSGExtended; 	{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Power(a, b);
end;
{$ENDIF WITHOUT_EXTENDED}

operator ** (const a : TSGSingle; 	const b : TSGLongInt) : TSGSingle; 	{$IFDEF SUPPORTINLINE}inline;{$ENDIF}	overload; 
begin
Result := Power(a, b);
end;

operator ** (const a, b : TSGLongInt) 	: TSGLongInt;	{$IFDEF SUPPORTINLINE}inline;{$ENDIF}	overload; 
begin
Result := Round(Power(a, b));
end;

operator ** (const a, b : TSGSingle) 	: TSGSingle; 	{$IFDEF SUPPORTINLINE}inline;{$ENDIF}	overload; 
begin
Result := Power(a, b);
end;

{$IFNDEF WITHOUT_EXTENDED}
function SGTruncUp(const T : TSGFloat80) : TSGInt64;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
begin
Result := Trunc(T) + 1;
end;
{$ENDIF WITHOUT_EXTENDED}

function SGTruncUp(const T : TSGFloat32) : TSGInt32;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
begin
Result := Trunc(T) + 1;
end;

function SGTruncUp(const T : TSGFloat64) : TSGInt32;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
begin
Result := Trunc(T) + 1;
end;

initialization
begin
RandomIze();
Nan := Sqrt(-1);
Inf := 1 / 0;
end;

end.
