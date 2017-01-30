{$INCLUDE SaGe.inc}

unit SaGeBase;

interface

uses
	 SysUtils
	,Classes
	,Process
	
	,SaGeBased
	,SaGeFileUtils
	;

const
	{$IFDEF MSWINDOWS}
		SGLibraryNameBegin = '';
		SGLibraryNameEnd = '.dll';
	{$ELSE}
		{$IFDEF UNIX}
			SGLibraryNameBegin = 'lib';
			SGLibraryNameEnd = '.so';
		{$ELSE}
			SGLibraryNameBegin = '';
			SGLibraryNameEnd = '';
			{$ENDIF}
		{$ENDIF}

const
	SGFrameButtonsType0f =               $000003;
	SGFrameButtonsTypeCleared = SGFrameButtonsType0f;
	SGFrameButtonsType1f =               $000004;
	SGFrameButtonsType3f =               $000005;

	SGObjectTimerConst : real = 0.02;

	SGFrameAnimationConst = 200;

	//Это для SaGeScreen.TSGComponent
	SGAlignNone =                        $000006;
	SGAlignLeft =                        $000007;
	SGAlignRight =                       $000008;
	SGAlignTop =                         $000009;
	SGAlignBottom =                      $00000A;
	SGAlignClient =                      $00000B;

	//Это для SaGeScreen.TSGComponent
	SGAnchorRight =                      $00000D;
	SGAnchorLeft =                       $00000E;
	SGAnchorTop =                        $00000F;
	SGAnchorBottom =                     $000010;

	//Типы проэкции для SaGeRender
	SG_3D =                              $000011;
	SG_3D_ORTHO =                        $000012;

	//Это для SaGeScreen
	SG_VERTEX_FOR_CHILDREN =             $000013;
	SG_VERTEX_FOR_PARENT =               $000014;

	//Это для SaGeScreen
	SG_LEFT =                            $000015;
	SG_TOP =                             $000016;
	SG_HEIGHT =                          $000017;
	SG_WIDTH =                           $000018;
	SG_RIGHT =                           $000019;
	SG_BOTTOM =                          $00001A;

	//Это для SaGeMath
	SG_VARIABLE =                        $00001B;
	SG_CONST =                           $00001C;
	SG_OPERATOR =                        $00001D;
	SG_BOOLEAN =                         $00001E;
	SG_REAL =                            $00001F;
	SG_NUMERIC =                         $000020;
	SG_OBJECT =                          $000021;
	SG_NONE =                            $000022;
	SG_NOTHINC = SG_NONE;
	SG_NOTHINK = SG_NONE;
	SG_FUNCTION =                        $000023;

	//Это для SaGeMath
	SG_ERROR =                           $000024;
	SG_WARNING =                         $000025;
	SG_NOTE =                            $000026;

	//Тип проэкции для SaGeRender
	SG_2D =                              $000027;

	//Это для SaGeShaders
	SG_GLSL_3_0 =                        $000028;
	SG_GLSL_ARB =                        $000029;
const
	SGSaGeDirectory = 
		{$IFDEF MOBILE}
			{$IFDEF ANDROID}
				DirectorySeparator + 'sdcard' + DirectorySeparator + '.SaGe'
			{$ELSE}
				''
			{$ENDIF}
		{$ELSE}
			'.' + DirectorySeparator + '..'
		{$ENDIF}
	;
	SGDataDirectory = '.' + DirectorySeparator + '..' + DirectorySeparator + 'Data';
	SGFontDirectory = SGDataDirectory + DirectorySeparator +'Fonts';
	SGTextureDirectory = SGDataDirectory + DirectorySeparator +'Textures';
	SGTexturesDirectory = SGTextureDirectory;
	SGFontsDirectory = SGFontDirectory;
	SGModelsDirectory = SGDataDirectory + DirectorySeparator +'Models';
	SGExamplesDirectory = SGDataDirectory + DirectorySeparator +'Examples';
	SGEngineDirectory = SGDataDirectory + DirectorySeparator +'Engine';
	SGImagesDirectory =
		{$IFDEF ANDROID}
			DirectorySeparator + 'sdcard' + DirectorySeparator + 'Images'
		{$ELSE}
			SGDataDirectory + DirectorySeparator +'Images'
		{$ENDIF}
	;
	{$IF (not defined(RELEASE)) and (not defined(MOBILE))}
		SGTempDirectory = '.'+DirectorySeparator+'..'+DirectorySeparator+'Temp';
		{$ENDIF}
