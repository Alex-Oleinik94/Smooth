//Файлик ресурсов для винды (Иконка + Курсор + Manifest)
{$IFDEF MSWINDOWS}
	{$R .\..\SaGe.res}
	{$ENDIF}
{$INCLUDE Includes\SaGe.inc}
//{$DEFINE USE_uSMBIOS}

unit SaGeBase;

interface

uses 
	crt
	,dos
	{$IFDEF MSWINDOWS}
		,Windows
		//,MMSystem
		{$ENDIF}
	{$IFDEF UNIX}
		,unix
		,dl
		{$ENDIF}
	,DynLibs
	,SaGeBased
	,SysUtils
	,Classes
	,Process
	{$IFDEF USE_uSMBIOS}
		,uSMBIOS
		{$ENDIF}
	{$IFDEF ANDROID}
		,ctypes
		,cmem
		,unixtype
		,android_native_app_glue
		{$ENDIF}
	;

{$IFDEF ANDROID}
				{*========POSIX Thread=========*}
	const
	 PTHREAD_CREATE_JOINABLE = 0;
	 PTHREAD_CREATE_DETACHED = 1;
	type
	 ppthread_t = ^pthread_t;
	 ppthread_attr_t = ^pthread_attr_t;
	 ppthread_mutex_t = ^pthread_mutex_t;
	 ppthread_cond_t = ^pthread_cond_t;
	 ppthread_mutexattr_t = ^pthread_mutexattr_t;
	 ppthread_condattr_t = ^pthread_condattr_t;

	 __start_routine_t = pointer;
	function pthread_create(__thread:ppthread_t; __attr:ppthread_attr_t;__start_routine: __start_routine_t;__arg:pointer):longint;cdecl;external 'libc.so';
	function pthread_attr_init(__attr:ppthread_attr_t):longint;cdecl;external 'libc.so';
	function pthread_attr_setdetachstate(__attr:ppthread_attr_t; __detachstate:longint):longint;cdecl;external 'libc.so';
	function pthread_mutex_init(__mutex:ppthread_mutex_t; __mutex_attr:ppthread_mutexattr_t):longint;cdecl;external 'libc.so';
	function pthread_mutex_destroy(__mutex:ppthread_mutex_t):longint;cdecl;external 'libc.so';
	function pthread_mutex_lock(__mutex: ppthread_mutex_t):longint;cdecl;external 'libc.so';
	function pthread_mutex_unlock(__mutex: ppthread_mutex_t):longint;cdecl;external 'libc.so';
	function pthread_cond_init(__cond:ppthread_cond_t; __cond_attr:ppthread_condattr_t):longint;cdecl;external 'libc.so';
	function pthread_cond_destroy(__cond:ppthread_cond_t):longint;cdecl;external 'libc.so';
	function pthread_cond_signal(__cond:ppthread_cond_t):longint;cdecl;external 'libc.so';
	function pthread_cond_broadcast(__cond:ppthread_cond_t):longint;cdecl;external 'libc.so';
	function pthread_cond_wait(__cond:ppthread_cond_t; __mutex:ppthread_mutex_t):longint;cdecl;external 'libc.so';
	//procedure pthread_exit(value : Pointer);cdecl;external 'libc.so';
	function  pthread_attr_destroy(__attr:ppthread_attr_t):longint;cdecl;external 'libc.so';
	//function pthread_cancel(__thread:pthread_t):LongInt;cdecl;external 'libc.so';
	function pthread_join(thread:pthread_t; a:pointer):LongInt;cdecl;external 'libc.so';
	{$ENDIF}

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
	//Табкица перевода символов изт кодировки WINDOWS1251 в CP866
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
	SGUnixEoln = #10;
	SGWinEoln  = #13+#10;
	SGMacEoln  = #13;
	SGDataDirectory = '.'+Slash+'..'+Slash+'Data';
	SGFontDirectory = SGDataDirectory + Slash +'Fonts';
	SGTextureDirectory = SGDataDirectory + Slash +'Textures';
	SGTexturesDirectory = SGTextureDirectory;
	SGFontsDirectory = SGFontDirectory;
	SGModelsDirectory = SGDataDirectory + Slash +'Models';
	SGExamplesDirectory = SGDataDirectory + Slash +'Examples';
	SGEngineDirectory = SGDataDirectory + Slash +'Engine';
	SGImagesDirectory = 
		{$IFDEF ANDROID}
			'/sdcard/Images'
		{$ELSE}
			SGDataDirectory + Slash +'Images'
		{$ENDIF};
	{$IF (not defined(RELEASE)) and (not defined(MOBILE))}
		SGTempDirectory = '.'+Slash+'..'+Slash+'Temp';
		{$ENDIF}
var
	//Если эту переменную задать как False, то SGLog.Sourse нечего делать не будет, 
	//и самого файлика лога SGLog.Create не создаст
	SGLogEnable:Boolean = {$IFDEF RELEASE}False{$ELSE}True{$ENDIF};
