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
	TSGInt8    = TSGShortInt;
	TSGUInt16  = TSGWord;
	TSGInt16   = TSGSmallInt;
	TSGUInt32  = TSGLongWord;
	TSGInt32   = TSGLongInt;
	TSGUInt64  = TSGQuadWord;
	// TSGInt64 allready defined
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

procedure SGCopyPartStreamToStream(const Source, Destination : TStream; const Size : TSGUInt64);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGCopyPartStreamToStream(const Source : TStream; Destination : TMemoryStream; const Size : TSGUInt64);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

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

type
	PSGStringList = ^ TSGStringList;

operator in(const S : TSGString; const A : TSGSettings):TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const A : TSGSettings; const S : TSGString):TSGSettings;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

type
	generic TSGList<T> = packed array of T;

implementation

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

procedure SGCopyPartStreamToStream(const Source : TStream; Destination : TMemoryStream; const Size : TSGUInt64);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	DestinationSizeOld : TSGUInt64;
begin
DestinationSizeOld := Destination.Size;
Destination.Size := DestinationSizeOld + Size;
Source.ReadBuffer(PSGByte(Destination.Memory)[DestinationSizeOld], Size);
Destination.Position := Size + DestinationSizeOld;
end;

procedure SGCopyPartStreamToStream(const Source, Destination : TStream; const Size : TSGUInt64);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Point : PSGByte;
begin
GetMem(Point, Size);
Source.ReadBuffer(Point^, Size);
Destination.WriteBuffer(Point^, Size);
FreeMem(Point, Size);
end;

end.