type
	TSGViewErrorCase = (
		SGPrintError,
		SGLogError);
	TSGViewErrorType = set of TSGViewErrorCase;
const
	SGViewErrorFull  : TSGViewErrorType = [SGPrintError, SGLogError];
	SGViewErrorPrint : TSGViewErrorType = [SGPrintError];
	SGViewErrorLog   : TSGViewErrorType = [SGLogError];
	SGViewErrorNULL  : TSGViewErrorType = [];
type
	TSGMaxEnum = SaGeBased.TSGMaxEnum;
	//Типы C++
	Float  = type Single;
	Double = type Real;
	Int    = type LongInt;

	//SaGe Unsigned Integer
	SGUint       = type LongWord;
	//Pointer for SaGe Unsigned Integer
	PSGUInt      = ^ SGUint;
	SGInt        = Int64;
	TSGHandle    = type LongInt;
	FileOfByte   = type File Of Byte;
	PFileOfByte  = ^ FileOfByte;

	TSGIdentifier = type LongWord;

	PReal     = ^ real;
	TSGExByte = type Int64;
	PSingle = ^ single;

	TSGSetOfByte   = type packed set   of byte;
	TArBoolean     = type packed array of boolean;
	TSGArBoolean   = type packed array of TSGBoolean;
	TArLongint     = type packed array of longint;
	TArLongword    = type packed array of longword;
	TArByte        = type packed array of byte;
	TArInteger     = type packed array of integer;
	TArWord        = type packed array of word;
	TArInt64       = type packed array of int64;
	TArReal        = type packed array of real;
	TArExtended    = type packed array of extended;
	TArTArLongWord = type packed array of TArLongWord;
	TArConst       = type packed array of TVarRec;
	TSGArConst     = type TArConst;

	PTArLongint  = ^ TArLongint;
	PTArLongword = ^ TArLongword;
	PTArByte     = ^ TArByte;
	PTArInteger  = ^ TArInteger;
	PTArWord     = ^ TArWord;
	PTArInt64    = ^ TArInt64;

	//Строки C++
	PChar    = ^ Char;
	SGPChar  = PChar;
	TArPChar = type packed array of PChar;
	TArChar  = type packed array of Char;

	//Файлики
	PText     = ^ TextFile;
	Text      = TextFile;
	PTextFile = ^ TextFile;

	TSGCaption =  TSGString;

	SGProcedure  = type TProcedure;
	TSGProcedure = type SGProcedure;

	SGFrameButtonsType = type TSGExByte;
type
	ArLong01          = packed array [0..1] of LongWord;
	PArLong01         = ^ ArLong01;
	SGObjectProcedure = ArLong01;

	//Расширение TSGBoolean. Тут есть SG_TRUE, SG_FALSE и SG_UNKNOWN
	TSGExBoolean = type TSGByte;

	//Начальный класс SaGe
	TSGClass=class;
	TSGClassClass = class of TSGClass;
	TSGClassOfClass = TSGClassClass;
	TSGClass=class
			public
		constructor Create();virtual;
		destructor Destroy();override;
		class function ClassName():TSGString;virtual;
		function Get(const What:string):TSGPointer;virtual;
		end;
const
	fmCreate = Classes.fmCreate;
	fmOpenRead = Classes.fmOpenRead;
const
	SGSetExists               : TSGExByte = 100;
	SGSetNote                 : TSGExByte = 101;
	SGSetExistsNext           : TSGExByte = 102;
	SGSetExistsAndExistsNext  : TSGExByte = 103;
type
	//Множество строк
	TSGSetOfString=class
			public
		constructor Create;
		destructor Destroy;override;
			public
		FArray:packed array of string;
			public
		procedure AddItem(const FItem:string);inline;
		function  HaveItem(const FItem:String):Boolean;overload;inline;
		function  ExistsItem(const FItem:String):TSGExByte;overload;
		procedure KillItem(const FItem:string);
		end;
