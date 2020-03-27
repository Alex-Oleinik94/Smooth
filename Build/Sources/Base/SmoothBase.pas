{$INCLUDE Smooth.inc}

unit SmoothBase;

interface

uses
	 Classes
	;
type
	// 8 bit, signed
	TSShortInt	= ShortInt;
	PSShortInt	= ^ TSShortInt;
	// 16 bit, signed
	TSSmallInt	= SmallInt;
	PSSmallInt	= ^ TSSmallInt;
	// 16 bit or 32 bit, signed
	TSInteger	= Integer;
	PSInteger	= ^ TSInteger;
	// 32 bit, signed
	TSLongInt	= LongInt;
	PSLongInt	= ^ TSLongInt;
	{$IFNDEF WITHOUT_EXTENDED}
		// 80 bit, float
		TSExtended	= Extended;
		PSExtended	= ^ TSExtended;
	{$ENDIF WITHOUT_EXTENDED}
	// 32 bit, float
	TSFloat	= Single;
	PSFloat	= ^ TSFloat;
	// 64 bit, float
	TSDouble	= Double;
	PSDouble	= ^ TSDouble;
	// 8 bit, unsigned
	TSByte		= Byte;
	PSByte		= ^ TSByte;
	// 64 bit, signed
	TSInt64	= Int64;
	PSInt64	= ^ TSInt64;
	// 32 bit, unsigned
	TSLongWord	= LongWord;
	PSLongWord	= ^ TSLongWord;
	// 64 bit, unsigned
	TSQuadWord	= QWord;
	PSQuadWord	= ^ TSQuadWord;
	// 16 bit, unsigned
	TSWord	    = Word;
	PSWord     = ^ TSWord;
type
	TSUInt8   = TSByte;
	PSUInt8   = ^TSUInt8;
	TSInt8    = TSShortInt;
	PSInt8   = ^TSInt8;
	TSUInt16  = TSWord;
	PSUInt16   = ^TSUInt16;
	TSInt16   = TSSmallInt;
	PSInt16   = ^TSInt16;
	TSUInt32  = TSLongWord;
	PSUInt32   = ^TSUInt32;
	TSInt32   = TSLongInt;
	PSInt32   = ^TSInt32;
	TSUInt64  = TSQuadWord;
	PSUInt64   = ^TSUInt64;
	// TSInt64 allready defined
	// PSInt64 allready defined
type
	TSFloat32 = TSFloat;
	PSFloat32 = ^ TSFloat32;
	TSFloat64 = TSDouble;
	PSFloat64 = ^ TSFloat64;
	{$IFNDEF WITHOUT_EXTENDED}
		TSFloat80 = TSExtended;
		PSFloat80 = ^ TSFloat80;
	{$ENDIF WITHOUT_EXTENDED}
type
	// Common
	TSChar		= Char;
	PSChar		= ^ TSChar;
	TSPointer  = Pointer;
	PSPointer  = ^ TSPointer;
	TSString 	= String;
	PSString 	= ^ TSString;
	
	TSCharSet = set of TSChar;
type
	// Aditional
	TSQWord	= QWord;
	TSSingle	= TSFloat;
	TSReal     = TSDouble;
	TSGuid     = TGuid;
	TSCardinal = Cardinal;
type
	// Boolean
	TSBoolean	= Boolean;
	PSBoolean	= ^ TSBoolean;
	TSBool     = TSBoolean;
	
	TSWordBool = WordBool;
	TSLongBool = LongBool;
	
	TSBool8 = TSBool;
	TSBool16 = TSWordBool;
	TSBool32 = TSLongBool;
type
	TSEnumPointer = 
		{$IFDEF CPU64}
			TSUInt64
		{$ELSE} {$IFDEF CPU32}
			TSUInt32
		{$ELSE} {$IFDEF CPU16}
			TSUInt16
		{$ENDIF}{$ENDIF}{$ENDIF}
		;
	TSMaxEnum = TSEnumPointer;
	TSMaxUnsignedEnum = TSMaxEnum;
	TSMaxFloat = 
		{$IFNDEF WITHOUT_EXTENDED}
			TSFloat80
		{$ELSE WITHOUT_EXTENDED}
			TSFloat64
		{$ENDIF WITHOUT_EXTENDED}
		;
	TSMaxFPUFloat = 
		{$IFDEF CPU64}
			TSFloat64
		{$ELSE} {$IFDEF CPU32}
			TSFloat32
		{$ENDIF}{$ENDIF}
		;
	TSMaxSignedEnum =
		{$IFDEF CPU64}
			TSInt64
		{$ELSE} {$IFDEF CPU32}
			TSInt32
		{$ELSE} {$IFDEF CPU16}
			TSInt16
		{$ENDIF}{$ENDIF}{$ENDIF}
		;
	TSSize = TSUInt64;
type
	TSFileOfByte = type file of TSByte;
	PSFileOfByte = ^ TSFileOfByte;
	TSHandle     = type TSMaxEnum;
	TSIdentifier = type TSMaxEnum;
	TSSetOfByte  = type packed set of byte;
	TSConstList  = type packed array of TVarRec;
	TSPCharList  = type packed array of PSChar;
type
	PText     = ^ TextFile;
	Text      = TextFile;
	PTextFile = ^ TextFile;
type
	TSProcedure = type TProcedure;
	TSNestedProcedure = type procedure() is nested;
	TSPointerProcedure = procedure (Void : TSPointer);
type
	// Начальный класс Smooth
	TSClass = class;
	TSClassClass = class of TSClass;
	TSClassOfClass = TSClassClass;
	TSClass = class(TObject)
			public
		constructor Create(); virtual;
		destructor Destroy(); override;
		class function ClassName():TSString; virtual;
		function Get(const What : TSString) : TSPointer; virtual;
		end;
const
	S_TRUE = TSByte(1);
	S_FALSE = TSByte(0);
	S_UNKNOWN = TSByte(2);

type
	generic TSList<T> = packed array of T;

procedure SKill(var _Stream : TStream); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure SKill(var _Stream : TMemoryStream); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure SKill(var _Data : PSByte); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

procedure SKill(var _Data : PSByte); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (_Data <> nil) then
	begin
	FreeMem(_Data);
	_Data := nil;
	end;
end;

procedure SKill(var _Stream : TStream); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (_Stream <> nil) then
	begin
	_Stream.Destroy();
	_Stream := nil;
	end;
end;

procedure SKill(var _Stream : TMemoryStream); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (_Stream <> nil) then
	begin
	_Stream.Destroy();
	_Stream := nil;
	end;
end;

class function TSClass.ClassName():TSString;
begin
Result := 'TSClass';
end;

function TSClass.Get(const What:TSString):TSPointer;
begin
Result := nil;
end;


constructor TSClass.Create();
begin
inherited;
end;

destructor TSClass.Destroy();
begin
inherited;
end;

end.
