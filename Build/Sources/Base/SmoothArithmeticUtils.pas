{$INCLUDE Smooth.inc}

unit SmoothArithmeticUtils;

interface

uses
	 SmoothBase
	;

const
	//Используется для вычисления с допустимой погрешностью
	SZero = 0.0001;
var
	//Несуществующее значение
	Nan : TSFloat64;
	//Бесконечное значение
	Inf : TSFloat64;
 
operator ** (const a, b: TSDouble) 	: TSDouble; 	{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload; 
operator ** (const a, b: TSByte) 		: TSByte; 		{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
operator ** (const a, b: TSLongWord) 	: TSInt64;		{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
operator ** (const a, b : TSLongInt) 	: TSLongInt;	{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload; 
operator ** (const a, b : TSSingle) 	: TSSingle; 	{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

operator ** (const a : TSReal;     const b : TSInt32) : TSReal;       {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
operator ** (const a : TSSingle;   const b : TSInt32) : TSSingle;     {$IFDEF SUPPORTINLINE}inline;{$ENDIF}	overload;
{$IFNDEF WITHOUT_EXTENDED}
operator ** (const a : TSExtended; const b : TSInt32) : TSExtended;   {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
{$ENDIF WITHOUT_EXTENDED}

function Max(const a, b : TSFloat32) : TSFloat32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Max(const a, b : TSFloat64) : TSFloat64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
{$IFNDEF WITHOUT_EXTENDED}
function Max(const a, b : TSFloat80) : TSFloat80; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
{$ENDIF WITHOUT_EXTENDED}
function Max(const a, b : TSInt8) : TSInt8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Max(const a, b : TSUInt8) : TSUInt8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Max(const a, b : TSInt16) : TSInt16; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Max(const a, b : TSUInt16) : TSUInt16; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Max(const a, b : TSInt32) : TSInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Max(const a, b : TSUInt32) : TSUInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Max(const a, b : TSInt64) : TSInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Max(const a, b : TSUInt64) : TSUInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

function Min(const a, b : TSFloat32) : TSFloat32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Min(const a, b : TSFloat64) : TSFloat64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
{$IFNDEF WITHOUT_EXTENDED}
function Min(const a, b : TSFloat80) : TSFloat80; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
{$ENDIF WITHOUT_EXTENDED}
function Min(const a, b : TSInt8) : TSInt8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Min(const a, b : TSUInt8) : TSUInt8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Min(const a, b : TSInt16) : TSInt16; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Min(const a, b : TSUInt16) : TSUInt16; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Min(const a, b : TSInt32) : TSInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Min(const a, b : TSUInt32) : TSUInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Min(const a, b : TSInt64) : TSInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function Min(const a, b : TSUInt64) : TSUInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

function Log(const a, b : TSFloat64) : TSFloat64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SCountSimbolsInNumber(L : TSInt32) : TSInt32;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SRandomOne() : TSInt8;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}

function SFloatExists(const F : TSFloat64) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SFloatsEqual(const F1, F2 : TSFloat32) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SFloatsEqual(const F1, F2 : TSFloat64) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
{$IFNDEF WITHOUT_EXTENDED}
function SFloatsEqual(const F1, F2 : TSFloat80) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
{$ENDIF WITHOUT_EXTENDED}

function STruncUp(const T : TSFloat64) : TSInt32;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
function STruncUp(const T : TSFloat32) : TSInt32;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
{$IFNDEF WITHOUT_EXTENDED}
function STruncUp(const T : TSFloat80) : TSInt64;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
{$ENDIF WITHOUT_EXTENDED}

implementation

uses
	 Math
	
	,SmoothBaseUtils
	;

function SRandomOne() : TSInt8;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if Random(2) = 0 then
	Result := -1
else
	Result := 1;
end;

function SCountSimbolsInNumber(L : TSInt32) : TSInt32;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := 0;
while L <> 0 do
	begin
	Result += 1;
	L := L div 10;
	end;
end;

function SFloatExists(const F : TSFloat64) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := 
	//(TSUInt64(Nan) <> TSUInt64(F)) and
	(TSUInt64(Inf) <> TSUInt64(F)) and
	(TSUInt64(-Inf) <> TSUInt64(F));
end;

function SFloatsEqual(const F1, F2 : TSFloat32) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Abs(F1 - F2) <= SZero;
end;

function SFloatsEqual(const F1, F2 : TSFloat64) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Abs(F1 - F2) <= SZero;
end;

{$IFNDEF WITHOUT_EXTENDED}
function SFloatsEqual(const F1, F2 : TSFloat80) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Abs(F1 - F2) <= SZero;
end;
{$ENDIF WITHOUT_EXTENDED}

function Log(const a, b : TSFloat64) : TSFloat64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Ln(b) / Ln(a);
end;

function Max(const a, b : TSFloat32) : TSFloat32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

function Max(const a, b : TSFloat64) : TSFloat64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

{$IFNDEF WITHOUT_EXTENDED}
function Max(const a, b : TSFloat80) : TSFloat80; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;
{$ENDIF WITHOUT_EXTENDED}

function Max(const a, b : TSInt8) : TSInt8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

function Max(const a, b : TSUInt8) : TSUInt8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

function Max(const a, b : TSInt16) : TSInt16; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

function Max(const a, b : TSUInt16) : TSUInt16; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

function Max(const a, b : TSInt32) : TSInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

function Max(const a, b : TSUInt32) : TSUInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

function Max(const a, b : TSInt64) : TSInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

function Max(const a, b : TSUInt64) : TSUInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a > b, a, b);
end;

function Min(const a, b : TSFloat32) : TSFloat32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

function Min(const a, b : TSFloat64) : TSFloat64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

{$IFNDEF WITHOUT_EXTENDED}
function Min(const a, b : TSFloat80) : TSFloat80; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;
{$ENDIF WITHOUT_EXTENDED}

function Min(const a, b : TSInt8) : TSInt8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

function Min(const a, b : TSUInt8) : TSUInt8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

function Min(const a, b : TSInt16) : TSInt16; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

function Min(const a, b : TSUInt16) : TSUInt16; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

function Min(const a, b : TSInt32) : TSInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

function Min(const a, b : TSUInt32) : TSUInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

function Min(const a, b : TSInt64) : TSInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

function Min(const a, b : TSUInt64) : TSUInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Iff(a < b, a, b);
end;

operator ** (const a, b: TSDouble) 		: TSDouble; 	{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload; 
begin
Result := Power(a, b);
end;

operator ** (const a, b: TSByte) 		: TSByte; 		{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Round(Power(a, b));
end;

operator ** (const a, b: TSLongWord) 	: TSInt64;		{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Round(Power(a, b));
end;
 
operator ** (const a : TSReal; 	const b : TSLongInt) : TSReal; 	{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Power(a, b);
end;

{$IFNDEF WITHOUT_EXTENDED}
operator ** (const a : TSExtended; 	const b : TSLongInt) : TSExtended; 	{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := Power(a, b);
end;
{$ENDIF WITHOUT_EXTENDED}

operator ** (const a : TSSingle; 	const b : TSLongInt) : TSSingle; 	{$IFDEF SUPPORTINLINE}inline;{$ENDIF}	overload; 
begin
Result := Power(a, b);
end;

operator ** (const a, b : TSLongInt) 	: TSLongInt;	{$IFDEF SUPPORTINLINE}inline;{$ENDIF}	overload; 
begin
Result := Round(Power(a, b));
end;

operator ** (const a, b : TSSingle) 	: TSSingle; 	{$IFDEF SUPPORTINLINE}inline;{$ENDIF}	overload; 
begin
Result := Power(a, b);
end;

{$IFNDEF WITHOUT_EXTENDED}
function STruncUp(const T : TSFloat80) : TSInt64;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
begin
Result := Trunc(T) + 1;
end;
{$ENDIF WITHOUT_EXTENDED}

function STruncUp(const T : TSFloat32) : TSInt32;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
begin
Result := Trunc(T) + 1;
end;

function STruncUp(const T : TSFloat64) : TSInt32;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
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