const
	SGLogDirectory = {$IFDEF ANDROID}'/sdcard/.SaGe'{$ELSE}SGDataDirectory{$ENDIF};
type
	//Это для приведения приведения типов к общему виду относительно х32 и х64
	//Так как Pointer на х32 занимает 4 байта, а на х64 - 8 байтов
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
	TSGLibHandle = type TSGHandle;
	TSGLibrary   = TSGLibHandle;
	FileOfByte   = type File Of Byte;
	PFileOfByte  = ^ FileOfByte;
	
	TSGIdentifier = type LongWord;
	
	PReal     = ^ real;
	TSGExByte = type Int64;
	PSingle = ^ single;
	
	TSGSetOfByte   = type packed set   of byte;
	TArBoolean     = type packed array of boolean;
	TSGArBoolean   = type packed array of TSGBoolean;
	TArString      = type packed array of string;
	TArLongint     = type packed array of longint;
	TArLongword    = type packed array of longword;
	TArByte        = type packed array of byte;
	TArInteger     = type packed array of integer;
	TArWord        = type packed array of word;
	TArInt64       = type packed array of int64;
	TArReal        = type packed array of real;
	TArExtended    = type packed array of extended;
	TArTArLongWord = type packed array of TArLongWord;
	//TSGArConst     = type packed array of const;
	TSGArString    = type packed array of TSGString;
	
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
	
	//Это для SaGeScreen
	TSGCaption =  string;
	SGCaption = TSGCaption;
	
	SGProcedure  = type TProcedure;
	TSGProcedure = type SGProcedure;
	
	SGFrameButtonsType = type TSGExByte;
type
	//Тип плоскости. Так как он не может Draw(), то он описан сдесь, а не в SaGeCommon
	//Указательна обьект плоскости
	PTSGPlane = ^ TSGPlane;
	TSGPlane  = object
		a, b, c, d : TSGReal;
		procedure Import(const a1:real = 0; const b1:real = 0; const c1:real = 0; const d1:real = 0);inline;
		procedure Write;inline;
		end;
	PSGPlane = PTSGPlane;
	SGPlane  = TSGPlane;
type
	ArLong01          = packed array [0..1] of LongWord;
	PArLong01         = ^ ArLong01;
	SGObjectProcedure = ArLong01;
	
	//Расширение TSGBoolean. Тут есть SG_TRUE, SG_FALSE и SG_UNKNOWN
	TSGExBoolean = type TSGByte;
	
	//Класс, который позволяет загружать динамические библиотеки
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
	
	TSGObject = class(TObject);
	
	//Начальный класс SaGe
	TSGClass=class;
	TSGClassClass = class of TSGClass;
	TSGClassOfClass = TSGClassClass;
	TSGClass=class(TSGObject)
			public
		constructor Create();virtual;
		destructor Destroy();override;
		class function ClassName():TSGString;virtual;
		function Get(const What:string):TSGPointer;virtual;
		end;
const
	fmCreate = Classes.fmCreate;
	fmOpenRead = Classes.fmOpenRead;
type
	//Класс даты и времени
	TArFrom1To8OfLongInt = array[1..8] of LongInt;
	PArFrom1To8OfLongInt = ^ TArFrom1To8OfLongInt;
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
	
	//Это для потоков
	TSGThreadProcedure     = procedure ( p : Pointer );
	TSGThreadFunctionResult = 
	{$IFDEF ANDROID}
		Pointer
	{$ELSE}
		{$IFDEF MSWINDOWS}
			LongWord
		{$ELSE}
			{$IFDEF UNIX}
				{$IFDEF CPU32}
					LongInt
					{$ENDIF}
				{$IFDEF CPU64}
					Int64
					{$ENDIF}
				{$ENDIF}
			{$ENDIF}
		{$ENDIF};
	TSGThreadID = {$IFDEF ANDROID} pthread_t {$ELSE}{$IFDEF DARWIN}TThreadID{$ELSE}LongWord{$ENDIF}{$ENDIF};
	TSGThreadFunction = function ( p : TSGPointer ): TSGThreadFunctionResult;
		{$IFDEF ANDROID}cdecl;{$ELSE} {$IF defined(MSWINDOWS)}stdcall;{$ENDIF}{$ENDIF}
	//Это класс, при помощью которого можно создать поток
	TSGThread=class(TSGObject)
			public
		constructor Create(const Proc:TSGThreadProcedure;const Para:Pointer = nil;const QuickStart:Boolean = True);
		destructor Destroy();override;
			public
		FHandle:TSGThreadID;
		FFinished:Boolean;
		FProcedure:TSGThreadProcedure;
		FParametr:Pointer;
		FThreadID:LongWord;
		{$IFDEF ANDROID} 
			attr : pthread_attr_t;
			mutex : pthread_mutex_t;
			cond : pthread_cond_t;
			{$ENDIF}
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
	//Лог программы
	TSGLog = class(TObject)
			public
		constructor Create;
		destructor Destroy;override;
		procedure Sourse(const s:string;const WithTime:Boolean = True);
		procedure Sourse(const Ar:array of const;const WithTime:Boolean = True);
			private
		FFileStream:TFileStream;
		end;
	TSGConsoleRecord = packed record
			FTitle : string;
			FProcedure : TSGProcedure;
			end;
	TSGConsoleMenuArray = packed array of TSGConsoleRecord;
