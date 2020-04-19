{$INCLUDE Smooth.inc}

unit SmoothLogStream;

interface

uses
	 SmoothBase
	,SmoothLists
	
	,Classes
	,SysUtils
	;
type
	TSLogEnablement = (
		SLogDisabled,
		SLogEnabled,
		SLogSmart);
const
	LogExtension = 'log';
var
	LogEnablement : TSLogEnablement = SLogSmart;
		//{$IFDEF RELEASE}SLogSmart{$ELSE}SLogEnabled{$ENDIF};
	LogSignificant : TSBoolean = False;
type
	TSLogStream = object
			public
		constructor Create(const LogFileName : TSString);
		destructor Destroy();
			private
		FStream : TStream;
		FFileName : TSString;
			public
		CriticalSection : TRTLCriticalSection;
			public
		property FileName        : TSString           read FFileName;
		property Stream          : TStream             read FStream;
		end;
	PSLogStream = ^ TSLogStream;

procedure SLogWrite(const StrintToWrite : TSString); overload;
procedure SLogWriteLn(const StrintToWrite : TSString = '');
procedure SLogWrite(const ArS : TSStringList; const Title : TSString; const SimbolsLength : TSUInt16 = 150); overload;

function SFreeLogFileName() : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SLogDirectory() : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothBaseUtils
	,SmoothDateTime
	,SmoothFileUtils
	,SmoothVersion
	,SmoothStreamUtils
	,SmoothStringUtils
	
	,StrMan
	;
var
	Log : PSLogStream = nil;

function SLogDirectory() : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := 
{$IF not defined(MOBILE)}
	SAplicationFileDirectory() + '.' + DirectorySeparator + '..' + DirectorySeparator + 'Log'
{$ELSE}
	{$IF defined(ANDROID)}
		DirectorySeparator + 'sdcard' + DirectorySeparator + '.Smooth'
	{$ELSE}
		''
	{$ENDIF}
{$ENDIF}
	;
end;

function SFreeLogFileName() : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SLogDirectory();
SMakeDirectory(Result);
Result += DirectorySeparator + SDateTimeString(True, False, True) + ' ' + SApplicationName + Iff(LogExtension <> '', '.' + LogExtension);
Result := SFreeFileName(Result, '');
end;

destructor TSLogStream.Destroy();
begin
DoneCriticalSection(CriticalSection);
SKill(FStream);
FillChar(Self, SizeOf(TSLogStream), 0);
end;

constructor TSLogStream.Create(const LogFileName : TSString);
begin
if (FStream <> nil) or (FFileName <> '') then
	exit;
FFileName := LogFileName;
if (LogEnablement <> SLogDisabled) then
	FStream := TFileStream.Create(FFileName, fmCreate)
else
	FStream := nil;
InitCriticalSection(CriticalSection);
end;

function SCreateLog(const FileName : TSString) : TSBoolean;
begin
if Log = nil then
	begin
	Log := GetMem(SizeOf(TSLogStream));
	FillChar(Log^, SizeOf(TSLogStream), 0);
	Log^.Create(FileName);
	end;
Result := Log <> nil;
end;

procedure SKillLog();
var
	FileName : TSString;
begin
if (Log <> nil) then
	begin
	FileName := Log^.FileName;
	Log^.Destroy();
	FreeMem(Log);
	Log := nil;
	
	if (LogEnablement = SLogSmart) and (not LogSignificant) then
		SDeleteFile(FileName);
	end;
end;

procedure SMakeLog();
begin
if Log <> nil then
	exit;
SMakeDirectory(SLogDirectory);
if not SCreateLog(SFreeLogFileName()) then
	if (SAplicationFileDirectory() <> '') then
		SCreateLog(SAplicationFileDirectory() + SFreeLogFileName());
if Log = nil then
	begin
	LogEnablement := SLogDisabled;
	SCreateLog('');
	end;
end;

procedure SLogWrite(const StrintToWrite : TSString); overload;
begin
if LogEnablement <> SLogDisabled then
	begin
	SMakeLog();
	EnterCriticalSection(Log^.CriticalSection);
	SWriteStringToStream(StrintToWrite, Log^.Stream, False);
	LeaveCriticalSection(Log^.CriticalSection);
	end;
end;

procedure SLogWriteLn(const StrintToWrite : TSString = '');
begin
if LogEnablement <> SLogDisabled then
	begin
	SMakeLog();
	EnterCriticalSection(Log^.CriticalSection);
	SWriteStringToStream(StrintToWrite + DefaultEndOfLine, Log^.Stream, False);
	LeaveCriticalSection(Log^.CriticalSection);
	end;
end;

procedure SLogWrite(const ArS : TSStringList; const Title : TSString; const SimbolsLength : TSUInt16 = 150); overload;
var
	i, WordCount, MaxLength, n, ii, TitleLength : TSMaxEnum;
	TempS : TSString;
begin
WordCount := 0;
if ArS <> nil then
	WordCount := Length(ArS);
if WordCount > 0 then
	begin
	if (WordCount = 1) and ((Length(Title + ' ->') + 1 + Length(SStringFromStringList(ArS, ' '))) < (SimbolsLength - 30)) then
		SLogWriteLn(Title + ' -> ' + SStringFromStringList(ArS, ' '))
	else if (Length(Title + ' (' + SStr(WordCount) + ') ->') + 1 + Length(SStringFromStringList(ArS, ' '))) < (SimbolsLength - 30) then
		SLogWriteLn(Title + ' (' + SStr(WordCount) + ') -> ' + SStringFromStringList(ArS, ' '))
	else
		begin
		SLogWriteLn(Title + ' (' + SStr(WordCount) + ') --->');
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
				SLogWriteLn(TempS);
				TempS := '  ';
				end;
			end;
		if TempS <> '  ' then
			SLogWriteLn(TempS);
		end;
	end;
end;

initialization
begin
SMakeLog();
end;

finalization
begin
SKillLog();
end;

end.
