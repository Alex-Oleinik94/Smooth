{$INCLUDE SaGe.inc}

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
	{$IFDEF ANDROID}
		,ctypes
		,cmem
		,unixtype
		,android_native_app_glue
		{$ENDIF}
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
	TSGLibHandle = type TSGMaxEnum;
	TSGLibHandleList = type packed array of TSGMaxEnum;
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
	TSGLibrary = class
			public
		constructor Create(const VLibraryName : TSGString);
		destructor Destroy();override;
			private
		FLibrary : TSGLibHandle;
			public
		function GetProcedureAddress(const VProcedureName : TSGString) : Pointer;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property LibHandle : TSGLibHandle read FLibrary;
		end;

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
const
	//Используется для вычисления с Эпсилон
	SGZero = 0.0001;
var
	//Несуществующее значение
	Nan:real;
	//Бесконечное значение
	Inf:real;

//Сливает массивы Real-ов
operator + (a,b:TArReal):TArReal;inline;

function SGIsConsole() : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function LoadLibrary(const AName : PChar): TSGLibHandle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function LoadLibrary(const AName : TSGString): TSGLibHandle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function UnloadLibrary(const VLib : TSGLibHandle) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function GetProcAddress(const Lib : TSGLibHandle; const VPChar:PChar):Pointer;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

//Result := Trunc(T)+1
function SGTruncUp(const T : Real):LongInt;inline;

//Возвращает имена всех файлов в этом каталоге
function SGGetFileNames(const Catalog:String;const What:String = ''):TSGStringList;

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

//Загружает часть потока в другой поток
procedure SGLoadLoadPartStreamToStream(const StreamIn,StreamOut:TStream; const Size:Int64);overload;inline;

//Загружает часть потока в другой поток. Оптимизировано под TMemoryStream
procedure SGLoadLoadPartStreamToStream(const StreamIn:TStream;StreamOut:TMemoryStream; const Size:Int64);overload;inline;

//Вычисления логорифма
function Log(const a,b:real):real;inline;

//Проверяет наличие файла на диске
function SGFileExists(const FileName:string = ''):boolean;

//Самая быстрая сортировка
procedure SGQuickSort(var Arr; const ArrLength,SizeOfElement:Int64;const SortFunction:Pointer);

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

//Возвразает количество цифр в числе
function SGGetQuantitySimbolsInNumber(l:LongInt):LongInt;inline;

//Возвращает свободное имя файла.
//Catalog - это полный путь папки, где он будет его искать.
//Sl - это то, что он будлет каждый раз прибавлять в конец имени файла в скобойкой и с нумерацией
function SGGetFreeFileName(const Name:string;const sl:string = 'Copy'):string;inline;

//Возвращает имя файла без его расширения
function SGGetFileNameWithoutExpansion(const FileName:string):string;inline;

//Аналог SGGetFreeFileName, только для каталогов (папок)
function SGGetFreeDirectoryName(const Name:string;const sl:string = 'Copy'):string;inline;

//Если в начале строки стоит '-' то функция возвращает строку без '-' в начале, ежели возвращает ''
function SGGetComand(const comand:string):string;inline;

//Проверяет, существует ли директория(каталог,папка)
function SGExistsDirectory(const DirWay:String):Boolean;inline;

//Возвращает директорию, в которой запужена программа
function SGGetCurrentDirectory():string;inline;

function SGSetExpansionToFileName(const FileName,Expansion:TSGString):TSGString;inline;

