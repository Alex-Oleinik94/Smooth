{$INCLUDE SaGe.inc}

unit SaGeBase;

interface

uses
	 Classes
	;
type
	// 8 bit, signed
	TSGShortInt	= ShortInt;
	PSGShortInt	= ^ TSGShortInt;
	// 16 bit, signed
	TSGSmallInt	= SmallInt;
	PSGSmallInt	= ^ TSGSmallInt;
	// 16 bit or 32 bit, signed
	TSGInteger	= Integer;
	PSGInteger	= ^ TSGInteger;
	// 32 bit, signed
	TSGLongInt	= LongInt;
	PSGLongInt	= ^ TSGLongInt;
	{$IFNDEF WITHOUT_EXTENDED}
		// 80 bit, float
		TSGExtended	= Extended;
		PSGExtended	= ^ TSGExtended;
	{$ENDIF WITHOUT_EXTENDED}
	// 32 bit, float
	TSGFloat	= Single;
	PSGFloat	= ^ TSGFloat;
	// 64 bit, float
	TSGDouble	= Double;
	PSGDouble	= ^ TSGDouble;
	// 8 bit, unsigned
	TSGByte		= Byte;
	PSGByte		= ^ TSGByte;
	// 64 bit, signed
	TSGInt64	= Int64;
	PSGInt64	= ^ TSGInt64;
	// 32 bit, unsigned
	TSGLongWord	= LongWord;
	PSGLongWord	= ^ TSGLongWord;
	// 64 bit, unsigned
	TSGQuadWord	= QWord;
	PSGQuadWord	= ^ TSGQuadWord;
	// 16 bit, unsigned
	TSGWord	    = Word;
	PSGWord     = ^ TSGWord;
type
	TSGUInt8   = TSGByte;
	PSGUInt8   = ^TSGUInt8;
	TSGInt8    = TSGShortInt;
	PSGInt8   = ^TSGInt8;
	TSGUInt16  = TSGWord;
	PSGUInt16   = ^TSGUInt16;
	TSGInt16   = TSGSmallInt;
	PSGInt16   = ^TSGInt16;
	TSGUInt32  = TSGLongWord;
	PSGUInt32   = ^TSGUInt32;
	TSGInt32   = TSGLongInt;
	PSGInt32   = ^TSGInt32;
	TSGUInt64  = TSGQuadWord;
	PSGUInt64   = ^TSGUInt64;
	// TSGInt64 allready defined
	// PSGInt64 allready defined
type
	TSGFloat32 = TSGFloat;
	PSGFloat32 = ^ TSGFloat32;
	TSGFloat64 = TSGDouble;
	PSGFloat64 = ^ TSGFloat64;
	{$IFNDEF WITHOUT_EXTENDED}
		TSGFloat80 = TSGExtended;
		PSGFloat80 = ^ TSGFloat80;
	{$ENDIF WITHOUT_EXTENDED}
type
	// Common
	TSGChar		= Char;
	PSGChar		= ^ TSGChar;
	TSGPointer  = Pointer;
	PSGPointer  = ^ TSGPointer;
	TSGString 	= String;
	PSGString 	= ^ TSGString;
	
	TSGCharSet = set of TSGChar;
type
	// Aditional
	TSGQWord	= QWord;
	TSGSingle	= TSGFloat;
	TSGReal     = TSGDouble;
	TSGGuid     = TGuid;
	TSGCardinal = Cardinal;
type
	// Boolean
	TSGBoolean	= Boolean;
	PSGBoolean	= ^ TSGBoolean;
	TSGBool     = TSGBoolean;
	
	TSGWordBool = WordBool;
	TSGLongBool = LongBool;
	
	TSGBool8 = TSGBool;
	TSGBool16 = TSGWordBool;
	TSGBool32 = TSGLongBool;
type
	TSGEnumPointer = 
		{$IFDEF CPU64}
			TSGUInt64
		{$ELSE} {$IFDEF CPU32}
			TSGUInt32
		{$ELSE} {$IFDEF CPU16}
			TSGUInt16
		{$ENDIF}{$ENDIF}{$ENDIF}
		;
	TSGMaxEnum = TSGEnumPointer;
	TSGMaxUnsignedEnum = TSGMaxEnum;
	TSGMaxFloat = 
		{$IFNDEF WITHOUT_EXTENDED}
			TSGFloat80
		{$ELSE WITHOUT_EXTENDED}
			TSGFloat64
		{$ENDIF WITHOUT_EXTENDED}
		;
	TSGMaxFPUFloat = 
		{$IFDEF CPU64}
			TSGFloat64
		{$ELSE} {$IFDEF CPU32}
			TSGFloat32
		{$ENDIF}{$ENDIF}
		;
	TSGMaxSignedEnum =
		{$IFDEF CPU64}
			TSGInt64
		{$ELSE} {$IFDEF CPU32}
			TSGInt32
		{$ELSE} {$IFDEF CPU16}
			TSGInt16
		{$ENDIF}{$ENDIF}{$ENDIF}
		;
	TSGSize = TSGUInt64;
