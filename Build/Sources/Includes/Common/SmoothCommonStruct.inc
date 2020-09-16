{$IFDEF INC_PLACE_INTERFACE}
type
	STRUCT_P_2 = ^ STRUCT_2;
	STRUCT_2 = object
			public
		x, y : STRUCT_TYPE;
			public
		function Create(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0) : STRUCT_2; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload; static;
		procedure Import(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		procedure Write();                                                      {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		procedure WriteLn();                                                    {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		{$IFDEF STRUCT_IS_FLOAT}
			function Round():STRUCT_2;                                          {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
			function Normalized() : STRUCT_2;                                   {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		{$ENDIF STRUCT_IS_FLOAT}
		function FieldsArray() : STRUCT_PTYPE;                                  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property Data : STRUCT_PTYPE read FieldsArray;
		{$IFDEF STRUCT_IS_COLOR}
			property r : STRUCT_TYPE read x write x;
			property g : STRUCT_TYPE read y write y;
		{$ENDIF}
		end;
	
	{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
	STRUCT_P_3 = ^ STRUCT_3;
	STRUCT_3 = object(STRUCT_2)
			public
		z : STRUCT_TYPE;
			public
		function Create(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0;const z1 : STRUCT_TYPE = 0) : STRUCT_3; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload; static;
		procedure Import(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0;const z1 : STRUCT_TYPE = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		procedure Write();                   {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		procedure WriteLn();                 {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		{$IFDEF STRUCT_IS_FLOAT}
			function Round():STRUCT_3;       {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
			function Normalized() : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		{$ENDIF STRUCT_IS_FLOAT}
		{$IFDEF STRUCT_IS_COLOR}
			property b : STRUCT_TYPE read z write z;
			procedure ConvertType();         {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		{$ENDIF STRUCT_IS_COLOR}
		end;
	{$IF    defined(STRUCT_4) and defined(STRUCT_P_4)}
	STRUCT_P_4 = ^ STRUCT_4;
	STRUCT_4 = object(STRUCT_3)
			public
		w : STRUCT_TYPE;
			public
		function Create(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0;const z1 : STRUCT_TYPE = 0;const w1 : STRUCT_TYPE = 0) : STRUCT_4; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload; static;
		procedure Import(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0;const z1 : STRUCT_TYPE = 0;const w1 : STRUCT_TYPE = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		procedure Write();                   {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		procedure WriteLn();                 {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		{$IFDEF STRUCT_IS_FLOAT}
			function Round():STRUCT_4;       {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		{$ENDIF STRUCT_IS_FLOAT}
		{$IFDEF STRUCT_IS_COLOR}
			function WithAlpha(const Alpha : STRUCT_TYPE):STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			procedure AddAlpha(const Alpha : STRUCT_TYPE);         {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			property a : STRUCT_TYPE read w write w;
		{$ENDIF}
		end;
	{$ENDIF defined(STRUCT_4) and defined(STRUCT_P_4)}
	{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
	
	{$IF    defined(STRUCT_2_LIST) and defined(STRUCT_2)}
		{$IF    defined(STRUCT_2_LIST_HELPER)}
		{$DEFINE DATATYPE_LIST_HELPER := STRUCT_2_LIST_HELPER}
		{$ENDIF defined(STRUCT_2_LIST_HELPER)}
		{$DEFINE DATATYPE_LIST        := STRUCT_2_LIST}
		{$DEFINE DATATYPE             := STRUCT_2}
		{$INCLUDE SmoothCommonList.inc}
		{$INCLUDE SmoothCommonListUndef.inc}
	{$ENDIF defined(STRUCT_2_LIST) and defined(STRUCT_2)}
	
	{$IF    defined(STRUCT_3_LIST) and defined(STRUCT_3)}
		{$IF    defined(STRUCT_3_LIST_HELPER)}
		{$DEFINE DATATYPE_LIST_HELPER := STRUCT_3_LIST_HELPER}
		{$ENDIF defined(STRUCT_3_LIST_HELPER)}
		{$DEFINE DATATYPE_LIST        := STRUCT_3_LIST}
		{$DEFINE DATATYPE             := STRUCT_3}
		{$INCLUDE SmoothCommonList.inc}
		{$INCLUDE SmoothCommonListUndef.inc}
	{$ENDIF defined(STRUCT_3_LIST) and defined(STRUCT_3)}
	
	{$IF    defined(STRUCT_4_LIST) and defined(STRUCT_4)}
		{$IF    defined(STRUCT_4_LIST_HELPER)}
		{$DEFINE DATATYPE_LIST_HELPER := STRUCT_4_LIST_HELPER}
		{$ENDIF defined(STRUCT_4_LIST_HELPER)}
		{$DEFINE DATATYPE_LIST        := STRUCT_4_LIST}
		{$DEFINE DATATYPE             := STRUCT_4}
		{$INCLUDE SmoothCommonList.inc}
		{$INCLUDE SmoothCommonListUndef.inc}
	{$ENDIF defined(STRUCT_4_LIST) and defined(STRUCT_4)}

{$IFNDEF INC_WITHOUT_FORWARD}

{$IF    defined(STRUCT_2_IMPORT_FUNC) and defined(STRUCT_2) and defined(STRUCT_TYPE)}
function STRUCT_2_IMPORT_FUNC(const x : STRUCT_TYPE = 0; const y : STRUCT_TYPE = 0):STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$ENDIF defined(STRUCT_2_IMPORT_FUNC) and defined(STRUCT_2) and defined(STRUCT_TYPE)}

{$IF    defined(STRUCT_3_IMPORT_FUNC) and defined(STRUCT_3) and defined(STRUCT_TYPE)}
function STRUCT_3_IMPORT_FUNC(const x : STRUCT_TYPE = 0; const y : STRUCT_TYPE = 0; const z : STRUCT_TYPE = 0):STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$ENDIF defined(STRUCT_3_IMPORT_FUNC) and defined(STRUCT_3) and defined(STRUCT_TYPE)}

{$IF    defined(STRUCT_4_IMPORT_FUNC) and defined(STRUCT_4) and defined(STRUCT_TYPE)}
function STRUCT_4_IMPORT_FUNC(const x : STRUCT_TYPE = 0; const y : STRUCT_TYPE = 0; const z : STRUCT_TYPE = 0; const w : STRUCT_TYPE = 0):STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$ENDIF defined(STRUCT_4_IMPORT_FUNC) and defined(STRUCT_4) and defined(STRUCT_TYPE)}

{$IF    defined(STRUCT_TYPE)}
function Max(const A, B : STRUCT_TYPE) : STRUCT_TYPE;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function Min(const A, B : STRUCT_TYPE) : STRUCT_TYPE;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF defined(STRUCT_TYPE)}

{$IFDEF STRUCT_IS_FLOAT}
function Abs(const S : STRUCT_2):STRUCT_TYPE;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
function Abs(const S : STRUCT_3):STRUCT_TYPE;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ELSE  STRUCT_IS_FLOAT}
function Abs(const S : STRUCT_2):TSFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function Abs(const S : STRUCT_2):TSFloat64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$IFNDEF WITHOUT_EXTENDED}
function Abs(const S : STRUCT_2):TSFloat80;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF WITHOUT_EXTENDED}
{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
function Abs(const S : STRUCT_3):TSFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function Abs(const S : STRUCT_3):TSFloat64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$IFNDEF WITHOUT_EXTENDED}
function Abs(const S : STRUCT_3):TSFloat80;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF WITHOUT_EXTENDED}
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF STRUCT_IS_FLOAT}

{$IF    defined(STRUCT_2)}
operator + (const A, B : STRUCT_2) : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const A, B : STRUCT_2) : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator = (const A, B : STRUCT_2) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const A : STRUCT_2) : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator :=(const A : STRUCT_TYPE) : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator * (const A : STRUCT_TYPE; const B : STRUCT_2) : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator * (const B : STRUCT_2; const A : STRUCT_TYPE) : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$IFDEF STRUCT_IS_FLOAT}
operator / (const B : STRUCT_2; const A : STRUCT_TYPE) : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ELSE  STRUCT_IS_FLOAT}
operator div (const B : STRUCT_2; const A : STRUCT_TYPE) : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF STRUCT_IS_FLOAT}
{$ENDIF defined(STRUCT_2)}

{$IF    defined(STRUCT_3)}
operator + (const A, B : STRUCT_3) : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const A, B : STRUCT_3) : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator = (const A, B : STRUCT_3) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const A : STRUCT_3) : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator :=(const A : STRUCT_TYPE) : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator * (const A : STRUCT_TYPE; const B : STRUCT_3) : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator * (const B : STRUCT_3; const A : STRUCT_TYPE) : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$IFDEF STRUCT_IS_FLOAT}
operator / (const B : STRUCT_3; const A : STRUCT_TYPE) : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ELSE  STRUCT_IS_FLOAT}
operator div (const B : STRUCT_3; const A : STRUCT_TYPE) : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF STRUCT_IS_FLOAT}
{$IFDEF STRUCT_IS_VERTEX}
operator * (const A, B : STRUCT_3) : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF STRUCT_IS_VERTEX}
{$ENDIF defined(STRUCT_3)}