const 
	//Значения, которые может принимать type TSGExBoolean
	SG_TRUE = TSGExBoolean(1);
	SG_FALSE = TSGExBoolean(0);
	SG_UNKNOWN = TSGExBoolean(2);
const
	//Используется для вычисления с Эпсилон 
	SGZero = 0.0001;
var
	//Экземпляр класса лога программы
	SGLog:TSGLog = nil;
	//Несуществующее значение
	Nan:real;
	//Бесконечное значение
	Inf:real;
type
	//Тип процедурок для SaGeScreen
	SGScreenProcedureWC =  procedure ( Context : Pointer ) ;
var
	//Это указатели на процедуры SaGeScreen, которые SaGeScreen
	//Присваивает при инициализации. Эти процедуры в дальнейшем 
	//Использует SaGeContext и SaGeRender для отрисовки,... окон
	SGScreenPaintProcedure           : SGScreenProcedureWC = nil;
	SGScreenForReSizeScreenProcedure : SGScreenProcedureWC = nil;
	SGScreenLoadProcedure            : SGScreenProcedureWC = nil;

//Тут задаются преведущие переменные
procedure SGSetScreenProcedure(const p:Pointer = nil);
procedure SCSetScreenScreenBounds(const p:Pointer = nil);
procedure SGSetScreenLoadProcedure(p:Pointer);

//Сливает массивы Real-ов
operator + (a,b:TArReal):TArReal;inline;

//Вычитает одну дату их другой. Из результата можно
//Вызвать функцию, возвращающую прошедшые (мили)секунды
//И получить разницу во времени этих дат в (мили)секундах
operator - (const a,b:TSGDateTime):TSGDateTime;inline;

//Загружает библиотеку с именем AName
function LoadLibrary(AName: PChar): TSGLibHandle;

//Возвращает указатель на процедуру в библиотеке Lib с названием VPChar
function GetProcAddress(const Lib:TSGLibrary;const VPChar:PChar):Pointer;

//Result := Trunc(T)+1
function SGTruncUp(const T : Real):LongInt;inline;

//Из потока считывается сткока, пока не будет найден нулевой байт
function SGReadStringFromStream(const Stream:TStream):String;inline;
function SGReadLnStringFromStream(const Stream:TStream):String;inline;

//Записывает строку в поток. Если (Stavit00 = True), то в конце записывается нулевой байт.
procedure SGWriteStringToStream(const String1:String;const Stream:TStream;const Stavit00:Boolean = True);inline;

//Читает изтекстовова файла строку, находящиюся в двойных кавычках
function SGReadStringInQuotesFromTextFile(const TextFile:PText):String;

//Читает слово из файла. (В слове нету пробелов)
function SGReadWordFromTextFile(const TextFile:PTextFile):String;

//Обращает строку в верхний регистр
function SGUpCaseString(const S:String):String;

//Добавляет в конце строки нулевой байт, и возвращает указатель на строку
function SGStringAsPChar(var Str:String):PChar;

//Если ( Bool = True ), то Result := Строка, нежели Result := ''.
function SGPCharIf(const Bool:Boolean;const VPChar:PChar):PChar;
function SGStringIf(const B:Boolean;const s:string):string;inline;

//Возвращает имена всех файлов в этом каталоге
function SGGetFileNames(const Catalog:String;const What:String = ''):TArString;

//Возвращает указатель на нулевой байт
function SGPCharNil:PChar;inline;

//Переводит LongInt в String
function SGStr(const Number : TSGInt64 = 0):String;inline;overload;

//Переводит секунды в строку, где они будут уже распределены на года, месяца и т д
function SGSecondsToStringTime(VSeconds:Int64;const Encoding : string = 'RUS1251'):string;inline;

//Это функции для отладки WinAPI функций, связанных с символами, получиными в SaGeContextWinAPI как коды клавиш
function SGWhatIsTheSimbol(const l:longint;const Shift:Boolean = False;const Caps:Boolean = False):string;inline;
function SGGetLanguage:String;inline;
function SGWhatIsTheSimbolRU(const l:longint;const Shift:boolean = False;const Caps:Boolean = False):string;inline;
function SGWhatIsTheSimbolEN(const l:longint;const Shift:boolean = False;const Caps:Boolean = False):string;inline;

