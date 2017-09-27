{$INCLUDE SaGe.inc}

unit SaGeLog;

interface

uses
	 Classes
	,SysUtils
	
	,SaGeBase
	,SaGeFileUtils
	;
type
	TSGViewErrorCase = (
		SGPrintError,
		SGLogError);
	TSGViewErrorType = set of TSGViewErrorCase;
	TSGViewType = TSGViewErrorType;
const
	SGLogType = SGLogError;
	SGPrintType = SGPrintError;
	SGViewErrorFull  : TSGViewErrorType = [SGPrintError, SGLogError];
	SGViewErrorPrint : TSGViewErrorType = [SGPrintError];
	SGViewErrorLog   : TSGViewErrorType = [SGLogError];
	SGViewErrorNULL  : TSGViewErrorType = [];
	SGViewTypeFull  : TSGViewType = [SGLogType, SGPrintType];
	SGViewTypePrint : TSGViewType = [SGPrintType];
	SGViewTypeLog   : TSGViewType = [SGLogType];
	SGViewTypeNULL  : TSGViewType = [];
var
	SGLogEnable : TSGBoolean = 
		{$IFDEF RELEASE}
			False
		{$ELSE}
			True
		{$ENDIF}
	;
const
	SGLogDirectory =
		{$IFDEF ANDROID}
			DirectorySeparator +'sdcard' + DirectorySeparator +'.SaGe'
		{$ELSE}
			'.' + DirectorySeparator + '..' + DirectorySeparator + 'Log'
		{$ENDIF}
	;
var
	SGLogFileName : TSGString = SGLogDirectory + DirectorySeparator + 'Application.log';
type
	TSGLog = class(TObject)
			public
		constructor Create(const LogFile : TSGString);
		destructor Destroy(); override;
		procedure Source(const S : TSGString; const WithTime : TSGBoolean = True);overload;
		procedure Source(const Ar : array of const; const WithTime : TSGBoolean = True);overload;
		procedure Source(const S : TSGString; const Title : TSGString; const Separators : TSGString; const SimbolsLength : TSGUInt16 = 150);overload;
		procedure Source(const ArS : TSGStringList; const Title : TSGString; const ViewTime : TSGBoolean = True; const SimbolsLength : TSGUInt16 = 150);overload;
			private
		FFileStream : TFileStream;
		end;
var
	//Экземпляр класса лога программы
	SGLog : TSGLog = nil;