{$IF    defined(STRUCT_4)}
operator + (const A, B : STRUCT_4) : STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const A, B : STRUCT_4) : STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator = (const A, B : STRUCT_4) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const A : STRUCT_4) : STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator :=(const A : STRUCT_TYPE) : STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator * (const A : STRUCT_TYPE; const B : STRUCT_4) : STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator * (const B : STRUCT_4; const A : STRUCT_TYPE) : STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$IFDEF STRUCT_IS_FLOAT}
operator / (const B : STRUCT_4; const A : STRUCT_TYPE) : STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ELSE  STRUCT_IS_FLOAT}
operator div (const B : STRUCT_4; const A : STRUCT_TYPE) : STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF STRUCT_IS_FLOAT}
{$ENDIF defined(STRUCT_4)}

{$ENDIF INC_WITHOUT_FORWARD}

{$ENDIF INC_PLACE_INTERFACE}

{$IFDEF INC_PLACE_IMPLEMENTATION}
{$IF    defined(STRUCT_IS_COLOR) and defined(STRUCT_3)}
procedure STRUCT_3.ConvertType();         {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Temp : STRUCT_TYPE;
begin
Temp := r;
r := b;
b := Temp;
end;
{$ENDIF defined(STRUCT_IS_COLOR) and defined(STRUCT_3)}

{$IF    defined(STRUCT_4)}
operator * (const A : STRUCT_TYPE; const B : STRUCT_4) : STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(B.x * A, B.y * A, B.z * A, B.w * A);
end;
operator * (const B : STRUCT_4; const A : STRUCT_TYPE) : STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(B.x * A, B.y * A, B.z * A, B.w * A);
end;
{$IFDEF STRUCT_IS_FLOAT}
operator / (const B : STRUCT_4; const A : STRUCT_TYPE) : STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(B.x / A, B.y / A, B.z / A, B.w / A);
end;
{$ELSE  STRUCT_IS_FLOAT}
operator div (const B : STRUCT_4; const A : STRUCT_TYPE) : STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(B.x div A, B.y div A, B.z div A, B.w div A);
end;
{$ENDIF STRUCT_IS_FLOAT}
{$ENDIF defined(STRUCT_4)}

{$IF    defined(STRUCT_3)}
operator * (const A : STRUCT_TYPE; const B : STRUCT_3) : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(B.x * A, B.y * A, B.z * A);
end;
operator * (const B : STRUCT_3; const A : STRUCT_TYPE) : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(B.x * A, B.y * A, B.z * A);
end;
{$IFDEF STRUCT_IS_FLOAT}
operator / (const B : STRUCT_3; const A : STRUCT_TYPE) : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(B.x / A, B.y / A, B.z / A);
end;
{$ELSE  STRUCT_IS_FLOAT}
operator div (const B : STRUCT_3; const A : STRUCT_TYPE) : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(B.x div A, B.y div A, B.z div A);
end;
{$ENDIF STRUCT_IS_FLOAT}
{$IFDEF STRUCT_IS_VERTEX}
operator * (const A, B : STRUCT_3) : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(
	A.y*B.z - A.z*B.y,
	A.z*B.x - A.x*B.z,
	A.x*B.y - A.y*B.x);
end;
{$ENDIF STRUCT_IS_VERTEX}
{$ENDIF defined(STRUCT_3)}

{$IF    defined(STRUCT_2)}
operator * (const A : STRUCT_TYPE; const B : STRUCT_2) : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(B.x * A, B.y * A);
end;
operator * (const B : STRUCT_2; const A : STRUCT_TYPE) : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(B.x * A, B.y * A);
end;
{$IFDEF STRUCT_IS_FLOAT}
operator / (const B : STRUCT_2; const A : STRUCT_TYPE) : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(B.x / A, B.y / A);
end;
{$ELSE  STRUCT_IS_FLOAT}
operator div (const B : STRUCT_2; const A : STRUCT_TYPE) : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(B.x div A, B.y div A);
end;
{$ENDIF STRUCT_IS_FLOAT}
{$ENDIF defined(STRUCT_2)}

{$IF    defined(STRUCT_2_IMPORT_FUNC) and defined(STRUCT_2) and defined(STRUCT_TYPE)}
function STRUCT_2_IMPORT_FUNC(const x : STRUCT_TYPE = 0; const y : STRUCT_TYPE = 0):STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(x, y);
end;
{$ENDIF defined(STRUCT_2_IMPORT_FUNC) and defined(STRUCT_2) and defined(STRUCT_TYPE)}

{$IF    defined(STRUCT_3_IMPORT_FUNC) and defined(STRUCT_3) and defined(STRUCT_TYPE)}
function STRUCT_3_IMPORT_FUNC(const x : STRUCT_TYPE = 0; const y : STRUCT_TYPE = 0; const z : STRUCT_TYPE = 0):STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(x, y, z);
end;
{$ENDIF defined(STRUCT_3_IMPORT_FUNC) and defined(STRUCT_3) and defined(STRUCT_TYPE)}

{$IF    defined(STRUCT_4_IMPORT_FUNC) and defined(STRUCT_4) and defined(STRUCT_TYPE)}
function STRUCT_4_IMPORT_FUNC(const x : STRUCT_TYPE = 0; const y : STRUCT_TYPE = 0; const z : STRUCT_TYPE = 0; const w : STRUCT_TYPE = 0):STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(x, y, z, w);
end;
{$ENDIF defined(STRUCT_4_IMPORT_FUNC) and defined(STRUCT_4) and defined(STRUCT_TYPE)}

{$IF    defined(STRUCT_TYPE)}
function Max(const A, B : STRUCT_TYPE) : STRUCT_TYPE;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if A > B then
	Result := A
else
	Result := B;
end;

function Min(const A, B : STRUCT_TYPE) : STRUCT_TYPE;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if A < B then
	Result := A
else
	Result := B;
end;

{$ENDIF defined(STRUCT_TYPE)}

{$IF    defined(STRUCT_2_LIST) and defined(STRUCT_2)}
	{$IF    defined(STRUCT_2_LIST_HELPER)}
	{$DEFINE DATATYPE_LIST_HELPER := STRUCT_2_LIST_HELPER}
	{$ENDIF defined(STRUCT_2_LIST_HELPER)}
	{$DEFINE DATATYPE_LIST        := STRUCT_2_LIST}
	{$DEFINE DATATYPE             := STRUCT_2}
	{$INCLUDE SmoothCommonList.inc}
	{$INCLUDE SmoothCommonListUndef.inc}
{$ENDIF defined(STRUCT_2_LIST) and defined(STRUCT_2)}

{$IF    defined(STRUCT_3_LIST) and defined(STRUCT_3)}
	{$IF    defined(STRUCT_3_LIST_HELPER)}
	{$DEFINE DATATYPE_LIST_HELPER := STRUCT_3_LIST_HELPER}
	{$ENDIF defined(STRUCT_3_LIST_HELPER)}
	{$DEFINE DATATYPE_LIST        := STRUCT_3_LIST}
	{$DEFINE DATATYPE             := STRUCT_3}
	{$INCLUDE SmoothCommonList.inc}
	{$INCLUDE SmoothCommonListUndef.inc}
{$ENDIF defined(STRUCT_3_LIST) and defined(STRUCT_3)}

{$IF    defined(STRUCT_4_LIST) and defined(STRUCT_4)}
	{$IF    defined(STRUCT_4_LIST_HELPER)}
	{$DEFINE DATATYPE_LIST_HELPER := STRUCT_4_LIST_HELPER}
	{$ENDIF defined(STRUCT_4_LIST_HELPER)}
	{$DEFINE DATATYPE_LIST        := STRUCT_4_LIST}
	{$DEFINE DATATYPE             := STRUCT_4}
	{$INCLUDE SmoothCommonList.inc}
	{$INCLUDE SmoothCommonListUndef.inc}
{$ENDIF defined(STRUCT_4_LIST) and defined(STRUCT_4)}

{$IF    defined(STRUCT_2)}
operator :=(const A : STRUCT_TYPE) : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(A, A);
end;
{$ENDIF defined(STRUCT_2)}

{$IF    defined(STRUCT_4)}
operator :=(const A : STRUCT_TYPE) : STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(A, A, A, A);
end;
{$ENDIF defined(STRUCT_4)}

{$IF    defined(STRUCT_3)}
operator :=(const A : STRUCT_TYPE) : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(A, A, A);
end;
{$ENDIF defined(STRUCT_3)}

{$IF    defined(STRUCT_2)}
operator + (const A, B : STRUCT_2) : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(A.x + B.x, A.y + B.y);
end;

operator - (const A, B : STRUCT_2) : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(A.x - B.x, A.y - B.y);
end;

operator = (const A, B : STRUCT_2) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := 
{$IFDEF STRUCT_IS_FLOAT}
	( Abs(A.x - B.x) + Abs(A.y - B.y) ) < SZero
{$ELSE  STRUCT_IS_FLOAT}
	(A.x = B.x) and (A.y = B.y)
{$ENDIF STRUCT_IS_FLOAT}
	;
end;

operator - (const A : STRUCT_2) : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import( - A.x, - A.y);
end;
{$ENDIF defined(STRUCT_2)}

{$IF    defined(STRUCT_3)}
operator + (const A, B : STRUCT_3) : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(A.x + B.x, A.y + B.y, A.z + B.z);
end;

operator - (const A, B : STRUCT_3) : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(A.x - B.x, A.y - B.y, A.z - B.z);
end;

operator = (const A, B : STRUCT_3) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := 
{$IFDEF STRUCT_IS_FLOAT}
	( Abs(A.x - B.x) + Abs(A.y - B.y) + Abs(A.z - B.z) ) < SZero
{$ELSE  STRUCT_IS_FLOAT}
	(A.x = B.x) and (A.y = B.y) and (A.z = B.z)
{$ENDIF STRUCT_IS_FLOAT}
	;
end;

operator - (const A : STRUCT_3) : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import( - A.x, - A.y, - A.z);
end;
{$ENDIF defined(STRUCT_3)}

{$IF    defined(STRUCT_4)}
{$IFDEF STRUCT_IS_COLOR}
	function STRUCT_4.WithAlpha(const Alpha : STRUCT_TYPE):STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	begin
	Result := Self;
	{$IFDEF STRUCT_IS_FLOAT}
		Result.a := Result.a * Alpha;
	{$ELSE  STRUCT_IS_FLOAT}
		Result.a := Trunc(Result.a * (Alpha / 255));
	{$ENDIF STRUCT_IS_FLOAT}
	end;
	procedure STRUCT_4.AddAlpha(const Alpha : STRUCT_TYPE);         {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	begin
	{$IFDEF STRUCT_IS_FLOAT}
		a := a * Alpha;
	{$ELSE  STRUCT_IS_FLOAT}
		a := Trunc(a * (Alpha / 255));
	{$ENDIF STRUCT_IS_FLOAT}
	end;
{$ENDIF}
operator + (const A, B : STRUCT_4) : STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(A.x + B.x, A.y + B.y, A.z + B.z, A.w + B.w);
end;

operator - (const A, B : STRUCT_4) : STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(A.x - B.x, A.y - B.y, A.z - B.z, A.w - B.w);
end;

operator = (const A, B : STRUCT_4) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := 
{$IFDEF STRUCT_IS_FLOAT}
	( Abs(A.x - B.x) + Abs(A.y - B.y) + Abs(A.z - B.z) + Abs(A.w - B.w) ) < SZero
{$ELSE  STRUCT_IS_FLOAT}
	(A.x = B.x) and (A.y = B.y) and (A.z = B.z) and (A.w = B.w)
{$ENDIF STRUCT_IS_FLOAT}
	;
end;

operator - (const A : STRUCT_4) : STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import( - A.x, - A.y, - A.z, - A.w);
end;
{$ENDIF defined(STRUCT_4)}

{$IFNDEF STRUCT_IS_FLOAT}
function Abs(const S : STRUCT_2):TSFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := sqrt(sqr(S.x) + sqr(S.y));
end;

function Abs(const S : STRUCT_2):TSFloat64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := sqrt(sqr(S.x) + sqr(S.y));
end;

{$IFNDEF WITHOUT_EXTENDED}
function Abs(const S : STRUCT_2):TSFloat80;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := sqrt(sqr(S.x) + sqr(S.y));
end;
{$ENDIF WITHOUT_EXTENDED}

{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
function Abs(const S : STRUCT_3):TSFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := sqrt(sqr(S.x) + sqr(S.y) + sqr(S.z));
end;

function Abs(const S : STRUCT_3):TSFloat64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := sqrt(sqr(S.x) + sqr(S.y) + sqr(S.z));
end;

{$IFNDEF WITHOUT_EXTENDED}
function Abs(const S : STRUCT_3):TSFloat80;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := sqrt(sqr(S.x) + sqr(S.y) + sqr(S.z));
end;
{$ENDIF WITHOUT_EXTENDED}
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF STRUCT_IS_FLOAT}

function STRUCT_2.FieldsArray() : STRUCT_PTYPE;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := STRUCT_PTYPE(@x);
end;

function STRUCT_2.Create(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0) : STRUCT_2; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} static;
begin
Result.Import(x1, y1);
end;

procedure STRUCT_2.Import(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
x := x1;
y := y1;
end;

procedure STRUCT_2.Write();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
{$IFDEF STRUCT_IS_FLOAT}
	System.Write(x:0:4,' ',y:0:4);
{$ELSE STRUCT_IS_FLOAT}
	System.Write(x,' ',y);
{$ENDIF STRUCT_IS_FLOAT}
end;

procedure STRUCT_2.WriteLn();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Write();
System.WriteLn();
end;

{$IFDEF STRUCT_IS_FLOAT}
	function Abs(const S : STRUCT_2) : STRUCT_TYPE;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
	begin
	Result := sqrt(sqr(S.x) + sqr(S.y));
	end;
	
	function STRUCT_2.Round() : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	begin
	Result.Import(System.Round(x),System.Round(y));
	end;
	
	function STRUCT_2.Normalized() : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	var
		ST : STRUCT_TYPE;
	begin
	ST := Abs(Self);
	Result.Import(x / ST, y / ST);
	end;
{$ENDIF STRUCT_IS_FLOAT}

{$IF defined(STRUCT_3) and defined(STRUCT_P_3)}
function STRUCT_3.Create(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0;const z1 : STRUCT_TYPE = 0) : STRUCT_3; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} static;
begin
Result.Import(x1, y1, z1);
end;

procedure STRUCT_3.Import(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0;const z1 : STRUCT_TYPE = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
x := x1;
y := y1;
z := z1;
end;

procedure STRUCT_3.Write();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
{$IFDEF STRUCT_IS_FLOAT}
	System.Write(x:0:4,' ',y:0:4,' ',z:0:4);
{$ELSE STRUCT_IS_FLOAT}
	System.Write(x,' ',y,' ',z);
{$ENDIF STRUCT_IS_FLOAT}
end;

procedure STRUCT_3.WriteLn();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Write();System.WriteLn();
end;

{$IFDEF STRUCT_IS_FLOAT}
	function Abs(const S : STRUCT_3):STRUCT_TYPE;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
	begin
	Result := sqrt(sqr(S.x) + sqr(S.y) + sqr(S.z));
	end;
	
	function STRUCT_3.Round():STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	begin
	Result.Import(System.Round(x),System.Round(y),System.Round(z));
	end;
	
	function STRUCT_3.Normalized() : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	var
		ST : STRUCT_TYPE;
	begin
	ST := Abs(Self);
	Result.Import(x / ST, y / ST, z / ST);
	end;
{$ENDIF STRUCT_IS_FLOAT}

{$IF    defined(STRUCT_4) and defined(STRUCT_P_4)}
function STRUCT_4.Create(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0;const z1 : STRUCT_TYPE = 0;const w1 : STRUCT_TYPE = 0) : STRUCT_4; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} static;
begin
Result.Import(x1, y1, z1, w1);
end;

procedure STRUCT_4.Import(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0;const z1 : STRUCT_TYPE = 0;const w1 : STRUCT_TYPE = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
x := x1;
y := y1;
z := z1;
w := w1;
end;

procedure STRUCT_4.Write();                   {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
{$IFDEF STRUCT_IS_FLOAT}
	System.Write(x:0:4,' ',y:0:4,' ',z:0:4,' ',w:0:4);
{$ELSE STRUCT_IS_FLOAT}
	System.Write(x,' ',y,' ',z,' ',w);
{$ENDIF STRUCT_IS_FLOAT}
end;

procedure STRUCT_4.WriteLn();                 {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Write();System.WriteLn();
end;

{$IFDEF STRUCT_IS_FLOAT}
	function STRUCT_4.Round():STRUCT_4;       {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	begin
	Result.Import(System.Round(x),System.Round(y),System.Round(z),System.Round(w));
	end;
{$ENDIF STRUCT_IS_FLOAT}
{$ENDIF defined(STRUCT_4) and defined(STRUCT_P_4)}
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF INC_PLACE_IMPLEMENTATION}

{$IFDEF INC_PLACE_RENDER_CLASS}
	{$DEFINE INC_PLACE_RENDER_INTERFACE}
{$ENDIF INC_PLACE_RENDER_CLASS}

{$IFDEF INC_PLACE_RENDER_INTERFACE}

{$IFDEF STRUCT_IS_VERTEX}
procedure Vertex(const S : STRUCT_2);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
procedure Translate(const S : STRUCT_2);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
procedure LightPosition(const S : STRUCT_2;const Ligth : TSUInt32 = SR_LIGHT0);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
procedure Translate(const S : STRUCT_3);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
procedure Vertex(const S : STRUCT_3);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
procedure Normal(const S : STRUCT_3);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
procedure LightPosition(const S : STRUCT_3;const Ligth : TSUInt32 = SR_LIGHT0);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
{$IF    defined(STRUCT_4) and defined(STRUCT_P_4)}
procedure Vertex(const S : STRUCT_4);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
procedure LightPosition(const S : STRUCT_4;const Ligth : TSUInt32 = SR_LIGHT0);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
{$ENDIF defined(STRUCT_4) and defined(STRUCT_P_4)}
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF STRUCT_IS_VERTEX}

{$IFDEF STRUCT_IS_COLOR}
{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
procedure Color(const S :  STRUCT_3);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
{$IF    defined(STRUCT_4) and defined(STRUCT_P_4)}
procedure Color(const S :  STRUCT_4);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
{$ENDIF defined(STRUCT_4) and defined(STRUCT_P_4)}
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF STRUCT_IS_COLOR}

{$IFDEF STRUCT_IS_TEX_VERTEX}
procedure TexCoord(const S : STRUCT_2);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
procedure TexCoord(const S :  STRUCT_3);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
{$IF    defined(STRUCT_4) and defined(STRUCT_P_4)}
procedure TexCoord(const S :  STRUCT_4);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
{$ENDIF defined(STRUCT_4) and defined(STRUCT_P_4)}
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF STRUCT_IS_TEX_VERTEX}

{$ENDIF INC_PLACE_RENDER_INTERFACE}

{$IFDEF INC_PLACE_RENDER_CLASS}
	{$UNDEF INC_PLACE_RENDER_INTERFACE}
{$ENDIF}

{$IFDEF INC_PLACE_RENDER_IMPLEMENTATION}

{$IFDEF STRUCT_IS_VERTEX}
procedure RENDER_CLASS.LightPosition(const S : STRUCT_2;const Ligth : TSUInt32 = SR_LIGHT0);overload;
var
	LightPos      : array[0..3] of TSFloat32;
	AmbientLight  : array[0..3] of TSFloat32 = (0.5,0.5,0.5,1.0);
	DiffuseLight  : array[0..3] of TSFloat32 = (1.0,1.0,1.0,1.0);
	SpecularLight : array[0..3] of TSFloat32 = (1.0,1.0,1.0,1.0);
begin
LightPos[0] := S.x;
LightPos[1] := S.y;
LightPos[2] := 0;
LightPos[3] := 2;
Enable(Ligth);
Lightfv(Ligth, SR_AMBIENT,  @AmbientLight);
Lightfv(Ligth, SR_DIFFUSE,  @DiffuseLight);
Lightfv(Ligth, SR_SPECULAR, @SpecularLight);
Lightfv(Ligth, SR_POSITION, @LightPos);
end;
procedure RENDER_CLASS.Translate(const S : STRUCT_2);overload;
begin
Translatef(S.x,S.y,0);
end;
procedure RENDER_CLASS.Vertex(const S : STRUCT_2);overload;
begin
Vertex2f(S.x,S.y);
end;
{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
procedure RENDER_CLASS.LightPosition(const S : STRUCT_3;const Ligth : TSUInt32 = SR_LIGHT0);overload;
var
	LightPos      : array[0..3] of TSFloat32;
	AmbientLight  : array[0..3] of TSFloat32 = (0.5,0.5,0.5,1.0);
	DiffuseLight  : array[0..3] of TSFloat32 = (1.0,1.0,1.0,1.0);
	SpecularLight : array[0..3] of TSFloat32 = (1.0,1.0,1.0,1.0);
begin
LightPos[0] := S.x;
LightPos[1] := S.y;
LightPos[2] := S.z;
LightPos[3] := 2;
Enable(Ligth);
Lightfv(Ligth, SR_AMBIENT,  @AmbientLight);
Lightfv(Ligth, SR_DIFFUSE,  @DiffuseLight);
Lightfv(Ligth, SR_SPECULAR, @SpecularLight);
Lightfv(Ligth, SR_POSITION, @LightPos);
end;
procedure RENDER_CLASS.Translate(const S : STRUCT_3);overload;
begin
Translatef(S.x,S.y,S.z);
end;
procedure RENDER_CLASS.Vertex(const S : STRUCT_3);overload;
begin
Vertex3f(S.x,S.y,S.z);
end;
procedure RENDER_CLASS.Normal(const S : STRUCT_3);overload;
begin
Normal3f(S.x,S.y,S.z);
end;
{$IF    defined(STRUCT_4) and defined(STRUCT_P_4)}
procedure RENDER_CLASS.LightPosition(const S : STRUCT_4;const Ligth : TSUInt32 = SR_LIGHT0);overload;
var
	LightPos      : array[0..3] of TSFloat32;
	AmbientLight  : array[0..3] of TSFloat32 = (0.5,0.5,0.5,1.0);
	DiffuseLight  : array[0..3] of TSFloat32 = (1.0,1.0,1.0,1.0);
	SpecularLight : array[0..3] of TSFloat32 = (1.0,1.0,1.0,1.0);
begin
LightPos[0] := S.x;
LightPos[1] := S.y;
LightPos[2] := S.z;
LightPos[3] := S.w;
Enable(Ligth);
Lightfv(Ligth, SR_AMBIENT,  @AmbientLight);
Lightfv(Ligth, SR_DIFFUSE,  @DiffuseLight);
Lightfv(Ligth, SR_SPECULAR, @SpecularLight);
Lightfv(Ligth, SR_POSITION, @LightPos);
end;

procedure RENDER_CLASS.Vertex(const S : STRUCT_4);overload;
begin
(* fiature *)Vertex3f(S.x,S.y,S.z);
//Vertex4f(S.x,S.y,S.z,S.w);
end;
{$ENDIF defined(STRUCT_4) and defined(STRUCT_P_4)}
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF STRUCT_IS_VERTEX}

{$IFDEF STRUCT_IS_COLOR}
{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
procedure RENDER_CLASS.Color(const S :  STRUCT_3);overload;
const
	OneOf255 = 1/255;
begin
{$IFDEF STRUCT_IS_FLOAT}
Color3f(S.r,S.g,S.b);
{$ELSE  STRUCT_IS_FLOAT}
(* fiature *)Color3f(S.r * OneOf255, S.g * OneOf255, S.b * OneOf255);
//Color3b(S.r,S.g,S.b);
{$ENDIF STRUCT_IS_FLOAT}
end;
{$IF    defined(STRUCT_4) and defined(STRUCT_P_4)}
procedure RENDER_CLASS.Color(const S :  STRUCT_4);overload;
const
	OneOf255 = 1/255;
begin
{$IFDEF STRUCT_IS_FLOAT}
Color4f(S.r,S.g,S.b,S.a);
{$ELSE  STRUCT_IS_FLOAT}
(* fiature *)Color4f(S.r * OneOf255, S.g * OneOf255, S.b * OneOf255, S.a * OneOf255);
//Color4b(S.r,S.g,S.b,S.a);
{$ENDIF STRUCT_IS_FLOAT}
end;
{$ENDIF defined(STRUCT_4) and defined(STRUCT_P_4)}
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF STRUCT_IS_COLOR}

{$IFDEF STRUCT_IS_TEX_VERTEX}
procedure RENDER_CLASS.TexCoord(const S : STRUCT_2);overload;
begin
TexCoord2f(S.x,S.y);
end;
{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
procedure RENDER_CLASS.TexCoord(const S :  STRUCT_3);overload;
begin
(* fiature *)TexCoord2f(S.x,S.y);
//TexCoord3f(S.x,S.y,S.z);
end;
{$IF    defined(STRUCT_4) and defined(STRUCT_P_4)}
procedure RENDER_CLASS.TexCoord(const S :  STRUCT_4);overload;
begin
(* fiature *)TexCoord2f(S.x,S.y);
//TexCoord4f(S.x,S.y,S.z,S.w);
end;
{$ENDIF defined(STRUCT_4) and defined(STRUCT_P_4)}
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF STRUCT_IS_TEX_VERTEX}

{$ENDIF INC_PLACE_RENDER_IMPLEMENTATION}
