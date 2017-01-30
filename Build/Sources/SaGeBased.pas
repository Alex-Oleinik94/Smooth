{$INCLUDE Includes\SaGe.inc}

unit SaGeBased;

interface

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
	// 80 bit, float
	TSGExtended	= Extended;
	PSGExtended	= ^ TSGExtended;
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
	TSGInt8    = TSGShortInt;
	TSGUInt16  = TSGWord;
	TSGInt16   = TSGSmallInt;
	TSGUInt32  = TSGLongWord;
	TSGInt32   = TSGLongInt;
	TSGUInt64  = TSGQuadWord;
	// TSGInt64 allready defined
	TSGFloat32 = TSGFloat;
	TSGFloat64 = TSGDouble;
	{$IFNDEF WITHOUT_EXTENDED}
		TSGFloat80 = TSGExtended;
	{$ENDIF}
type
	// Common
	TSGChar		= Char;
	PSGChar		= ^ TSGChar;
	TSGBoolean	= Boolean;
	TSGPointer  = Pointer;
	TSGString 	= String;
	
	TSGCharSet = set of TSGChar;
type
	// Aditional
	TSGBool     = TSGBoolean;
	TSGQWord	= QWord;
	TSGSingle	= TSGFloat;
	TSGReal     = TSGDouble;
	TSGGuid     = TGuid;
	TSGCardinal = Cardinal;
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
 
 { TYPE To TYPE }
 function SGShortIntToInt(Value : TSGShortInt) : TSGInteger; {$IFDEF WITHASMINC} assembler; register; {$ENDIF} overload;

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

{$DEFINE  INC_PLACE_INTERFACE}
{$INCLUDE SaGeCommonLists.inc}
{$UNDEF   INC_PLACE_INTERFACE}

operator in(const S : TSGString; const A : TSGSettings):TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const A : TSGSettings; const S : TSGString):TSGSettings;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

type
	TSGStringHelper = type helper for TSGString
		function Len() : TSGMaxEnum; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;
type
	generic TSGList<T> = packed array of T;

implementation

uses 
	Math
	;

function TSGStringHelper.Len() : TSGMaxEnum; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Length(Self);
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

operator = (const A, B : TSGOption) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (A.FName = B.FName) and (A.FOption = B.FOption);
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$INCLUDE SaGeCommonLists.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}


function SGShortIntToInt(Value : TSGShortInt) : TSGInteger; 
{$IFDEF WITHASMINC} assembler; register; {$ENDIF}  overload;
{$IFDEF WITHASMINC}
	asm
		cbw
		cwde
	end;
{$ELSE}
	begin
	Result := Value;
	end;
	{$ENDIF}

end.