//Вычисление максимального или минимального значения из заданых
function SGMax(const a,b:single):single;inline;overload;
function SGMax(const a,b:real):real;inline;overload;
function SGMax(const a,b:extended):extended;inline;overload;
function SGMax(const a,b:Int64):Int64;inline;overload;
function SGMin(const a,b:single):single;inline;overload;
function SGMin(const a,b:real):real;inline;overload;
function SGMin(const a,b:extended):extended;inline;overload;
function SGMin(const a,b:LongInt):LongInt;overload;inline;
function SGMin(const a,b:LongWord):LongWord;overload;inline;
function SGMin(const a,b:Int64):Int64;overload;inline;
function SGMin(const a,b:QWord):QWord;overload;inline;

//Возвращает расширение файла в верхнем регистре
function SGGetFileExpansion(const FileName:string):string;inline;

//Проверяет, не образована ли строка AString как Part + [хз]
function SGExistsFirstPartString(const AString:String;const Part:String):Boolean;

//Читает строку из потока, находящиюся между символами Quote
function SGReadStringInQuotesFromStream(Const Stream:TStream;const Quote:char = #39):string;inline;

//Загружает часть потока в другой поток
procedure SGLoadLoadPartStreamToStream(const StreamIn,StreamOut:TStream; const Size:Int64);overload;inline;

//Загружает часть потока в другой поток. Оптимизировано под TMemoryStream
procedure SGLoadLoadPartStreamToStream(const StreamIn:TStream;StreamOut:TMemoryStream; const Size:Int64);overload;inline;

//Вычисления логорифма
function Log(const a,b:real):real;inline;

//Возвращает длинну строки
function SGPCharLength(const pc:PChar):int64;inline;

//Перевод Boolean в String
function SGStr(const b:boolean):String;overload;inline;

//Возвращает строку, гду красивенько написан размер файла, занимающего Size байт
function SGGetSizeString(const Size:Int64;const Language:TSGString = 'RU'):String;inline;

//Переводит действительное число в строку, оставив после запятой l цифр
function SGStrReal(r:real;const l:longint):string;
function SGStrExtended(r:Extended;const l:longint):string;inline;
function SGFloatToString(const R:Extended;const Zeros:LongInt = 0):string;inline;

//перевод строки в строку С++. При этом выбеляется память (Length(s)+1) под указатель на строк С++.
function SGStringToPChar(const s:string):PCHAR;

//Проверяет наличие файла на диске
function SGFileExists(const FileName:string = ''):boolean;

//Это для SGConsoleMenu
operator + (const a,b:TSGConsoleRecord):TSGConsoleMenuArray;overload;inline;
operator + (const a:TSGConsoleMenuArray;b:TSGConsoleRecord):TSGConsoleMenuArray;overload;inline;
function SGConsoleRecord(const s:string;const p:pointer):TSGConsoleRecord;inline;

//Псевдографическое меню в консоли.
procedure SGConsoleMenu(const Ar:TSGConsoleMenuArray;
	const VBackGround:LongWord = 0;
	const VText:LongWord = 15;
	const VActiveBackGround:LongWord = 0;
	const VActiveText:LongWord = 10;
	const Koima:Boolean = True);

//Перевод строки C++ в строку
function SGPCharToString(const VChar:PChar):string;inline;

//Переводит строку в число
function SGVal(const Text:string = '0'):Int64;inline;overload;

//Возвращаето часть строки, находящуюся между [a..b] включительно
function SGStringGetPart(const S:string;const a,b:LongWord):String;

//Самая быстрая сортировка
procedure SGQuickSort(var Arr; const ArrLength,SizeOfElement:Int64;const SortFunction:Pointer);

//Переводит тип (array of const) в строку
//(array of const) можно задавать как ['dsdas',123,'a',#34,123.5].
function SGGetStringFromConstArray(const Ar:packed array of const):String;

function SGArConstToArString(const Ar:packed array of const):TSGArString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

//Возвращает краткое имя файла, из полного имени файла
function SGGetFileName(const WayName:string):string;

//Реализует путь Way
procedure SGReleazeFileWay(WAy:string);

//Возвращает путь к файлу из полного имени файла
function SGGetFileWay(const Way:String):String;

//Создает папку. 
function SGMakeDirectory(const DirWay:String):Boolean;inline;

//Вычисление матриц
function SGGetMatrix2x2(a1,a2,a3,a4:real):real;inline;
function SGGetMatrix3x3(a1,a2,a3,a4,a5,a6,a7,a8,a9:real):real;inline;

//Добавляет к строке С++ символ в конец строки
function SGPCharAddSimbol(var VPChar:PChar; const VChar:Char):PChar;

//Проверяет эквивалентность строк С++
function SGPCharsEqual(const PChar1,PChar2:PChar):Boolean;inline;

//Возвращает индекс последнего элемента строки
function SGPCharHigh(const VPChar:PChar):LongInt;inline;

//Возвращает длинну строки
function SGPCharLength(const VPChar:PChar):LongWord;inline;

//Урезает строку С++ на Number символов с конца
function SGPCharDecFromEnd(var VPChar:PChar; const Number:LongWord = 1):PChar;

//Возвращает строку С++ в верхнем регистре
function SGPCharUpCase(const VPChar:PChar):PChar;inline;

//Чистает строку С++ с клавиатуры
function SGPCharRead():PChar;inline;

//Читает один символ с клавиатуры
function SGCharRead:Char;inline;

//Удаляет все пробелы в строке С++
function SGPCharDeleteSpaces(const VPChar:PCHAR):PChar;inline;

//Возвращает конкютинацию строк С++
function SGPCharTotal(const VPChar1,VPChar2:PChar):PChar;inline;

//Проверяет, не находятся ли значения параметров функции в одной Эпсилон окресности какой-то точки
function SGRealsEqual(const r1,r2:real):Boolean;inline;

//Проверяет, не является ли параметр функции больше любого наперед заданного числа
function SGRealExists(const r:real):Boolean;inline;

//Быстро поменять местами параметры процедуры
procedure SGQuickRePlaceReals(var Real1,Real2:Real);inline;
procedure SGQuickRePlaceLongInt(var LongInt1,LongInt2:LongInt);inline;

//Случайно возвращает либо (-1) либо (1)
function SGRandomMinus():Int;inline;

//Возвращает обьект плоскости, полученый вт результате приобразования трех точек
function SGGetPlaneFromNineReals(const x1,y1,z1,x2,y2,z2,x0,y0,z0:real):SGPlane;

//Возвращает часть строки С++, находящуюся между позициями включительно
function SGPCharGetPart(const VPChar:PChar;const Position1,Position2:LongInt):PChar;

//Возвразает количество цифр в числе
function SGGetQuantitySimbolsInNumber(l:LongInt):LongInt;inline;

//Возвращает свободное имя файла. 
//Catalog - это полный путь папки, где он будет его искать.
//Sl - это то, что он будлет каждый раз прибавлять в конец имени файла в скобойкой и с нумерацией
function SGGetFreeFileName(const Name:string;const sl:string = 'Copy'):string;inline;

//Возвращает имя файла без его расширения
function SGGetFileNameWithoutExpansion(const FileName:string):string;inline;

//Читает строку из консольки
function SGReadLnString():String;

//Читает один байт из консольки
function SGReadLnByte():Byte;

//Аналог SGGetFreeFileName, только для каталогов (папок)
function SGGetFreeDirectoryName(const Name:string;const sl:string = 'Copy'):string;inline;

//Если в начале строки стоит '-' то функция возвращает строку без '-' в начале, ежели возвращает ''
function SGGetComand(const comand:string):string;inline;

//Проверяет, существует ли директория(каталог,папка)
function SGExistsDirectory(const DirWay:String):Boolean;inline;

//Возвращает директорию, в которой запужена программа
function SGGetCurrentDirectory():string;inline;

//Возвращает количество логических ядер процессора
function SGGetCoreCount():Byte;inline;

function SGSetExpansionToFileName(const FileName,Expansion:TSGString):TSGString;inline;

function SGConvertAnsiToASCII(const s:TSGString):TSGString;

function SGDownCaseString(const str:TSGString):TSGString;
function DownCase(const c:TSGChar):TSGChar;

procedure SGRunComand(const Comand : String;const ProcessOptions : TProcessOptions = []; const ViewOutput : Boolean = false);

function Iff(const b : TSGBoolean;const s1,s2:TSGString):TSGString;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSGBoolean;const s1,s2:TSGFloat):TSGFloat;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SGAddToLog(const FileName, Line : String);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGStringReplace(const VString : TSGString; const C1, C2 : TSGChar):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