procedure SGRunComand(const Comand : String; const ViewOutput : Boolean = True);
function Iff(const b : TSGBoolean; const s1, s2 : TSGString) : TSGString;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSGBoolean; const s1, s2 : TSGFloat): TSGFloat;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGAddToLog(const FileName, Line : String);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetApplicationFileName() : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SGHint(const MessageStr : TSGString; const ViewCase : TSGViewErrorType = [SGPrintError, SGLogError]);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
procedure SGHint(const MessagePtrs : array of const; const ViewCase : TSGViewErrorType = [SGPrintError, SGLogError]);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
procedure SGPrintStackTrace();
procedure SGPrintExceptionStackTrace(const e : Exception);
procedure SGPrintParams(const S : TSGString; const Title : TSGString; const Separators : TSGString; const SimbolsLength : TSGUInt16 = 78);overload;
procedure SGPrintParams(const ArS : TSGStringList; const Title : TSGString; const SimbolsLength : TSGUInt16 = 78);overload;
procedure SGStringListTrimAll(var SL : TSGStringList; const Garbage : TSGChar = ' ');
procedure SGPrintStream(const Stream : TStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
procedure SGWriteStream(const Stream : TStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SGStringToStream(const Str : TSGString) : TMemoryStream; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SGMatchingStreamString(const Stream : TStream; const Str : TSGString; const DestroyingStream : TSGBoolean = False) : TSGBool; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}

implementation

uses
	 StrMan
	
	,SaGeStringUtils
	,SaGeThreads
	,SaGeDateTime
	,SaGeEncodingUtils
	,SaGeFileUtils
	,SaGeConsoleUtils
	,SaGeMathUtils
	,SaGeSysUtils
	,SaGeLog
	;

function SGMatchingStreamString(const Stream : TStream; const Str : TSGString; const DestroyingStream : TSGBoolean = False) : TSGBool; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	Str2 : TSGString = '';
	C : TSGChar;
begin
Result := False;
while (Stream.Size <> Stream.Position) and (Length(Str2) < Length(Str)) do
	begin
	Stream.Read(C, 1);
	Str2 += C;
	end;
Result := Str2 = Str;
if DestroyingStream then
	Stream.Destroy();
end;

function SGStringToStream(const Str : TSGString) : TMemoryStream; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := TMemoryStream.Create();
SGWriteStringToStream(Str, Result, False);
end;

procedure SGWriteStream(const Stream : TStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	Write(SGReadLnStringFromStream(Stream));
end;

procedure SGPrintStream(const Stream : TStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	WriteLn(SGReadLnStringFromStream(Stream));
end;

procedure SGStringListTrimAll(var SL : TSGStringList; const Garbage : TSGChar = ' ');
var
	i : TSGUInt32;
begin
if SL <> nil then
	if Length(SL) > 0 then
		for i := 0 to High(SL) do
			SL[i] := StringTrimAll(SL[i], Garbage);
end;

procedure SGPrintExceptionStackTrace(const e : Exception);
var
	I, H   : Integer;
	Frames : PPointer;
	Report : TSGString;
begin
Report := 'An unhandled exception occurred at ' + SGAddrStr(ExceptAddr) + ':' + SGWinEoln;
if E <> nil then
	Report += E.ClassName + ': ' + E.Message + SGWinEoln;
Report += BackTraceStrFunc(ExceptAddr) + SGWinEoln;
Frames := ExceptFrames;
H := ExceptFrameCount - 1;
for I := 0 to H do
	begin
	Report += BackTraceStrFunc(Frames[I]);
	if I <> H then
		Report += SGWinEoln;
	end;
SGHint(Report);
Report := '';
end;

procedure SGPrintStackTrace();
var
	bp: Pointer;
	addr: Pointer;
	oldbp: Pointer;
begin
bp := get_caller_frame(get_frame);
while bp<>nil do
	begin
	addr := get_caller_addr(bp);
	SGHint(BackTraceStrFunc(addr));
	oldbp := bp;
	bp := get_caller_frame(bp);
	if (bp <= oldbp) or (bp > (StackBottom + StackLength)) then
		bp := nil;
	end;
end;

procedure SGHint(const MessagePtrs : array of const; const ViewCase : TSGViewErrorType = [SGPrintError, SGLogError]);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
begin
SGHint(SGGetStringFromConstArray(MessagePtrs), ViewCase);
end;

procedure SGHint(const MessageStr : TSGString; const ViewCase : TSGViewErrorType = [SGPrintError, SGLogError]);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
begin
if SGLogError in ViewCase then
	SGLog.Source(MessageStr);
if SGPrintError in ViewCase then
	WriteLn(MessageStr);
end;

function SGGetApplicationFileName() : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := argv[0];
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

procedure SGRunComand(const Comand : String; const ViewOutput : Boolean = True);
var
	AProcess: TProcess;

procedure WriteFromStringList();
var
	AStringList: TStringList;
	i : LongInt;
begin
AProcess.WaitOnExit();
AStringList := TStringList.Create;
AStringList.LoadFromStream(AProcess.Output);
for i := 0 to AStringList.Count - 1 do
	begin
	WriteLn(AStringList[i]);
	end;
AStringList.Free;
end;

procedure WriteFromBytes();
var
	Error : TSGBoolean;
begin
Error := False;
while AProcess.Active or (not Error) do
	begin
	Error := False;
	try
	Write(Char(AProcess.Output.ReadByte));
	except
	Error := True;
	end;
	if Error then
		Sleep(10);
	end;
end;

begin
AProcess := TProcess.Create(nil);
AProcess.CommandLine := Comand;
AProcess.Options := AProcess.Options + [poUsePipes, poStderrToOutPut];
AProcess.Execute();

if (poUsePipes in AProcess.Options) and ViewOutput then
	begin
	//WriteFromStringList();
	WriteFromBytes();
	end;

AProcess.Free();
end;

function SGSetExpansionToFileName(const FileName,Expansion:TSGString):TSGString;inline;
begin
Result:= SGGetFileWay(FileName)+SGGetFileNameWithoutExpansion(SGGetFileName(FileName))+'.'+Expansion;
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

procedure SGQuickRePlaceLongInt(var LongInt1,LongInt2:LongInt);inline;
var
	LongInt3:LongInt;
begin
LongInt3:=LongInt1;
LongInt1:=LongInt2;
LongInt2:=LongInt3;
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
Move(PByte(TSGMaxEnum(@Arr)+((L+R)div 2)*SizeOfElement)^,Key^,SizeOfElement);
repeat
while SGQSF(SortFunction)(PByte(TSGMaxEnum(@Arr)+i*SizeOfElement)^,Key^) do i+=1;
while SGQSF(SortFunction)(Key^,PByte(TSGMaxEnum(@Arr)+j*SizeOfElement)^) do j-=1;
if i<=j then
	begin
	Move(PByte(TSGMaxEnum(@Arr)+i*SizeOfElement)^,Temp^,SizeOfElement);
	Move(PByte(TSGMaxEnum(@Arr)+j*SizeOfElement)^,
		 PByte(TSGMaxEnum(@Arr)+i*SizeOfElement)^,SizeOfElement);
	Move(Temp^,PByte(TSGMaxEnum(@Arr)+j*SizeOfElement)^,SizeOfElement);
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

procedure SGPrintParams(const ArS : TSGStringList; const Title : TSGString; const SimbolsLength : TSGUInt16 = 78);overload;
var
	i, WordCount, MaxLength, n, ii: TSGLongWord;
	TempS : TSGString;
begin
WordCount := 0;
if ArS <> nil then
	WordCount := Length(ArS);
if WordCount > 0 then
	begin
	WriteLn(Title + ' (' + SGStr(WordCount) + ')');
	MaxLength := Length(ArS[0]);
	if Length(ArS) > 1 then
		begin
		for i := 1 to High(ArS) do
			if Length(ArS[i]) > MaxLength then
				MaxLength := Length(ArS[i]);
		end;
	MaxLength += 2;
	n := SimbolsLength div MaxLength;
	MaxLength += (SimbolsLength mod MaxLength) div n;
	ii := 0;
	TempS := '  ';
	for i := 0 to High(ArS) do
		begin
		if (ii = n - 1) or (i = High(ArS)) then
			TempS += ArS[i]
		else
			TempS += StringJustifyLeft(ArS[i], MaxLength, ' ');
		ii +=1;
		if ii = n then
			begin
			ii := 0;
			WriteLn(TempS);
			TempS := '  ';
			end;
		end;
	if TempS <> '  ' then
		WriteLn(TempS);
	end;
end;

procedure SGPrintParams(const S : TSGString; const Title : TSGString; const Separators : TSGString; const SimbolsLength : TSGUInt16 = 78);
var
	ArS : TSGStringList = nil;
begin
ArS := SGStringListFromString(S, Separators);
SGPrintParams(ArS, Title, SimbolsLength);
SetLength(ArS, 0);
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

function SGMax(const a,b:Int64):Int64;inline;overload;
begin
if a>b then
	Result:=a
else
	Result:=b;
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

function SGGetFileNames(const Catalog:String;const What:String = ''):TSGStringList;
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


function SGTruncUp(const t:real):LongInt;inline;
begin
Result:=Trunc(t)+1;
end;

function SGIsConsole() : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
{$IF defined(MSWINDOWS)}
	Result := IsConsole;
{$ELSEIF defined(LINUX)}
	Result := True;
{$ELSEIF defined(ANDROID)}
	Result := False;
{$ELSE}
	Result := False;
{$ENDIF}
end;

destructor TSGLibrary.Destroy;
begin
UnloadLibrary(FLibrary);
inherited;
end;

constructor TSGLibrary.Create(const VLibraryName : TSGString);
var
	p : PChar;
begin
inherited Create();
p := SGStringToPChar(VLibraryName);
FLibrary := LoadLibrary(p);
FreeMem(p);
end;

function TSGLibrary.GetProcedureAddress(const VProcedureName : TSGString) : Pointer;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	p : PChar;
begin
p := SGStringToPChar(VProcedureName);
Result := GetProcAddress(FLibrary, p);
FreeMem(p);
end;

function UnloadLibrary(const VLib : TSGLibHandle) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := dynlibs.UnloadLibrary(VLib);
end;

function GetProcAddress(const Lib:TSGLibHandle; const VPChar:PChar):Pointer;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
{$IFDEF WINDOWS}
	Result:=Windows.GetProcAddress(Lib,VPChar);
{$ELSE}
	Result:=GetProcedureAddress(Lib,VPChar);
	{$ENDIF}
end;

function LoadLibrary(const AName : TSGString): TSGLibHandle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	PC : PSGChar;
begin
PC := SGStringToPChar(AName);
Result := LoadLibrary(PC);
FreeMem(PC, SGPCharLength(PC) + 1);
end;

function LoadLibrary(const AName: PChar) : TSGLibHandle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result:=
	{$ifdef UNIX}
		TSGLibHandle( dlopen(AName, RTLD_LAZY or RTLD_GLOBAL) );
	{$else}
		Windows.LoadLibrary(AName);
		{$endif}
end;

initialization
begin
Nan:=sqrt(-1);
Inf:=1/0;
RandomIze();
end;

end.