procedure SGHint(const MessageStr : TSGString; const ViewCase : TSGViewErrorType = [SGPrintError, SGLogError];const ViewTime : TSGBoolean = False);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
procedure SGHint(const MessagePtrs : array of const; const ViewCase : TSGViewErrorType = [SGPrintError, SGLogError];const ViewTime : TSGBoolean = False);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
procedure SGAddToLog(const FileName, Line : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGLogDateTimePredString(const A : TSGBoolean = True) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGLogParams(const Log : TSGLog; Params : TSGStringList);
function SGCreateLog(var Log : TSGLog; const LogFile : TSGString) : TSGBoolean;
procedure SGFinalizeLog(); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGFreeLogFileName() : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeDateTime
	,SaGeStringUtils
	,SaGeBaseUtils
	,SaGeConsoleUtils
	,SaGeEncodingUtils
	,SaGeConsoleToolsBase
	,SaGeVersion
	
	,StrMan
	;

function SGFreeLogFileName() : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	DateTime  : TSGDateTime;
begin
DateTime.Get();
Result := 
{$IFNDEF MOBILE}
	SGAplicationFileDirectory() 
	{$ENDIF}
	+ SGLogDirectory;
SGMakeDirectory(Result);
Result += DirectorySeparator +
	'[' +
		StringJustifyRight(SGStr(DateTime.Years), 4, '0') + '.' + 
		StringJustifyRight(SGStr(DateTime.Month), 2, '0') + '.' +
		StringJustifyRight(SGStr(DateTime.Day),   2, '0') +
	']' +
	'[' +
		StringJustifyRight(SGStr(DateTime.Hours),   2, '0') + '.' + 
		StringJustifyRight(SGStr(DateTime.Minutes), 2, '0') + '.' + 
		StringJustifyRight(SGStr(DateTime.Seconds), 2, '0') + '.' + 
		StringJustifyRight(SGStr(DateTime.Sec100),  2, '0') + 
	']' + SGApplicationName + '.log';
Result := SGFreeFileName(Result, '');
end;

function SGLogDateTimePredString(const A : TSGBoolean = True) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	DateTime  : TSGDateTime;
begin
DateTime.Get();
Result := 
	'[' +
		StringJustifyRight(SGStr(DateTime.Day),   2, '0') + '.' + 
		StringJustifyRight(SGStr(DateTime.Month), 2, '0') + '.' +
		StringJustifyRight(SGStr(DateTime.Years), 4, '0') + '/' + 
		SGStr(DateTime.Week) + 
	']' +
	'[' +
		StringJustifyRight(SGStr(DateTime.Hours),   2, '0') + ':' + 
		StringJustifyRight(SGStr(DateTime.Minutes), 2, '0') + ':' + 
		StringJustifyRight(SGStr(DateTime.Seconds), 2, '0') + '/' + 
		StringJustifyRight(SGStr(DateTime.Sec100),  2, '0') + 
	']' + Iff(A, ' -->');
	;
end;

procedure SGAddToLog(const FileName, Line : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	ss : TSGString;
	pc :PSGChar;
	FFileStream : TMemoryStream;
begin
FFileStream := TMemoryStream.Create();
if SGFileExists(FileName) then
	begin
	FFileStream.LoadFromFile(FileName);
	FFileStream.Position := FFileStream.Size;
	end;
ss := SGLogDateTimePredString() + Line;
pc := SGStringToPChar(ss + SGWinEoln);
FFileStream.WriteBuffer(pc^, Length(ss) + 2);
FreeMem(pc, Length(ss) + 3);
FFileStream.Position := 0;
FFileStream.SaveToFile(FileName);
FFileStream.Destroy();
end;

procedure SGHint(const MessagePtrs : array of const; const ViewCase : TSGViewErrorType = [SGPrintError, SGLogError];const ViewTime : TSGBoolean = False);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
begin
SGHint(SGGetStringFromConstArray(MessagePtrs), ViewCase, ViewTime);
end;

procedure SGHint(const MessageStr : TSGString; const ViewCase : TSGViewErrorType = [SGPrintError, SGLogError];const ViewTime : TSGBoolean = False);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
begin
if SGLogError in ViewCase then
	SGLog.Source(MessageStr, ViewTime);
if SGPrintError in ViewCase then
	WriteLn(SGConvertStringToConsoleEncoding(MessageStr));
end;

procedure TSGLog.Source(const Ar : array of const; const WithTime:Boolean = True);
var
	OutString:String = '';
begin
 if SGLogEnable then
	begin
	OutString:=SGGetStringFromConstArray(Ar);
	Source(OutString,WithTime);
	SetLength(OutString,0);
	end;
end;

procedure TSGLog.Source(const ArS : TSGStringList; const Title : TSGString; const ViewTime : TSGBoolean = True; const SimbolsLength : TSGUInt16 = 150);overload;
var
	i, WordCount, MaxLength, n, ii, TitleLength : TSGMaxEnum;
	TempS : TSGString;
begin
WordCount := 0;
if ArS <> nil then
	WordCount := Length(ArS);
if WordCount > 0 then
	begin
	if (WordCount = 1) and ((Length(Title + ' ->') + 1 + Length(SGStringFromStringList(ArS, ' '))) < (SimbolsLength - 30)) then
		Source(Title + ' -> ' + SGStringFromStringList(ArS, ' '), ViewTime)
	else if (Length(Title + ' (' + SGStr(WordCount) + ') ->') + 1 + Length(SGStringFromStringList(ArS, ' '))) < (SimbolsLength - 30) then
		Source(Title + ' (' + SGStr(WordCount) + ') -> ' + SGStringFromStringList(ArS, ' '), ViewTime)
	else
		begin
		Source(Title + ' (' + SGStr(WordCount) + ') --->', ViewTime);
		MaxLength := Length(ArS[0]);
		if Length(ArS) > 1 then
			begin
			for i := 1 to High(ArS) do
				if Length(ArS[i]) > MaxLength then
					MaxLength := Length(ArS[i]);
			end;
		MaxLength += 2;
		n := 150 div MaxLength;
		MaxLength += (150 mod MaxLength) div n;
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
				Source(TempS, False);
				TempS := '  ';
				end;
			end;
		if TempS <> '  ' then
			Source(TempS, False);
		end;
	end;
end;

procedure TSGLog.Source(const S : TSGString; const Title : TSGString; const Separators : TSGString; const SimbolsLength : TSGUInt16 = 150);overload;
var
	ArS : TSGStringList = nil;
begin
ArS := SGStringListFromString(S, Separators);
Source(ArS, Title, True, SimbolsLength);
SetLength(ArS, 0);
end;

procedure TSGLog.Source(const s:string;const WithTime:Boolean = True);
var
	ss : TSGString;
	pc : PSGChar;
begin
if Self <> nil then
	if SGLogEnable and (FFileStream <> nil) then
		begin
		pc := SGStringToPChar(Iff(WithTime, SGLogDateTimePredString()) + SGStringDeleteEndOfLineDublicates(SGConvertString(S, SGEncodingWindows1251) + SGWinEoln));
		FFileStream.WriteBuffer(PC^, SGPCharLength(PC));
		SGPCharFree(PC);
		end;
end;

constructor TSGLog.Create(const LogFile : TSGString);
begin
inherited Create();
if SGLogEnable then
	FFileStream := TFileStream.Create(LogFile, fmCreate);
end;

destructor TSGLog.Destroy;
begin
if SGLogEnable then
	FFileStream.Destroy;
inherited;
end;

function SGCreateLog(var Log : TSGLog; const LogFile : TSGString) : TSGBoolean;

procedure KillLog();
begin
if Log <> nil then
	begin
	Log.Destroy();
	Log := nil;
	end;
end;

begin
KillLog();
Result := True;
try
	Log := TSGLog.Create(LogFile);
except
	Result := False;
	KillLog();
end;
end;

procedure SGLogParams(const Log : TSGLog; Params : TSGStringList);
var
	Str : TSGString = '';
begin
Str := SGStringFromStringList(Params, ' ');
if StringTrimAll(Str, ' ') <> '' then
	if Length(Str) < 106 then
		Log.Source('Executable params: ' + Str)
	else if Length(Str) < 150 then
		begin
		Log.Source('Executable params --> (' + SGStr(Length(Params)) + ')');
		Log.Source('  ' + Str);
		end
	else
		Log.Source(Params, 'Executable params');
SetLength(Params, 0);
end;

procedure SGFinalizeLog(); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if SGLogEnable then
	SGLog.Source('  << Destroy Log >>');
SGLog.Destroy();
SGLog := nil;
end;

initialization
begin
SGMakeDirectory(SGLogDirectory);
SGLogFileName := SGFreeLogFileName();
SGCreateLog(SGLog, SGLogFileName);
if (SGLog = nil) and (SGAplicationFileDirectory() <> '') then
	SGCreateLog(SGLog, SGAplicationFileDirectory() + SGLogFileName);
if SGLog = nil then
	begin
	SGLogEnable := False;
	SGLogFileName := '';
	SGCreateLog(SGLog, SGLogFileName);
	end;
if SGLogEnable then
	begin
	SGLog.Source('(***) SaGe Engine Log (***)', False);
	SGLog.Source('  << Create Log >>');
	SGLogParams(SGLog, SGSystemParamsToConcoleCallerParams());
	end;
end;

{$IFNDEF WITHLEAKSDETECTOR}
finalization
begin
SGFinalizeLog();
end;
{$ENDIF WITHLEAKSDETECTOR}

end.