function SGStringReplace(const VString : TSGString; const C1, C2 : TSGChar):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
begin
Result := VString;
for i := 1 to Length(Result) do
	if Result[i] = C1 then
		Result[i] := C2;
end;

procedure SGAddToLog(const FileName, Line : String);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	ss:string;
	a:TSGDateTime;
	pc:PChar;
	FFileStream : TMemoryStream;
begin
FFileStream := TMemoryStream.Create();
if SGFileExists(FileName) then
	begin
	FFileStream.LoadFromFile(FileName);
	FFileStream.Position := FFileStream.Size;
	end;
a.Get;
with a do
	ss:='['+SGStr(Day)+'.'+SGStr(Month)+'.'+SGStr(Years)+'/'+SGStr(Week)+']'+
		'['+SGStr(Hours)+':'+SGStr(Minutes)+':'+SGStr(Seconds)+'/'+SGStr(Sec100)+'] -->'+Line;
pc:=SGStringToPChar(ss+SGWinEoln);
FFileStream.WriteBuffer(pc^,Length(ss)+2);
FreeMem(pc,Length(ss)+3);
FFileStream.Position := 0;
FFileStream.SaveToFile(FileName);
FFileStream.Destroy();
end;

function Iff(const b : TSGBoolean;const s1,s2:TSGFloat):TSGFloat;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSGBoolean;const s1,s2:TSGString):TSGString;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

