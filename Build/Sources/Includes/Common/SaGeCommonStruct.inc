{$IFDEF INC_PLACE_INTERFACE}
type
	STRUCT_P_2 = ^ STRUCT_2;
	STRUCT_2 = object
			public
		x, y : STRUCT_TYPE;
			public
		procedure Import(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Write();                                                      {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure WriteLn();                                                    {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		{$IFDEF STRUCT_IS_FLOAT}
			function Round():STRUCT_2;                                          {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			function Normalized() : STRUCT_2;                                   {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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
		procedure Import(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0;const z1 : STRUCT_TYPE = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Write();                   {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure WriteLn();                 {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		{$IFDEF STRUCT_IS_FLOAT}
			function Round():STRUCT_3;       {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			function Normalized() : STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		{$ENDIF STRUCT_IS_FLOAT}
		{$IFDEF STRUCT_IS_COLOR}
			property b : STRUCT_TYPE read z write z;
		{$ENDIF}
		end;
	{$IF    defined(STRUCT_4) and defined(STRUCT_P_4)}
	STRUCT_P_4 = ^ STRUCT_4;
	STRUCT_4 = object(STRUCT_3)
			public
		w : STRUCT_TYPE;
			public
		procedure Import(const x1 : STRUCT_TYPE = 0;const y1 : STRUCT_TYPE = 0;const z1 : STRUCT_TYPE = 0;const w1 : STRUCT_TYPE = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Write();                   {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure WriteLn();                 {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		{$IFDEF STRUCT_IS_FLOAT}
			function Round():STRUCT_4;       {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		{$ENDIF STRUCT_IS_FLOAT}
		{$IFDEF STRUCT_IS_COLOR}
			property a : STRUCT_TYPE read w write w;
		{$ENDIF}
		end;
	{$ENDIF defined(STRUCT_4) and defined(STRUCT_P_4)}
	{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
	
	{$IF    defined(STRUCT_2_LIST) and defined(STRUCT_2)}
	STRUCT_2_LIST = packed array of STRUCT_2;
	{$ENDIF defined(STRUCT_2_LIST) and defined(STRUCT_2)}
	
	{$IF    defined(STRUCT_3_LIST) and defined(STRUCT_3)}
	STRUCT_3_LIST = packed array of STRUCT_3;
	{$ENDIF defined(STRUCT_3_LIST) and defined(STRUCT_3)}
	
	{$IF    defined(STRUCT_4_LIST) and defined(STRUCT_4)}
	STRUCT_4_LIST = packed array of STRUCT_4;
	{$ENDIF defined(STRUCT_4_LIST) and defined(STRUCT_4)}

{$IFNDEF INC_WITHOUT_FORWARD}

{$IF    defined(STRUCT_2_IMPORT_FUNC) and defined(STRUCT_2) and defined(STRUCT_TYPE)}
function STRUCT_2_IMPORT_FUNC(const x : STRUCT_TYPE = 0; const y : STRUCT_TYPE = 0):STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF defined(STRUCT_2_IMPORT_FUNC) and defined(STRUCT_2) and defined(STRUCT_TYPE)}

{$IF    defined(STRUCT_3_IMPORT_FUNC) and defined(STRUCT_3) and defined(STRUCT_TYPE)}
function STRUCT_3_IMPORT_FUNC(const x : STRUCT_TYPE = 0; const y : STRUCT_TYPE = 0; const z : STRUCT_TYPE = 0):STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF defined(STRUCT_3_IMPORT_FUNC) and defined(STRUCT_3) and defined(STRUCT_TYPE)}

{$IF    defined(STRUCT_4_IMPORT_FUNC) and defined(STRUCT_4) and defined(STRUCT_TYPE)}
function STRUCT_4_IMPORT_FUNC(const x : STRUCT_TYPE = 0; const y : STRUCT_TYPE = 0; const z : STRUCT_TYPE = 0; const w : STRUCT_TYPE = 0):STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
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
function Abs(const S : STRUCT_2):TSGFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function Abs(const S : STRUCT_2):TSGFloat64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function Abs(const S : STRUCT_2):TSGFloat80;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
function Abs(const S : STRUCT_3):TSGFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function Abs(const S : STRUCT_3):TSGFloat64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function Abs(const S : STRUCT_3):TSGFloat80;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF STRUCT_IS_FLOAT}

{$IF    defined(STRUCT_2)}
operator + (const A, B : STRUCT_2) : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const A, B : STRUCT_2) : STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator = (const A, B : STRUCT_2) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
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
operator = (const A, B : STRUCT_3) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
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
operator = (const A, B : STRUCT_4) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
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

{$IF    defined(STRUCT_2_LIST) and defined(STRUCT_2)}
operator :=(const A : STRUCT_2) : STRUCT_2_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator + (const A : STRUCT_2_LIST;const B : STRUCT_2) : STRUCT_2_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const A : STRUCT_2_LIST;const B : STRUCT_2) : STRUCT_2_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF defined(STRUCT_2_LIST) and defined(STRUCT_2)}

{$IF    defined(STRUCT_3_LIST) and defined(STRUCT_3)}
operator :=(const A : STRUCT_3) : STRUCT_3_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator + (const A : STRUCT_3_LIST;const B : STRUCT_3) : STRUCT_3_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const A : STRUCT_3_LIST;const B : STRUCT_3) : STRUCT_3_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF defined(STRUCT_3_LIST) and defined(STRUCT_3)}

{$IF    defined(STRUCT_4_LIST) and defined(STRUCT_4)}
operator :=(const A : STRUCT_4) : STRUCT_4_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator + (const A : STRUCT_4_LIST;const B : STRUCT_4) : STRUCT_4_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const A : STRUCT_4_LIST;const B : STRUCT_4) : STRUCT_4_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF defined(STRUCT_4_LIST) and defined(STRUCT_4)}

{$ENDIF INC_WITHOUT_FORWARD}

{$ENDIF INC_PLACE_INTERFACE}

{$IFDEF INC_PLACE_IMPLEMENTATION}

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
function STRUCT_2_IMPORT_FUNC(const x : STRUCT_TYPE = 0; const y : STRUCT_TYPE = 0):STRUCT_2;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(x, y);
end;
{$ENDIF defined(STRUCT_2_IMPORT_FUNC) and defined(STRUCT_2) and defined(STRUCT_TYPE)}

{$IF    defined(STRUCT_3_IMPORT_FUNC) and defined(STRUCT_3) and defined(STRUCT_TYPE)}
function STRUCT_3_IMPORT_FUNC(const x : STRUCT_TYPE = 0; const y : STRUCT_TYPE = 0; const z : STRUCT_TYPE = 0):STRUCT_3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(x, y, z);
end;
{$ENDIF defined(STRUCT_3_IMPORT_FUNC) and defined(STRUCT_3) and defined(STRUCT_TYPE)}

{$IF    defined(STRUCT_4_IMPORT_FUNC) and defined(STRUCT_4) and defined(STRUCT_TYPE)}
function STRUCT_4_IMPORT_FUNC(const x : STRUCT_TYPE = 0; const y : STRUCT_TYPE = 0; const z : STRUCT_TYPE = 0; const w : STRUCT_TYPE = 0):STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
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
operator :=(const A : STRUCT_2) : STRUCT_2_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
SetLength(Result, 1);
Result[0] := A;
end;

operator + (const A : STRUCT_2_LIST;const B : STRUCT_2) : STRUCT_2_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := A;
if Result = nil then
	SetLength(Result, 1)
else
	SetLength(Result, Length(Result) + 1);
Result[High(Result)] := B;
end;

operator - (const A : STRUCT_2_LIST;const B : STRUCT_2) : STRUCT_2_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	i, ii : TSGMaxEnum;
begin
Result := A;
if Result <> nil then 
	begin
	ii := Length(Result);
	if ii > 0 then
		begin
		i := 0;
		while (i < Length(Result)) do
			begin
			if Result[i] = B then
				begin
				if High(Result) <> i then
					begin
					for ii := i to High(Result) - 1 do
						Result[ii] := Result[ii + 1];
					end;
				SetLength(Result, Length(Result) - 1);
				end
			else
				i += 1;
			end;
		end;
	end;
end;

{$ENDIF defined(STRUCT_2_LIST) and defined(STRUCT_2)}

{$IF    defined(STRUCT_3_LIST) and defined(STRUCT_3)}
operator :=(const A : STRUCT_3) : STRUCT_3_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
SetLength(Result, 1);
Result[0] := A;
end;

operator + (const A : STRUCT_3_LIST;const B : STRUCT_3) : STRUCT_3_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := A;
if Result = nil then
	SetLength(Result, 1)
else
	SetLength(Result, Length(Result) + 1);
Result[High(Result)] := B;
end;

operator - (const A : STRUCT_3_LIST;const B : STRUCT_3) : STRUCT_3_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	i, ii : TSGMaxEnum;
begin
Result := A;
if Result <> nil then 
	begin
	ii := Length(Result);
	if ii > 0 then
		begin
		i := 0;
		while (i < Length(Result)) do
			begin
			if Result[i] = B then
				begin
				if High(Result) <> i then
					begin
					for ii := i to High(Result) - 1 do
						Result[ii] := Result[ii + 1];
					end;
				SetLength(Result, Length(Result) - 1);
				end
			else
				i += 1;
			end;
		end;
	end;
end;

{$ENDIF defined(STRUCT_3_LIST) and defined(STRUCT_3)}

{$IF    defined(STRUCT_4_LIST) and defined(STRUCT_4)}
operator :=(const A : STRUCT_4) : STRUCT_4_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
SetLength(Result, 1);
Result[0] := A;
end;

operator + (const A : STRUCT_4_LIST;const B : STRUCT_4) : STRUCT_4_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := A;
if Result = nil then
	SetLength(Result, 1)
else
	SetLength(Result, Length(Result) + 1);
Result[High(Result)] := B;
end;

operator - (const A : STRUCT_4_LIST;const B : STRUCT_4) : STRUCT_4_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	i, ii : TSGMaxEnum;
begin
Result := A;
if Result <> nil then 
	begin
	ii := Length(Result);
	if ii > 0 then
		begin
		i := 0;
		while (i < Length(Result)) do
			begin
			if Result[i] = B then
				begin
				if High(Result) <> i then
					begin
					for ii := i to High(Result) - 1 do
						Result[ii] := Result[ii + 1];
					end;
				SetLength(Result, Length(Result) - 1);
				end
			else
				i += 1;
			end;
		end;
	end;
end;


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

operator = (const A, B : STRUCT_2) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := 
{$IFDEF STRUCT_IS_FLOAT}
	( Abs(A.x - B.x) + Abs(A.y - B.y) ) < SGZero
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

operator = (const A, B : STRUCT_3) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := 
{$IFDEF STRUCT_IS_FLOAT}
	( Abs(A.x - B.x) + Abs(A.y - B.y) + Abs(A.z - B.z) ) < SGZero
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
operator + (const A, B : STRUCT_4) : STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(A.x + B.x, A.y + B.y, A.z + B.z, A.w + B.w);
end;

operator - (const A, B : STRUCT_4) : STRUCT_4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(A.x - B.x, A.y - B.y, A.z - B.z, A.w - B.w);
end;

operator = (const A, B : STRUCT_4) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := 
{$IFDEF STRUCT_IS_FLOAT}
	( Abs(A.x - B.x) + Abs(A.y - B.y) + Abs(A.z - B.z) + Abs(A.w - B.w) ) < SGZero
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
function Abs(const S : STRUCT_2):TSGFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := sqrt(sqr(S.x) + sqr(S.y));
end;

function Abs(const S : STRUCT_2):TSGFloat64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := sqrt(sqr(S.x) + sqr(S.y));
end;

function Abs(const S : STRUCT_2):TSGFloat80;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := sqrt(sqr(S.x) + sqr(S.y));
end;
{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
function Abs(const S : STRUCT_3):TSGFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := sqrt(sqr(S.x) + sqr(S.y) + sqr(S.z));
end;

function Abs(const S : STRUCT_3):TSGFloat64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := sqrt(sqr(S.x) + sqr(S.y) + sqr(S.z));
end;

function Abs(const S : STRUCT_3):TSGFloat80;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := sqrt(sqr(S.x) + sqr(S.y) + sqr(S.z));
end;
{$ENDIF defined(STRUCT_3) and defined(STRUCT_P_3)}
{$ENDIF STRUCT_IS_FLOAT}

function STRUCT_2.FieldsArray() : STRUCT_PTYPE;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := STRUCT_PTYPE(@x);
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
procedure LightPosition(const S : STRUCT_2;const Ligth : TSGUInt32 = SGR_LIGHT0);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
{$IF    defined(STRUCT_3) and defined(STRUCT_P_3)}
procedure Translate(const S : STRUCT_3);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
procedure Vertex(const S : STRUCT_3);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
procedure Normal(const S : STRUCT_3);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
procedure LightPosition(const S : STRUCT_3;const Ligth : TSGUInt32 = SGR_LIGHT0);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
{$IF    defined(STRUCT_4) and defined(STRUCT_P_4)}
procedure Vertex(const S : STRUCT_4);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
procedure LightPosition(const S : STRUCT_4;const Ligth : TSGUInt32 = SGR_LIGHT0);{$IFDEF INC_PLACE_RENDER_CLASS}virtual;overload;{$ENDIF}
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
procedure RENDER_CLASS.LightPosition(const S : STRUCT_2;const Ligth : TSGUInt32 = SGR_LIGHT0);overload;
var
	LightPos      : array[0..3] of TSGFloat32;
	AmbientLight  : array[0..3] of TSGFloat32 = (0.5,0.5,0.5,1.0);
	DiffuseLight  : array[0..3] of TSGFloat32 = (1.0,1.0,1.0,1.0);
	SpecularLight : array[0..3] of TSGFloat32 = (1.0,1.0,1.0,1.0);
begin
LightPos[0] := S.x;
LightPos[1] := S.y;
LightPos[2] := 0;
LightPos[3] := 2;
Enable(Ligth);
Lightfv(Ligth, SGR_AMBIENT,  @AmbientLight);
Lightfv(Ligth, SGR_DIFFUSE,  @DiffuseLight);
Lightfv(Ligth, SGR_SPECULAR, @SpecularLight);
Lightfv(Ligth, SGR_POSITION, @LightPos);
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
procedure RENDER_CLASS.LightPosition(const S : STRUCT_3;const Ligth : TSGUInt32 = SGR_LIGHT0);overload;
var
	LightPos      : array[0..3] of TSGFloat32;
	AmbientLight  : array[0..3] of TSGFloat32 = (0.5,0.5,0.5,1.0);
	DiffuseLight  : array[0..3] of TSGFloat32 = (1.0,1.0,1.0,1.0);
	SpecularLight : array[0..3] of TSGFloat32 = (1.0,1.0,1.0,1.0);
begin
LightPos[0] := S.x;
LightPos[1] := S.y;
LightPos[2] := S.z;
LightPos[3] := 2;
Enable(Ligth);
Lightfv(Ligth, SGR_AMBIENT,  @AmbientLight);
Lightfv(Ligth, SGR_DIFFUSE,  @DiffuseLight);
Lightfv(Ligth, SGR_SPECULAR, @SpecularLight);
Lightfv(Ligth, SGR_POSITION, @LightPos);
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
procedure RENDER_CLASS.LightPosition(const S : STRUCT_4;const Ligth : TSGUInt32 = SGR_LIGHT0);overload;
var
	LightPos      : array[0..3] of TSGFloat32;
	AmbientLight  : array[0..3] of TSGFloat32 = (0.5,0.5,0.5,1.0);
	DiffuseLight  : array[0..3] of TSGFloat32 = (1.0,1.0,1.0,1.0);
	SpecularLight : array[0..3] of TSGFloat32 = (1.0,1.0,1.0,1.0);
begin
LightPos[0] := S.x;
LightPos[1] := S.y;
LightPos[2] := S.z;
LightPos[3] := S.w;
Enable(Ligth);
Lightfv(Ligth, SGR_AMBIENT,  @AmbientLight);
Lightfv(Ligth, SGR_DIFFUSE,  @DiffuseLight);
Lightfv(Ligth, SGR_SPECULAR, @SpecularLight);
Lightfv(Ligth, SGR_POSITION, @LightPos);
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