const
	//Значения, которые может принимать type TSGExBoolean
	SG_TRUE = TSGExBoolean(1);
	SG_FALSE = TSGExBoolean(0);
	SG_UNKNOWN = TSGExBoolean(2);

//Сливает массивы Real-ов
operator + (a,b:TArReal):TArReal;inline;

//Загружает часть потока в другой поток
procedure SGLoadLoadPartStreamToStream(const StreamIn,StreamOut:TStream; const Size:Int64);overload;inline;

//Загружает часть потока в другой поток. Оптимизировано под TMemoryStream
procedure SGLoadLoadPartStreamToStream(const StreamIn:TStream;StreamOut:TMemoryStream; const Size:Int64);overload;inline;

implementation

uses
	 StrMan
	
	,SaGeStringUtils
	,SaGeThreads
	,SaGeDateTime
	,SaGeEncodingUtils
	,SaGeConsoleUtils
	,SaGeMathUtils
	,SaGeSysUtils
	,SaGeLog
	,SaGeBaseUtils
	;


class function TSGClass.ClassName():TSGString;
begin
Result:='';
end;

function TSGClass.Get(const What:string):TSGPointer;
begin
Result:=nil;
end;


constructor TSGClass.Create;
begin
inherited;
end;

destructor TSGClass.Destroy;
begin
inherited;
end;

procedure SGLoadLoadPartStreamToStream(const StreamIn:TStream;StreamOut:TMemoryStream; const Size:Int64);overload;inline;
var
	SizeOld:Int64;
begin
SizeOld:=StreamOut.Size;
StreamOut.Size:=SizeOld+Size;
StreamIn.ReadBuffer(PByte(StreamOut.Memory)[SizeOld],Size);
StreamOut.Position:=Size+SizeOld;
end;

procedure SGLoadLoadPartStreamToStream(const StreamIn,StreamOut:TStream; const Size:Int64);overload;inline;
var
	Point:PByte;
begin
GetMem(Point,Size);
StreamIn.ReadBuffer(Point^,Size);
StreamOut.WriteBuffer(Point^,Size);
FreeMem(Point,Size);
end;

function TSGSetOfString.HaveItem(const FItem:String):Boolean;overload;inline;
begin
Result:=(ExistsItem(FItem) in [SGSetExists,SGSetExistsAndExistsNext]);
end;

procedure TSGSetOfString.KillItem(const FItem:string);
var
	i,ii:LongInt;
begin
for i:=0 to High(FArray) do
	if FArray[i]=FItem then
		begin
		for ii:=i+1 to High(FArray) do
			FArray[ii-1]:=FArray[ii];
		SetLength(FArray,Length(FArray)-1);
		Break;
		end;
end;

constructor TSGSetOfString.Create;
begin
FArray:=nil;
end;

destructor TSGSetOfString.Destroy;
begin
SetLength(FArray,0);
FArray:=nil;
end;

procedure TSGSetOfString.AddItem(const FItem:string);inline;
begin
SetLength(FArray,Length(FArray)+1);
FArray[High(FArray)]:=FItem;
end;

function TSGSetOfString.ExistsItem(const FItem:String):TSGExByte;overload;
var
	i:LongInt;
begin
Result:=SGSetNote;
for i:=0 to High(FArray) do
	begin
	if FArray[i]=FItem then
		begin
		if Result=SGSetExistsNext then
			Result:=SGSetExistsAndExistsNext
		else
			if Result=SGSetNote then
				Result:=SGSetExists;
		end;
	if SGExistsFirstPartString(FArray[i],FItem) then
		begin
		if Result=SGSetNote then
			Result:=SGSetExistsNext
		else
			if Result=SGSetExists then
				Result:=SGSetExistsAndExistsNext;
		end;
	if Result=SGSetExistsAndExistsNext then
		Break;
	end;
end;

operator + (a,b:TArReal):TArReal;inline;
var
	i,ii:LongInt;
begin
SetLength(Result,Length(a)+Length(b));
i:=0;
while i<Length(a) do
	begin
	Result[i]:=a[i];
	i+=1;
	end;
ii:=0;
while ii<Length(b) do
	begin
	Result[i+ii]:=b[ii];
	ii+=1;
	end;
end;

end.