procedure SGRunComand(const Comand : String;const ProcessOptions : TProcessOptions = []; const ViewOutput : Boolean = false);
var
	AProcess: TProcess;
	AStringList: TStringList;
	i : LongInt;
begin
AProcess := TProcess.Create(nil);
AProcess.CommandLine := Comand;
AProcess.Options := AProcess.Options + ProcessOptions;
AProcess.Execute();

if (poUsePipes in ProcessOptions) and ViewOutput then
	begin
	AStringList := TStringList.Create;
	AStringList.LoadFromStream(AProcess.Output);
	for i := 0 to AStringList.Count - 1 do
		begin
		WriteLn(AStringList[i]);
		end;
	AStringList.Free;
	end;

AProcess.Free(); 
end;

function DownCase(const c:TSGChar):TSGChar;
begin
if c in ['A'..'Z'] then
	begin
	Result:=TSGChar(TSGByte(c)-(TSGByte('A')-TSGByte('a')))
	end
else
	Result:=c;
end;

function SGDownCaseString(const str:TSGString):TSGString;
var
	i:TSGMaxEnum;
begin
for i:=1 to Length(str) do
	Result+=DownCase(str[i]);
end;

function SGConvertAnsiToASCII(const s:TSGString):TSGString;
var
	i,ii,iii:TSGLongWord;
begin
Result:='';
for i:=1 to Length(s) do
	begin
	Result+=SGAnsiToASCII[s[i]];
	end;
end;

function SGSetExpansionToFileName(const FileName,Expansion:TSGString):TSGString;inline;
begin
Result:= SGGetFileWay(FileName)+SGGetFileNameWithoutExpansion(SGGetFileName(FileName))+'.'+Expansion;
end;

function SGGetCoreCount():Byte;inline;
{$IFDEF USE_uSMBIOS}
Var
  SMBios             : TSMBios;
  LProcessorInfo     : TProcessorInformation;
{$ENDIF}
begin
Result:=0;
{$IFDEF USE_uSMBIOS}
try
	SMBios:=TSMBios.Create();
	if SMBios.HasProcessorInfo then
		for LProcessorInfo in SMBios.ProcessorInfo do
			if SMBios.SmbiosVersion>='2.5' then
				Result:=LProcessorInfo.RAWProcessorInformation^.CoreCount;
finally
	SMBios.Free;
	end;
{$ENDIF}
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
Result:=DirectoryExists(DirWay);
{try
MKDir(DirWay);
except
Result:=True;
end;
if Result=False then
	RMDIR(DirWay);}
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

procedure SGSetScreenLoadProcedure(p:Pointer);
begin
SGScreenLoadProcedure:=SGScreenProcedureWC(p);
end;


procedure SGSetScreenProcedure(const p:Pointer = nil);
begin
SGScreenPaintProcedure:=SGScreenProcedureWC(p);
end;

procedure SCSetScreenScreenBounds(const p:Pointer = nil);
begin
SGScreenForReSizeScreenProcedure:=SGScreenProcedureWC(p);
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

procedure SGReleazeFileWay(WAy:string);
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

