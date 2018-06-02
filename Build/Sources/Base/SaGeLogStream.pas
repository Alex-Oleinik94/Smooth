{$INCLUDE SaGe.inc}

unit SaGeLogStream;

interface

uses
	 SaGeBase
	,SaGeLists
	
	,Classes
	,SysUtils
	;
type
	TSGLogEnablement = (
		SGLogDisabled,
		SGLogEnabled,
		SGLogSmart);
const
	LogExtension = 'log';
var
	LogEnablement : TSGLogEnablement = 
		{$IFDEF RELEASE}
			SGLogSmart
		{$ELSE}
			SGLogEnabled
		{$ENDIF};
	LogSignificant : TSGBoolean = False;
type
	TSGLogStream = object
			public
		constructor Create(const LogFileName : TSGString);
		destructor Destroy();
			private
		FStream : TStream;
		FFileName : TSGString;
			public
		CriticalSection : TRTLCriticalSection;
			public
		property FileName        : TSGString           read FFileName;
		property Stream          : TStream             read FStream;
		end;
	PSGLogStream = ^ TSGLogStream;

procedure SGLogWrite(const StrintToWrite : TSGString); overload;
procedure SGLogWriteLn(const StrintToWrite : TSGString = '');
procedure SGLogWrite(const ArS : TSGStringList; const Title : TSGString; const SimbolsLength : TSGUInt16 = 150); overload;

function SGFreeLogFileName() : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGLogDirectory() : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeBaseUtils
	,SaGeDateTime
	,SaGeFileUtils
	,SaGeVersion
	,SaGeStreamUtils
	,SaGeStringUtils
	
	,StrMan
	;
var
	Log : PSGLogStream = nil;

function SGLogDirectory() : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := 
{$IF not defined(MOBILE)}
	SGAplicationFileDirectory() + '.' + DirectorySeparator + '..' + DirectorySeparator + 'Log'
{$ELSE}
	{$IF defined(ANDROID)}
		DirectorySeparator +'sdcard' + DirectorySeparator +'.SaGe'
	{$ELSE}
		''
	{$ENDIF}
{$ENDIF}
	;
end;

function SGFreeLogFileName() : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGLogDirectory();
SGMakeDirectory(Result);
Result += DirectorySeparator + SGDateTimeString(True, False, True) + ' ' + SGApplicationName + Iff(LogExtension <> '', '.' + LogExtension);
Result := SGFreeFileName(Result, '');
end;

destructor TSGLogStream.Destroy();
begin
DoneCriticalSection(CriticalSection);
SGKill(FStream);
FillChar(Self, SizeOf(TSGLogStream), 0);
end;

constructor TSGLogStream.Create(const LogFileName : TSGString);
begin
if (FStream <> nil) or (FFileName <> '') then
	exit;
FFileName := LogFileName;
if (LogEnablement <> SGLogDisabled) then
	FStream := TFileStream.Create(FFileName, fmCreate)
else
	FStream := nil;
InitCriticalSection(CriticalSection);
end;

function SGCreateLog(const FileName : TSGString) : TSGBoolean;
begin
if Log = nil then
	begin
	Log := GetMem(SizeOf(TSGLogStream));
	FillChar(Log^, SizeOf(TSGLogStream), 0);
	Log^.Create(FileName);
	end;
Result := Log <> nil;
end;

procedure SGKillLog();
var
	FileName : TSGString;
begin
if (Log <> nil) then
	begin
	FileName := Log^.FileName;
	Log^.Destroy();
	FreeMem(Log);
	Log := nil;
	
	if (LogEnablement = SGLogSmart) and (not LogSignificant) then
		SGDeleteFile(FileName);
	end;
end;

procedure SGMakeLog();
begin
if Log <> nil then
	exit;
SGMakeDirectory(SGLogDirectory);
if not SGCreateLog(SGFreeLogFileName()) then
	if (SGAplicationFileDirectory() <> '') then
		SGCreateLog(SGAplicationFileDirectory() + SGFreeLogFileName());
if Log = nil then
	begin
	LogEnablement := SGLogDisabled;
	SGCreateLog('');
	end;
end;

procedure SGLogWrite(const StrintToWrite : TSGString);
begin
if LogEnablement <> SGLogDisabled then
	begin
	SGMakeLog();
	EnterCriticalSection(Log^.CriticalSection);
	SGWriteStringToStream(StrintToWrite, Log^.Stream, False);
	LeaveCriticalSection(Log^.CriticalSection);
	end;
end;

procedure SGLogWriteLn(const StrintToWrite : TSGString = '');
begin
if LogEnablement <> SGLogDisabled then
	begin
	SGMakeLog();
	EnterCriticalSection(Log^.CriticalSection);
	SGWriteStringToStream(StrintToWrite + SGWinEoln, Log^.Stream, False);
	LeaveCriticalSection(Log^.CriticalSection);
	end;
end;

procedure SGLogWrite(const ArS : TSGStringList; const Title : TSGString; const SimbolsLength : TSGUInt16 = 150); overload;
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
		SGLogWriteLn(Title + ' -> ' + SGStringFromStringList(ArS, ' '))
	else if (Length(Title + ' (' + SGStr(WordCount) + ') ->') + 1 + Length(SGStringFromStringList(ArS, ' '))) < (SimbolsLength - 30) then
		SGLogWriteLn(Title + ' (' + SGStr(WordCount) + ') -> ' + SGStringFromStringList(ArS, ' '))
	else
		begin
		SGLogWriteLn(Title + ' (' + SGStr(WordCount) + ') --->');
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
				SGLogWriteLn(TempS);
				TempS := '  ';
				end;
			end;
		if TempS <> '  ' then
			SGLogWriteLn(TempS);
		end;
	end;
end;

initialization
begin
SGMakeLog();
end;

finalization
begin
SGKillLog();
end;

end.
