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
const
	SGViewErrorFull  : TSGViewErrorType = [SGPrintError, SGLogError];
	SGViewErrorPrint : TSGViewErrorType = [SGPrintError];
	SGViewErrorLog   : TSGViewErrorType = [SGLogError];
	SGViewErrorNULL  : TSGViewErrorType = [];
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
			SGDataDirectory
		{$ENDIF}
	;
	SGLogFileName = SGLogDirectory + DirectorySeparator + 'EngineLog.log';
type
	TSGLog = class(TObject)
			public
		constructor Create();
		destructor Destroy();override;
		procedure Source(const s:string;const WithTime:Boolean = True);overload;
		procedure Source(const Ar : array of const;const WithTime:Boolean = True);overload;
		procedure Source(const S : TSGString; const Title : TSGString; const Separators : TSGString; const SimbolsLength : TSGUInt16 = 150);overload;
		procedure Source(const ArS : TSGStringList; const Title : TSGString; const SimbolsLength : TSGUInt16 = 150);overload;
			private
		FFileStream : TFileStream;
		end;
var
	//Экземпляр класса лога программы
	SGLog : TSGLog = nil;

procedure SGHint(const MessageStr : TSGString; const ViewCase : TSGViewErrorType = [SGPrintError, SGLogError]);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
procedure SGHint(const MessagePtrs : array of const; const ViewCase : TSGViewErrorType = [SGPrintError, SGLogError]);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
procedure SGAddToLog(const FileName, Line : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGLogDateTimePredString() : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeDateTime
	,SaGeStringUtils
	,SaGeBaseUtils
	
	,StrMan
	;

function SGLogDateTimePredString() : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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
	']' + ' -->'
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

procedure TSGLog.Source(const ArS : TSGStringList; const Title : TSGString; const SimbolsLength : TSGUInt16 = 150);overload;
var
	i, WordCount, MaxLength, n, ii: TSGLongWord;
	TempS : TSGString;
begin
WordCount := 0;
if ArS <> nil then
	WordCount := Length(ArS);
if WordCount > 0 then
	begin
	Source(Title + ' (' + SGStr(WordCount) + ')',True);
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

procedure TSGLog.Source(const S : TSGString; const Title : TSGString; const Separators : TSGString; const SimbolsLength : TSGUInt16 = 150);overload;
var
	ArS : TSGStringList = nil;
begin
ArS := SGStringListFromString(S, Separators);
Source(ArS, Title, SimbolsLength);
SetLength(ArS, 0);
end;

procedure TSGLog.Source(const s:string;const WithTime:Boolean = True);
var
	ss : TSGString;
	pc : PSGChar;
begin
if SGLogEnable and (FFileStream <> nil) then
	begin
	pc := SGStringToPChar(Iff(WithTime, SGLogDateTimePredString()) + s + SGWinEoln);
	FFileStream.WriteBuffer(PC^, SGPCharLength(PC));
	SGPCharFree(PC);
	end;
end;

constructor TSGLog.Create();
begin
inherited;
if SGLogEnable then
	FFileStream := TFileStream.Create(SGLogFileName, fmCreate);
end;

destructor TSGLog.Destroy;
begin
if SGLogEnable then
	FFileStream.Destroy;
inherited;
end;

initialization
begin
{$IFDEF ANDROID}
	SGMakeDirectory(SGLogDirectory);
	{$ENDIF}
try
	SGLog := TSGLog.Create();
	SGLog.Source('(***) SaGe Engine Log (***)', False);
	SGLog.Source('  << Create Log >>');
except
	SGLogEnable := False;
	SGLog := TSGLog.Create();
end;
end;

finalization
begin
if SGLogEnable then
	SGLog.Source('  << Destroy Log >>');
SGLog.Destroy();
SGLog := nil;
end;

end.