function SGArConstToArString(const Ar : packed array of const):TSGArString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
begin
SetLength(Result, Length(Ar));
if High(Ar)>=0 then 
	begin
	for i := 0 to High(Ar) do
		case Ar[i].vtype of
		vtInteger: 
			Result[i] := SGStr(Ar[i].vinteger);
		vtString: 
			Result[i] := (Ar[i].vstring^);
		vtAnsiString: 
			Result[i] := (AnsiString(Ar[i].vpointer));
		vtBoolean: 
			Result[i] := SGStr(Ar[i].vboolean);
		vtChar: 
			Result[i] := Ar[i].vchar;
		vtExtended: 
			Result[i] := SGStrReal(Extended(Ar[i].vpointer^),5);
		end;
	end;
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
Result.FTitle:=s;
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
	iiii:=3+((MaxLength - Length(Ar[ii].FTitle))div 2);
	Crt.GoToXY(iiii,i);
	Crt.TextColor(VActiveText*Byte(NowActive=ii)+VText*Byte((NowActive<>ii)));
	Crt.TextBackGround(VActiveBackGround*Byte(NowActive=ii)+VBackGround*Byte((NowActive<>ii)));
	if DAll or ((not DAll) and ((ii=NowActive) or (ii=OldActive))) then
		if Koima then 
			begin
			if ii=NowActive then
				begin
				Write(#218);for iii:=1 to Length(Ar[ii].FTitle) do Write(#196);Write(#191);
				i+=1;Crt.GoToXY(iiii,i);
				Write(#179);Write(Ar[ii].FTitle);Write(#179);
				i+=1;Crt.GoToXY(iiii,i);
				Write(#192);for iii:=1 to Length(Ar[ii].FTitle) do Write(#196);Write(#217);
				end
			else
				begin
				Write(#201);for iii:=1 to Length(Ar[ii].FTitle) do Write(#205);Write(#187);
				i+=1;Crt.GoToXY(iiii,i);
				Write(#186);Write(Ar[ii].FTitle);Write(#186);
				i+=1;Crt.GoToXY(iiii,i);
				Write(#200);for iii:=1 to Length(Ar[ii].FTitle) do Write(#205);Write(#188);
				end;
			i+=1;
			end
		else
			begin
			Write(Ar[ii].FTitle);
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
	if MaxLength<Length(Ar[OldActive].FTitle) then
		MaxLength:=Length(Ar[OldActive].FTitle);
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
		pc:=SGStringToPChar(s+SGWinEoln);
		FFileStream.WriteBuffer(pc^,Length(s)+2);
		FreeMem(pc,Length(s)+3);
		end
	else
		begin
		a.Get;
		with a do
			ss:='['+SGStr(Day)+'.'+SGStr(Month)+'.'+SGStr(Years)+'/'+SGStr(Week)+']'+
				'['+SGStr(Hours)+':'+SGStr(Minutes)+':'+SGStr(Seconds)+'/'+SGStr(Sec100)+'] -->'+s;
		pc:=SGStringToPChar(ss+SGWinEoln);
		FFileStream.WriteBuffer(pc^,Length(ss)+2);
		FreeMem(pc,Length(ss)+3);
		end;
end;

constructor TSGLog.Create();
begin
inherited;
if SGLogEnable then
	FFileStream:=TFileStream.Create(SGLogDirectory+Slash+'EngineLog.log',fmCreate);
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
var
	i     : TSGLongInt;
begin
if r<0 then 
	Result:='-' 
else 
	Result:='';
r:=abs(r);
Result+=SGStr(Trunc(r));
r-=trunc(r);
r:=abs(r);
if R>1/(10**l) then
	begin
	Result+='.';
	for i:=1 to l do
		begin
		if r=0 then 
			Break;
		r*=10;
		Result+=SGStr(trunc(r));
		r-=trunc(r);
		end;
	end;
if (Result='') or (Result='-') then 
	Result+='0';
end;

function SGStrExtended(r:Extended;const l:longint):string;inline;
var
	i     : TSGLongInt;
begin
if r<0 then 
	Result:='-' 
else 
	Result:='';
if ((SGStr(Trunc(abs(r)))='9223372036854775808') and
	((SGStr(Trunc(abs(r/100)))='9223372036854775808'))) or
	((SGStr(Trunc(abs(r)))='-9223372036854775808') and
	((SGStr(Trunc(abs(r/100)))='-9223372036854775808'))) then
		begin
		Result+='Inf';
		Exit();
		end;
r:=abs(r);
Result+=SGStr(Trunc(r));
r-=trunc(r);
r:=abs(r);
if R>1/(10**l) then
	begin
	Result+='.';
	for i:=1 to l do
		begin
		if r=0 then 
			Break;
		r*=10;
		Result+=SGStr(trunc(r));
		r-=trunc(r);
		end;
	end;
if (Result='') or (Result='-') then 
	Result+='0';
end;

function SGGetSizeString(const Size:Int64;const Language:TSGString = 'RU'):String;inline;
var
	e:extended;
	d:LongWord = 0;
begin
if Size<1024 then
	begin
	Result:=SGStr(Size);
	if Language='RU' then
		Result+=' байт'
	else
		Result+=' byte';
	end
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
		if Language='RU' then
			Result+=' КБайт'
		else
			Result+=' KByte';
	2:
		if Language='RU' then
			Result+=' MБайт'
		else
			Result+=' MByte';
	3:
		if Language='RU' then
			Result+=' ГБайт'
		else
			Result+=' GByte';
	4:
		if Language='RU' then
			Result+=' ТБайт'
		else
			Result+=' TByte';
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
FFinished:=True;
FParametr:=Para;
FProcedure:=Proc;
FillChar(FHandle,SizeOf(FHandle),0);
FThreadID:=0;
{$IFDEF ANDROID}
	fillchar(attr,sizeof(attr),0);
	fillchar(cond,sizeof(cond),0);
	fillchar(mutex,sizeof(mutex),0);
	{$ENDIF}
if QuickStart then
	Start();
end;

procedure TSGThread.SetProcedure(const Proc:TSGThreadProcedure);
begin
FProcedure:=Proc;
end;

procedure TSGThread.SetParametr(const Pointer:Pointer);
begin
FParametr:=Pointer;
end;

procedure TSGThread.Execute();
begin
{$IFDEF ANDROID}
	pthread_mutex_lock(@mutex);
	{$ENDIF}
FFinished:=False;
{$IFDEF ANDROID}
	pthread_cond_broadcast(@cond);
	pthread_mutex_unlock(@mutex);
	{$ENDIF}
if Pointer(FProcedure)<>nil then
	FProcedure(FParametr);
{$IFDEF ANDROID}
	pthread_mutex_lock(@mutex);
	{$ENDIF}
FFinished:=True;
{$IFDEF ANDROID}
	pthread_mutex_unlock(@mutex);
	{$ENDIF}
end;

function TSGThreadStart(ThreadClass:TSGThread):TSGThreadFunctionResult;
{$IFDEF ANDROID}cdecl;{$ELSE}{$IF defined(MSWINDOWS)}stdcall;{$ENDIF}{$ENDIF}
begin
Result:={$IFDEF ANDROID}nil{$ELSE}0{$ENDIF};
ThreadClass.Execute();
{$IFDEF ANDROID}
	while true do
		begin
		Sleep(10000); 
		end;
	{$ENDIF}
end;

destructor TSGThread.Destroy();
{$IFDEF MSWINDOWS}
	var
		i : TSGBoolean;
	{$ENDIF}
begin
{$IFDEF MSWINDOWS}
	if not FFinished then
		begin
		i:=TerminateThread(FHandle,0);
		SGLog.Sourse(['TSGThread__Destroy : FHandle=',FHandle,',FThreadID=',FThreadID,',Terminate Result=',i,'.']);
		end;
	if FHandle <> 0 then
		CloseHandle(FHandle);
{$ELSE}
	{$IFDEF ANDROID}
		{if not FFinished then
			pthread_cancel(FHandle);}
		pthread_cond_destroy(@cond);
		pthread_mutex_destroy(@mutex);
		pthread_attr_destroy(@attr);
	{$ELSE}
	if not FFinished then
		KillThread(FHandle);
		{$ENDIF}
	{$ENDIF}
FillChar(FHandle,SizeOf(FHandle),0);
FThreadID:=0;
inherited;
end;

procedure TSGThread.Start();
begin
{$IFDEF MSWINDOWS}
	FHandle:=CreateThread(nil,0,@TSGThreadStart,Self,0,FThreadID);
{$ELSE}
	{$IFDEF ANDROID}
			SGLog.Sourse('Start thread');
			pthread_mutex_init(@mutex, nil);
			pthread_cond_init(@cond, nil);
			pthread_attr_init(@attr);
			pthread_attr_setdetachstate(@attr,PTHREAD_CREATE_DETACHED);
			FThreadID:=pthread_create(@FHandle,@attr,TSGThreadFunction(@TSGThreadStart),Self);
			pthread_mutex_lock(@mutex);
			while FFinished do
				pthread_cond_wait(@cond, @mutex);
			pthread_mutex_unlock(@mutex);
			SGLog.Sourse('End start thread : FHandle = '+SGStr(LongWord(FHandle))+', FThreadID = '+SGStr(FThreadID)+', Self = '+SGStr(TSGLongWord(Self))+'.');
		{$ELSE}
			FHandle := BeginThread(TSGThreadFunction(@TSGThreadStart),Self);
		{$ENDIF}
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
74:if Shift xor Caps then Result:='J' else Result:='j';
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

function SGSecondsToStringTime(VSeconds:Int64;const Encoding : string = 'RUS1251'):string;inline;
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

function SGStr(const Number : TSGInt64 = 0):String;inline;overload;
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

function SGReadLnStringFromStream(const Stream:TStream):String;inline;

function EolnChars(const c : char):TSGBoolean; inline;
begin
Result := (c = #13) or (c = #0) or (c = #10) or (c = #27);
end;

var
	c:char = #1;
	ToOut : TSGBoolean = False;
begin
Result:='';
while (Stream.Position < Stream.Size) and ((not ToOut) or EolnChars(c))  do
	begin
	Stream.ReadBuffer(c,1);
	if EolnChars(c) then
		ToOut := True
	else if (not ToOut) then
		Result += c;
	end;
if Stream.Position <> Stream.Size then
	Stream.Position := Stream.Position - 1;
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

operator - (const a,b:TSGDateTime):TSGDateTime;inline;
var
	i:TSGByte;
begin
for i:=1 to 8 do
	PArFrom1To8OfLongInt(@Result)^[i]:=PArFrom1To8OfLongInt(@a)^[i]-PArFrom1To8OfLongInt(@b)^[i];
end;

function TSGDateTime.GetPastSeconds:int64;
begin
Result:=Seconds;
Result+=Minutes*60;
Result+=Hours  *60*60;
Result+=Day    *60*60*24;
Result+=Month  *60*60*24*30;
Result+=Years  *60*60*24*365;
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
{$IFDEF ANDROID}SGMakeDirectory('/sdcard/.SaGe');{$ENDIF}
try
SGLog:=TSGLog.Create();
SGLog.Sourse('(***) SaGe Engine Log (***)',False);
SGLog.Sourse('  << Create Log >>');
except
SGLogEnable:=False;
SGLog:=TSGLog.Create();
end;

Nan:=sqrt(-1);
Inf:=1/0;
RandomIze();
end;

finalization
begin
SGLog.Sourse('  << Destroy Log >>');
SGLog.Destroy();
end;

end.
