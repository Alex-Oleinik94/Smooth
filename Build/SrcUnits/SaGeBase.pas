{$IFDEF MSWINDOWS}
	{$R .\..\SaGe.res}
	{$ENDIF}
{$I Includes\SaGe.inc}
unit SaGeBase;

interface

uses 
	crt
	,dos
	{$IFDEF MSWINDOWS}
		,windows
		,MMSystem
		{$ENDIF}
	{$IFDEF UNIX}
		,unix
		,dl
		{$ENDIF}
	,DynLibs
	,SaGeBased
	,SysUtils
	,Classes
	,uSMBIOS
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
	SGAnsiToASCII: packed array[char] of char = {Ansi - WINDOWS1251(CP1251); ASCII - CP866 }
    (#$00, #$01, #$02, #$03, #$04, #$05, #$06, #$07,   { $00 - $07 }
     #$08, #$09, #$0a, #$0b, #$0c, #$0d, #$0e, #$0f,   { $08 - $0f }
     #$10, #$11, #$12, #$13, #$14, #$15, #$16, #$17,   { $10 - $17 }
     #$18, #$19, #$1a, #$1b, #$1c, #$1d, #$1e, #$1f,   { $18 - $1f }
     #$20, #$21, #$22, #$23, #$24, #$25, #$26, #$27,   { $20 - $27 }
     #$28, #$29, #$2a, #$2b, #$2c, #$2d, #$2e, #$2f,   { $28 - $2f }
     #$30, #$31, #$32, #$33, #$34, #$35, #$36, #$37,   { $30 - $37 }
     #$38, #$39, #$3a, #$3b, #$3c, #$3d, #$3e, #$3f,   { $38 - $3f }
     #$40, #$41, #$42, #$43, #$44, #$45, #$46, #$47,   { $40 - $47 }
     #$48, #$49, #$4a, #$4b, #$4c, #$4d, #$4e, #$4f,   { $48 - $4f }
     #$50, #$51, #$52, #$53, #$54, #$55, #$56, #$57,   { $50 - $57 }
     #$58, #$59, #$5a, #$5b, #$5c, #$5d, #$5e, #$5f,   { $58 - $5f }
     #$60, #$61, #$62, #$63, #$64, #$65, #$66, #$67,   { $60 - $67 }
     #$68, #$69, #$6a, #$6b, #$6c, #$6d, #$6e, #$6f,   { $68 - $6f }
     #$70, #$71, #$72, #$73, #$74, #$75, #$76, #$77,   { $70 - $77 }
     #$78, #$79, #$7a, #$7b, #$7c, #$7d, #$7e, #$7f,   { $78 - $7f }
     '?' , '?' , '?' , '?' , '?' , '?' , '?' , '?' ,   { $80 - $87 }
     '?' , '?' , '?' , '?' , '?' , '?' , '?' , '?' ,   { $88 - $8f }
     '?' , '?' , '?' , '?' , '?' , '?' , '?' , '?' ,   { $90 - $97 }
     '?' , '?' , '?' , '?' , '?' , '?' , '?' , '?' ,   { $98 - $9f }
     #$ff, #$ad, #$9b, #$9c, '?' , #$9d, '?' , '?' ,   { $a0 - $a7 }
     '?' , '?' , #$a6, #$ae, #$aa, '?' , '?' , '?' ,   { $a8 - $af }
     #$f8, #$f1, #$fd, '?' , '?' , #$e6, '?' , #$fa,   { $b0 - $b7 }
     '?' , '?' , #$a7, #$af, #$ac, #$ab, '?' , #$a8,   { $b8 - $bf }
     '?' , '?' , '?' , '?' , #$8e, #$8f, #$92, #$80,   { $c0 - $c7 }
     '?' , #$90, '?' , '?' , '?' , '?' , '?' , '?' ,   { $c8 - $cf }
     '?' , #$a5, '?' , '?' , '?' , '?' , #$99, '?' ,   { $d0 - $d7 }
     '?' , '?' , '?' , '?' , #$9a, '?' , '?' , #$e1,   { $d8 - $df }
     #$85, #$a0, #$83, '?' , #$84, #$86, #$91, #$87,   { $e0 - $e7 }
     #$8a, #$82, #$88, #$89, #$8d, #$a1, #$8c, #$8b,   { $e8 - $ef }
     '?' , #$a4, #$95, #$a2, #$93, '?' , #$94, #$f6,   { $f0 - $f7 }
     '?' , #$97, #$a3, #$96, #$81, '?' , '?' , #$98);  { $f8 - $ff }
const
	SGFrameButtonsType0f =               $000003;
	SGFrameButtonsTypeCleared = SGFrameButtonsType0f;
	SGFrameButtonsType1f =               $000004;
	SGFrameButtonsType3f =               $000005;
	
	SGObjectTimerConst : real = 0.02;
	
	SGFrameAnimationConst = 200;
	SGFrameFObject = 5;
	SGFrameFNObject = 1;
	
	SGAlignNone =                        $000006;
	SGAlignLeft =                        $000007;
	SGAlignRight =                       $000008;
	SGAlignTop =                         $000009;
	SGAlignBottom =                      $00000A;
	SGAlignClient =                      $00000B;
	
	SGAnchorRight =                      $00000D;
	SGAnchorLeft =                       $00000E;
	SGAnchorTop =                        $00000F;
	SGAnchorBottom =                     $000010;
	
	SG_3D =                              $000011;
	SG_3D_ORTHO =                        $000012;
	SG_VERTEX_FOR_CHILDREN =             $000013;
	SG_VERTEX_FOR_PARENT =               $000014;
	
	SG_LEFT =                            $000015;
	SG_TOP =                             $000016;
	SG_HEIGHT =                          $000017;
	SG_WIDTH =                           $000018;
	SG_RIGHT =                           $000019;
	SG_BOTTOM =                          $00001A;
	
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
	
	SG_ERROR =                           $000024;
	SG_WARNING =                         $000025;
	SG_NOTE =                            $000026;
	
	SG_2D =                              $000027;
	
	SG_GLSL_3_0 =                        $000028;
	SG_GLSL_ARB =                        $000029;
const
	WinSlash = '\';
	UnixSlash = '/';
	Slash = 
		{$IFDEF MSWINDOWS}
			WinSlash
		{$ELSE}
			{$IFDEF UNIX}
				UnixSlash
			{$ELSE}
				'/'
				{$ENDIF}
			{$ENDIF}
		;
	DataDirectory = 
		{$IFNDEF ANDROID}
			'.'+Slash+'..'+Slash+'Data'
		{$ELSE}
			'/sdcard'
			{$ENDIF};
	FontDirectory = DataDirectory + Slash +'Fonts';
	TextureDirectory = DataDirectory + Slash +'Textures';
	TexturesDirectory = TextureDirectory;
	FontsDirectory = FontDirectory;
var
	SGLogEnable:Boolean = True;
type
	TSGEnumPointer = 
		{$IFDEF CPU64}
			QWord;
		{$ELSE}
			{$IFDEF CPU32}
				LongWord;
			{$ELSE}
				{$IFDEF CPU16}
					Word;
					{$ENDIF}
				{$ENDIF}
			{$ENDIF}
	TSGMaxEnum = TSGEnumPointer;
	Float = Single;
	Double = Real;
	
	SGUint = type LongWord;
	PSGUInt = ^ SGUint;
	SGInt = Int64;
	TSGHandle = type LongInt;
	TSGLibHandle = type TSGHandle;
	TSGLibrary = TSGLibHandle;
	FileOfByte = type File Of Byte;
	PFileOfByte = ^ FileOfByte;
	
	TSGIdentifier = LongWord;
	
	PReal=^real;
	Int = type LongInt;
	TSGByte = type Int64;
	SGByte = TSGByte;
	SGSetOfByte = type packed set of byte;
	TArBoolean = type packed array of boolean;
	TArString = type packed array of string;
	TArLongint = type packed array of longint;
	TArLongword = type packed array of longword;
	TArByte = type packed array of byte;
	TArInteger = type packed array of integer;
	TArWord = type packed array of word;
	TArInt64 = type packed array of int64;
	TArReal = type packed array of real;
	TArExtended = type packed array of extended;
	
	PTArLongint = ^ TArLongint;
	PTArLongword = ^ TArLongword;
	PTArByte = ^ TArByte;
	PTArInteger = ^ TArInteger;
	PTArWord = ^ TArWord;
	PTArInt64 = ^ TArInt64;
	
	TArTArLongWord = type packed array of TArLongWord;
	
	PChar=^Char;
	SGPChar = PChar;
	TArPChar = type packed array of PChar;
	TArChar = type packed array of Char;
	
	PText=^TextFile;
	Text=TextFile;
	PTextFile=^TextFile;
	
	TSGCaption =  string;
	SGCaption = TSGCaption;
	
	SGProcedure = type TProcedure;
	
	SGFrameButtonsType = type TSGByte;
	
	TSGProcedure = TProcedure;
type
	PTSGPlane = ^ TSGPlane;
	TSGPlane=object
		a,b,c,d:real;
		procedure Import(const a1:real = 0; const b1:real = 0; const c1:real = 0; const d1:real = 0);inline;
		procedure Write;inline;
		end;
	PSGPlane = PTSGPlane;
	SGPlane = TSGPlane;
type
	ArLong01=packed array [0..1] of LongWord;
	PArLong01 = ^ArLong01;
	SGObjectProcedure = ArLong01;
	
	TSGBoolean = type TSGByte;
	
	TSGLibraryClass=class
			public
		constructor Create;
		destructor Destroy;override;
			public
		FSaGeLibrary:TSGLibrary;
			public
		property SaGeLibrary : TSGLibrary read FSaGeLibrary;
		function qwerty(const Index:LongWord):float;virtual;abstract;
			public
		property qwertp[Index : LongWord]:float read qwerty;
		end;
	
	TSGArTObject = type packed array of TObject;
	
	TSGObject=class(TObject);
	
	TSGClass=class;
	TSGClassClass = class of TSGClass;
	TSGClassOfClass = TSGClassClass;
	TSGClass=class(TSGObject)
			public
		constructor Create;virtual;
		destructor Destroy;override;
		class function ClassName:String;virtual;abstract;
		function Get(const What:string):Pointer;virtual;abstract;
		end;
	
	TMemoryStream = Classes.TMemoryStream;
	
	TArFrom1To8OfLongInt = array[1..8] of LongInt;
	PArFrom1To8OfLongInt = ^TArFrom1To8OfLongInt;
	TSGDateTime=object
		Years,Month,Day,Week:LongInt;
		Hours,Minutes,Seconds,Sec100:LongInt;
		procedure Get;
		function GetPastSecondsFrom(const a:TSGDateTime):int64;
		function GetPastSeconds:int64;
		procedure Write;
		procedure Import(a1,a2,a3,a4,a5,a6,a7,a8:LongInt);
		procedure ImportFromSeconds( Sec:int64);
		procedure Clear;
		function GetPastMiliSeconds:int64;
		function GetPastMiliSecondsFrom(const a:TSGDateTime):int64;
		end;
	TSGDataTime=TSGDateTime;
	
	TSGThreadProcedure = procedure ( p : pointer );
	TSGThreadFunctionResult = 
	{$IFDEF MSWINDOWS}
		LongWord;
	{$ELSE}
		{$IFDEF UNIX}
			{$IFDEF CPU32}
				LongInt;
				{$ENDIF}
			{$IFDEF CPU64}
				Int64;
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
	TSGThreadFunction = function ( p:pointer ) : TSGThreadFunctionResult; {$IFDEF MSWINDOWS}stdcall;{$ENDIF}
	TSGThread=class(TSGObject)
			public
		constructor Create(const Proc:TSGThreadProcedure;const Para:Pointer = nil;const QuickStart:Boolean = True);
		destructor Destroy;override;
			public
		FHandle:LongWord;
		FFinished:Boolean;
		FProcedure:TSGThreadProcedure;
		FParametr:Pointer;
		FThreadID:LongWord;
		procedure Execute;virtual;
		procedure Start;virtual;
		property Finished: boolean read FFinished write FFinished;
		procedure SetProcedure(const Proc:TSGThreadProcedure);
		procedure SetParametr(const Pointer:Pointer);
		end;
	SGThread = TSGThread;
	ArTSGThread = type packed array of TSGThread;
	TArTSGThread = ArTSGThread; 
const
	SGSetExists:TSGByte = 100;
	SGSetNote:TSGByte = 101;
	SGSetExistsNext:TSGByte = 102;
	SGSetExistsAndExistsNext:TSGByte = 103;
type
	TSGSetOfString=class
			public
		constructor Create;
		destructor Destroy;override;
			public
		FArray:packed array of string;
			public
		procedure AddItem(const FItem:string);inline;
		function HaveItem(const FItem:String):Boolean;overload;inline;
		function ExistsItem(const FItem:String):TSGByte;overload;
		procedure KillItem(const FItem:string);
		end;
	TSGLog=class(TObject)
			public
		constructor Create;
		destructor Destroy;override;
		procedure Sourse(const s:string;const WithTime:Boolean = True);
		procedure Sourse(const Ar:array of const;const WithTime:Boolean = True);
			private
		FFileStream:TFileStream;
		end;
	TSGConsoleRecord=packed record
			FTittle:string;
			FProcedure:TSGProcedure;
			end;
	TSGConsoleMenuArray=packed array of TSGConsoleRecord;
const 
	SG_TRUE = TSGBoolean(1);
	SG_FALSE = TSGBoolean(0);
	SG_UNKNOWN = TSGBoolean(2);

var
	SGZero:extended = 0.00001;
	SGLog:TSGLog = nil;
	Nan:real;
	Inf:real;
type
	SGCLProcedureWC =  procedure ( Context:Pointer) ;
var
	SGCLPaintProcedure : SGCLProcedureWC = nil;
	SGCLForReSizeScreenProcedure : SGCLProcedureWC = nil;
	SGCLLoadProcedure : SGCLProcedureWC = nil;
operator + (a,b:TArReal):TArReal;inline;
function LoadLibrary(AName: PChar): TSGLibHandle;
function GetProcAddress(const Lib:TSGLibrary;const VPChar:PChar):Pointer;
function SGTruncUp(const t:real):LongInt;inline;
operator -(a,b:TSGDateTime):TSGDateTime;inline;
function SGReadStringFromStream(const Stream:TStream):String;inline;
procedure SGWriteStringToStream(const String1:String;const Stream:TStream;const Stavit00:Boolean = True);inline;
function SGReadStringInQuotesFromTextFile(const TextFile:PText):String;
function SGReadWordFromTextFile(const TextFile:PTextFile):String;
function SGUpCaseString(const S:String):String;
function SGStringAsPChar(var Str:String):PChar;
function SGPCharIf(const Bool:Boolean;const VPChar:PChar):PChar;
function SGGetFileNames(const Catalog:String;const What:String = ''):TArString;
function SGPCharNil:PChar;inline;
function SGStr(const Number : LongInt = 0):String;inline;overload;
function SGSecondsToStringTime(VSeconds:Int64):string;inline;
function SGWhatIsTheSimbol(const l:longint;const Shift:Boolean = False;const Caps:Boolean = False):string;inline;
function SGGetLanguage:String;inline;
function SGWhatIsTheSimbolRU(const l:longint;const Shift:boolean = False;const Caps:Boolean = False):string;inline;
function SGWhatIsTheSimbolEN(const l:longint;const Shift:boolean = False;const Caps:Boolean = False):string;inline;
function SGMax(const a,b:single):single;inline;overload;
function SGMax(const a,b:real):real;inline;overload;
function SGMax(const a,b:extended):extended;inline;overload;
function SGMin(const a,b:single):single;inline;overload;
function SGMin(const a,b:real):real;inline;overload;
function SGMin(const a,b:extended):extended;inline;overload;
function SGGetFileExpansion(const FileName:string):string;inline;
function SGExistsFirstPartString(const AString:String;const Part:String):Boolean;
function SGReadStringInQuotesFromStream(Const Stream:TStream;const Quote:char = #39):string;inline;
procedure SGLoadLoadPartStreamToStream(const StreamIn,StreamOut:TStream; const Size:Int64);overload;inline;
procedure SGLoadLoadPartStreamToStream(const StreamIn:TStream;StreamOut:TMemoryStream; const Size:Int64);overload;inline;
function Log(const a,b:real):real;inline;
function SGPCharLength(const pc:PChar):int64;inline;
function SGStr(const b:boolean):String;overload;inline;
function SGGetSizeString(const Size:Int64):String;inline;
function SGStrReal(r:real;const l:longint):string;
function SGMax(const a,b:Int64):Int64;inline;overload;
function SGStringToPChar(const s:string):PCHAR;
function SGFileExists(const FileName:string = ''):boolean;
operator + (const a,b:TSGConsoleRecord):TSGConsoleMenuArray;overload;inline;
operator + (const a:TSGConsoleMenuArray;b:TSGConsoleRecord):TSGConsoleMenuArray;overload;inline;
function SGConsoleRecord(const s:string;const p:pointer):TSGConsoleRecord;inline;
procedure SGConsoleMenu(const Ar:TSGConsoleMenuArray;
	const VBackGround:LongWord = 0;
	const VText:LongWord = 15;
	const VActiveBackGround:LongWord = 0;
	const VActiveText:LongWord = 10;
	const Koima:Boolean = True);
function SGPCharToString(const VChar:PChar):string;inline;
function SGMin(const a,b:LongInt):LongInt;overload;inline;
function SGMin(const a,b:LongWord):LongWord;overload;inline;
function SGMin(const a,b:Int64):Int64;overload;inline;
function SGMin(const a,b:QWord):QWord;overload;inline;
function SGStrExtended(r:Extended;const l:longint):string;inline;
function SGVal(const Text:string = '0'):Int64;inline;overload;
function SGStringIf(const B:Boolean;const s:string):string;inline;
function SGStringGetPart(const S:string;const a,b:LongWord):String;
procedure SGQuickSort(var Arr; const ArrLength,SizeOfElement:Int64;const SortFunction:Pointer);
function SGGetStringFromConstArray(const Ar:packed array of const):String;
function SGGetFileName(const WayName:string):string;
procedure SGReleaseFileWay(WAy:string);
function SGGetFileWay(const Way:String):String;
function SGMakeDirectory(const DirWay:String):Boolean;inline;
procedure FindInPas(const Cmd:Boolean = False);
function SGGetMatrix2x2(a1,a2,a3,a4:real):real;inline;
function SGGetMatrix3x3(a1,a2,a3,a4,a5,a6,a7,a8,a9:real):real;inline;
function SGPCharAddSimbol(var VPChar:PChar; const VChar:Char):PChar;

function SGPCharsEqual(const PChar1,PChar2:PChar):Boolean;inline;
function SGPCharHigh(const VPChar:PChar):LongInt;inline;
function SGPCharLength(const VPChar:PChar):LongWord;inline;
function SGPCharDecFromEnd(var VPChar:PChar; const Number:LongWord = 1):PChar;
function SGPCharUpCase(const VPChar:PChar):PChar;inline;
function SGPCharRead:PChar;inline;
function SGCharRead:Char;inline;
function SGPCharDeleteSpaces(const VPChar:PCHAR):PChar;inline;
function SGPCharTotal(const VPChar1,VPChar2:PChar):PChar;inline;

function SGRealsEqual(const r1,r2:real):Boolean;inline;
function SGRealExists(const r:real):Boolean;inline;
procedure SGQuickRePlaceReals(var Real1,Real2:Real);inline;
function SGRandomMinus():Int;inline;
function SGGetPlaneFromNineReals(const x1,y1,z1,x2,y2,z2,x0,y0,z0:real):SGPlane;
procedure SGQuickRePlaceLongInt(var LongInt1,LongInt2:LongInt);inline;
function SGPCharGetPart(const VPChar:PChar;const Position1,Position2:LongInt):PChar;
function SGGetQuantitySimbolsInNumber(l:LongInt):LongInt;inline;
function SGGetFreeFileName(const Name:string;const sl:string = 'Copy'):string;inline;
function SGGetFileNameWithoutExpansion(const FileName:string):string;inline;
function SGFloatToString(const R:Extended;const Zeros:LongInt = 0):string;inline;
function SGReadLnString:String;
function SGReadLnByte:Byte;
function SGGetFreeDirectoryName(const Name:string;const sl:string = 'Copy'):string;inline;

procedure SGSetCLProcedure(const p:Pointer = nil);
procedure SCSetCLScreenBounds(const p:Pointer = nil);
procedure SGSetCLLoadProcedure(p:Pointer);

function SGGetComand(const comand:string):string;inline;
function SGExistsDirectory(const DirWay:String):Boolean;inline;
function SGGetCurrentDirectory():string;inline;

//Это тупая и очень тупая процедура, сделал ее специально для андроида.
(*Скорее всего она не найдет свое применение, но для начала не помешает*)
//В общем ты ей задаешь файл, а она тебе пишет модуль на паскале
//И при вызове особой процедурки из этого модуля при включении 
//Этого модуля в программу у тебя конструируется TMemoryStream,
//В котором и будет тот файл, который ты задал в FileName
procedure SGResourseManager(const FileName,UnitWay,NameUnit:string);

//Возвращает количество логических ядер процессора
function SGGetCoreCount():Byte;inline;

implementation


function SGGetCoreCount():Byte;inline;
Var
  SMBios             : TSMBios;
  LProcessorInfo     : TProcessorInformation;
begin
Result:=0;
SMBios:=TSMBios.Create();
try
	if SMBios.HasProcessorInfo then
		for LProcessorInfo in SMBios.ProcessorInfo do
			if SMBios.SmbiosVersion>='2.5' then
				Result:=LProcessorInfo.RAWProcessorInformation^.CoreCount;
finally
	SMBios.Free;
	end;
end;


procedure SGResourseManager(const FileName,UnitWay,NameUnit:string);
var
	Step:LongWord = 100;
var
	OutStream:TStream = nil;
	InStream:TStream = nil;
	A:array of Byte;
	I,iiii,i5:LongWord;
procedure WriteProc(const ThisStep:LongWord);
var
	III,II:LongWord;
begin
InStream.ReadBuffer(A[0],ThisStep);
SGWriteStringToStream('procedure '+NameUnit+'_LoadToStream_'+SGStr(I)+'(const Stream:TStream);'+#13+#10,OutStream,False);
I+=1;
SGWriteStringToStream('var'+#13+#10,OutStream,False);
SGWriteStringToStream('	A:array ['+'1..'+SGStr(ThisStep)+'] of byte = ('+#13+#10+'	',OutStream,False);
II:=0;
for iii:=0 to ThisStep-1 do
	begin
	if II=10 then
		begin
		SGWriteStringToStream(''+#13+#10+'	',OutStream,False);
		II:=0;
		end;
	SGWriteStringToStream(SGStr(A[iIi]),OutStream,False);
	if III<>ThisStep-1 then
		SGWriteStringToStream(', ',OutStream,False);
	II+=1;
	end;
SGWriteStringToStream(');'+#13+#10,OutStream,False);
SGWriteStringToStream('begin'+#13+#10,OutStream,False);
SGWriteStringToStream('Stream.WriteBuffer(A,'+SGStr(ThisStep)+');'+#13+#10,OutStream,False);
SGWriteStringToStream('end;'+#13+#10,OutStream,False);
end;
begin
I:=0;
SetLength(A,Step);
OutStream:=TFileStream.Create(UnitWay+Slash+NameUnit+'.pas',fmCreate);
InStream:=TFileStream.Create(FileName,fmOpenRead);
SGWriteStringToStream('{$MODE OBJFPC}'+#13+#10,OutStream,False);
SGWriteStringToStream('unit '+NameUnit+';'+#13+#10,OutStream,False);
SGWriteStringToStream('interface'+#13+#10,OutStream,False);
SGWriteStringToStream('uses'+#13+#10,OutStream,False);
SGWriteStringToStream('	Classes;'+#13+#10,OutStream,False);
SGWriteStringToStream('function '+NameUnit+'_LoadToStream():TMemoryStream;'+#13+#10,OutStream,False);
SGWriteStringToStream('implementation'+#13+#10,OutStream,False);
while InStream.Position<=InStream.Size-Step do
	WriteProc(Step);
if InStream.Position<>InStream.Size then
	begin
	IIii:=InStream.Size-InStream.Position;
	WriteProc(IIii);
	end;
SGWriteStringToStream('function '+NameUnit+'_LoadToStream():TMemoryStream;'+#13+#10,OutStream,False);
SGWriteStringToStream('begin'+#13+#10,OutStream,False);
SGWriteStringToStream('Result:=TMemoryStream.Create();'+#13+#10,OutStream,False);
for i5:=0 to i-1 do
	SGWriteStringToStream(NameUnit+'_LoadToStream_'+SGStr(i5)+'(Result);'+#13+#10,OutStream,False);
SGWriteStringToStream('end;'+#13+#10,OutStream,False);
SGWriteStringToStream('end.'+#13+#10,OutStream,False);
SetLength(A,0);
end;

function SGGetCurrentDirectory():string;inline;
begin
if argc>0 then
	Result:=SGGetFileWay(argv[0])
else
	Result:='';
end;

function SGExistsDirectory(const DirWay:String):Boolean;inline;
begin
Result:=False;
try
MKDir(DirWay);
except
Result:=True;
end;
if Result=False then
	RMDIR(DirWay);
end;

function SGGetComand(const comand:string):string;inline;
var
	i:LongWord;
begin
if comand[1]='-' then
	begin
	Result:='';
	for i:=2 to Length(comand) do
		Result+=comand[i];
	Result:=SGUpCaseString(Result);
	end
else
	Result:=Comand;
end;

procedure SGSetCLLoadProcedure(p:Pointer);
begin
SGCLLoadProcedure:=SGCLProcedureWC(p);
end;


procedure SGSetCLProcedure(const p:Pointer = nil);
begin
SGCLPaintProcedure:=SGCLProcedureWC(p);
end;

procedure SCSetCLScreenBounds(const p:Pointer = nil);
begin
SGCLForReSizeScreenProcedure:=SGCLProcedureWC(p);
end;

procedure SGQuickRePlaceLongInt(var LongInt1,LongInt2:LongInt);inline;
var
	LongInt3:LongInt;
begin
LongInt3:=LongInt1;
LongInt1:=LongInt2;
LongInt2:=LongInt3;
end;

function SGReadLnByte:Byte;
begin 
Readln(Result);
end;

function SGReadLnString:String;
begin
Readln(Result);
end;

function SGPCharGetPart(const VPChar:PChar;const Position1,Position2:LongInt):PChar;
var
	i:LongInt;
begin
Result:='';
i:=Position1;
while (VPChar[i]<>#0) and (i<>Position2+1) do
	begin
	SGPCharAddSimbol(Result,VPChar[i]);
	i+=1;
	end;
end;

function SGGetQuantitySimbolsInNumber(l:LongInt):LongInt;inline;
begin
Result:=0;
while l<>0 do
	begin
	Result+=1;
	l:=l div 10;
	end;
end;

function SGFloatToString(const R:Extended;const Zeros:LongInt = 0):string;inline;
var
	i:LongInt;
begin
Result:='';
if Trunc(R)=0 then
	begin
	if R<0 then
		Result+='-';
	Result+='0';
	end
else
	Result+=SGStr(Trunc(R));
if Zeros<>0 then
	begin
	if Abs(R-Trunc(R))*10**Zeros<>0 then
		begin
		i:=Zeros-SGGetQuantitySimbolsInNumber(Trunc(Abs(R-Trunc(R))*(10**Zeros)));
		Result+='.';
		while i>0 do
			begin
			i-=1;
			Result+='0';
			end;
		Result+=SGStr(Trunc(Abs(R-Trunc(R))*(10**Zeros)));
		while Result[Length(Result)]='0' do
			SetLength(Result,Length(Result)-1);//Byte(Result[0])-=1;
		if Result[Length(Result)]='.' then
			SetLength(Result,Length(Result)-1);//Byte(Result[0])-=1;
		end;
	end;
end;

function SGGetFileNameWithoutExpansion(const FileName:string):string;inline;
var
	i:LongInt;
	PointPosition:LongInt = 0;
begin
for i:=1 to Length(FileName) do
	begin
	if FileName[i]='.' then
		begin
		PointPosition:=i;
		end;
	end;
if (PointPosition=0) then
	Result:=FileName
else
	begin
	Result:='';
	for i:=1 to PointPosition-1 do
		Result+=FileName[i];
	end;
end;

function SGGetFreeDirectoryName(const Name:string;const sl:string = 'Copy'):string;inline;
var 
	Number:LongInt = 1;
begin
if SGExistsDirectory(Name) then
	begin
	while SGExistsDirectory(Name+' ('+Sl+' '+SGStr(Number)+')') do
		Number+=1;
	Result:=Name+' ('+Sl+' '+SGStr(Number)+')';
	end
else
	Result:=Name;
end;

function SGGetFreeFileName(const Name:string; const Sl:string = 'Copy'):string;inline;
var
	FileExpansion:String = '';
	FileName:string = '';
	Number:LongInt = 1;

begin
if FileExists(Name) then
	begin
	FileExpansion:=SGGetFileExpansion(Name);
	FileName:=SGGetFileNameWithoutExpansion(Name);
	while FileExists(FileName+' ('+Sl+' '+SGStr(Number)+').'+FileExpansion) do
		Number+=1;
	Result:=FileName+' ('+Sl+' '+SGStr(Number)+').'+FileExpansion;
	end
else
	Result:=Name;
end;

function SGGetPlaneFromNineReals(const x1,y1,z1,x2,y2,z2,x0,y0,z0:real):SGPlane;
begin
Result.Import(
	+SGGetMatrix2x2(y1-y0,z1-z0,y2-y0,z2-z0),
	-SGGetMatrix2x2(x1-x0,z1-z0,x2-x0,z2-z0),
	+SGGetMatrix2x2(x1-x0,y1-y0,x2-x0,y2-y0),
	-x0*SGGetMatrix2x2(y1-y0,z1-z0,y2-y0,z2-z0)
	+y0*SGGetMatrix2x2(x1-x0,z1-z0,x2-x0,z2-z0)
	-z0*SGGetMatrix2x2(x1-x0,y1-y0,x2-x0,y2-y0))
end;

procedure TSGPlane.Import(const a1:real = 0; const b1:real = 0; const c1:real = 0; const d1:real = 0);
begin
a:=a1;
b:=b1;
c:=c1;
d:=d1;
end;

procedure TSGPlane.Write;
begin
System.Write(a:0:10,' ',b:0:10,' ',c:0:10,' ',d:0:10);
end;

function SGRandomMinus:Int;inline;
begin
if random(2)=0 then
	Result:=-1
else
	Result:=1;
end;

procedure SGQuickRePlaceReals(var Real1,Real2:Real);inline;
var
	Real3:Real;
begin
Real3:=Real1;
Real1:=Real2;
Real2:=Real3;
end;

function SGRealExists(const r:real):Boolean;inline;
begin
Result:={(r<>Nan) and} (r<>Inf) and (r<>-Inf);
end;

function SGRealsEqual(const r1,r2:real):Boolean;inline;
begin
Result:=abs(r1-r2)<=SGZero;
end;

function SGPCharTotal(const VPChar1,VPChar2:PChar):PChar;inline;
var
	Length1:LongInt = 0;
	Length2:LongInt = 0;
	I:LongInt = 0;
begin
Length1:=SGPCharLength(VPChar1);
Length2:=SGPCharLength(VPChar2);
Result:=nil;
GetMem(Result,Length1+Length2+1);
Result[Length1+Length2]:=#0;
for I:=0 to Length1-1 do
	Result[I]:=VPChar1[i];
for i:=Length1 to Length1+Length2-1 do
	Result[I]:=VPChar2[I-Length1];
end;

function SGPCharDeleteSpaces(const VPChar:PCHAR):PChar;inline;
var
	I:Longint = 0;
begin
GetMem(Result,1);
Result^:=#0;
while VPChar[i]<>#0 do
	begin
	if VPChar[i]<>' ' then
		SGPCharAddSimbol(Result,VPChar[i]);
	I+=1;
	end;
end;

function SGCharRead:Char;inline;
begin
Read(Result);
end;

function SGPCharRead:PChar;inline;
begin
GetMem(Result,1);
Result[0]:=#0;
while not eoln do
	begin
	SGPCharAddSimbol(Result,SGCharRead);
	end;
end;

function SGPCharUpCase(const VPChar:PChar):PChar;inline;
var
	i:LongWord = 0;
begin
Result:=nil;
if (VPChar<>nil) then
	begin
	I:=SGPCharLength(VPChar);
	GetMem(Result,I+1);
	Result[I]:=#0;
	I:=0;
	while VPChar[i]<>#0 do
		begin
		Result[i]:=UpCase(VPChar[i]);
		I+=1;
		end;
	end;
end;

function SGPCharDecFromEnd(var VPChar:PChar; const Number:LongWord = 1):PChar;
var
	NewVPChar:PChar = nil;
	LengthOld:LongWord = 0;
	I:LongInt = 0;
begin
LengthOld:=SGPCharLength(VPChar);
GetMem(NewVPChar,LengthOld-Number+1);
for I:=0 to LengthOld-Number-1 do
	NewVPChar[i]:=VPChar[i];
NewVPChar[LengthOld-Number]:=#0;
VPChar:=NewVPChar;
Result:=NewVPChar;
end;

function SGPCharLength(const VPChar:PChar):LongWord;inline;
begin
Result:=SGPCharHigh(VPChar)+1;
end;

function SGPCharHigh(const VPChar:PChar):LongInt;inline;
begin
if (VPChar = nil) or (VPChar[0] = #0) then
	Result:=-1
else
	begin
	Result:=0;
	while VPChar[Result]<>#0 do
		Result+=1;
	Result-=1;
	end;
end;

function SGPCharsEqual(const PChar1,PChar2:PChar):Boolean;inline;
var
	I:LongInt = 0;
	VExit:Boolean = False;
begin
Result:=True;
if not ((PChar1=nil) and (PChar2=nil)) then
	while Result and (not VExit) do
		begin
		if (PChar1=nil) or (PChar2=nil) or (PChar1[i]=#0) or (PChar2[i]=#0) then
			VExit:=True;
		if  ((PChar1=nil) and (PChar2<>nil) and (PChar2[i]<>#0)) or
			((PChar2=nil) and (PChar1<>nil) and (PChar1[i]<>#0))then
				Result:=False
		else
			if (PChar1<>nil) and (PChar2<>nil) and 
				(((PChar1[i]=#0) and (PChar2[i]<>#0)) or 
				 ((PChar2[i]=#0) and (PChar1[i]<>#0))) then
					Result:=False
			else
				if (PChar1<>nil) and (PChar2<>nil) and 
					(PChar1[i]<>#0) and (PChar2[i]<>#0) and 
					(PChar1[i]<>PChar2[i]) then
						Result:=False;					
		I+=1;
		end;
end;

function SGPCharAddSimbol(var VPChar:PChar; const VChar:Char):PChar;
var
	NewVPChar:PChar = nil;
	LengthOld:LongInt = 0;
	I:LongInt = 0;
begin
if VPChar<>nil then
	begin
	while (VPChar[LengthOld]<>#0) do
		LengthOld+=1;
	end;
GetMem(NewVPChar,LengthOld+2);
for I:=0 to LengthOld-1 do
	NewVPChar[i]:=VPChar[i];
NewVPChar[LengthOld]:=VChar;
NewVPChar[LengthOld+1]:=#0;
VPChar:=NewVPChar;
Result:=NewVPChar;
end;

function SGGetMatrix3x3(a1,a2,a3,a4,a5,a6,a7,a8,a9:real):real;inline;
begin
Result:=a1*SGGetMatrix2x2(a5,a6,a8,a9)-a2*SGGetMatrix2x2(a4,a6,a7,a9)+a3*SGGetMatrix2x2(a4,a5,a7,a8);
end;

function SGGetMatrix2x2(a1,a2,a3,a4:real):real;inline;
begin
Result:=a1*a4-a2*a3;
end;

procedure FindInPas(const Cmd:Boolean = False);
var
	ArWords:array of string = nil;
//nu:	Stream:TFileStream = nil;
	Oy:LongWord;
	PF,PS:LongWord;
	FArF:packed array of TFileStream = nil;
	i,ii:LongWord;
	ArF:packed array of string = nil;
	FDir:string = '.';
var
	TempS,TempS2:String;
	NameFolder:string = '';
	ChisFi:LongWord = 0;
procedure FindInFile(const VFile:String);
var
	f:text;
	Str:string;
	i:LongWord;
	ii:LongWord;
	iii:LongWord;
	iiii:LongWord;
	KolStr:LongWord = 0;
begin
PF+=1;
assign(f,VFile);
reset(f);
KolStr:=0;
while not eof(f) do
	begin
	KolStr+=1;
	readln(f,str);
	for ii:=1 to Length(str) do
		str[ii]:=UpCase(str[ii]);
	iii:=0;
	for ii:=Low(ArWords) to High(ArWords) do
		begin
		iiii:=Pos(ArWords[ii],str);
		if iiii<>0 then
			begin
			iii+=1;
			end;
		end;
	if iii<>0 then
		begin
		{SetLength(ArResults,Length(ArResults)+1);
		ArResults[High(ArResults)].Kol:=iii;
		ArResults[High(ArResults)].Str:=KolStr;
		ArResults[High(ArResults)].Fail:=ArFiles[i];}
		PS+=iii;
		if FArF=nil then
			iiii:=0
		else
			iiii:=Length(FArF);
		if iii>iiii then
			begin
			SetLength(FArF,iii);
			for i:=iiii to iii-1 do
				FArF[i]:=nil;
			end;
		if FArF[iii-1]=nil then
			FArF[iii-1]:=TFileStream.Create(NameFolder+Slash+'Results of '+SGStr(iii)+' matches.txt',fmCreate);
		SGWriteStringToStream('"'+VFile+'" : "'+SGStr(KolStr)+'"'+#13+#10,FArF[iii-1],False);
		end;
	end;
close(f);

Gotoxy(1,Oy);
textcolor(15);
write('Finded ');
textcolor(10);
write(PS);
textcolor(15);
write(' matches. Processed ');
textcolor(10);
write(PF);
textcolor(15);
write(' files in ');
TextColor(14);
Write(ChisFi);
TextColor(15);
wRITElN(' derictoryes...');
end;

procedure DoFiles(const VDir:string);
var
	sr:dos.searchrec;
	I:LongWord;
begin
for i:=0 to High(ArF) do
	begin
	dos.findfirst(VDir+Slash+'*.'+ArF[i],$3F,sr);
	while DosError<>18 do
		begin
		//SGWriteStringToStream('Do file "'+VDir+sr.name+'".'+#13+#10,Stream);
		FindInFile(VDir+sr.name);
		dos.findnext(sr);
		end;
	dos.findclose(sr);
	end;
end;

procedure ConstWords;
var
	l:longint;
	i:longint;
begin
textcolor(15);
write('Enter words quantity:');
textcolor(10);
readln(l);
textcolor(15);
SetLength(ArWords,l);
for i:=Low(ArWords) to High(ArWords) do
	begin
	textcolor(15);
	write('Enter ',i+1,' word:');
	textcolor(10);
	readln(ArWords[i]);
	textcolor(15);
	end;
end;

procedure SkanWords;
var
	i:longint;
	ii:longint;
begin
for i:=Low(ArWords) to High(ArWords) do
	begin
	for ii:=1 to Length(ArWords[i]) do
		ArWords[i][ii]:=UpCase(ArWords[i][ii]);
	end;
i:=Low(ArWords);
while i<=High(ArWords) do
	begin
	if (ArWords[i]='') or (ArWords[i]=' ') or (ArWords[i]='  ') or (ArWords[i]='   ') or (ArWords[i]='    ') then
		begin
		for ii:=i to High(ArWords)-1 do
			ArWords[i]:=ArWords[i+1];
		SetLength(ArWords,Length(ArWords)-1);
		end;
	i+=1;
	end;
end;

procedure DoDirectories(const VDir:string);
var
	sr:dos.searchrec;
begin
//SGWriteStringToStream('Do dir "'+VDir+'".'+#13+#10,Stream);
DoFiles(VDir+Slash);
dos.findfirst(VDir+Slash+'*',$10,sr);
while DosError<>18 do
	begin
	if (sr.name<>'.') and (sr.name<>'..') and (not(SGFileExists(VDir+Slash+sr.name))) then
		BEGIN
		ChisFi+=1;
		DoFiles(VDir+Slash+sr.name+Slash);
		DoDirectories(VDir+Slash+sr.name);
		END;
	dos.findnext(sr);
	end;
dos.findclose(sr);
end;

begin
SetLength(ArF,9);
ArF[0]:='pas';
ArF[1]:='pp';
ArF[2]:='inc';
ArF[3]:='cpp';
ArF[4]:='cxx';
ArF[5]:='h';
ArF[6]:='hpp';
ArF[7]:='hxx';
ArF[8]:='c';
textcolor(15);
if Cmd and (argc>2) then
	begin
	for i:=2 to argc-1 do
		begin
		if (argv[i][0]='-') then
			begin
			TempS:=SGPCharToString(argv[i]);
			TempS:=SGGetComand(TempS);
			if (Length(TempS)>2) or (TempS='H') then
				if (TempS[1]='F') and (TempS[2]='D') then
					begin
					TempS2:='';
					for ii:=3 to Length(TempS) do
						TempS2+=TempS[ii];
					while (Length(TempS2)>0) and ((TempS2[Length(TempS2)]='\') or (TempS2[Length(TempS2)]='/')) do
						SetLength(TempS2,Length(TempS2)-1);
					if TempS2='' then
						TempS2:='.';
					FDir:=TempS2;
					Write('Selected find directory "');TextColor(14);Write(FDir);TextColor(15);WriteLn('".');
					end
				else if (TempS='VIEWEXP') then
					begin
					Write('Finding expansion:');textColor(14);Write('{');
					for ii:=0 to High(ArF) do
						begin
						TextColor(13);Write(ArF[ii]);TextColor(14);
						if ii<>High(ArF) then
							Write(',');
						end;
					TextColor(14);WriteLn('}');TextColor(15);
					end
				else if (TempS='HELP') or (TempS='H') then
					begin
					WriteLn('This is help for "Find in pas".');
					Write('    -FD');TextColor(13);Write('($directory)');TextColor(15);WriteLn(' : for change find directory.');
					WriteLn('    -H; -HELP : for run help.');
					WriteLn('    -VIEWEXP : for view expansion for find');
					end
				else
					WriteLn('Erroe syntax comand "',argv[i],'"')
			else
				WriteLn('Erroe syntax comand "',argv[i],'"');
			end
		else
			WriteLn('Erroe syntax comand "',argv[i],'"');
		end;
	end;
PF:=0;PS:=0;OY:=0;
NameFolder:=SGGetFreeDirectoryName('Find In Pas Results','Part');
Write('Created results directory "');TextColor(14);Write(NameFolder);TextColor(15);WriteLn('".');
SGMakeDirectory(NameFolder);
ConstWords;
SkanWords;
writeln('Find was begining... Psess any key to stop him...');
Oy:=WhereY;
DoDirectories(FDir);
if FArF<>nil then
	begin
	for i:=0 to High(FArF) do
		if FArF[i]<>nil then
			begin
			FArF[i].Destroy;
			end;
	SetLength(FArF,0);
	end;
if PS=0 then
	begin
	RMDIR(NameFolder);
	TextColor(12);Writeln('Matches don''t exists...');
	TextColor(15);Write('Deleted results directory "');TextColor(14);Write(NameFolder);TextColor(15);WriteLn('".');
	end;
SetLength(ArF,0);
SetLength(ArWords,0);
end;

function SGMakeDirectory(const DirWay:String):Boolean;inline;
begin
Result:=True;
try
	MKDir(DirWay);
except
	Result:=False;
end;
end;

function SGGetFileWay(const Way:String):String;
var
	i,ii:LongWord;
begin
if SGGetFileName(Way)='' then
	Result:=Way
else
	begin
	Result:='';
	ii:=0;
	for i:=1 to Length(Way) do
		if Way[i] in [UnixSlash,WinSlash] then
			ii:=i;
	if ii<>0 then
		begin
		for i:=1 to ii do
			Result+=Way[i];
		end;
	end;
end;

procedure SGReleaseFileWay(WAy:string);
var
	ArF:packed array of string = nil;
	i:LongWord = 0;
	NowWay:String = '';
begin
Way:=SGGetFileWay(Way);
SetLength(ArF,1);
ArF[0]:='';
i:=1;
while (i<=Length(Way)) do
	begin
	if Way[i] in [UnixSlash,WinSlash] then
		begin
		SetLength(ArF,Length(ArF)+1);
		ArF[High(ArF)]:='';
		end
	else
		begin
		ArF[High(ArF)]+=Way[i];
		end;
	i+=1;
	end;
NowWay:='';
for i:=0 to high(ArF) do
	if ArF[i]<>'' then
		begin
		if (ArF[i]<>'.') and (ArF[i]<>'..') then
			SGMakeDirectory(NowWay+ArF[i]);
		NowWay+=ArF[i]+Slash;
		end;
SetLength(ArF,0);
end;

function SGGetFileName(const WayName:string):string;
var
	i:LongWord;
	B:Boolean = False;
	E:Boolean = False;
	S:String = '';
begin
Result:='';
i:=Length(WayName);
while (not E) and (i>0) and (WayName[i]<>UnixSlash) and (WayName[i]<>WinSlash)  do
	begin
	Result+=WayName[i];
	if WayName[i]='.' then
		if b then
			E:=True
		else
			begin
			b:=True;
			Result:='';
			end;
	i-=1;
	end;
S:=Result;
Result:='';
for i:=Length(S) downto 1 do
	Result+=S[i];
SetLength(S,0);
end;

function SGGetStringFromConstArray(const Ar:packed array of const):String;
var
	i:LongWord;
begin
Result:='';
if High(Ar)>=0 then 
	begin
	for i := 0 to High(ar) do
		case ar[i].vtype of
		vtInteger: 
			Result+=SGStr(ar[i].vinteger);
		vtString: 
			Result+=(ar[i].vstring^);
		vtAnsiString: 
			Result+=(AnsiString(ar[i].vpointer));
		vtBoolean: 
			Result+=SGStr(ar[i].vboolean);
		vtChar: 
			Result+=ar[i].vchar;
		vtExtended: 
			Result+=SGStrReal(Extended(ar[i].vpointer^),5);
		end;
	end;
end;

procedure SGQuickSort(var Arr; const ArrLength,SizeOfElement:Int64;const SortFunction:Pointer);
type
	SGQSF = function (var a,b):Boolean;

procedure Sort(const L,R:Int64);
var
	i,j:Int64;
	Key,Temp:PByte;
begin
i:=L; 
j:=R;
GetMem(Key,SizeOfElement);
GetMem(Temp,SizeOfElement);
Move(PByte(LongWord(@Arr)+((L+R)div 2)*SizeOfElement)^,Key^,SizeOfElement);
repeat
while SGQSF(SortFunction)(PByte(LongWord(@Arr)+i*SizeOfElement)^,Key^) do i+=1;
while SGQSF(SortFunction)(Key^,PByte(LongWord(@Arr)+j*SizeOfElement)^) do j-=1;
if i<=j then
	begin
	Move(PByte(LongWord(@Arr)+i*SizeOfElement)^,Temp^,SizeOfElement);
	Move(PByte(LongWord(@Arr)+j*SizeOfElement)^,
		 PByte(LongWord(@Arr)+i*SizeOfElement)^,SizeOfElement);
	Move(Temp^,PByte(LongWord(@Arr)+j*SizeOfElement)^,SizeOfElement);
	i+=1;
	j-=1;
	end;
until i>j;
FreeMem(Key);
FreeMem(Temp);
If L < j Then Sort(L, j);
If i < R Then Sort(i, R);
end;

begin
Sort(0,ArrLength-1);
end;

function SGStringGetPart(const S:string;const a,b:LongWord):String;
var
	i:LongWord;
begin
Result:='';
for i:=a to b do
	Result+=S[i];
end;

function SGStringIf(const B:Boolean;const s:string):string;inline;
begin
if B then
	Result:=S
else
	Result:='';
end;

function SGVal(const Text:string = '0'):Int64;inline;overload;
begin
Val(Text,Result);
end;

function SGMin(const a,b:LongInt):LongInt;overload;inline;
begin
if a<b then
	Result:=a
else
	Result:=b;
end;

function SGMin(const a,b:LongWord):LongWord;overload;inline;
begin
if a<b then
	Result:=a
else
	Result:=b;
end;

function SGMin(const a,b:Int64):Int64;overload;inline;
begin
if a<b then
	Result:=a
else
	Result:=b;
end;

function SGMin(const a,b:QWord):QWord;overload;inline;
begin
if a<b then
	Result:=a
else
	Result:=b;
end;

function SGPCharToString(const VChar:PChar):string;inline;
var
	i:Longint = 0;
begin
try
	Result:='';
	while byte(VChar[i])<>0 do
		begin
		Result+=VChar[i];
		i+=1;
		end;
except
	Result:='';
	end;
end;

procedure TSGLog.Sourse(const Ar:array of const;const WithTime:Boolean = True);
var
	OutString:String = '';
begin
 if SGLogEnable then
	begin
	OutString:=SGGetStringFromConstArray(Ar);
	Sourse(OutString,WithTime);
	SetLength(OutString,0);
	end;
end;

function SGConsoleRecord(const s:string;const p:pointer):TSGConsoleRecord;inline;
begin
Result.FTittle:=s;
Result.FProcedure:=TSGProcedure(p);
end;

operator + (const a,b:TSGConsoleRecord):TSGConsoleMenuArray;overload;inline;
begin
SetLength(Result,2);
Result[0]:=a;
Result[1]:=b;
end;

operator + (const a:TSGConsoleMenuArray;b:TSGConsoleRecord):TSGConsoleMenuArray;overload;inline;
begin
Result:=a;
SetLength(Result,Length(Result)+1);
Result[High(Result)]:=b;
end;

procedure SGConsoleMenu(const Ar:TSGConsoleMenuArray;
	const VBackGround:LongWord = 0;
	const VText:LongWord = 15;
	const VActiveBackGround:LongWord = 0;
	const VActiveText:LongWord = 10;
	const Koima:Boolean = True);
var
	NowActive:LongWord;
	OldActive:LongWord = 0;
	c:char = #0;
	GoExit:Boolean = False;
	DAll:Boolean = True;
	MaxLength:LongWord = 0;
procedure DS;
var
	iiii,iii,ii,i:LongWord;
begin
Crt.TextBackGround(VBackGround);
if DAll then
	Crt.ClrScr;
i:=2;
for ii:=0 to High(Ar) do
	begin
	iiii:=3+((MaxLength - Length(Ar[ii].FTittle))div 2);
	Crt.GoToXY(iiii,i);
	Crt.TextColor(VActiveText*Byte(NowActive=ii)+VText*Byte((NowActive<>ii)));
	Crt.TextBackGround(VActiveBackGround*Byte(NowActive=ii)+VBackGround*Byte((NowActive<>ii)));
	if DAll or ((not DAll) and ((ii=NowActive) or (ii=OldActive))) then
		if Koima then 
			begin
			if ii=NowActive then
				begin
				Write(#218);for iii:=1 to Length(Ar[ii].FTittle) do Write(#196);Write(#191);
				i+=1;Crt.GoToXY(iiii,i);
				Write(#179);Write(Ar[ii].FTittle);Write(#179);
				i+=1;Crt.GoToXY(iiii,i);
				Write(#192);for iii:=1 to Length(Ar[ii].FTittle) do Write(#196);Write(#217);
				end
			else
				begin
				Write(#201);for iii:=1 to Length(Ar[ii].FTittle) do Write(#205);Write(#187);
				i+=1;Crt.GoToXY(iiii,i);
				Write(#186);Write(Ar[ii].FTittle);Write(#186);
				i+=1;Crt.GoToXY(iiii,i);
				Write(#200);for iii:=1 to Length(Ar[ii].FTittle) do Write(#205);Write(#188);
				end;
			i+=1;
			end
		else
			begin
			Write(Ar[ii].FTittle);
			i+=1;
			end
	else
		if Koima then
			i+=3
		else
			i+=1;
	end;
Crt.GoToXY(80,25);
DAll:=False;
end;

begin
for OldActive:=0  to High(Ar) do
	if MaxLength<Length(Ar[OldActive].FTittle) then
		MaxLength:=Length(Ar[OldActive].FTittle);
OldActive:=0;
NowActive:=Random(Length(Ar));
DS;
while not GoExit do
	begin
	c:=Crt.ReadKey;
	case c of
	#27:GoExit:=True;
	#80:if NowActive<High(Ar) then
		begin
		OldActive:=NowActive;
		NowActive+=1;
		DS;
		end;
	#72:if NowActive>0 then 
		begin
		OldActive:=NowActive;
		NowActive-=1;
		DS;
		end;
	#13:if Ar[NowActive].FProcedure=nil then
		GoExit:=True
	else
		begin
		Ar[NowActive].FProcedure();
		DAll:=true;
		DS;
		end;
	end;
	end;
end;

procedure TSGLog.Sourse(const s:string;const WithTime:Boolean = True);
var
	ss:string;
	a:TSGDateTime;
	pc:PChar;
begin
if SGLogEnable then
if not WithTime then
	begin
	pc:=SGStringToPChar(s+#13+#10);
	FFileStream.WriteBuffer(pc^,Length(s)+2);
	FreeMem(pc,Length(s)+3);
	end
else
	begin
	a.Get;
	with a do
		ss:='['+SGStr(Day)+'.'+SGStr(Month)+'.'+SGStr(Years)+'/'+SGStr(Week)+']'+
			'['+SGStr(Hours)+':'+SGStr(Minutes)+':'+SGStr(Seconds)+'/'+SGStr(Sec100)+'] -->'+s;
	pc:=SGStringToPChar(ss+#13+#10);
	FFileStream.WriteBuffer(pc^,Length(ss)+2);
	FreeMem(pc,Length(ss)+3);
	end;
end;

constructor TSGLog.Create();
begin
inherited;
if SGLogEnable then
	FFileStream:=TFileStream.Create(DataDirectory+Slash+'EngineLog.log',fmCreate);
end;

destructor TSGLog.Destroy;
begin
if SGLogEnable then
	FFileStream.Destroy;
inherited;
end;

function SGFileExists(const FileName:string = ''):boolean;
begin
Result:=FileExists(FileName);
end;

constructor TSGClass.Create;
begin
inherited;
end;

destructor TSGClass.Destroy;
begin
inherited;
end;

function SGStringToPChar(const s:string):PCHAR;
var
	i:longint;
begin
GetMem(Result,Length(s)+1);
for i:=1 to Length(s) do
	Result[i-1]:=s[i];
Result[i]:=#0;
end;

function SGMax(const a,b:Int64):Int64;inline;overload;
begin
if a>b then
	Result:=a
else
	Result:=b;
end;

function SGStrReal(r:real;const l:longint):string;inline;
label 1;
var
	i:longint;
	st:string;
begin
if r<0 then  st:='-' else st:='';
r:=abs(r);
if r=0 then 
	goto 1;
st+=SGStr(trunc(r));
if r=0 then 
	goto 1;
r-=trunc(r);
r:=abs(r);
if r=0 then 
	goto 1;
st+='.';
for i:=1 to l do
	begin
	if r=0 then 
		goto 1;
	r*=10;
	st+=SGStr(trunc(r));
	r-=trunc(r);
	end;
1:
	if st='' then st:='0';
	Result:=st;
end;

function SGStrExtended(r:Extended;const l:longint):string;inline;
label 1;
var
	i:longint;
	st:string;
begin
if r<0 then  st:='-' else st:='';
r:=abs(r);
if r=0 then 
	goto 1;
st+=SGStr(trunc(r));
if r=0 then 
	goto 1;
r-=trunc(r);
r:=abs(r);
if r=0 then 
	goto 1;
st+='.';
for i:=1 to l do
	begin
	if r=0 then 
		goto 1;
	r*=10;
	st+=SGStr(trunc(r));
	r-=trunc(r);
	end;
1:
	if st='' then st:='0';
	Result:=st;
end;

function SGGetSizeString(const Size:Int64):String;inline;
var
	e:extended;
	d:LongWord = 0;
begin
if Size<1024 then
	Result:=SGStr(Size)+' байт'
else
	begin
	e:=Size;
	repeat
	e:=e/1024;
	d+=1;
	until e<1024;
	Result:=SGStrReal(e,2);
	case d of
	1:
		Result+=' КБайт';
	2:
		Result+=' MБайт';
	3:
		Result+=' ГБайт';
	4:
		Result+=' ТБайт';
	end;
	end;
end;

function SGStr(const b:boolean):String;overload;inline;
begin
if b then
	Result:='TRUE'
else
	Result:='FALSE';
end;

function SGPCharLength(const pc:PChar):int64;inline;
begin
Result:=StrLen(pc);
end;

function Log(const a,b:real):real;inline;
begin
Result:=(Ln(b)/Ln(a));
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

function SGReadStringInQuotesFromStream(Const Stream:TStream;const Quote:char = #39):string;inline;
var
	c:char;
begin
Result:='';
Stream.ReadBuffer(c,SizeOf(c));
repeat
Stream.ReadBuffer(c,SizeOf(c));
if c <> Quote then
	Result+=c;
until c = Quote;
end;

function SGExistsFirstPartString(const AString:String;const Part:String):Boolean;
var
	i:LongInt;
begin
if Length(Part)>Length(AString) then
	Result:=False
else
	if Part=AString then
		Result:=False
	else
		begin
		Result:=True;
		for i:=1 to Length(Part) do
			begin
			if Part[i]<>AString[i] then
				Result:=False;
			if Result=False then
				Break;
			end;
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

function TSGSetOfString.ExistsItem(const FItem:String):TSGByte;overload;
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

procedure TSGDateTime.Clear;
begin
Years:=0;
Month:=0;
Hours:=0;
Day:=0;
Week:=0;
Minutes:=0;
Seconds:=0;
Sec100:=0;
end;

function TSGDateTime.GetPastMiliSeconds:int64;
begin
Result:=GetPastSeconds*100+Sec100;
end;

function TSGDateTime.GetPastMiliSecondsFrom(const a:TSGDateTime):int64;
begin
Result:=(Self-a).GetPastMiliSeconds;
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

function SGGetFileExpansion(const FileName:string):string;inline;
var
	i:LongInt;
	Expansion:string = '';
begin
Result:='';
i:=Length(FileName);
while (i<>0)and(FileName[i]<>'.')and(FileName[i]<>UnixSlash)and(FileName[i]<>WinSlash) do
	begin
	Result+=FileName[i];
	i-=1;
	end;
if FileName=Result then
	Result:=''
else
	begin
	Expansion:=Result;
	Result:='';
	i:=Length(Expansion);
	while i<>0 do
		begin
		Result+=Expansion[i];
		i-=1;
		end;
	end;
Result:=SGUpCaseString(Result);
end;

function SGMin(const a,b:single):single;inline;overload;
begin
if a<b then
	Result:=a
else
	Result:=b;
end;

function SGMin(const a,b:real):real;inline;overload;
begin
if a<b then
	Result:=a
else
	Result:=b;
end;

function SGMin(const a,b:extended):extended;inline;overload;
begin
if a<b then
	Result:=a
else
	Result:=b;
end;

function SGMax(const a,b:real):real;inline;overload;
begin
if a>b then
	Result:=a
else
	Result:=b;
end;

function SGMax(const a,b:extended):extended;inline;overload;
begin
if a>b then
	Result:=a
else
	Result:=b;
end;

function SGMax(const a,b:single):single;inline;overload;
begin
if a>b then
	Result:=a
else
	Result:=b;
end;

constructor TSGThread.Create(const Proc:TSGThreadProcedure;const Para:Pointer = nil;const QuickStart:Boolean = True);
begin
inherited Create;
FFinished:=true;
FParametr:=Para;
FProcedure:=Proc;
FHandle:=0;
FThreadID:=0;
if QuickStart then
	Start;
end;

procedure TSGThread.Execute;
begin
FFinished:=False;
if Pointer(FProcedure)<>nil then
	FProcedure(FParametr);
FFinished:=True;
end;

procedure TSGThread.SetProcedure(const Proc:TSGThreadProcedure);
begin
FProcedure:=Proc;
end;

procedure TSGThread.SetParametr(const Pointer:Pointer);
begin
FParametr:=Pointer;
end;

function TSGThreadStart(ThreadClass:TSGThread):TSGThreadFunctionResult; {$IFDEF MSWINDOWS}stdcall;{$ENDIF}
begin
Result:=0;
ThreadClass.Execute;
end;

destructor TSGThread.Destroy;
{$IFDEF MSWINDOWS}
	var
		i:Boolean;
	{$ENDIF}
begin
{$IFDEF MSWINDOWS}
	if not FFinished then
		begin
		i:=TerminateThread(FHandle,0);
		SGLog.Sourse(['TSGThread__Destroy : FHandle=',FHandle,',FThreadID=',FThreadID,',Terminate Result=',i,'.']);
		end;
	if FHandle<>0 then
		CloseHandle(FHandle);
{$ELSE}
	if not FFinished then
		KillThread(FHandle);
	{$ENDIF}
FHandle:=0;
FThreadID:=0;
inherited;
end;

procedure TSGThread.Start;
begin
{$IFDEF MSWINDOWS}
	FHandle:=CreateThread(nil,0,@TSGThreadStart,Self,0,FThreadID);
{$ELSE}
	FHandle:=BeginThread(TSGThreadFunction(@TSGThreadStart),Self);
	{$ENDIF}
end;


function SGWhatIsTheSimbolEN(const l:longint;const Shift:boolean = False;const Caps:Boolean = False):string;inline;
begin
SGWhatIsTheSimbolEN:='';
case l of
32:Result:=' ';
48:if Shift then Result:=')' else Result:='0';
49:if Shift then Result:='!' else Result:='1';
50:if Shift then Result:='@' else Result:='2';
51:if Shift then Result:='#' else Result:='3';
52:if Shift then Result:='$' else Result:='4';
53:if Shift then Result:='%' else Result:='5';
54:if Shift then Result:='^' else Result:='6';
55:if Shift then Result:='&' else Result:='7';
56:if Shift then Result:='*' else Result:='8';
57:if Shift then Result:='(' else Result:='9';
65:if Shift xor Caps then Result:='A' else Result:='a';
66:if Shift xor Caps then Result:='B' else Result:='b';
67:if Shift xor Caps then Result:='C' else Result:='c';
68:if Shift xor Caps then Result:='D' else Result:='d';
69:if Shift xor Caps then Result:='E' else Result:='e';
70:if Shift xor Caps then Result:='F' else Result:='f';
71:if Shift xor Caps then Result:='G' else Result:='g';
72:if Shift xor Caps then Result:='H' else Result:='h';
73:if Shift xor Caps then Result:='I' else Result:='i';
74:if Shift xor Caps then Result:='G' else Result:='g';
75:if Shift xor Caps then Result:='K' else Result:='k';
76:if Shift xor Caps then Result:='L' else Result:='l';
77:if Shift xor Caps then Result:='M' else Result:='m';
78:if Shift xor Caps then Result:='N' else Result:='n';
79:if Shift xor Caps then Result:='O' else Result:='o';
80:if Shift xor Caps then Result:='P' else Result:='p';
81:if Shift xor Caps then Result:='Q' else Result:='q';
82:if Shift xor Caps then Result:='R' else Result:='r';
83:if Shift xor Caps then Result:='S' else Result:='s';
84:if Shift xor Caps then Result:='T' else Result:='t';
85:if Shift xor Caps then Result:='U' else Result:='u';
86:if Shift xor Caps then Result:='V' else Result:='v';
87:if Shift xor Caps then Result:='W' else Result:='w';
88:if Shift xor Caps then Result:='X' else Result:='x';
89:if Shift xor Caps then Result:='Y' else Result:='y';
90:if Shift xor Caps then Result:='Z' else Result:='z';
186:if Shift then Result:=':' else Result:=';';
187:if Shift then Result:='+' else Result:='=';
188:if Shift then Result:='<' else Result:=',';
189:if Shift then Result:='_' else Result:='-';
190:if Shift then Result:='>' else Result:='.';
191:if Shift then Result:='?' else Result:='/';
192:if Shift then Result:='~' else Result:='`';
219:if Shift then Result:='{' else Result:='[';
220:if Shift then Result:='|' else Result:='\';
221:if Shift then Result:='}' else Result:=']';
222:if Shift then Result:='"' else Result:='"';
end;
end;

function SGWhatIsTheSimbolRU(const l:longint;const Shift:boolean = False;const Caps:Boolean = False):string;inline;
begin
SGWhatIsTheSimbolRU:='';
case l of
32:Result:=' ';
48:if Shift then Result:=')' else Result:='0';
49:if Shift then Result:='!' else Result:='1';
50:if Shift then Result:='"' else Result:='2';
51:if Shift then Result:='№' else Result:='3';
52:if Shift then Result:=';' else Result:='4';
53:if Shift then Result:='%' else Result:='5';
54:if Shift then Result:='^' else Result:='6';
55:if Shift then Result:='?' else Result:='7';
56:if Shift then Result:='*' else Result:='8';
57:if Shift then Result:='(' else Result:='9';
65:if Shift xor Caps then Result:='Ф' else Result:='ф';
66:if Shift xor Caps then Result:='И' else Result:='и';
67:if Shift xor Caps then Result:='С' else Result:='с';
68:if Shift xor Caps then Result:='В' else Result:='в';
69:if Shift xor Caps then Result:='У' else Result:='у';
70:if Shift xor Caps then Result:='А' else Result:='а';
71:if Shift xor Caps then Result:='П' else Result:='п';
72:if Shift xor Caps then Result:='Р' else Result:='р';
73:if Shift xor Caps then Result:='Ш' else Result:='ш';
74:if Shift xor Caps then Result:='О' else Result:='о';
75:if Shift xor Caps then Result:='Л' else Result:='л';
76:if Shift xor Caps then Result:='Д' else Result:='д';
77:if Shift xor Caps then Result:='Ь' else Result:='ь';
78:if Shift xor Caps then Result:='Т' else Result:='т';
79:if Shift xor Caps then Result:='Щ' else Result:='щ';
80:if Shift xor Caps then Result:='З' else Result:='з';
81:if Shift xor Caps then Result:='Й' else Result:='й';
82:if Shift xor Caps then Result:='К' else Result:='к';
83:if Shift xor Caps then Result:='Ы' else Result:='ы';
84:if Shift xor Caps then Result:='Е' else Result:='е';
85:if Shift xor Caps then Result:='Г' else Result:='г';
86:if Shift xor Caps then Result:='М' else Result:='м';
87:if Shift xor Caps then Result:='Ц' else Result:='ц';
88:if Shift xor Caps then Result:='Ч' else Result:='ч';
89:if Shift xor Caps then Result:='Н' else Result:='н';
90:if Shift xor Caps then Result:='Я' else Result:='я';
186:if Shift xor Caps then Result:='Ж' else Result:='ж';
187:if Shift xor Caps then Result:='+' else Result:='=';
188:if Shift xor Caps then Result:='Б' else Result:='б';
189:if Shift then Result:='_' else Result:='-';
190:if Shift xor Caps then Result:='Ю' else Result:='ю';
191:if Shift then Result:=',' else Result:='.';
192:if Shift xor Caps then Result:='Ё' else Result:='ё';
219:if Shift xor Caps then Result:='Х' else Result:='х';
220:if Shift then Result:='/' else Result:='\';
221:if Shift xor Caps then Result:='Ъ' else Result:='ъ';
222:if Shift xor Caps then Result:='Э' else Result:='э';
end;
end;

function SGGetLanguage:String;inline;
{$IFDEF MSWINDOWS}
	var
		Layout:array [0..kl_namelength]of char;
	{$ENDIF}
begin
{$IFDEF MSWINDOWS}
	GetKeyboardLayoutname(Layout);
	if layout='00000409' then
		Result:='EN'
	else
		Result:='RU';
{$ELSE}
	Result:='EN';
	{$ENDIF}
end;

function SGWhatIsTheSimbol(const l:longint;const Shift:Boolean = False;const Caps:Boolean = False):string;inline;
var
	Language:string = '';
begin
Language:=SGGetLanguage;
if Language='EN' then
	begin
	Result:=SGWhatIsTheSimbolEN(l,Shift,Caps);
	end
else
	if Language='RU' then
		Result:=SGWhatIsTheSimbolRU(l,Shift,Caps)
	else
		Result:=char(l);
end;

function SGSecondsToStringTime(VSeconds:Int64):string;inline;
var
	Seconds:Int64 = 0;
	Minutes:Int64 = 0;
	Hours:Int64 = 0;
	Days:Int64 = 0;
	Monthes:Int64 = 0;
	Years:Int64 = 0;
	
	QWr:Word = 0;
begin
Result:='';

Seconds:=VSeconds mod 60;
VSeconds:=VSeconds div 60;

Minutes:=VSeconds mod 60;
VSeconds:=VSeconds div 60;

Hours:=VSeconds mod 24;
VSeconds:=VSeconds div 24;

Days:=VSeconds mod 30;
VSeconds:=VSeconds div 30;

Monthes:=VSeconds mod 12;
VSeconds:=VSeconds div 12;

Years:=VSeconds;

if (Years<>0) and (QWr<=2) then
	begin
	Result+=SGStr(Years)+' г ';
	QWr+=1;
	end;
if (Monthes<>0)  and (QWr<=2)then
	begin
	Result+=SGStr(Monthes)+' мес ';
	QWr+=1;
	end;
if (Days<>0)  and (QWr<=2)then
	begin
	Result+=SGStr(Days)+' дн ';
	QWr+=1;
	end;
if (Hours<>0)  and (QWr<=2)then
	begin
	Result+=SGStr(Hours)+' ч ';
	QWr+=1;
	end;
if (Minutes<>0)  and (QWr<=2)then
	begin
	Result+=SGStr(Minutes)+' мин ';
	QWr+=1;
	end;
if ((Result='') or (Seconds<>0)) and (QWr<=2) then
	begin
	Result+=SGStr(Seconds)+' сек ';
	QWr+=1;
	end;
end;

function SGStr(const Number : LongInt = 0):String;inline;overload;
begin
Str(Number,Result);
end;

function SGPCharNil:PChar;inline;
begin
GetMem(Result,1);
Result[0]:=#0;
end;

function SGGetFileNames(const Catalog:String;const What:String = ''):TArString;
var
	Found:Integer;
	SearchRec:TSearchRec;
begin
Result:=nil;
if What<>'' then
	Found:=FindFirst(Catalog + What, faAnyFile, SearchRec)
else
	Found:=FindFirst(Catalog + '*.*', faAnyFile, SearchRec);
while Found = 0 do
	begin
	SetLEngth(Result,Length(Result)+1);
	Result[High(Result)]:=SearchRec.Name;
	Found:=FindNext(SearchRec);
	end;
SysUtils.FindClose(SearchRec);
end;

function SGPCharIf(const Bool:Boolean;const VPChar:PChar):PChar;
begin
if Bool then
	Result:=VPChar
else
	Result:=nil;
end;

function SGStringAsPChar(var Str:String):PChar;
begin
Str[Length(Str)+1]:=#0;
Result:=@Str[1];
end;

function SGUpCaseString(const S:String):String;
var
	i:LongWord;
begin
SetLength(Result,Length(S));
for i:=1 to Length(S) do
	Result[i]:=UpCase(S[i]);
end;

function SGReadWordFromTextFile(const TextFile:PTextFile):String;
var
	c:char = #0;
begin
Result:='';
Read(TextFile^,C);
while c=' ' do
	Read(TextFile^,C);
while (c<>' ') and (Not Eoln(TextFile^)) do
	begin
	Result+=C;
	Read(TextFile^,C);
	end;
end;

function SGReadStringInQuotesFromTextFile(const TextFile:PText):String;
var
	C:char;
begin
Result:='';
Read(TextFile^,C);
while (c in [' ','	']) do
	Read(TextFile^,C);
if c='"' then
	begin
	Read(TextFile^,C);
	while (c<>'"') do
		begin
		Result+=C;
		Read(TextFile^,C);
		end;
	end
else
	Result:='';
end;

procedure SGWriteStringToStream(const String1:String;const Stream:TStream;const Stavit00:Boolean = True);inline;
var
	c:char = #0;
begin
Stream.WriteBuffer(String1[1],Length(String1));
if Stavit00 then
	Stream.WriteBuffer(c,SizeOf(Char));
end;


function SGReadStringFromStream(const Stream:TStream):String;inline;
var
	c:char = #1;
begin
Result:='';
while c<>#0 do
	begin
	Stream.ReadBuffer(c,1);
	if c<>#0 then
		Result+=c;
	end;
end;

procedure TSGDateTime.ImportFromSeconds(Sec:int64);
begin
Sec100:=0;
Seconds:=Sec mod 60;
Sec:=Sec div 60;
Minutes:= Sec mod 60;
Sec:=Sec div 60;
Hours:=Sec mod 24;
Sec:=Sec div 24;
Day:=Sec mod 30;
Month:=(Sec div 30) mod 12;
Years:=Sec mod 365;
{
Result+=b.Month*60*60*24*30;
Result+=b.Years*60*60*24*365;}
end;

procedure TSGDateTime.Import(a1,a2,a3,a4,a5,a6,a7,a8:LongInt);
begin
PArFrom1To8OfLongInt(@Self)^[1]:=a1;
PArFrom1To8OfLongInt(@Self)^[2]:=a2;
PArFrom1To8OfLongInt(@Self)^[3]:=a3;
PArFrom1To8OfLongInt(@Self)^[4]:=a4;
PArFrom1To8OfLongInt(@Self)^[5]:=a5;
PArFrom1To8OfLongInt(@Self)^[6]:=a6;
PArFrom1To8OfLongInt(@Self)^[7]:=a7;
PArFrom1To8OfLongInt(@Self)^[8]:=a8;
end;

procedure TSGDateTime.Write;
begin
writeln(Years,' ',Month,' ',Day,' ',Week,' ',Hours,' ',Minutes,' ',Seconds,' ',Sec100);
end;

operator - ( a,b:TSGDateTime):TSGDateTime;inline;
var
	i:LongInt;
begin
for i:=1 to 8 do
	PArFrom1To8OfLongInt(@Result)^[i]:=PArFrom1To8OfLongInt(@a)^[i]-PArFrom1To8OfLongInt(@b)^[i];
end;

function TSGDateTime.GetPastSeconds:int64;
begin
Result:=Seconds;
Result+=Minutes*60;
Result+=Hours*60*60;
Result+=Day*60*60*24;
Result+=Month*60*60*24*30;
Result+=Years*60*60*24*365;
end;

function TSGDateTime.GetPastSecondsFrom(const a:TSGDateTime):int64;
begin
Result:=0;
Result:=(Self-a).GetPastSeconds;
end;

procedure TSGDateTime.Get;
var
	NYears,NMonth,NDay,NWeek:Word;
	NHours,NMinutes,NSeconds,NSec100:Word;
begin
GetDate(NYears,NMonth,NDay,NWeek);
GetTime(NHours,NMinutes,NSeconds,NSec100);
Years:=NYears;
Month:=NMonth;
Day:=NDay;
Week:=NWeek;
Hours:=NHours;
Minutes:=NMinutes;
Seconds:=NSeconds;
Sec100:=NSec100;
end;

function SGTruncUp(const t:real):LongInt;inline;
begin
Result:=Trunc(t)+1;
end;

destructor TSGLibraryClass.Destroy;
begin
FreeLibrary(FSaGeLibrary);
inherited;
end;

constructor TSGLibraryClass.Create;
begin
inherited;
FSaGeLibrary:=LoadLibrary(SGLibraryNameBegin+'SaGeLib'+SGLibraryNameEnd);
end;

function GetProcAddress(const Lib:TSGLibrary;const VPChar:PChar):Pointer;
begin
{$IFDEF WINDOWS}
	Result:=Windows.GetProcAddress(Lib,VPChar);
{$ELSE}
	Result:=GetProcedureAddress(Lib,VPChar);
	{$ENDIF}
end;

function LoadLibrary(AName: PChar): TSGLibHandle;
begin
Result:=
	{$ifdef UNIX} 
		TSGLibrary( dlopen(AName, RTLD_LAZY or RTLD_GLOBAL) );
	{$else} 
		Windows.LoadLibrary(AName);
		{$endif}
end; 

initialization
begin
(*
{$IFDEF ANDROID}
	SGMakeDirectory('/sdcard/SaGe');
	SGMakeDirectory('/sdcard/SaGe/Data');
	SGMakeDirectory('/sdcard/SaGe/Data/Fonts');
	SGMakeDirectory('/sdcard/SaGe/Data/Images');
	SGMakeDirectory('/sdcard/SaGe/Data/Textures');
	{$ENDIF}
*)

try
SGLog:=TSGLog.Create();
SGLog.Sourse('(***) SaGe Engine Log (***)',False);
SGLog.Sourse('  << Create Log >>');
except
SGLogEnable:=False;
SGLog:=TSGLog.Create;
end;

Nan:=sqrt(-1);
Inf:=1/0;
RandomIze();
end;

finalization
begin
SGLog.Sourse('  << Destroy Log >>');
SGLog.Destroy;
end;

end.