type
	TSGFileOfByte = type file of TSGByte;
	PSGFileOfByte = ^ TSGFileOfByte;
	TSGHandle     = type TSGMaxEnum;
	TSGIdentifier = type TSGMaxEnum;
	TSGSetOfByte  = type packed set of byte;
	TSGConstList  = type packed array of TVarRec;
	TSGPCharList  = type packed array of PSGChar;
type
	PText     = ^ TextFile;
	Text      = TextFile;
	PTextFile = ^ TextFile;
type
	TSGProcedure = type TProcedure;
	TSGNestedProcedure = type procedure() is nested;
	TSGPointerProcedure = procedure (Void : TSGPointer);
type
	// Начальный класс SaGe
	TSGClass = class;
	TSGClassClass = class of TSGClass;
	TSGClassOfClass = TSGClassClass;
	TSGClass = class
			public
		constructor Create();virtual;
		destructor Destroy();override;
		class function ClassName():TSGString;virtual;
		function Get(const What : TSGString) : TSGPointer; virtual;
		end;
const
	SG_TRUE = TSGByte(1);
	SG_FALSE = TSGByte(0);
	SG_UNKNOWN = TSGByte(2);

type
	TSGOptionPointer = TSGPointer;
	
	TSGOption = object
			public
		FName : TSGString;
		FOption : TSGOptionPointer;
			public
		procedure Import(const VName : TSGString; const VPointer : TSGOptionPointer);
		end;

operator = (const A, B : TSGOption) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

type
	TSGDoubleString = packed array[0..1] of TSGString;

operator = (const A, B : TSGDoubleString) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$DEFINE  INC_PLACE_INTERFACE}
{$INCLUDE SaGeCommonLists.inc}
{$UNDEF   INC_PLACE_INTERFACE}

operator in(const S : TSGString; const A : TSGDoubleStrings) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGDoubleString(const FirstString, SecondString : TSGString) : TSGDoubleString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

type
	PSGStringList = ^ TSGStringList;
procedure SGStringListDeleteByIndex(var StringList : TSGStringList; const Index : TSGMaxEnum);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGStringListLength(const StringList : TSGStringList) : TSGMaxEnum;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

operator in(const S : TSGString; const A : TSGSettings) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const A : TSGSettings; const S : TSGString) : TSGSettings;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

type
	generic TSGList<T> = packed array of T;

implementation

operator in(const S : TSGString; const A : TSGDoubleStrings) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	Index : TSGMaxEnum;
begin
Result := '';
if (A <> nil) and (Length(A) > 0) then
	for Index := 0 to High(A) do
		if A[Index][0] = S then
			begin
			Result := A[Index][1];
			break;
			end;
end;

function SGDoubleString(const FirstString, SecondString : TSGString) : TSGDoubleString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result[0] := FirstString;
Result[1] := SecondString;
end;

function SGStringListLength(const StringList : TSGStringList): TSGMaxEnum;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if StringList = nil then
	Result := 0
else
	Result := Length(StringList);
end;

procedure SGStringListDeleteByIndex(var StringList : TSGStringList; const Index : TSGMaxEnum);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGMaxEnum;
begin
if (Index >= 0) and (Index < SGStringListLength(StringList)) then
	begin
	if Index <> SGStringListLength(StringList) - 1 then
		for i := Index to SGStringListLength(StringList) - 2 do
			StringList[Index] := StringList[Index + 1];
	SetLength(StringList, SGStringListLength(StringList) - 1);
	end;
end;

operator - (const A : TSGSettings; const S : TSGString):TSGSettings;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
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
			if Result[i].FName = S then
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

operator in(const S : TSGString; const A : TSGSettings):TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	O : TSGOption;
begin
Result := False;
for O in A do
	begin
	if O.FName = S then
		begin
		Result := True;
		break;
		end;
	end;
end;

procedure TSGOption.Import(const VName : TSGString; const VPointer : TSGOptionPointer);
begin
FName := VName;
FOption := VPointer;
end;

operator = (const A, B : TSGDoubleString) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (A[0] = B[0]) and (A[1] = B[1]);
end;

operator = (const A, B : TSGOption) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (A.FName = B.FName) and (A.FOption = B.FOption);
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$INCLUDE SaGeCommonLists.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

class function TSGClass.ClassName():TSGString;
begin
Result := 'TSGClass';
end;

function TSGClass.Get(const What:TSGString):TSGPointer;
begin
Result := nil;
end;


constructor TSGClass.Create();
begin
inherited;
end;

destructor TSGClass.Destroy();
begin
inherited;
end;

end.
